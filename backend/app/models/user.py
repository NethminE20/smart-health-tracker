# app/models/user.py
from pydantic import BaseModel, EmailStr
from typing import Optional

class User(BaseModel):
    name: str
    email: EmailStr
    password: str  # Will store hashed password

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserProfile(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    bio: Optional[str] = None
    profile_picture: Optional[str] = None

# Input schema for prediction
class HealthInput(BaseModel):
    age: int
    bmi: float
    systolicbp: int
    diastolicbp: int
    heartrate: int
    glucose: int

class PredictResponse(BaseModel):
    condition: str