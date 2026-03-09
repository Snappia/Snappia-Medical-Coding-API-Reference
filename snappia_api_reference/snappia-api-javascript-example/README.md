# Snappia Medical Coding API – Javascript Reference Client

This repository provides **reference Javascript code** demonstrating how to interact with the **Snappia Medical Coding API** using Node.js.

The API processes patient reports and returns structured medical coding results including:

* **ICD-10-CM diagnosis codes**
* **CPT procedure codes**
* **ICD–CPT linkage mappings**

---

# API Workflow

The Snappia API follows an **asynchronous job-based workflow**:

1. Submit a patient report
2. Receive a `job_id`
3. Poll the job until processing completes
4. Retrieve the medical coding results

---

# Repository Structure

```
snappia-api-javascript-example/

README.md
package.json
snappia_client.js
example_usage.js
```

| File                | Description                                    |
| ------------------- | ---------------------------------------------- |
| `snappia_client.js` | Javascript client module for the API (ESM)     |
| `example_usage.js`  | Example script demonstrating full workflow     |
| `package.json`      | Node.js dependencies (axios)                   |

---

# Installation

Install dependencies:

```bash
npm install
```

---

# Authentication

All API requests require a **Bearer API token**.

Set your API token inside the script:

```javascript
const API_TOKEN = "<your_api_token>";
```

---

# Example Workflow

### 1 Submit a Job

```javascript
const jobId = await client.submitJob(patientReport);
console.log("Job submitted:", jobId);
```

### 2 Poll Job Status

```javascript
const result = await client.pollJob(jobId);
```

Recommended polling interval: **5 seconds**.

### 3 Retrieve Coding Results

```javascript
const icdCodes = SnappiaClient.getIcdCodes(result);
const cptCodes = SnappiaClient.getCptCodes(result);
```

---

# Example Output

Example ICD results:
```
ICD RESULTS
Code: I20.9
Description: Angina pectoris, unspecified
```

---

# Listing Jobs

```javascript
await client.listJobs(statusFilter, skip, limit);
```

---

# Rate Limits

* **Job Submission:** 50 jobs per day.
* **Polling:** 60 requests per minute.

If exceeded, the API returns **429 Too Many Requests**.

---

# Example Script

Run the example workflow:

```bash
node example_usage.js
```

---

# API Base URL

```
https://api.snappia.claims/api/v1
```
