#!/usr/bin/env python3
import requests
import json
import time

# Create a test configuration
config = {
    "name": "WebTest_Config",
    "preset": "PE_500",
    "overrides": {
        "L": 1500,
        "D": 150,
        "t": 2.0,
        "top": "snapring",
        "bottom": "enkel",
        "bottom_opt": "zonder"
    }
}

# Post to the API
print("Posting configuration to API...")
try:
    response = requests.post('http://localhost:5000/api/generate', json=config)
    result = response.json()
    print(f"Response: {json.dumps(result, indent=2)}")
    
    job_id = result.get('job_id')
    if job_id:
        # Poll for completion
        print(f"\nWaiting for job {job_id} to complete...")
        for i in range(30):
            status_response = requests.get(f'http://localhost:5000/api/generate/{job_id}')
            status = status_response.json()
            print(f"[{i}] Status: {status['status']}, Progress: {status['progress']}%")
            
            if status['status'] in ['completed', 'failed', 'error']:
                print(f"\nFinal status: {status['status']}")
                print("\nLast 5 logs:")
                for log in status['logs'][-5:]:
                    print(f"  {log}")
                if 'error_details' in status:
                    print(f"\nError Details:\n{status['error_details']}")
                break
            
            time.sleep(0.5)

except Exception as e:
    print(f"Error: {e}")
