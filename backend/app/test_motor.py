import asyncio
from app.database import db

async def test_connection():
    try:
        # List collections to force a connection
        collections = await db.list_collection_names()
        print("Connected! Collections:", collections)
    except Exception as e:
        print("MongoDB connection failed:", e)

asyncio.run(test_connection())
