# api/commands.py
from flask import Blueprint, request, jsonify
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
commands_bp = Blueprint('commands', __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

@commands_bp.route('/api/send_command', methods=['POST'])
def send_command():
    try:
        data = request.get_json()
        command = data.get("command")
        box_id = data.get("box_id")

        if not command or not box_id:
            return jsonify({"error": "Missing 'command' or 'box_id'"}), 400

        result = supabase.table("commands").insert({
            "command": command,
            "box_id": box_id
        }).execute()

        if result.status_code == 201:
            return jsonify({"message": f"Command '{command}' sent to box {box_id}"}), 201
        else:
            return jsonify({"error": "Failed to insert command"}), 500

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@commands_bp.route('/api/last_temperature', methods=['GET'])
def get_last_temperature():
    box_id = request.args.get("box_id")

    if not box_id:
        return jsonify({"error": "Missing box_id"}), 400

    try:
        response = supabase.table("temperature") \
            .select("*") \
            .eq("box_id", int(box_id)) \
            .order("temperature_time", desc=True) \
            .limit(1) \
            .execute()

        if response.data:
            return jsonify(response.data[0]), 200
        else:
            return jsonify({"error": "No temperature data found"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500
