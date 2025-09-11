import joblib
import numpy as np
import os

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

