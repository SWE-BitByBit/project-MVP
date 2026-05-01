import json
from commands.validate_password_command import ValidatePasswordCmd
from commands.validate_token_command import ValidateTokenCmd
from commands.login_command import LoginCmd
from commands.logout_command import LogoutCmd
from commands.set_password_command import SetPasswordCmd
from domain.diary_type import DiaryType

class DiaryAccessController:

    def __init__(self, service):
        self.service = service

    def response(self, status, body):
        return {
            "statusCode": status,
            "body": json.dumps(body)
        }

    def _get_user_id(self, event):
        claims = (
            event.get("requestContext", {})
            .get("authorizer", {})
            .get("jwt", {})
            .get("claims", {})
        )
        return claims.get("sub")

    def handle_request(self, event, context):
        route = event.get("routekey")

        if route == "/diary/auth/login":
            return self.login(event)

        elif route == "/diary/auth/logout":
            return self.logout(event)

        elif route == "/diary/auth/set_password":
            return self.set_password(event)

        elif route == "/diary/auth/status":
            return self.status(event)

        return self.response(404, {"error": "Route not found"})

    def login(self, event):
        body = json.loads(event["body"])

        cmd = LoginCmd(
            user_id=self._get_user_id(event),
            password=body.get("password")
        )

        try:
            result = self.service.login(cmd)
            if result is None:
                return self.response(401, {"error": "Login failed"})

            return self.response(200, result)

        except ValueError as e:
            return self.response(400, {"error": str(e)})

        except RuntimeError as e:
            return self.response(500, {"error": str(e)})

    def logout(self, event):
        cmd = LogoutCmd(
            user_id=self._get_user_id(event),
        )

        try:
            result = self.service.logout(cmd)
            return self.response(200, result)

        except ValueError as e:
            return self.response(400, {"error": str(e)})
            
        except RuntimeError as e:
            return self.response(500, {"error": str(e)})

    def set_password(self, event):
        body = json.loads(event["body"])

        diary_type_raw = body.get("diary_type")

        try:
            diary_type = DiaryType(diary_type_raw) # REAL_DIARY o FAKE_DIARY
        except ValueError:
            return self.response(400, {"error": "Invalid diary_type"})

        cmd = SetPasswordCmd(
            user_id=self._get_user_id(event),
            password=body.get("password"),
            previous_password=body.get("previous_password"),
            diary_type=diary_type
        )

        try:
            if diary_type == DiaryType.REAL_DIARY:
                self.service.set_real_password(cmd)
            else:
                self.service.set_fake_password(cmd)

            return self.response(200, {"message": "Password set successfully"})

        except ValueError as e:
            return self.response(400, {"error": str(e)})

        except RuntimeError as e:
            return self.response(500, {"error": str(e)})

    def validate_token(self, user_id: str, token: str) -> bool:
        cmd = ValidateTokenCmd(
            user_id = user_id,
            token = token
        )

        return self.service.validate_token(cmd)


    def status(self, event):        
        try:
            result = self.service.check_password_status(
                user_id=self._get_user_id(event),
            )

            return self.response(200, result)
        except ValueError as e:
            return self.response(400, {"error": str(e)})

        except RuntimeError as e:
            return self.response(500, {"error": str(e)})