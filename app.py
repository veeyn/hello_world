from flask import Flask, jsonify

app = Flask (__name__)

@app.route("/")
def home():
    return '', 200

@app.route("/hello")
def hello():
    return jsonify({'message': 'Hello world'})

if __name__== '__main__':
    app.run(host='0.0.0.0', port=8888)