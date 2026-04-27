import axios from 'axios';

/**
 * Javascript client for the Snappia Medical Coding API.
 */
export class SnappiaClient {
    constructor(apiToken, baseUrl = "https://api.snappia.claims/api/v1", timeout = 30000) {
        this.baseUrl = baseUrl;
        this.timeout = timeout;
        this.client = axios.create({
            baseURL: baseUrl,
            timeout: timeout,
            headers: {
                'Authorization': `Bearer ${apiToken}`,
                'Content-Type': 'application/json'
            }
        });
    }

    // ----------------------------
    // Submit Job
    // ----------------------------
    async submitJob(patientReport) {
        try {
            const response = await this.client.post('/jobs', {
                patient_report: patientReport
            });
            return response.data.job_id;
        } catch (error) {
            if (error.response && error.response.status === 429) {
                throw new Error("Daily submission limit reached");
            }
            throw error;
        }
    }

    // ----------------------------
    // Get Job
    // ----------------------------
    async getJob(jobId) {
        try {
            const response = await this.client.get(`/jobs/${jobId}`);
            return response.data;
        } catch (error) {
            if (error.response && error.response.status === 429) {
                throw new Error("Polling rate limit exceeded");
            }
            throw error;
        }
    }

    // ----------------------------
    // Poll Job
    // ----------------------------
    async pollJob(jobId, interval = 10000, maxWait = 600000) {
        const startTime = Date.now();
        while (true) {
            const job = await this.getJob(jobId);
            const status = job.status;
            console.log(`Job status: ${status}`);

            if (status === 'completed' || status === 'failed') {
                return job;
            }

            if (Date.now() - startTime > maxWait) {
                throw new Error("Polling timed out");
            }

            await new Promise(resolve => setTimeout(resolve, interval));
        }
    }

    // ----------------------------
    // List Jobs
    // ----------------------------
    async listJobs(statusFilter = null, skip = 0, limit = 5) {
        const params = { skip, limit };
        if (statusFilter) {
            params.status_filter = statusFilter;
        }
        const response = await this.client.get('/jobs', { params });
        return response.data;
    }

    // ----------------------------
    // Data Extraction Helpers
    // ----------------------------
    static getIcdCodes(jobResult) {
        return jobResult.medical_coding_result.icd;
    }

    static getCptCodes(jobResult) {
        return jobResult.medical_coding_result.cpt;
    }

    static getHcpcsCodes(jobResult) {
        return jobResult.medical_coding_result.hcpcs;
    }

    static getPcsCodes(jobResult) {
        return jobResult.medical_coding_result.pcs;
    }

    static getLinkages(jobResult) {
        return jobResult.medical_coding_result.linkage;
    }

    static getIcdCptLinkage(jobResult) {
        return jobResult.medical_coding_result.linkage.icd_cpt_linkage;
    }

    static getIcdHcpcsLinkage(jobResult) {
        return jobResult.medical_coding_result.linkage.icd_hcpcs_linkage;
    }

    static getIcdPcsLinkage(jobResult) {
        return jobResult.medical_coding_result.linkage.icd_pcs_linkage;
    }
}
