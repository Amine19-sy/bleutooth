# api/box.py
from flask import Blueprint, request, jsonify
from supabase import create_client
from dotenv import load_dotenv
import os

load_dotenv()
box_bp = Blueprint('box', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

# ✅ Add Box
@box_bp.route('/api/add_box', methods=['POST'])
def add_box():
    data = request.get_json()
    user_id = data.get("user_id")
    name = data.get("name")
    description = data.get("description", "")

    if not user_id or not name:
        return jsonify({"error": "Missing 'user_id' or 'name'"}), 400

    try:
        result = supabase.table("Box").insert({
            "user_id": int(user_id),
            "name": name,
            "description": description,
            "is_open": False
        }).execute()
        if result.data:
            return jsonify(result.data[0]), 201
        else:
            return jsonify({"error": "Failed to insert box"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Fetch User Boxes
@box_bp.route('/api/boxes', methods=['GET'])
def fetch_user_boxes():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400
    try:
        result = supabase.table("Box").select("*").eq("user_id", user_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Request Box Access
@box_bp.route('/api/box/request_access', methods=['POST'])
def request_box_access():
    data = request.get_json()
    box_id = data.get("box_id")
    invitee_email = data.get("invitee_email")
    requested_by = data.get("requested_by")

    if not box_id or not invitee_email or not requested_by:
        return jsonify({"error": "Missing fields"}), 400

    try:
        user_resp = supabase.table("User").select("id").eq("email", invitee_email).single().execute()
        if not user_resp.data:
            return jsonify({"error": "Invitee not found"}), 404

        access_result = supabase.table("BoxAccessRequest").insert({
            "box_id": box_id,
            "user_id": user_resp.data["id"],
            "requested_by": requested_by,
            "status": "pending"
        }).execute()

        if access_result.data:
            return jsonify(access_result.data[0]), 201
        else:
            return jsonify({"error": "Insert failed"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Fetch Sent Requests
@box_bp.route('/api/box/requests_sent', methods=['GET'])
def fetch_requests_sent():
    owner_id = request.args.get("owner_id")
    try:
        result = supabase.table("BoxAccessRequest").select("*").eq("requested_by", owner_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Fetch Received Requests
@box_bp.route('/api/box/requests_received', methods=['GET'])
def fetch_requests_received():
    user_id = request.args.get("user_id")
    try:
        result = supabase.table("BoxAccessRequest").select("*").eq("user_id", user_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Respond to Request
@box_bp.route('/api/box/respond_request', methods=['POST'])
def respond_request():
    data = request.get_json()
    request_id = data.get("request_id")
    accept = data.get("accept")
    user_id = data.get("user_id")

    try:
        new_status = "accepted" if accept else "declined"
        update_result = supabase.table("BoxAccessRequest").update({
            "status": new_status,
            "responded_at": "now()"
        }).eq("id", request_id).execute()
        return jsonify(update_result.data[0]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Fetch Shared Boxes
@box_bp.route('/api/shared_boxes', methods=['GET'])
def shared_boxes():
    user_id = request.args.get("user_id")
    try:
        # Get accepted requests for the user
        requests = supabase.table("BoxAccessRequest") \
            .select("box_id") \
            .eq("user_id", user_id) \
            .eq("status", "accepted") \
            .execute()

        box_ids = [req["box_id"] for req in requests.data]
        if not box_ids:
            return jsonify([]), 200

        result = supabase.table("Box").select("*").in_("id", box_ids).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Fetch Collaborators for a box
@box_bp.route('/api/box/collaborators', methods=['GET'])
def fetch_collaborators():
    box_id = request.args.get("box_id")
    try:
        reqs = supabase.table("BoxAccessRequest") \
            .select("user_id") \
            .eq("box_id", box_id) \
            .eq("status", "accepted") \
            .execute()

        user_ids = [r["user_id"] for r in reqs.data]
        if not user_ids:
            return jsonify([]), 200

        users = supabase.table("User").select("id,username,email").in_("id", user_ids).execute()
        return jsonify(users.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
