# Snappia Medical Coding API – Javascript Reference Client

This repository provides **reference Javascript code** demonstrating how to interact with the **Snappia Medical Coding API** using Node.js.

The API processes patient reports and returns structured medical coding results including:

* **ICD-10-CM diagnosis codes**
* **CPT procedure codes**
* **HCPCS procedure/supply codes**
* **ICD-10-PCS procedure codes** (inpatient)
* **ICD↔CPT, ICD↔HCPCS, and ICD↔PCS linkage mappings**

The examples in this repository show how to:

* Authenticate with the API
* Submit a patient report for coding
* Poll for job completion
* Retrieve structured coding results
* Extract ICD, CPT, HCPCS, PCS, and linkage data
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

Clone the repository:

```bash
git clone https://github.com/anuragjoardar/Snappia-Medical-Coding.git
cd snappia_api_reference
cd snappia-api-javascript-example
```

Install dependencies:

```bash
npm install
```

Dependencies:

```
axios
```

---

# Authentication

All API requests require a **Bearer API token**.

Example header:

```
Authorization: Bearer <your_api_token>
```

Set your API token inside the script:

```javascript
const API_TOKEN = "<api-token-key>";
```

---

# Example Workflow

The following example demonstrates the **complete API workflow**.

### 1 Submit a Job

```javascript
const jobId = await client.submitJob(patientReport);
console.log("Job submitted:", jobId);
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

```javascript
const result = await client.pollJob(jobId);
```

Recommended polling interval:

```
10 seconds
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
HCPCS Results
ICD-10-PCS Results
ICD-CPT / ICD-HCPCS / ICD-PCS linkage mappings
```

Example extraction:

```javascript
const icdResult   = result["medical_coding_result"]["icd"];
const cptResult   = result["medical_coding_result"]["cpt"];
const hcpcsResult = result["medical_coding_result"]["hcpcs"];
const pcsResult   = result["medical_coding_result"]["pcs"];

