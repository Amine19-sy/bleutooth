# bleutooth/Backend/api/search.py

from flask import Blueprint, request, jsonify
from supabase import create_client
import os
from dotenv import load_dotenv
from datetime import datetime, timezone

load_dotenv()
search_bp = Blueprint("search", __name__)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))


@search_bp.route('/api/boxes_items_grouped', methods=['GET'])
def boxes_items_grouped():
    # 1) Read and validate user_id
    user_id = request.args.get('user_id', type=int)
    if user_id is None:
        return jsonify({'error': 'Missing or invalid user_id parameter'}), 400

    # 2) Parse optional date_from / date_to filters (ISO 8601 strings)
    date_from_str = request.args.get('date_from')  # e.g. "2025-05-01T00:00:00"
    date_to_str   = request.args.get('date_to')    # e.g. "2025-05-31T23:59:59"

    try:
        # Build ISO‐formatted UTC strings for the filters
        date_from_iso = None
        if date_from_str:
            dtf = datetime.fromisoformat(date_from_str)
            date_from_iso = dtf.astimezone(timezone.utc).isoformat()

        if date_to_str:
            dtt = datetime.fromisoformat(date_to_str)
            date_to_iso = dtt.astimezone(timezone.utc).isoformat()
        else:
            # if no date_to given, use “now” as upper bound
            now_utc = datetime.utcnow().replace(tzinfo=timezone.utc)
            date_to_iso = now_utc.isoformat()

        # 3) Fetch all boxes owned by this user
        boxes_resp = supabase.table("Box") \
                              .select("id, name") \
                              .eq("user_id", user_id) \
                              .execute()

        # If supabase returns None (unlikely), treat as empty list
        boxes = boxes_resp.data or []

        grouped = []
        # 4) For each box, query its items applying only the date filters
        for box in boxes:
            box_id   = box["id"]
            box_name = box["name"]

            # Build the base query
            query = supabase.table("Item") \
                            .select("id, box_id, name, added_at",'user_id') \
                            .eq("box_id", box_id)

            # Apply date_from, if provided
            if date_from_iso:
                query = query.gte("added_at", date_from_iso)

            # Always apply date_to (either user‐provided or “now”)
            query = query.lte("added_at", date_to_iso)

            items_filtered_resp = query.execute()
            items = items_filtered_resp.data or []

            # If no items match for this box, skip it
            if not items:
                continue

            grouped.append({
                "box_id":   box_id,
                "box_name": box_name,
                "items":    items
            })

        return jsonify(grouped), 200

    except Exception as e:
        # Print to your console for debugging
        print("[ERROR] boxes_items_grouped:", str(e))
        return jsonify({"error": str(e)}), 500

# @search_bp.route('/api/boxes_items_grouped', methods=['GET'])
# def boxes_items_grouped():
#     # 1) Convert user_id to int (or return 400)
#     user_id = request.args.get('user_id', type=int)
#     if user_id is None:
#         return jsonify({'error': 'Missing or invalid user_id parameter'}), 400

#     # parse optional filters
#     date_from_str = request.args.get('date_from')    # ISO format string
#     date_to_str   = request.args.get('date_to')      # ISO format string
#     added_by      = request.args.get('added_by', type=int)

#     try:
#         # 2) Build ISO‐formatted UTC strings for date filters
#         date_from_iso = None
#         if date_from_str:
#             dtf = datetime.fromisoformat(date_from_str)
#             date_from_iso = dtf.replace(tzinfo=timezone.utc).isoformat()

#         if date_to_str:
#             dt = datetime.fromisoformat(date_to_str)
#             date_to_iso = dt.replace(tzinfo=timezone.utc).isoformat()
#         else:
#             now_utc     = datetime.utcnow().replace(tzinfo=timezone.utc)
#             date_to_iso = now_utc.isoformat()

#         # 3) Fetch all boxes owned by this user
#         boxes_resp = supabase.table("Box") \
#                               .select("id, name") \
#                               .eq("user_id", user_id) \
#                               .execute()
#         if boxes_resp.error:
#             raise Exception(boxes_resp.error.message)

