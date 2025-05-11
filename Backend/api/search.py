# bleutooth/Backend/api/search.py

from flask import Blueprint, request, jsonify
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
search_bp = Blueprint("search", __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@search_bp.route('/api/boxes_items_grouped', methods=['GET'])
def boxes_items_grouped():
    user_id = request.args.get('user_id')
    try:
        # 1. Get all boxes for this user
        boxes_resp = supabase.table("Box").select("id, name").eq("user_id", user_id).execute()
        boxes = boxes_resp.data

        grouped = []
        for box in boxes:
            # 2. For each box, fetch its items
            items_resp = supabase.table("Item").select("*").eq("box_id", box["id"]).execute()
            grouped.append({
                "box_id": box["id"],
                "box_name": box["name"],
                "items": items_resp.data
            })

        return jsonify(grouped), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
