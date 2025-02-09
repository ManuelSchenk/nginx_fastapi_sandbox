from fastapi import FastAPI
import os
import time
import uvicorn
from utils.logging import ic

app = FastAPI()
container_name = os.popen("hostname").read().strip()

@app.get("/health_check")
def health_check():
    response = f"Reverse Proxy is healthy on container {container_name}"
    ic(response)
    return {"message": response}

@app.post("/long_running_process")
def long_runner():
    ic("Long running Process started. The Server is going to be blocked for 60 seconds...")
    time.sleep(60)  # Block for 60 seconds
    return {"message": f"Server on conatiner {container_name} was blocked for 60 seconds."}

if __name__ == "__main__":
    ic("Starting FastAPI server on port 3003...")
    uvicorn.run(app, host="0.0.0.0", port=3003)
