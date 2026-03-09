import { SnappiaClient } from './snappia_client.js';

const API_TOKEN = "<your_api_token>";

const client = new SnappiaClient(API_TOKEN);

const patientReport = `
Patient is a 55-year-old male presenting with chest pain
and shortness of breath for the past 2 hours.
`;

async function runExample() {
    if (API_TOKEN === "<your_api_token>") {
        console.error("Please set your API_TOKEN in the script.");
        return;
    }

    try {
        // Submit Job
        const jobId = await client.submitJob(patientReport);
        console.log("Submitted Job:", jobId);

        // Poll Job
        const job = await client.pollJob(jobId);

        if (job.status === "failed") {
            console.error("Job failed:", job.error_message);
            return;
        }

        // Extract Results
        const icdCodes = SnappiaClient.getIcdCodes(job);
        const cptCodes = SnappiaClient.getCptCodes(job);
        const linkages = SnappiaClient.getLinkages(job);

        console.log("\nICD Codes");
        icdCodes.forEach(code => {
            console.log(`${code["ICD-10-CM Code"]} - ${code["ICD Description"]}`);
        });

        console.log("\nCPT Codes");
        cptCodes.forEach(code => {
            console.log(`${code["code"]} - ${code["description"]}`);
        });

        console.log("\nLinkages");
        for (const [cpt, data] of Object.entries(linkages)) {
            console.log(`${cpt} → ${data.icd}`);
        }

        // List Jobs
        console.log("\nListing recent jobs...");
        const jobs = await client.listJobs(null, 0, 3);
        console.log(`Retrieved ${jobs.items.length} jobs.`);

    } catch (error) {
        console.error("Error:", error.message);
    }
}

runExample();
