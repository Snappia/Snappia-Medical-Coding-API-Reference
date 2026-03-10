# Snappia Medical Coding API – Reference Implementations

Welcome to the **Snappia Medical Coding API** reference repository. This collection provides code examples and client implementations in various languages to help you integrate Snappia's automated medical coding into your workflow.

The Snappia API uses advanced AI Workflow to process patient reports and return structured results, including **ICD-10-CM diagnosis codes**, **CPT procedure codes**, and **ICD–CPT linkage mappings**.

---

## Available Reference Clients

Select the implementation that best fits your tech stack:

| Language / Tool | Location | Description |
| :--- | :--- | :--- |
| **Python** | [`/snappia-api-python-example`](./snappia_api_reference/snappia-api-python-example) | Production-ready Python client using `requests`. |
| **JavaScript** | [`/snappia-api-javascript-example`](./snappia_api_reference/snappia-api-javascript-example) | Node.js client using `axios` (ES Modules). |
| **CURL / Bash** | [`/snappia-api-curl-example`](./snappia_api_reference/snappia-api-curl-example) | Raw REST examples and a workflow shell script. |

---

## General API Workflow

The Snappia API follows an **asynchronous job-based workflow**:

1.  **Submit Job**: POST a patient report to `/jobs`.
2.  **Poll Status**: GET the job status using the returned `job_id`.
3.  **Retrieve Results**: Once the status is `completed`, extract the medical coding results.

Typical processing time ranges from **1 to 10 minutes** depending on the complexity of the report.

---

## Authentication

All API requests require a **Bearer API token** in the authorization header:

```http
Authorization: Bearer <your_api_token>
```

---

## API Details

-   **Base URL**: `https://api.snappia.claims/api/v1`
-   **Content-Type**: `application/json`

### Rate Limits
-   **Job Submission**: User specific.
-   **Polling**: 60 requests per minute.

---

## Testing with Postman

Each folder contains a `snappia_api.postman_collection.json` file. You can import this into Postman to quickly test endpoints without writing any code.

---

## Support

For API access, token generation, or technical support, please contact your Snappia account administrator.
