# Snappia Medical Coding API – CURL Reference

This repository provides **reference CURL commands** demonstrating how to interact with the **Snappia Medical Coding API**.

The API processes patient reports and returns structured medical coding results.

---

# Authentication

All API requests require a **Bearer API token**.

```bash
export API_TOKEN="<your_api_token>"
```

---

# API Workflow

## 1. Submit a Job

```bash
curl -X POST "https://api.snappia.claims/api/v1/jobs" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{ "patient_report": "Patient is a 55-year-old male presenting with chest pain and shortness of breath for the past 2 hours." }'
```

Example Response:
```json
{
  "job_id": "bc6d24cc-bf76-4a70-9099-9cc3f01d9632",
  "status": "pending"
}
```

## 2. Get Job Status / Results

Replace `<JOB_ID>` with the ID received from the submission.

```bash
curl -X GET "https://api.snappia.claims/api/v1/jobs/<JOB_ID>" \
     -H "Authorization: Bearer $API_TOKEN"
```

## 3. List Jobs

```bash
curl -X GET "https://api.snappia.claims/api/v1/jobs?skip=0&limit=5" \
     -H "Authorization: Bearer $API_TOKEN"
```

### Filtering by status:

```bash
curl -X GET "https://api.snappia.claims/api/v1/jobs?status_filter=completed&skip=0&limit=5" \
     -H "Authorization: Bearer $API_TOKEN"
```

---

# Error Handling

Common error codes:

| Code | Meaning                |
| ---- | ---------------------- |
| 401  | Invalid API token      |
| 403  | Missing authentication |
| 404  | Job not found          |
| 422  | Validation error       |
| 429  | Rate limit exceeded    |

---

# API Base URL

```
https://api.snappia.claims/api/v1
```

---

# Workflow Script

A `workflow.sh` script is provided to demonstrate the full submission and polling process.

```bash
chmod +x workflow.sh
./workflow.sh
```