#         boxes = boxes_resp.data  # list of {"id":…, "name":…}

#         # 4) Build a temporary list (groupedd) of all boxes + their items (no filters yet)
#         groupedd = []
#         for box in boxes:
#             items_resp = supabase.table("Item") \
#                                  .select("*") \
#                                  .eq("box_id", box["id"]) \
#                                  .execute()
#             if items_resp.error:
#                 raise Exception(items_resp.error.message)

#             groupedd.append({
#                 "box_id":   box["id"],
#                 "box_name": box["name"],
#                 # we'll re‐filter items below, so just store the raw list for now
#                 "items":    items_resp.data
#             })

#         # 5) If added_by is specified: fetch all item_ids added by that user
#         added_by_item_ids = None
#         if added_by is not None:
#             hist_resp = supabase.table("History") \
#                                 .select("item_id") \
#                                 .eq("user_id", added_by) \
#                                 .eq("action_type", "Item Added") \
#                                 .execute()
#             if hist_resp.error:
#                 raise Exception(hist_resp.error.message)

#             added_by_item_ids = {h["item_id"] for h in hist_resp.data}

#         # 6) Now iterate over each entry in groupedd, apply date + added_by filters
#         grouped = []
#         for entry in groupedd:
#             box_id   = entry["box_id"]
#             box_name = entry["box_name"]

#             # Build a new query for this box, applying date filters
#             query = supabase.table("Item") \
#                              .select("id, box_id, name, added_at, /* …any other fields… */") \
#                              .eq("box_id", box_id)

#             if date_from_iso:
#                 query = query.gte("added_at", date_from_iso)
#             if date_to_iso:
#                 query = query.lte("added_at", date_to_iso)

#             # If added_by filter is present
#             if added_by is not None:
#                 # If no items ever added by that user, skip this box entirely
#                 if not added_by_item_ids:
#                     continue
#                 # Otherwise, only keep items whose id is in added_by_item_ids
#                 query = query.in_("id", list(added_by_item_ids))

#             items_filtered_resp = query.execute()
#             if items_filtered_resp.error:
#                 raise Exception(items_filtered_resp.error.message)

#             if not items_filtered_resp.data:
#                 # No items match for this box → skip
#                 continue

#             grouped.append({
#                 "box_id":   box_id,
#                 "box_name": box_name,
#                 "items":    items_filtered_resp.data
#             })

#         return jsonify(grouped), 200

#     except Exception as e:
#         print(str(e))
#         return jsonify({"error": str(e)}), 500





































# @search_bp.route('/api/boxes_items_grouped', methods=['GET'])
# def boxes_items_grouped():
#     user_id = request.args.get('user_id')

#     # parse optional filters
#     date_from_str = request.args.get('date_from')    # expected ISO format, e.g. "2025-06-01T00:00:00"
#     date_to_str   = request.args.get('date_to')      # same
#     added_by      = request.args.get('added_by', type=int)

# #     try:
# #         # Convert date filters to ISO strings (Supabase expects ISO‐formatted timestamps)
# #         date_from_iso = None
# #         if date_from_str:
# #             dtf = datetime.fromisoformat(date_from_str)
# #             date_from_iso = dtf.replace(tzinfo=timezone.utc).isoformat()

# #         if date_to_str:
# #             dt = datetime.fromisoformat(date_to_str)
# #             date_to_iso = dt.replace(tzinfo=timezone.utc).isoformat()
# #         else:
# #             # If date_to not provided, default to “now” in UTC
# #             now_utc     = datetime.utcnow().replace(tzinfo=timezone.utc)
# #             date_to_iso = now_utc.isoformat()

#     try:


#         date_from_iso = None
#         if date_from_str:
#             dtf = datetime.fromisoformat(date_from_str)
#             date_from_iso = dtf.replace(tzinfo=timezone.utc).isoformat()

#         if date_to_str:
#             dt = datetime.fromisoformat(date_to_str)
#             date_to_iso = dt.replace(tzinfo=timezone.utc).isoformat()
#         else:
#             # If date_to not provided, default to “now” in UTC
#             now_utc     = datetime.utcnow().replace(tzinfo=timezone.utc)
#             date_to_iso = now_utc.isoformat()

