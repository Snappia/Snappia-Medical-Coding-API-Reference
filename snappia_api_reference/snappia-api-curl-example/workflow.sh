#!/bin/bash

# Snappia API Workflow Script (CURL)

# Configuration
API_TOKEN="<api-token-key>"
BASE_URL="https://api.snappia.claims/api/v1"
PATIENT_REPORT="Henry is a 40-year-old male patient, who presents to California Orthopedic Hospital after severe pain in his joints. For the past few years, he has been suffering from a chronic condition called rheumatoid arthritis. Now, he is undergoing a therapeutic procedure for the treatment of this disorder. He is also receiving regular monitoring of his medication levels. A therapeutic drug assay used to measure adalimumab levels is prescribed by a physician. The main purpose of this assay is to limit the amount of the drug so that it may not exceed its therapeutic range. The patient is also taking oxcarbazepine routinely and a separate test is also conducted to monitor this medication levels in blood. Both essays prescribed by the physician are performed by laboratory, during the same visit. The laboratory also provided a detailed special report of results."

if [ "$API_TOKEN" == "<api-token-key>" ]; then
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

        # Extract and display ICD Codes
        echo -e "\nICD Codes"
        if command -v jq &> /dev/null; then
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.icd.result[] | "\(.["ICD-10-CM Code"]) - \(.["ICD Description"])"'
        else
            echo $JOB_RESPONSE
        fi

        # Extract and display CPT Codes
        echo -e "\nCPT Codes"
        if command -v jq &> /dev/null; then
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.cpt.result[] | "\(.code) - \(.description)"'
        fi

        # Extract and display Linkages
        echo -e "\nLinkages"
        if command -v jq &> /dev/null; then
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.linkage.linkage | to_entries[] | "\(.key) → \(.value.icd | join(", "))"'
        fi

        break
    elif [ "$STATUS" == "failed" ]; then
        echo "Job failed."
        echo $JOB_RESPONSE
        break
    fi

    sleep 10
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
