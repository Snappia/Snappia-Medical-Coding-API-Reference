#!/bin/bash

# Snappia API Workflow Script (CURL)

# Configuration
API_TOKEN="<your_api_token>"
BASE_URL="https://api.snappia.claims/api/v1"
PATIENT_REPORT="Patient is a 55-year-old male presenting with chest pain and shortness of breath for the past 2 hours."

if [ "$API_TOKEN" == "<your_api_token>" ]; then
    echo "Error: Please set your API_TOKEN in the script."
    exit 1
fi

# 1. Submit Job
echo "Submitting job..."
SUBMIT_RESPONSE=$(curl -s -X POST "$BASE_URL/jobs" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{\"patient_report\": \"$PATIENT_REPORT\"}")

# Extract Job ID using sed (simple fallback for environments without jq)
JOB_ID=$(echo $SUBMIT_RESPONSE | sed -n 's/.*"job_id":"\([^"]*\)".*/\1/p')

if [ -z "$JOB_ID" ]; then
    echo "Failed to submit job. Response: $SUBMIT_RESPONSE"
    exit 1
fi

echo "Job submitted. ID: $JOB_ID"

# 2. Poll Job
echo "Polling job status..."
while true; do
    JOB_RESPONSE=$(curl -s -X GET "$BASE_URL/jobs/$JOB_ID" \
         -H "Authorization: Bearer $API_TOKEN")
    
    STATUS=$(echo $JOB_RESPONSE | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')
    echo "Current status: $STATUS"

    if [ "$STATUS" == "completed" ]; then
        echo "Job completed successfully!"
        # Try to use jq for pretty printing if available
        if command -v jq &> /dev/null; then
            echo $JOB_RESPONSE | jq .
        else
            echo $JOB_RESPONSE
        fi
        break
    elif [ "$STATUS" == "failed" ]; then
        echo "Job failed."
        echo $JOB_RESPONSE
        break
    fi

    sleep 5
done

# 3. List Jobs
echo -e "\nListing recent jobs..."
if command -v jq &> /dev/null; then
    curl -s -X GET "$BASE_URL/jobs?limit=3" \
         -H "Authorization: Bearer $API_TOKEN" | jq .
else
    curl -s -X GET "$BASE_URL/jobs?limit=3" \
         -H "Authorization: Bearer $API_TOKEN"
fi
