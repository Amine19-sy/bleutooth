from flask import Blueprint, request, jsonify
from supabase import create_client
import os
import base64
from dotenv import load_dotenv

load_dotenv()
item_bp = Blueprint('item', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

# ✅ Add Item (base64-encoded image_data)
@item_bp.route('/api/add_item', methods=['POST'])
def add_item():
    box_id = request.form.get('box_id')
    name = request.form.get('name')
    user_id = request.form.get('user_id')
    image = request.files.get('image')

    encoded_image = None
    if image:
        try:
            image_bytes = image.read()
            encoded_image = base64.b64encode(image_bytes).decode('utf-8')
        except Exception as e:
            return jsonify({'error': f'Error encoding image: {str(e)}'}), 500

    try:
        # ✅ Check if user exists
        user_check = supabase.table("User").select("id").eq("id", int(user_id)).execute()
        if not user_check.data:
            return jsonify({'error': f"User ID {user_id} not found."}), 400

        # ✅ Insert item
        result = supabase.table('Item').insert({
            'box_id': int(box_id),
            'name': name,
            'user_id': int(user_id),
            'image_data': encoded_image  # base64 string or None
        }).execute()

        if result.data:
            return jsonify(result.data[0]), 201
        else:
            return jsonify({'error': 'Insert failed'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ✅ Get Items by box
@item_bp.route('/api/items', methods=['GET'])
def get_items():
    box_id = request.args.get('box_id')
    if not box_id:
        return jsonify({'error': 'Missing box_id'}), 400

    try:
        result = supabase.table('Item').select("*").eq("box_id", box_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ✅ Delete Item
@item_bp.route('/api/remove_item/<int:item_id>', methods=['DELETE'])
def remove_item(item_id):
    user_id = request.args.get('user_id')

    try:
        result = supabase.table("Item").delete().eq("id", item_id).eq("user_id", user_id).execute()
        return jsonify({"message": "Item deleted successfully."}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ✅ Search Items
@item_bp.route('/api/search_items', methods=['GET'])
def search_items():
    name = request.args.get('name')
    box_id = request.args.get('box_id')

    try:
        query = supabase.table('Item').select("*").ilike("name", f"%{name}%")
        if box_id:
            query = query.eq("box_id", box_id)
        result = query.execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
