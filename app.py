import os
from typing import Any, Dict, Optional

import joblib
import numpy as np
from flask import Flask, jsonify, request
from flask_cors import CORS

from weather_service import WeatherService

MODEL_PATH = os.getenv("HEAT_STRESS_MODEL_PATH", "backend/heat_stress_model.pkl")

app = Flask(__name__)
CORS(app)


def _load_model(path: str):
    if not os.path.exists(path):
        return None
    try:
        return joblib.load(path)
    except Exception:
        return None


model = _load_model(MODEL_PATH)


def _validate_numeric_payload(data: Dict[str, Any]) -> Optional[str]:
    required_fields = ["temperature", "humidity", "wind_speed"]
    for field in required_fields:
        if field not in data:
            return f"Missing required field: {field}"
        if not isinstance(data[field], (int, float)):
            return f"Field '{field}' must be a number"
    return None


def _rule_based_risk(temperature: float, humidity: float, wind_speed: float) -> str:
    heat_index_like = temperature + (0.1 * humidity) - (0.4 * wind_speed)

    if heat_index_like >= 42:
        return "High"
    if heat_index_like >= 34:
        return "Moderate"
    return "Low"


def _predict_heat_stress(temperature: float, humidity: float, wind_speed: float) -> str:
    if model is not None:
        sample = np.array([[temperature, humidity, wind_speed]], dtype=float)
        prediction = model.predict(sample)[0]
        return str(prediction)
    return _rule_based_risk(temperature, humidity, wind_speed)


@app.get("/health")
def health() -> Any:
    return jsonify({"status": "ok", "model_loaded": model is not None})


@app.post("/predict")
def predict() -> Any:
    data = request.get_json(silent=True) or {}
    validation_error = _validate_numeric_payload(data)
    if validation_error:
        return jsonify({"error": validation_error}), 400

    temperature = float(data["temperature"])
    humidity = float(data["humidity"])
    wind_speed = float(data["wind_speed"])

    prediction = _predict_heat_stress(temperature, humidity, wind_speed)

    return jsonify(
        {
            "prediction": prediction,
            "inputs": {
                "temperature": temperature,
                "humidity": humidity,
                "wind_speed": wind_speed,
            },
            "model_source": "ml_model" if model is not None else "rule_based",
        }
    )


@app.get("/weather")
def weather() -> Any:
    city = request.args.get("city", "").strip()
    if not city:
        return jsonify({"error": "Query param 'city' is required"}), 400

    service = WeatherService(
        openweathermap_api_key=os.getenv("OPENWEATHERMAP_API_KEY", ""),
        weatherapi_key=os.getenv("WEATHERAPI_KEY", ""),
    )

    try:
        weather_data = service.get_weather(city)
    except ValueError as exc:
        return jsonify({"error": str(exc)}), 500
    except Exception:
        return jsonify({"error": "Failed to fetch weather data"}), 502

    return jsonify(weather_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")), debug=True)
