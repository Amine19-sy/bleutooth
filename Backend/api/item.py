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

    # 1. Encode image if present
    encoded_image = None
    if image:
        try:
            image_bytes = image.read()
            encoded_image = base64.b64encode(image_bytes).decode('utf-8')
        except Exception as e:
            return jsonify({'error': f'Error encoding image: {str(e)}'}), 500

    try:
        # 2. Verify that the user exists
        user_check = supabase.table("User").select("id").eq("id", int(user_id)).execute()
        if not user_check.data:
            return jsonify({'error': f"User ID {user_id} not found."}), 400

        # 3. Insert new item into Item table
        insert_resp = supabase.table('Item').insert({
            'box_id': int(box_id),
            'name': name,
            'user_id': int(user_id),
            'image_data': encoded_image  # base64 string or None
        }).execute()

        # 4. If insert succeeded, grab the new item’s ID
        if insert_resp.data and len(insert_resp.data) > 0:
            new_item = insert_resp.data[0]
            new_item_id = new_item.get('id')

            # 5. Insert a row into History to record the “add” action
            history_resp = supabase.table('History').insert({
                'user_id': int(user_id),
                'box_id': int(box_id),
                'item_id': int(new_item_id),
                'action_type': 'Item Added',
                'details': f"Added item '{name}' to box {box_id}"
                # action_time will default to CURRENT_TIMESTAMP
            }).execute()

            # 6. Return the newly created item back to client
            return jsonify(new_item), 201

        else:
            return jsonify({'error': 'Item insert failed.'}), 500

    except Exception as e:
        return jsonify({'error': str(e)}), 500
# def add_item():
#     box_id = request.form.get('box_id')
#     name = request.form.get('name')
#     user_id = request.form.get('user_id')
#     image = request.files.get('image')

#     encoded_image = None
#     if image:
#         try:
#             image_bytes = image.read()
#             encoded_image = base64.b64encode(image_bytes).decode('utf-8')
#         except Exception as e:
#             return jsonify({'error': f'Error encoding image: {str(e)}'}), 500

#     try:
#         # ✅ Check if user exists
#         user_check = supabase.table("User").select("id").eq("id", int(user_id)).execute()
#         if not user_check.data:
#             return jsonify({'error': f"User ID {user_id} not found."}), 400

#         # ✅ Insert item
#         result = supabase.table('Item').insert({
#             'box_id': int(box_id),
#             'name': name,
#             'user_id': int(user_id),
#             'image_data': encoded_image  # base64 string or None
#         }).execute()

#         if result.data:
#             return jsonify(result.data[0]), 201
#         else:
#             return jsonify({'error': 'Insert failed'}), 500
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500


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
    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    try:
        # 1) Fetch the item (so we know box_id, name)
        fetch_resp = supabase.table('Item') \
                             .select('id, box_id, name') \
                             .eq('id', item_id) \
                             .eq('user_id', int(user_id)) \
                             .execute()

        if not fetch_resp.data:
            return jsonify({'error': f"Item {item_id} not found for user {user_id}"}), 404

        existing_item = fetch_resp.data[0]
        box_id = existing_item['box_id']
        item_name = existing_item['name']

        # 2) Update the History row: set item_id = NULL, action_type = 'Item Removed'
        supabase.table('History').update({
            'item_id': None,
            'action_type': 'Item Removed',
            'details': f"Deleted item '{item_name}'  from box {box_id}"
        }) \
        .eq('item_id', item_id) \
        .eq('action_type', 'Item Added') \
        .execute()

        # 3) Now that no history row references item_id=13, delete the item
        supabase.table('Item') \
                .delete() \
                .eq('id', item_id) \
                .eq('user_id', int(user_id)) \
                .execute()

        return jsonify({"message": "Item deleted, history updated (item_id set to NULL)."}), 200

    except Exception as e:
        import traceback; traceback.print_exc()
        return jsonify({'error': 'Server error', 'details': str(e)}), 500




# @item_bp.route('/api/remove_item/<int:item_id>', methods=['DELETE'])
# def remove_item(item_id):
#     user_id = request.args.get('user_id')
#     if not user_id:
#         return jsonify({'error': 'Missing user_id in query parameters.'}), 400

#     try:
#         # 1. Fetch the existing item row so we know its box_id (and maybe name)
#         fetch_resp = supabase.table('Item') \
#                              .select('id, box_id, name') \
#                              .eq('id', int(item_id)) \
#                              .eq('user_id', int(user_id)) \
#                              .execute()
#         print("fetch_resp:", fetch_resp.data, fetch_resp.error)


#         if not fetch_resp.data or len(fetch_resp.data) == 0:
#             return jsonify({'error': f"Item ID {item_id} not found for user {user_id}."}), 404

#         existing_item = fetch_resp.data[0]
#         box_id = existing_item.get('box_id')
#         item_name = existing_item.get('name')

#         # 2. Delete the item from Item table
#         del_resp = supabase.table("Item") \
#                            .delete() \
#                            .eq("id", int(item_id)) \
#                            .eq("user_id", int(user_id)) \
#                            .execute()
        
#         # 3. Insert a row into History to record the “delete” action
#         #    Even if supabase returns an empty .data for delete, we assume success if no exception thrown
#         history_resp = supabase.table('History').insert({
#             'user_id': int(user_id),
#             'box_id': box_id,               # using the box_id we fetched earlier
#             'item_id': int(item_id),
#             'action_type': 'Item Removed',
#             'details': f"Deleted item '{item_name}' (id={item_id}) from box {box_id}"
#         }).execute()

#         return jsonify({"message": "Item deleted successfully."}), 200

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500
# def remove_item(item_id):
#     user_id = request.args.get('user_id')

#     try:
#         result = supabase.table("Item").delete().eq("id", item_id).eq("user_id", user_id).execute()
#         return jsonify({"message": "Item deleted successfully."}), 200
#     except Exception as e:
#         return jsonify({'error': str(e)}), 500


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
