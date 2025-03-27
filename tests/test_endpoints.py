import pytest
from fastapi.testclient import TestClient

# Import the FastAPI app from your main script
from reverse_proxy.main import app

# Create a TestClient instance for our FastAPI app
client = TestClient(app)

def test_health_check():
    response = client.get("/health_check")
    assert response.status_code == 200

    # Check that the JSON contains the expected data
    data = response.json()
    assert "message" in data
    assert "healthy" in data["message"], "Expected 'healthy' substring in the message"

def test_long_running_process():
    response = client.post("/long_running_process")
    assert response.status_code == 200

    data = response.json()
    assert data == {"message": "Server was blocked for 5 seconds."}
