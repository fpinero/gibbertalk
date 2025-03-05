import os
from openai import OpenAI

# Configuración de la API de DeepSeek
DEEPSEEK_API_KEY = os.environ.get('DEEPSEEK_API_KEY', 'tu-api-key-aqui')
DEEPSEEK_API_URL = "https://api.deepseek.com"

print(f"Usando API key: {DEEPSEEK_API_KEY[:5]}...")
print(f"Usando API URL: {DEEPSEEK_API_URL}")

# Eliminar temporalmente la variable de entorno OPENAI_API_KEY para evitar conflictos
original_openai_api_key = os.environ.get('OPENAI_API_KEY')
if 'OPENAI_API_KEY' in os.environ:
    print(f"Eliminando temporalmente OPENAI_API_KEY: {original_openai_api_key[:5]}...")
    del os.environ['OPENAI_API_KEY']

try:
    # Inicializar el cliente con la configuración mínima necesaria
    print("Inicializando cliente OpenAI...")
    client = OpenAI(
        api_key=DEEPSEEK_API_KEY,
        base_url=DEEPSEEK_API_URL
    )
    print("Cliente OpenAI inicializado correctamente")
    
    # Probar una llamada simple
    print("Enviando mensaje a DeepSeek...")
    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": "Eres un asistente útil y amigable."},
            {"role": "user", "content": "Hola, ¿cómo estás?"}
        ],
        temperature=0.7,
        max_tokens=50
    )
    
    # Extraer la respuesta
    ai_response = response.choices[0].message.content
    print(f"Respuesta recibida de DeepSeek: {ai_response}")
    
except Exception as e:
    print(f"Error: {e}")
    print(f"Tipo de error: {type(e)}")
    import traceback
    traceback.print_exc()

# Restaurar la variable de entorno original si existía
if original_openai_api_key:
    print(f"Restaurando OPENAI_API_KEY...")
    os.environ['OPENAI_API_KEY'] = original_openai_api_key 