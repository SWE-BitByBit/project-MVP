from dataclasses import dataclass

@dataclass
class AlertCmd:
    user_id: str
    user_email: str
    latitude: float | None = None
    longitude: float | None = None