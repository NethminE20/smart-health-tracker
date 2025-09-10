# app/services/user_service.py
from app.database import db
from app.models.user import User
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from bson import ObjectId
import os
from fastapi import UploadFile

SECRET_KEY = "YOUR_SECRET_KEY"   # replace with secure random string in .env
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# =====================
# Password helpers
# =====================
def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


# =====================
# User ID Counter helper
# =====================
async def get_next_user_id():
    counter = await db.counters.find_one_and_update(
        {"_id": "user_id"},
        {"$inc": {"seq": 1}},
        upsert=True,
        return_document=True
    )
    return counter["seq"]


# =====================
# User Services
# =====================

# Add new user (signup)
async def add_user_to_db(user: User):
    user.password = hash_password(user.password)
    user_id = await get_next_user_id()
    user_doc = user.dict()
    user_doc["user_id"] = user_id  # use sequential user_id
    result = await db.users.insert_one(user_doc)
    return user_id

# Authenticate user (login)
async def authenticate_user(email: str, password: str):
    user = await db.users.find_one({"email": email})
    if user and verify_password(password, user["password"]):
        return user
    return None

# Create JWT token
def create_access_token(data: dict, expires_delta: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=expires_delta)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# Get all registered users
async def get_all_users():
    users = []
    cursor = db.users.find()
    async for doc in cursor:
        doc["_id"] = str(doc["_id"])  # convert ObjectId to string
        if "password" in doc:
            del doc["password"]  # hide password hash
        users.append(doc)
    return users

# Delete user by sequential user_id
async def delete_user(user_id: int):
    result = await db.users.delete_one({"user_id": user_id})
    return result.deleted_count > 0

UPLOAD_DIR = "uploads/profile_pics"
os.makedirs(UPLOAD_DIR, exist_ok=True)

async def update_profile(email: str, profile_data: dict, file: UploadFile = None):
    update_fields = {}

    # Add text fields
    for k, v in profile_data.items():
        if v is not None:
            update_fields[k] = v

    # Handle file upload
    if file:
        file_path = os.path.join(UPLOAD_DIR, f"{email}_{file.filename}")
        with open(file_path, "wb") as f:
            f.write(await file.read())
        update_fields["profile_picture"] = file_path

    if update_fields:
        await db.users.update_one({"email": email}, {"$set": update_fields})
        return True
    return False

async def get_profile(email: str):
    user = await db.users.find_one({"email": email})
    if not user:
        return None

    # Clean sensitive data
    user["_id"] = str(user["_id"])
    if "password" in user:
        del user["password"]

    return user

async def delete_profile(email: str):
    user = await db.users.find_one({"email": email})
    if not user:
        return False

    # Delete profile picture file if exists
    if "profile_picture" in user and user["profile_picture"]:
        try:
            if os.path.exists(user["profile_picture"]):
                os.remove(user["profile_picture"])
        except Exception as e:
            print(f"Error deleting profile picture: {e}")

    # Remove user document
    result = await db.users.delete_one({"email": email})
    return result.deleted_count > 0




