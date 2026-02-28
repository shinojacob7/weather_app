# weather_app

A weather and heat-stress prediction application built with Flutter (frontend) and Python (backend).

## Backend setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. (Optional) Configure API keys:

```bash
export OPENWEATHERMAP_API_KEY="your_openweathermap_key"
export WEATHERAPI_KEY="your_weatherapi_key"
```

3. (Optional) Configure a trained model path:

```bash
export HEAT_STRESS_MODEL_PATH="backend/heat_stress_model.pkl"
```

4. Run the backend:

```bash
python app.py
```

## Backend endpoints

- `GET /health`:
  - Health check with model status.
- `POST /predict`:
  - Body:
    ```json
    {
      "temperature": 35,
      "humidity": 70,
      "wind_speed": 2
    }
    ```
  - Returns heat-stress risk (`Low`, `Moderate`, `High` for rule-based mode).
- `GET /weather?city=Kochi`:
  - Returns combined weather payload from OpenWeatherMap and WeatherAPI.

## Model training

A starter training script is provided at `backend/heat_stress_predictor.py`.
