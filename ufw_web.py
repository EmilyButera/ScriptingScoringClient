from flask import Flask, jsonify, send_from_directory
import json
import os

app = Flask(__name__)
STATUS_FILE = "/var/www/html/ufw_status.json"

@app.route("/")
def homepage():
    return send_from_directory('.', 'index.html')

@app.route("/status")
def ufw_status():
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE) as f:
            data = json.load(f)
        return jsonify(data)
    else:
        return jsonify({"error": "Status file not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
