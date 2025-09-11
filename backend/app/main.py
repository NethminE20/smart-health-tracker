from fastapi import FastAPI
from app.routes import users, predict

app = FastAPI(title="Smart Health Tracker Backend")

# Register routes
app.include_router(users.router)
app.include_router(predict.router, prefix="/ml", tags=["Prediction"])

@app.get("/")
def root():
    return {"message": "Backend is working!"}



