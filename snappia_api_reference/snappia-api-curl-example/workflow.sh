#!/bin/bash

# Snappia API Workflow Script (CURL)

# Configuration
API_TOKEN="<api-token-key>"
BASE_URL="https://api.snappia.claims/api/v1"
PATIENT_REPORT="David, a 63-year-old established male patient, presents to Massachusetts General Hospital's ophthalmology clinic with progressive blurring of vision in his right eye over the past eight months, difficulty driving at night, and increased glare sensitivity. His past medical history includes type 2 diabetes mellitus with diabetic retinopathy in both eyes, well-controlled hypertension, and benign prostatic hyperplasia. Comprehensive ophthalmologic examination revealed a best-corrected visual acuity of 20/80 in the right eye and 20/30 in the left eye, with slit-lamp examination demonstrating a dense nuclear sclerotic cataract grade 3+ in the right eye. Intraocular pressures and dilated fundus examination were within acceptable limits for surgical intervention, with stable non-proliferative diabetic retinopathy noted. After failure of conservative management with updated refraction and glare-reducing lenses, the ophthalmologist recommended cataract extraction with intraocular lens implantation. The patient underwent outpatient phacoemulsification of the right eye cataract with insertion of a monofocal posterior chamber intraocular lens. Monitored anesthesia care with topical and intracameral anesthesia was administered personally by the attending anesthesiologist, with a total anesthesia time of 35 minutes. A separate problem-focused evaluation and management visit including interval history, complete ophthalmologic examination, and low-complexity medical decision-making was documented earlier on the same date of service prior to the procedure."

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

        if command -v jq &> /dev/null; then
            echo -e "\nICD Codes"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.icd.result[] | "\(.["ICD-10-CM Code"]) - \(.["ICD Description"])"'

            echo -e "\nCPT Codes"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.cpt.result[] | "\(.code) - \(.description)"'

            echo -e "\nHCPCS Codes"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.hcpcs.result[] | "\(.code) - \(.description)"'

            echo -e "\nICD-10-PCS Codes"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.pcs.result[] | "\(.code) - \(.description)"'

            echo -e "\nICD-CPT Linkage"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.linkage.icd_cpt_linkage | to_entries[] | "\(.key) → \([.value.icd[] | "\(.["ICD-10-CM Code"]) - \(.["ICD Description"])"] | join(", "))"'

            echo -e "\nICD-HCPCS Linkage"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.linkage.icd_hcpcs_linkage | to_entries[] | "\(.key) → \([.value.icd[] | "\(.["ICD-10-CM Code"]) - \(.["ICD Description"])"] | join(", "))"'

            echo -e "\nICD-PCS Linkage"
            echo $JOB_RESPONSE | jq -r '.medical_coding_result.linkage.icd_pcs_linkage | to_entries[] | "\(.key) → \([.value.icd[] | "\(.["ICD-10-CM Code"]) - \(.["ICD Description"])"] | join(", "))"'
        else
            echo $JOB_RESPONSE
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
