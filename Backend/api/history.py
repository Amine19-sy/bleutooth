# api/history.py
from flask import Blueprint, jsonify
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
history_bp = Blueprint('history', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@history_bp.route('/api/history/<int:box_id>', methods=['GET'])
def get_history(box_id):
    # print("hola")
    result = supabase.table('History').select('*').eq('box_id', str(box_id)).order('action_time', desc=True).execute()
    # print("tessst")
    # print(result)
    return jsonify(result.data), 200
