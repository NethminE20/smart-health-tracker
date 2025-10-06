import joblib
import numpy as np
import os
from app.models.ml_model import Issue
from typing import List

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "..", "health_model.pkl")
SCALER_PATH = os.path.join(BASE_DIR, "..", "scaler.pkl")
ENCODER_PATH = os.path.join(BASE_DIR, "..", "label_encoder.pkl")

# Load once when service starts
model = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)
encoder = joblib.load(ENCODER_PATH)


def predict_condition(age: int, bmi: float, systolicbp: int, diastolicbp: int, heartrate: int, glucose: int) -> str:
    """Predict health condition from features."""
    features = np.array([[age, bmi, systolicbp, diastolicbp, heartrate, glucose]])
    
    # Apply the same scaling as training
    features_scaled = scaler.transform(features)

    # Predict class index
    prediction = model.predict(features_scaled)[0]

    # Decode back to label
    return encoder.inverse_transform([prediction])[0]

def analyze_parameters(
    age: int,
    bmi: float,
    systolicbp: int,
    diastolicbp: int,
    heartrate: int,
    glucose: int
) -> List[Issue]:
    """Analyze input parameters and return a list of Issue models."""
    issues: List[Issue] = []

    # BMI
    if bmi < 18.5:
        issues.append(Issue(
            parameter="BMI",
            value=bmi,
            status="Underweight",
            suggestion="Increase calorie intake with healthy foods."
        ))
    elif bmi >= 30:
        issues.append(Issue(
            parameter="BMI",
            value=bmi,
            status="Obese",
            suggestion="Adopt a calorie-controlled diet and regular exercise."
        ))

    # Systolic BP
    if systolicbp > 140:
        issues.append(Issue(
            parameter="Systolic BP",
            value=systolicbp,
            status="High",
            suggestion="Reduce salt, manage stress, and consult a doctor."
        ))
    elif systolicbp < 90:
        issues.append(Issue(
            parameter="Systolic BP",
            value=systolicbp,
            status="Low",
            suggestion="Stay hydrated and eat small, frequent meals."
        ))

    # Diastolic BP
    if diastolicbp > 90:
        issues.append(Issue(
            parameter="Diastolic BP",
            value=diastolicbp,
            status="High",
            suggestion="Monitor regularly and reduce sodium intake."
        ))
    elif diastolicbp < 60:
        issues.append(Issue(
            parameter="Diastolic BP",
            value=diastolicbp,
            status="Low",
            suggestion="Stay hydrated and consult a doctor if symptoms occur."
        ))

    # Heart Rate
    if heartrate > 100:
        issues.append(Issue(
            parameter="Heart Rate",
            value=heartrate,
            status="High",
            suggestion="Reduce caffeine, manage stress, and seek medical advice if persistent."
        ))
    elif heartrate < 60:
        issues.append(Issue(
            parameter="Heart Rate",
            value=heartrate,
            status="Low",
            suggestion="Could indicate athletic conditioning, but consult a doctor if symptoms occur."
        ))

    # Blood Sugar
    if glucose > 125:
        issues.append(Issue(
            parameter="Blood Sugar",
            value=glucose,
            status="High",
            suggestion="Limit sugar intake and get checked for diabetes."
        ))
    elif glucose < 70:
        issues.append(Issue(
            parameter="Blood Sugar",
            value=glucose,
            status="Low",
            suggestion="Consume fast-acting carbs like fruit juice."
        ))

    return issues
