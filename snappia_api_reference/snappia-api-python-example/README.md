# Snappia Medical Coding API – Python Reference Client

This repository provides **reference Python code** demonstrating how to interact with the **Snappia Medical Coding API**.

The API processes patient reports and returns structured medical coding results including:

* **ICD-10-CM diagnosis codes**
* **CPT procedure codes**
* **ICD–CPT linkage mappings**

The examples in this repository show how to:

* Authenticate with the API
* Submit a patient report for coding
* Poll for job completion
* Retrieve structured coding results
* Extract ICD, CPT, and linkage data
* List submitted jobs with pagination

---

# API Workflow

The Snappia API follows an **asynchronous job-based workflow**:

1. Submit a patient report
2. Receive a `job_id`
3. Poll the job until processing completes
4. Retrieve the medical coding results

```
Submit Job → Job Queued → Processing → Completed → Retrieve Results
```

Typical processing time is **1–10 minutes depending on report complexity**.

---

# Repository Structure

```
snappia-api-python-example/

README.md
requirements.txt
snappia_client.py
example_usage.py
```

| File                | Description                                |
| ------------------- | ------------------------------------------ |
| `snappia_client.py` | Python client for interacting with the API |
| `example_usage.py`  | Example script demonstrating full workflow |
| `requirements.txt`  | Python dependencies                        |

---

# Installation

Clone the repository:

```bash
git clone https://github.com/anuragjoardar/Snappia-Medical-Coding.git
cd snappia_api_reference
cd snappia-api-python-example
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Dependencies:

```
requests
```

---

# Authentication

All API requests require a **Bearer API token**.

Example header:

```
Authorization: Bearer <your_api_token>
```

Set your API token inside the script:

```python
API_TOKEN = "<your_api_token>"
```

---

# Example Workflow

The following example demonstrates the **complete API workflow**.

### 1 Submit a Job

```python
job_id = client.submit_job(patient_report)
print("Job submitted:", job_id)
```

Example response:

```json
{
  "job_id": "bc6d24cc-bf76-4a70-9099-9cc3f01d9632",
  "status": "pending"
}
```

---

### 2 Poll Job Status

Jobs should be polled until they reach a terminal state:

* `completed`
* `failed`

Example:

```python
result = client.poll_job(job_id)
```

Recommended polling interval:

```
5 seconds
```

If the API returns a **429 rate limit error**, the client should wait **10–15 seconds** before retrying.

---

### 3 Retrieve Coding Results

Once the job status becomes **completed**, the response contains:

```
medical_coding_result
```

Which includes:

```
ICD Results
CPT Results
ICD–CPT linkage mappings
```

Example extraction:

```python
icd_result = result["medical_coding_result"]["icd"]
cpt_result = result["medical_coding_result"]["cpt"]
```

---

# Example Output

Example ICD results:

```
{
"care_setting": "outpatient",
"rationale": "Based on the clinical documentation...",
"result": [
  {
    "ICD-10-CM Code": "I20.9",
    "ICD Description": "Angina pectoris, unspecified",
    "Type": "Primary",
    "Order No.": 1,
    "Rationale": "The patient presents with chest pain...",
    "Confidence Score": 95.5
  }
          ]
}
```

Example CPT results:

```
{
"rationale": "Based on the level of service documented...",
"result": [
  {
    "code": "99213",
    "description": "Office or other outpatient visit for evaluation and management...",
    "modifier": null,
    "units": 1,
    "score": 92.0,
    "rationale": "The documentation supports a level 3 E/M visit..."
  }
          ]
}
```

Example ICD-CPT linkage:

```
{
"linkage": {
        "99213": {
          "icd": ["I20.9 - Angina pectoris, unspecified"],
          "description": "Office or other outpatient visit...",
          "modifier": null,
          "units": 1,
          "score": 92.0,
          "rationale": "This CPT code is linked to the primary ICD..."
                  }
          }
}
```

---

# Listing Jobs

You can retrieve previously submitted jobs.

Example:

```python
client.list_jobs()
```

Optional filters:

```python
client.list_jobs(status_filter="completed")
```

Pagination parameters:

| Parameter | Description                |
| --------- | -------------------------- |
| `skip`    | Offset for pagination      |
| `limit`   | Number of records per page |

Example:

```python
client.list_jobs(status_filter="completed", skip=5, limit=5)
```

---

# Rate Limits

Two limits are enforced per user.

### Job Submission

| Limit           | Reset        |
| --------------- | ------------ |
| User Specific | Midnight UTC |

### Polling

| Limit                  | Window             |
| ---------------------- | ------------------ |
| 60 requests per minute | Rolling 60 seconds |

If exceeded, the API returns:

```
429 Too Many Requests
```

The client should **retry after a delay**.

---

# Error Handling

All API errors return JSON responses.

Example:

```json
{
  "detail": "Invalid or inactive API token"
}
```

Common error codes:

| Code | Meaning                |
| ---- | ---------------------- |
| 401  | Invalid API token      |
| 403  | Missing authentication |
| 404  | Job not found          |
| 422  | Validation error       |
| 429  | Rate limit exceeded    |

---

# Example Script

Run the example workflow:

```bash
python example_usage.py
```

The script will:

1. Submit a patient report
2. Poll the job until completion
3. Print ICD codes
4. Print CPT codes
5. Print ICD-CPT linkage
6. List previously submitted jobs

---

# Example Patient Report

```
Henry is a 40-year-old male patient, who presents to California Orthopedic Hospital after severe pain in his joints. For the past few years, he has been suffering from a chronic condition called rheumatoid arthritis. Now, he is undergoing a therapeutic procedure for the treatment of this disorder. He is also receiving regular monitoring of his medication levels. A therapeutic drug assay used to measure adalimumab levels is prescribed by a physician. The main purpose of this assay is to limit the amount of the drug so that it may not exceed its therapeutic range. The patient is also taking oxcarbazepine routinely and a separate test is also conducted to monitor this medication levels in blood. Both essays prescribed by the physician are performed by laboratory, during the same visit. The laboratory also provided a detailed special report of results.
```

---

# API Base URL

```
https://api.snappia.claims/api/v1
```

---

# License

This repository is provided as **reference code for Snappia API users**.

---

# Support

For API access or support, contact your Snappia account administrator.
