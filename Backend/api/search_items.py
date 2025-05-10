# api/search_items.py
from flask import Blueprint, request, jsonify
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
search_items_bp = Blueprint('search_items', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@search_items_bp.route('/api/search_items', methods=['GET'])
def search_items():
    name = request.args.get('name')
    box_id = request.args.get('box_id')

    query = supabase.table('Item').select('*').ilike('name', f'%{name}%')
    if box_id:
        query = query.eq('box_id', box_id)

    result = query.execute()
    return jsonify(result.data), 200
