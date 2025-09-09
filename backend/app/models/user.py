# app/models/user.py
from pydantic import BaseModel, EmailStr

class User(BaseModel):
    name: str
    email: EmailStr
    password: str  # Will store hashed password

class UserLogin(BaseModel):
    email: EmailStr
    password: str