#         # 1. Get all boxes for this user
#         boxes_resp = supabase.table("Box").select("id, name").eq("user_id", user_id).execute()
#         boxes = boxes_resp.data

#         groupedd = []
#         for box in boxes:
#             # 2. For each box, fetch its items
#             items_resp = supabase.table("Item").select("*").eq("box_id", box["id"]).execute()
#             groupedd.append({
#                 "box_id": box["id"],
#                 "box_name": box["name"],
#                 "items": items_resp.data
#             })
        
#         grouped = []
#         for box_id, box_data in groupedd.items():
#             # Build a base Item query
#             query = supabase.table("Item").select("id, box_id, name, added_at") \
#                                             .eq("box_id", box_id)
#             if date_from_iso:
#                 query = query.gte("added_at", date_from_iso)
#             if date_to_iso:
#                 query = query.lte("added_at", date_to_iso)

#             # # If added_by is specified, restrict to items that appear in added_by_item_ids
#             # if added_by_item_ids is not None:
#             #     # If no item IDs found in history at all, skip querying
#             #     if not added_by_item_ids:
#             #         continue
#             #     query = query.in_("id", list(added_by_item_ids))

#             items_resp = query.execute()
#             if items_resp.error:
#                 raise Exception(items_resp.error.message)

#             # items_resp.data is a list of item‐dicts already filtered by Supabase
#             if not items_resp.data:
#                 # No items for this box match the filters → skip
#                 continue

#             grouped.append({
#                 "box_id":   box_data["id"],
#                 "box_name": box_data["name"],
#                 "items":    items_resp.data
#             })


        

#         return jsonify(grouped), 200
#     except Exception as e:
#         print(str(e))
#         return jsonify({"error": str(e)}), 500

# @search_bp.route('/api/user_collaborators', methods=['GET'])

@search_bp.route('/api/user_collaborators', methods=['GET'])
def user_collaborators():
    user_id = request.args.get('user_id', type=int)
    if user_id is None:
        return jsonify({'error': 'Missing or invalid user_id parameter'}), 400

    try:
        # 1) Fetch all Box IDs owned by this user
        boxes_resp = supabase.table("Box") \
                             .select("id") \
                             .eq("user_id", user_id) \
                             .execute()
        owned_ids = [b["id"] for b in (boxes_resp.data or [])]

        # 2) Find all BoxAccess rows where box_id ∈ owned_ids AND status == "ACCEPTED"
        if owned_ids:
            accesses_resp = supabase.table("BoxAccessRequest") \
                                   .select("user_id") \
                                   .in_("box_id", owned_ids) \
                                   .eq("status", "ACCEPTED") \
                                   .execute()
            collaborator_ids = {user_id} | {a["user_id"] for a in (accesses_resp.data or [])}
        else:
            # If no owned boxes, the only “collaborator” is the user themself
            collaborator_ids = {user_id}

        # 3) Fetch User records for each ID in collaborator_ids
        users_resp = supabase.table("User") \
                             .select("id, username") \
                             .in_("id", list(collaborator_ids)) \
                             .execute()

        result = [{"id": u["id"], "name": u["username"]} for u in (users_resp.data or [])]
        return jsonify(result), 200

    except Exception as e:
        print("[ERROR] user_collaborators:", str(e))
        return jsonify({"error": str(e)}), 500

    

# @search_bp.route('/api/boxes_items_grouped', methods=['GET'])
# def get_boxes_items_grouped():
#     user_id = request.args.get('user_id', type=int)
#     if not user_id:
#         return jsonify({'error': 'Missing user_id parameter'}), 400

#     # parse optional filters
#     date_from_str = request.args.get('date_from')    # expected ISO format, e.g. "2025-06-01T00:00:00"
#     date_to_str   = request.args.get('date_to')      # same
#     added_by      = request.args.get('added_by', type=int)

#     try:
#         # Convert date filters to ISO strings (Supabase expects ISO‐formatted timestamps)
#         date_from_iso = None
#         if date_from_str:
#             dtf = datetime.fromisoformat(date_from_str)
#             date_from_iso = dtf.replace(tzinfo=timezone.utc).isoformat()

