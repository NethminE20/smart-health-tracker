# app/database.py
from motor.motor_asyncio import AsyncIOMotorClient
import os, certifi
from dotenv import load_dotenv

BASE_DIR = os.path.dirname(__file__)
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

MONGODB_URI = os.getenv("MONGODB_URI")

client = AsyncIOMotorClient(MONGODB_URI, tlsCAFile=certifi.where())
db = client.smart_health

