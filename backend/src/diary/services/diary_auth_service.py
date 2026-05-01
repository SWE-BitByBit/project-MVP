from typing import Optional
import re

from ports.validation_port import ValidationPort
from ports.set_password_port import SetPasswordPort
from ports.check_password_status_port import CheckPasswordStatusPort
from ports.diary_auth_repository_port import DiaryAuthRepositoryPort
from ports.access_port import AccessPort
from commands.login_command import LoginCmd
from commands.logout_command import LogoutCmd
from commands.validate_password_command import ValidatePasswordCmd
from commands.validate_token_command import ValidateTokenCmd
from commands.set_password_command import SetPasswordCmd
from domain.diary_type import DiaryType


class DiaryAuthService(ValidationPort, SetPasswordPort, CheckPasswordStatusPort, AccessPort):
    
    def __init__(self, auth_repository: DiaryAuthRepositoryPort):
        self.auth_repository = auth_repository

    def validate_password(self, cmd: ValidatePasswordCmd) -> Optional[DiaryType]:
        diary_type = self.auth_repository.validate_password(cmd.password, cmd.user_id)
        return diary_type

    def validate_token(self, cmd: ValidateTokenCmd) -> bool:
        return self.auth_repository.validate_token(cmd.token, cmd.user_id)

    def login(self, cmd: LoginCmd) -> dict:
        validate_cmd = ValidatePasswordCmd(
            cmd.user_id,
            cmd.password
        )

        target_diary = self.validate_password(validate_cmd)

        if target_diary is None:
            return {
                "diary_type" : None,
                "access_token" : None
            }
        
        access_token = self.auth_repository.start_session(cmd.user_id)
        return {
            "diary_type" : target_diary,
            "access_token" : access_token
        }

    def logout(self, cmd: LogoutCmd) -> None:
        self.auth_repository.end_session(cmd.user_id)

    
    def is_valid_password(self, new_password: str) -> bool:
        if len(new_password) < 10:
            return False

        if not re.search(r"[A-Z]", new_password):
            return False

        if not re.search(r"[a-z]", new_password):
            return False

        if not re.search(r"[0-9]", new_password):
            return False

        if not re.search(r'[!@#%^&*(),.?":{}|<>]', new_password):
            return False

        if re.search(r"\s", new_password):
            return False

        return True

    def set_real_password(self, cmd: SetPasswordCmd) -> None:
        if not self.is_valid_password(cmd.password):
            raise ValueError("Password does not meet safety requirements")

        self._verify_previous_password_if_needed(cmd)
        
        success = self.auth_repository.set_password(
            password=cmd.password,
            user_id=cmd.user_id,
            diary_type=DiaryType.REAL_DIARY
        )
        
        if not success:
            raise RuntimeError("Failed to set real password")

    def set_fake_password(self, cmd: SetPasswordCmd) -> None:
        if not self.is_valid_password(cmd.password):
            raise ValueError("Password does not meet safety requirements")

        self._verify_previous_password_if_needed(cmd)
        
        success = self.auth_repository.set_password(
            password=cmd.password,
            user_id=cmd.user_id,
            diary_type=DiaryType.FAKE_DIARY
        )
        
        if not success:
            raise RuntimeError("Failed to set fake password")
    
    def check_password_status(self, user_id: str) -> dict:
        if not user_id:
            raise ValueError("User not found")
            
        try:
            user_data = self.auth_repository.get_user_passwords(user_id)
        except Exception as e:
            raise RuntimeError(f"Backend error while checking password status: {e}")
        
        if not user_data:
            return {
                "has_real_password": False,
                "has_fake_password": False
            }

        return {
            "has_real_password": user_data.get("real_password") is not None,
            "has_fake_password": user_data.get("fake_password") is not None
        }
    
    def _verify_previous_password_if_needed(self, cmd: SetPasswordCmd) -> None:
        password_status = self.check_password_status(cmd.user_id)

        if not password_status["has_real_password"] and cmd.diary_type == DiaryType.REAL_DIARY:
            return
        
        if not password_status["has_fake_password"] and cmd.diary_type == DiaryType.FAKE_DIARY:
            return

        if not cmd.previous_password:
            raise ValueError("Previous password is required to change password")

        result = self.validate_password(
            ValidatePasswordCmd(cmd.user_id, cmd.previous_password)
        )

        if result != cmd.diary_type:
            raise ValueError(
                f"Previous password does not match {cmd.diary_type.value}"
            )