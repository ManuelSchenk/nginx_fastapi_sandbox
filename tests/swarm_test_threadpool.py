import requests
import concurrent.futures

# URL to the long-running endpoint via the Swarm load balancer
BASE_URL = "http://localhost:2222/"
sequences = [
    ("long_running_process", "post"),
    ("long_running_process", "post"), 
    ("long_running_process", "post"), 
    ("health_check", "get"), 
    ("health_check", "get"), 
    ]

def call(endpoint: str, method: str):
    if method.lower() == "get":
        response = requests.get(BASE_URL + endpoint, timeout=15)
    elif method.lower() == "post":
        response = requests.post(BASE_URL + endpoint, timeout=65)
    else:
        raise ValueError("The method must be either POST or GET!")
    # Raise an exception if the response was not successful
    response.raise_for_status()
    return response.json()

def test_load_balancer_routing_multi_thread():
    # Use a ThreadPoolExecutor to send two requests concurrently (multi threading)
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(sequences)) as executor:
        # i will test if the server is blocked after sending two long running post request
        # so i expect that the 3th call health_check respond with an error
        # HINT: to call all simultaneously you need the same amount of workers
        futures = [executor.submit(call, *seq) for seq in sequences]
        # Collect the results
        results = [future.result() for future in concurrent.futures.as_completed(futures)]
    
    print("Results from the two replicas:")
    for idx, res in enumerate(results, start=1):
        print(f"Result {idx}: {res}")


if __name__ == "__main__":
    test_load_balancer_routing()
