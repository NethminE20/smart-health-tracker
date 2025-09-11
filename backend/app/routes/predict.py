from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.services.ml_service import predict_condition
from app.routes.auth import get_current_user
from app.models.user import HealthInput, PredictResponse

router = APIRouter()

# Protected endpoint for prediction
@router.post("/predict/", response_model=PredictResponse)
async def predict_health(
    data: HealthInput, 
    current_user: str = Depends(get_current_user)
):
    result = predict_condition(
        data.age,
        data.bmi,
        data.systolicbp,
        data.diastolicbp,
        data.heartrate,
        data.glucose,
    )
    return {"condition": result}
