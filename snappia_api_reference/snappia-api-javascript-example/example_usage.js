import { SnappiaClient } from './snappia_client.js';

const API_TOKEN = "<api-token-key>";

const client = new SnappiaClient(API_TOKEN);

const patientReport = `
Henry is a 40-year-old male patient, who presents to California Orthopedic Hospital after severe pain in his joints. For the past few years, he has been suffering from a chronic condition called rheumatoid arthritis. Now, he is undergoing a therapeutic procedure for the treatment of this disorder. He is also receiving regular monitoring of his medication levels. A therapeutic drug assay used to measure adalimumab levels is prescribed by a physician. The main purpose of this assay is to limit the amount of the drug so that it may not exceed its therapeutic range. The patient is also taking oxcarbazepine routinely and a separate test is also conducted to monitor this medication levels in blood. Both essays prescribed by the physician are performed by laboratory, during the same visit. The laboratory also provided a detailed special report of results.
`;

async function runExample() {
    if (API_TOKEN === "<api-token-key>") {
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
        for (const code of icdCodes["result"]) {
            console.log(`${code["ICD-10-CM Code"]} - ${code["ICD Description"]}`);
        }

        console.log("\nCPT Codes");
        for (const code of cptCodes["result"]) {
            console.log(`${code["code"]} - ${code["description"]}`);
        }

        console.log("\nLinkages");
        for (const [cpt, data] of Object.entries(linkages["linkage"])) {
            const icdList = data.icd.map(i => `${i["ICD-10-CM Code"]} - ${i["ICD Description"]}`);
            console.log(`${cpt} → ${icdList}`);
        }

        // List Jobs
        console.log("\nListing recent jobs...");
        const jobs = await client.listJobs(null, 0, 3);
        console.log(`Retrieved ${jobs.jobs.length} jobs.`);

    } catch (error) {
        console.error("Error:", error.message);
    }
}

runExample();
