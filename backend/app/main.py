from fastapi import FastAPI
from app.routes import users

app = FastAPI(title="Smart Health Tracker Backend")

# Register routes
app.include_router(users.router)

@app.get("/")
def root():
    return {"message": "Backend is working!"}



