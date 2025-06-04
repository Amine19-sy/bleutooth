from firebase_admin import messaging
from models.device_token import DeviceToken
from extensions import db
from datetime import datetime

# def send_push_to_user(user_id: int, title: str, body: str, data: dict = None):
#     # 1) Gather all tokens for this user
#     tokens = [
#         dt.token
#         for dt in DeviceToken.query.filter_by(user_id=user_id).all()
#     ]
#     if not tokens:
#         return {"success": False, "reason": "no_tokens"}

#     # 2) Build the multicast message
#     message = messaging.MulticastMessage(
#         notification=messaging.Notification(title=title, body=body),
#         data=data or {},
#         tokens=tokens,
#     )

#     # 3) Send it
#     response = messaging.send_multicast(message)
#     # response.success_count, response.failure_count, response.responses

#     # 4) Optionally, clean up invalid tokens
#     for idx, resp in enumerate(response.responses):
#         if not resp.success:
#             # for example, if token is no-longer-registered, remove it
#             err = resp.exception
#             if hasattr(err, 'code') and err.code in (
#                 'registration-token-not-registered',
#                 'invalid-registration-token'
#             ):
#                 bad_token = tokens[idx]
#                 DeviceToken.query.filter_by(token=bad_token).delete()

#     db.session.commit()

#     return {
#         "success": True,
#         "sent": response.success_count,
#         "failed": response.failure_count
#     }

def send_push_to_user(user_id: int, title: str, body: str, data: dict = None):
    tokens = [dt.token for dt in DeviceToken.query.filter_by(user_id=user_id)]
    success, failed = 0, 0

    for token in tokens:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data=data or {},
            token=token,
        )
        try:
            messaging.send(message)
            success += 1
        except messaging.ApiCallError as e:
            failed += 1
            # prune invalid tokens if you like:
            if hasattr(e, 'code') and e.code in (
                'registration-token-not-registered',
                'invalid-registration-token'
            ):
                DeviceToken.query.filter_by(token=token).delete()

    db.session.commit()
    return {"sent": success, "failed": failed}