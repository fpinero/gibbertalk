from flask import Flask, render_template, jsonify, send_from_directory, request
import os
import json
import sys
import httpx
from flask_cors import CORS  # Importar Flask-CORS

app = Flask(__name__)

# Configurar CORS para permitir solicitudes desde los dominios especificados
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://gibbersound.com", "https://www.gibbersound.com", "https://stats.gibbersound.com", 
                   "http://localhost:5001", "http://localhost:5000", "*"],
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Origin", "Accept"]
    }
})

# Configuración de la API de DeepSeek
DEEPSEEK_API_KEY = os.environ.get('DEEPSEEK_API_KEY')
if not DEEPSEEK_API_KEY:
    print("Error: La variable de entorno DEEPSEEK_API_KEY no está configurada.")
    print("Por favor, configúrela con: export DEEPSEEK_API_KEY='tu-api-key'")
    # En producción, podrías querer que la aplicación continúe funcionando sin la API
    # En desarrollo, es mejor fallar rápido para detectar problemas
    if not os.environ.get('FLASK_ENV') == 'production':
        sys.exit(1)

DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions"

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/health')
def health_check():
    return jsonify({"status": "healthy"})

@app.route('/api/chat', methods=['POST'])
def chat():
    try:
        # Registrar información de la solicitud para depuración
        print(f"Solicitud recibida desde: {request.headers.get('Origin', 'Origen desconocido')}")
        print(f"Método: {request.method}")
        print(f"Encabezados: {dict(request.headers)}")
        
        data = request.json
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({"error": "No message provided"}), 400
        
        # Verificar que tenemos la API key
        if not DEEPSEEK_API_KEY:
            return jsonify({"error": "DeepSeek API key not configured"}), 500
        
        try:
            print(f"Enviando mensaje a DeepSeek: {user_message}")
            
            # Preparar los datos para la solicitud
            payload = {
                "model": "deepseek-chat",
                "messages": [
                    {"role": "system", "content": "Eres un asistente útil y amigable. Proporciona siempre respuestas breves y concisas, limitándote a la información esencial. Evita explicaciones largas o detalles innecesarios."},
                    {"role": "user", "content": user_message}
                ],
                "temperature": 0.7,
                "max_tokens": 250
            }
            
            # Configurar los encabezados
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {DEEPSEEK_API_KEY}"
            }
            
            # Hacer la solicitud a la API de DeepSeek
            with httpx.Client(timeout=30.0) as client:
                print("Enviando solicitud a la API de DeepSeek...")
                response = client.post(
                    DEEPSEEK_API_URL,
                    json=payload,
                    headers=headers
                )
                
                # Verificar si la solicitud fue exitosa
                response.raise_for_status()
                print(f"Respuesta de DeepSeek recibida con código: {response.status_code}")
                
                # Parsear la respuesta
                response_data = response.json()
                
                # Extraer la respuesta
                ai_response = response_data["choices"][0]["message"]["content"]
                print(f"Respuesta recibida de DeepSeek: {ai_response[:100]}...")  # Mostrar los primeros 100 caracteres
                
                # Preparar la respuesta con encabezados CORS explícitos
                resp = jsonify({"response": ai_response})
                return resp
            
        except httpx.HTTPStatusError as e:
            print(f"Error HTTP en la llamada a la API de DeepSeek: {e}")
            print(f"Respuesta: {e.response.text}")
            return jsonify({"error": f"Error calling DeepSeek API: {str(e)}"}), 500
        except httpx.RequestError as e:
            print(f"Error de conexión a la API de DeepSeek: {e}")
            return jsonify({"error": f"Connection error to DeepSeek API: {str(e)}"}), 500
        except Exception as e:
            print(f"Error en la llamada a la API de DeepSeek: {e}")
            print(f"Tipo de error: {type(e)}")
            import traceback
            traceback.print_exc()
            return jsonify({"error": f"Error calling DeepSeek API: {str(e)}"}), 500
    
    except Exception as e:
        print(f"Error general en /api/chat: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

# Ruta explícita para servir archivos estáticos si es necesario
@app.route('/static/<path:filename>')
def serve_static(filename):
    response = send_from_directory('static', filename)
    return response

# Ruta para servir el site.webmanifest
@app.route('/site.webmanifest')
def serve_manifest():
    response = send_from_directory('static/favicon', 'site.webmanifest')
    return response

# Añadir encabezados CORS a todas las respuestas
@app.after_request
def add_cors_headers(response):
    # Permitir solicitudes desde los dominios especificados
    allowed_origins = ["https://gibbersound.com", "https://www.gibbersound.com", "http://localhost:5001", 
                      "http://localhost:5000", "*"]
    origin = request.headers.get('Origin')
    
    if origin in allowed_origins or '*' in allowed_origins:
        if origin:
            response.headers.add('Access-Control-Allow-Origin', origin)
        else:
            response.headers.add('Access-Control-Allow-Origin', '*')
    
    # Permitir credenciales
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    
    # Permitir métodos
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    
    # Permitir encabezados
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization, Origin, Accept')
    
    # Permitir que el navegador almacene en caché los resultados de la verificación previa
    response.headers.add('Access-Control-Max-Age', '3600')
    
    return response

# Manejar solicitudes OPTIONS para preflight CORS
@app.route('/api/chat', methods=['OPTIONS'])
def handle_options():
    response = jsonify({'status': 'ok'})
    return response

if __name__ == '__main__':
    # Usar puerto 5001 para evitar conflictos con el Centro de Control de macOS
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=True) 