const icdCptLinkage   = result["medical_coding_result"]["linkage"]["icd_cpt_linkage"];
const icdHcpcsLinkage = result["medical_coding_result"]["linkage"]["icd_hcpcs_linkage"];
const icdPcsLinkage   = result["medical_coding_result"]["linkage"]["icd_pcs_linkage"];
```

---

# Example Output

Example ICD results:

```
{
  "care_setting": "outpatient",
  "rationale": "The patient note clearly indicates an 'ophthalmology clinic' visit ...",
  "result": [
    {
      "Order No.": 1,
      "ICD-10-CM Code": "H25.11",
      "ICD Description": "Age-related nuclear cataract, right eye",
      "Type": "Primary",
      "Confidence Score": 92.3,
      "Rationale": "The patient has a dense nuclear sclerotic cataract grade 3+ ..."
    }
  ]
}
```

Example CPT results:

```
{
  "rationale": "Code 66984 was retained as it accurately describes ...",
  "result": [
    {
      "code": "66984",
      "description": "Extracapsular cataract removal with insertion of intraocular lens prosthesis ...",
      "units": 1,
      "modifier": "RT",
      "rationale": "The patient underwent outpatient phacoemulsification ...",
      "score": 100.0
    }
  ]
}
```

Example HCPCS results:

```
{
  "rationale": "Code Selection Summary: The patient underwent cataract extraction ...",
  "result": [
    {
      "code": "G9654",
      "description": "Monitored anesthesia care (mac)",
      "modifier": "AA-P2-QS",
      "units": 1,
      "score": 100,
      "rationale": "The patient received 'Monitored anesthesia care' ..."
    }
  ]
}
```

Example ICD-10-PCS results:

```
{
  "rationale": "These ICD-10-PCS codes comprehensively document ...",
  "result": [
    {
      "code": "08R03JZ",
      "description": "Medical and Surgical - Eye - Replacement - Eye, Right - Percutaneous - Synthetic Substitute - No Qualifier",
      "score": 95.26,
      "rationale": "This procedure involves the surgical removal of a cataract ..."
    }
  ]
}
```

The `linkage` object is split into three sub-keys: `icd_cpt_linkage`, `icd_hcpcs_linkage`, and `icd_pcs_linkage`. Each is a map from procedure code → entry (with `description`, `rationale`, `score`, and — for CPT/HCPCS — `units` and `modifier`). The `icd` field on every entry is an array of the full ICD objects linked to that procedure.

Example ICD-CPT linkage:

```
{
  "icd_cpt_linkage": {
    "66984": {
      "description": "Extracapsular cataract removal with insertion of intraocular lens prosthesis ...",
      "units": 1,
      "modifier": "RT",
      "rationale": "The patient underwent outpatient phacoemulsification ...",
      "score": 100.0,
      "icd": [
        {
          "Order No.": 1,
          "ICD-10-CM Code": "H25.11",
          "ICD Description": "Age-related nuclear cataract, right eye",
          "Type": "Primary",
          "Confidence Score": 92.3,
          "Rationale": "The patient has a dense nuclear sclerotic cataract ..."
        }
      ]
    }
  }
}
```

Example ICD-HCPCS linkage:

```
{
  "icd_hcpcs_linkage": {
    "G9654": {
      "description": "Monitored anesthesia care (mac)",
      "units": 1,
      "modifier": "AA-P2-QS",
      "rationale": "The patient received 'Monitored anesthesia care' ...",
      "score": 100,
      "icd": [
        {
          "Order No.": 1,
          "ICD-10-CM Code": "H25.11",
          "ICD Description": "Age-related nuclear cataract, right eye",
          "Type": "Primary",
          "Confidence Score": 92.3,
          "Rationale": "The patient has a dense nuclear sclerotic cataract ..."
        }
      ]
    }
  }
}
```

Example ICD-PCS linkage (note: no `units`/`modifier`):

```
{
  "icd_pcs_linkage": {
    "08R03JZ": {
      "description": "Medical and Surgical - Eye - Replacement - Eye, Right - Percutaneous - Synthetic Substitute - No Qualifier",
      "score": 95.26,
      "rationale": "This procedure involves the surgical removal of a cataract ...",
      "icd": [
        {
          "Order No.": 1,
          "ICD-10-CM Code": "H25.11",
          "ICD Description": "Age-related nuclear cataract, right eye",
          "Type": "Primary",
          "Confidence Score": 92.3,
          "Rationale": "The patient has a dense nuclear sclerotic cataract ..."
        }
      ]
    }
  }
}
```

---

# Listing Jobs

You can retrieve previously submitted jobs.

Example:

```javascript
await client.listJobs();
```

Optional filters:

```javascript
await client.listJobs("completed");
```

Pagination parameters:

| Parameter | Description                |
| --------- | -------------------------- |
| `skip`    | Offset for pagination      |
| `limit`   | Number of records per page |

Example:

```javascript
await client.listJobs("completed", 5, 5);
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
node example_usage.js
```

The script will:

1. Submit a patient report
2. Poll the job until completion
3. Print ICD codes
4. Print CPT codes
5. Print HCPCS codes
6. Print ICD-10-PCS codes
7. Print ICD-CPT linkage
8. Print ICD-HCPCS linkage
9. Print ICD-PCS linkage
10. List previously submitted jobs

---

# Example Patient Report

```
David, a 63-year-old established male patient, presents to Massachusetts General Hospital's ophthalmology clinic with progressive blurring of vision in his right eye over the past eight months, difficulty driving at night, and increased glare sensitivity. His past medical history includes type 2 diabetes mellitus with diabetic retinopathy in both eyes, well-controlled hypertension, and benign prostatic hyperplasia. Comprehensive ophthalmologic examination revealed a best-corrected visual acuity of 20/80 in the right eye and 20/30 in the left eye, with slit-lamp examination demonstrating a dense nuclear sclerotic cataract grade 3+ in the right eye. Intraocular pressures and dilated fundus examination were within acceptable limits for surgical intervention, with stable non-proliferative diabetic retinopathy noted. After failure of conservative management with updated refraction and glare-reducing lenses, the ophthalmologist recommended cataract extraction with intraocular lens implantation. The patient underwent outpatient phacoemulsification of the right eye cataract with insertion of a monofocal posterior chamber intraocular lens. Monitored anesthesia care with topical and intracameral anesthesia was administered personally by the attending anesthesiologist, with a total anesthesia time of 35 minutes. A separate problem-focused evaluation and management visit including interval history, complete ophthalmologic examination, and low-complexity medical decision-making was documented earlier on the same date of service prior to the procedure.
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

For API access, token generation, or technical support, please contact api@snappia.claims
