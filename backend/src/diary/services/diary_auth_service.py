from typing import Optional

from ports.validate_password_port import ValidatePasswordPort
from ports.set_password_port import SetPasswordPort
from ports.check_password_status_port import CheckPasswordStatusPort
from ports.diary_auth_repository_port import DiaryAuthRepositoryPort
from commands.validate_password_command import ValidatePasswordCmd
from commands.set_password_command import SetPasswordCmd
from domain.diary_type import DiaryType


class DiaryAuthService(ValidatePasswordPort, SetPasswordPort, CheckPasswordStatusPort):
    
    def __init__(self, auth_repository: DiaryAuthRepositoryPort):
        self.auth_repository = auth_repository
    
    def validate_password(self, cmd: ValidatePasswordCmd) -> str:
        return self.auth_repository.validate_password(cmd.password, cmd.user_id)
    
    def set_real_password(self, cmd: SetPasswordCmd) -> None:
        self._verify_previous_password_if_needed(cmd)
        
        success = self.auth_repository.set_password(
            password=cmd.password,
            user_id=cmd.user_id,
            diary_type=DiaryType.REAL_DIARY
        )
        
        if not success:
            raise RuntimeError("Failed to set real password")
    
    def set_fake_password(self, cmd: SetPasswordCmd) -> None:
        self._verify_previous_password_if_needed(cmd)
        
        success = self.auth_repository.set_password(
            password=cmd.password,
            user_id=cmd.user_id,
            diary_type=DiaryType.FAKE_DIARY
        )
        
        if not success:
            raise RuntimeError("Failed to set fake password")
    
    def check_password_status(self, user_id: str) -> dict:
        user_data = self.auth_repository.get_user_passwords(user_id)
        
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

        result = self.auth_repository.validate_password(
            cmd.previous_password,
            cmd.user_id
        )

        expected_result = (
            "real" if cmd.diary_type == DiaryType.REAL_DIARY
            else "fake"
        )

        if result != expected_result:
            raise ValueError(
                f"Previous password does not match {cmd.diary_type.value} diary"
            )