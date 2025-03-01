from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

# Esta ruta solo sería necesaria si decides procesar en el backend
@app.route('/api/translate', methods=['POST'])
def translate_to_gibberlink():
    text = request.json.get('text', '')
    # En este caso, solo devolvemos el texto para que el frontend lo procese
    return jsonify({'text': text})

if __name__ == '__main__':
    app.run(debug=True) 