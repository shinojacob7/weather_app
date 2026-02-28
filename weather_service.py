from typing import Any, Dict

import requests


class WeatherService:
    def __init__(self, openweathermap_api_key: str, weatherapi_key: str):
        self.openweathermap_api_key = openweathermap_api_key
        self.weatherapi_key = weatherapi_key

    def get_openweathermap_data(self, city: str) -> Dict[str, Any]:
        if not self.openweathermap_api_key:
            return {"error": "OPENWEATHERMAP_API_KEY is not configured"}

        url = "https://api.openweathermap.org/data/2.5/weather"
        response = requests.get(
            url,
            params={"q": city, "appid": self.openweathermap_api_key, "units": "metric"},
            timeout=10,
        )
        response.raise_for_status()
        return response.json()

    def get_weatherapi_data(self, city: str) -> Dict[str, Any]:
        if not self.weatherapi_key:
            return {"error": "WEATHERAPI_KEY is not configured"}

        url = "https://api.weatherapi.com/v1/current.json"
        response = requests.get(
            url,
            params={"key": self.weatherapi_key, "q": city, "aqi": "no"},
            timeout=10,
        )
        response.raise_for_status()
        return response.json()

    def get_weather(self, city: str) -> Dict[str, Any]:
        if not city.strip():
            raise ValueError("City cannot be empty")

        openweathermap_data = self.get_openweathermap_data(city)
        weatherapi_data = self.get_weatherapi_data(city)

        return {
            "city": city,
            "openweathermap": openweathermap_data,
            "weatherapi": weatherapi_data,
        }
