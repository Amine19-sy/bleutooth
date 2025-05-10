# api/register.py
from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
register_bp = Blueprint('register', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@register_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not all([username, email, password]):
        return jsonify({'error': 'Missing fields'}), 400

    # Vérifie si l'email existe déjà
    exists = supabase.table('User').select('*').eq('email', email).execute()
    if exists.data:
        return jsonify({'error': 'Email already exists'}), 400

    # 🔒 Hasher le mot de passe
    password_hash = generate_password_hash(password)

    result = supabase.table('User').insert({
        'username': username,
        'email': email,
        'password_hash': password_hash
    }).execute()

    if result.data:
        return jsonify(result.data[0]), 201
    
    return jsonify({'error': 'Registration failed'}), 500