#         if date_to_str:
#             dt = datetime.fromisoformat(date_to_str)
#             date_to_iso = dt.replace(tzinfo=timezone.utc).isoformat()
#         else:
#             # If date_to not provided, default to “now” in UTC
#             now_utc     = datetime.utcnow().replace(tzinfo=timezone.utc)
#             date_to_iso = now_utc.isoformat()

#         # === 1) Owned boxes ===
#         owned_resp = supabase.table("Box") \
#                               .select("id, name") \
#                               .eq("user_id", user_id) \
#                               .execute()
#         if owned_resp.error:
#             raise Exception(owned_resp.error.message)

#         owned_boxes = owned_resp.data  # each item is {"id": ..., "name": ...}

#         owned_ids = [b["id"] for b in owned_boxes]

#         # === 2) Shared & accepted boxes ===
#         # shared_boxes = []
#         # if owned_ids:
#         #     # First find all BoxAccess rows where user_id == this user AND status == "ACCEPTED"
#         #     ba_resp = supabase.table("BoxAccess") \
#         #                       .select("box_id") \
#         #                       .eq("user_id", user_id) \
#         #                       .eq("status", "ACCEPTED") \
#         #                       .execute()
#         #     if ba_resp.error:
#         #         raise Exception(ba_resp.error.message)

#         #     shared_box_ids = [r["box_id"] for r in ba_resp.data]

#         #     if shared_box_ids:
#         #         # Now fetch those boxes’ id & name
#         #         boxes_resp = supabase.table("Box") \
#         #                              .select("id, name") \
#         #                              .in_("id", shared_box_ids) \
#         #                              .execute()
#         #         if boxes_resp.error:
#         #             raise Exception(boxes_resp.error.message)
#         #         shared_boxes = boxes_resp.data

#         # === 3) Merge & dedupe boxes into a dict keyed by box.id ===
#         final_boxes_dict = {}
#         for b in owned_boxes:
#             final_boxes_dict[b["id"]] = {"id": b["id"], "name": b["name"]}

#         # for b in shared_boxes:
#         #     final_boxes_dict.setdefault(b["id"], {"id": b["id"], "name": b["name"]})

#         # === If added_by filter is provided: fetch all item_ids that were added by that user ===
#         added_by_item_ids = None
#         if added_by is not None:
#             hist_resp = supabase.table("History") \
#                                 .select("item_id") \
#                                 .eq("user_id", added_by) \
#                                 .eq("action_type", "Item Added") \
#                                 .execute()
#             if hist_resp.error:
#                 raise Exception(hist_resp.error.message)
#             added_by_item_ids = {h["item_id"] for h in hist_resp.data}

#         # === 4) For each box, fetch items with filters ===
#         grouped = []
#         for box_id, box_data in final_boxes_dict.items():
#             # Build a base Item query
#             query = supabase.table("Item").select("id, box_id, name, added_at, /* ...other fields... */") \
#                                             .eq("box_id", box_id)
#             if date_from_iso:
#                 query = query.gte("added_at", date_from_iso)
#             if date_to_iso:
#                 query = query.lte("added_at", date_to_iso)

#             # If added_by is specified, restrict to items that appear in added_by_item_ids
#             if added_by_item_ids is not None:
#                 # If no item IDs found in history at all, skip querying
#                 if not added_by_item_ids:
#                     continue
#                 query = query.in_("id", list(added_by_item_ids))

#             items_resp = query.execute()
#             if items_resp.error:
#                 raise Exception(items_resp.error.message)

#             # items_resp.data is a list of item‐dicts already filtered by Supabase
#             if not items_resp.data:
#                 # No items for this box match the filters → skip
#                 continue

#             # (Optionally, if you have an Item.to_dict() equivalent, you may transform. Here, we return raw fields.)
#             grouped.append({
#                 "box_id":   box_data["id"],
#                 "box_name": box_data["name"],
#                 "items":    items_resp.data
#             })

#         return jsonify(grouped), 200

#     except Exception as e:
#         return jsonify({"error": str(e)}), 500