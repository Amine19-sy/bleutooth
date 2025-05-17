# api/box.py
from flask import Blueprint, request, jsonify
from supabase import create_client
from dotenv import load_dotenv
import os

load_dotenv()
box_bp = Blueprint('box', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

# 🔁 Claim and Link a Box
@box_bp.route('/api/claim_box', methods=['POST'])
def claim_box():
    data = request.get_json()
    original_name = data.get("original_name")
    user_id = data.get("user_id")
    user_box_name = data.get("user_box_name")
    description = data.get("description", "")

    if not original_name or not user_id or not user_box_name:
        return jsonify({"error": "Missing original_name, user_id or user_box_name"}), 400

    try:
        # Rechercher une box disponible (user_id == null)
        result = supabase.table("Box") \
            .select("*") \
            .eq("original_name", original_name.lower()) \
            .is_("user_id", "null") \
            .limit(1) \
            .execute()

        if not result.data or len(result.data) == 0:
            return jsonify({"error": "Box not available or already claimed"}), 404

        box_id = result.data[0]["id"]

        # Mise à jour de la box
        update = supabase.table("Box").update({
            "user_id": user_id,
            "name": user_box_name,
            "description": description
        }).eq("id", box_id).execute()

        return jsonify(update.data[0]), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ✅ Get all boxes linked to a user
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


# ✅ Request access to a box (shared use)
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

        return jsonify(access_result.data[0]), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ✅ View requests sent
@box_bp.route('/api/box/requests_sent', methods=['GET'])
def fetch_requests_sent():
    owner_id = request.args.get("owner_id")
    try:
        result = supabase.table("BoxAccessRequest").select("*").eq("requested_by", owner_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ✅ View requests received
@box_bp.route('/api/box/requests_received', methods=['GET'])
def fetch_requests_received():
    user_id = request.args.get("user_id")
    try:
        result = supabase.table("BoxAccessRequest").select("*").eq("user_id", user_id).execute()
        return jsonify(result.data), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ✅ Accept / Decline request
@box_bp.route('/api/box/respond_request', methods=['POST'])
def respond_request():
    data = request.get_json()
    request_id = data.get("request_id")
    accept = data.get("accept")

    try:
        new_status = "accepted" if accept else "declined"
        update_result = supabase.table("BoxAccessRequest").update({
            "status": new_status,
            "responded_at": "now()"
        }).eq("id", request_id).execute()

        return jsonify(update_result.data[0]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ✅ List boxes shared with a user
@box_bp.route('/api/shared_boxes', methods=['GET'])
def shared_boxes():
    user_id = request.args.get("user_id")
    try:
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


# ✅ List collaborators of a box
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
