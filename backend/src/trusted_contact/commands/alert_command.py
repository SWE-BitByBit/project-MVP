from dataclasses import dataclass

@dataclass
class AlertCmd:
    user_id: str
    user_name: str
    latitude: float | None = None
    longitude: float | None = None