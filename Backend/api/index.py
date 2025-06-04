# api/index.py
from flask import Flask, jsonify
from register import register_bp
from login import login_bp
from item import item_bp
from history import history_bp
from commands import commands_bp
from box import box_bp
from search import search_bp

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({"message": "It works"}), 200

@app.errorhandler(Exception)
def handle_exception(e):
    import traceback
    return jsonify({
        "error": str(e),
        "trace": traceback.format_exc()
    }), 500

# Enregistrement des blueprints
app.register_blueprint(register_bp)
app.register_blueprint(login_bp)
app.register_blueprint(item_bp)
app.register_blueprint(history_bp)
app.register_blueprint(commands_bp)
app.register_blueprint(box_bp)
app.register_blueprint(search_bp)



if __name__ == "__main__":
    app.run(host='0.0.0.0',port=5000,debug=True)