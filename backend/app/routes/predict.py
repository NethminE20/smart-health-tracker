from fastapi import APIRouter, Depends, FastAPI
from app.models.ml_model import HealthInput, PredictResponse, Issue
from app.services.ml_service import predict_condition, analyze_parameters
from app.routes.auth import get_current_user

router = APIRouter()

@router.post("/predict/", response_model=PredictResponse)
async def predict_health(
    data: HealthInput,
    current_user: str = Depends(get_current_user)
):
    condition = predict_condition(
        data.age,
        data.bmi,
        data.systolicbp,
        data.diastolicbp,
        data.heartrate,
        data.glucose,
    )

    issues_list = analyze_parameters(
        age=data.age,
        bmi=data.bmi,
        systolicbp=data.systolicbp,
        diastolicbp=data.diastolicbp,
        heartrate=data.heartrate,
        glucose=data.glucose
    )

    if not issues_list:
        return PredictResponse(
            condition=condition,
            message="All parameters normal",
            issues=[]  # always include the field
        )

    return PredictResponse(
        condition=condition,
        message="Some parameters are abnormal",
        issues=issues_list
    )


app = FastAPI()
app.include_router(router)




