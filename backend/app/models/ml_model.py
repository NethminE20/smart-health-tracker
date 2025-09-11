from pydantic import BaseModel

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