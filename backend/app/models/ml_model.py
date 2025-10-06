# models/ml_model.py
from pydantic import BaseModel
from typing import List, Optional

class HealthInput(BaseModel):
    age: int
    bmi: float
    systolicbp: int
    diastolicbp: int
    heartrate: int
    glucose: int

class Issue(BaseModel):
    parameter: str
    value: float
    status: str
    suggestion: str

class PredictResponse(BaseModel):
    condition: str
    message: str
    issues: List[Issue]  # always a list, even if empty


