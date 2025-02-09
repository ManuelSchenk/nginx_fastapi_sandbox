import asyncio
import httpx

sequences = [
    ("long_running_process", "post"),
    ("long_running_process", "post"), 
    ("long_running_process", "post"), 
    ("health_check", "get"), 
    ("health_check", "get"), 
    ]
# Base URL to your load balancer endpoint
BASE_URL = "http://localhost:2222/"

async def call(endpoint: str, method: str):
    url = BASE_URL + endpoint
    async with httpx.AsyncClient() as client:
        if method.lower() == "get":
            response = await client.get(url, timeout=15)
        elif method.lower() == "post":
            response = await client.post(url, timeout=65)
        else:
            raise ValueError("The method must be either POST or GET!")
        response.raise_for_status()
        return response.json()

async def test_load_balancer_routing():
    # Create tasks for each request to run them concurrently.
    tasks = [asyncio.create_task(call(endpoint, method)) for endpoint, method in sequences]
    
    # Await all tasks concurrently.
    results = await asyncio.gather(*tasks, return_exceptions=True)
    
    print("Results from the replicas:")
    for idx, res in enumerate(results, start=1):
        print(f"Result {idx}: {res}")

if __name__ == "__main__":
    asyncio.run(test_load_balancer_routing())
