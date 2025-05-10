# api/login.py
from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
login_bp = Blueprint('login', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@login_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not all([username, password]):
        return jsonify({'error': 'Missing username or password'}), 400

    # Récupère l'utilisateur depuis la base
    result = supabase.table('User').select('*').eq('username', username).execute()

    if not result.data or len(result.data) == 0:
        return jsonify({'error': 'User not found'}), 404

    user = result.data[0]

    # Vérifie le mot de passe avec hash
    if not check_password_hash(user.get('password_hash', ''), password):
        return jsonify({'error': 'Incorrect password'}), 401

    # Supprimer le hash du retour (par sécurité)
    user.pop('password_hash', None)

    return jsonify(user), 200
