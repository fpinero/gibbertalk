from flask import Flask, render_template, jsonify, send_from_directory
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/health')
def health_check():
    return jsonify({"status": "healthy"})

# Ruta explícita para servir archivos estáticos si es necesario
@app.route('/static/<path:filename>')
def serve_static(filename):
    return send_from_directory('static', filename)

# Ruta para servir el site.webmanifest
@app.route('/site.webmanifest')
def serve_manifest():
    return send_from_directory('static/favicon', 'site.webmanifest')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 