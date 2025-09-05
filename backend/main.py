from fastapi import FastAPI
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

# Explicitly load .env from backend folder
BASE_DIR = os.path.dirname(__file__)  # backend/
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# MongoDB connection
MONGODB_URI = os.getenv("MONGODB_URI")
client = AsyncIOMotorClient(MONGODB_URI)
db = client["smart_health"]  # Database name

app = FastAPI(title="Smart Health Tracker Backend")

@app.get("/")
def root():
    return {"message": "Backend is working!"}

@app.post("/add-user")
async def add_user(user: dict):
    """Add a user to MongoDB"""
    result = await db.users.insert_one(user)
    return {"inserted_id": str(result.inserted_id)}

@app.get("/users")
async def get_users():
    """Get all users"""
    users = []
    async for doc in db.users.find():
        doc["_id"] = str(doc["_id"])
        users.append(doc)
    return users

print("MONGODB_URI from .env:", MONGODB_URI)  # Debug line

