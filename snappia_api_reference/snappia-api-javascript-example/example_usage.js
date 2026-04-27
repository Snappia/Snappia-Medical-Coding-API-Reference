import { SnappiaClient } from './snappia_client.js';

const API_TOKEN = "<api-token-key>";

const client = new SnappiaClient(API_TOKEN);

const patientReport = `
David, a 63-year-old established male patient, presents to Massachusetts General Hospital's ophthalmology clinic with progressive blurring of vision in his right eye over the past eight months, difficulty driving at night, and increased glare sensitivity. His past medical history includes type 2 diabetes mellitus with diabetic retinopathy in both eyes, well-controlled hypertension, and benign prostatic hyperplasia. Comprehensive ophthalmologic examination revealed a best-corrected visual acuity of 20/80 in the right eye and 20/30 in the left eye, with slit-lamp examination demonstrating a dense nuclear sclerotic cataract grade 3+ in the right eye. Intraocular pressures and dilated fundus examination were within acceptable limits for surgical intervention, with stable non-proliferative diabetic retinopathy noted. After failure of conservative management with updated refraction and glare-reducing lenses, the ophthalmologist recommended cataract extraction with intraocular lens implantation. The patient underwent outpatient phacoemulsification of the right eye cataract with insertion of a monofocal posterior chamber intraocular lens. Monitored anesthesia care with topical and intracameral anesthesia was administered personally by the attending anesthesiologist, with a total anesthesia time of 35 minutes. A separate problem-focused evaluation and management visit including interval history, complete ophthalmologic examination, and low-complexity medical decision-making was documented earlier on the same date of service prior to the procedure.
`;

function icdSummary(icdList) {
    return icdList.map(i => `${i["ICD-10-CM Code"]} - ${i["ICD Description"]}`);
}

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
        const hcpcsCodes = SnappiaClient.getHcpcsCodes(job);
        const pcsCodes = SnappiaClient.getPcsCodes(job);
        const icdCptLinkage = SnappiaClient.getIcdCptLinkage(job);
        const icdHcpcsLinkage = SnappiaClient.getIcdHcpcsLinkage(job);
        const icdPcsLinkage = SnappiaClient.getIcdPcsLinkage(job);

        console.log("\nICD Codes");
        for (const code of icdCodes["result"]) {
            console.log(`${code["ICD-10-CM Code"]} - ${code["ICD Description"]}`);
        }

        console.log("\nCPT Codes");
        for (const code of cptCodes["result"]) {
            console.log(`${code["code"]} - ${code["description"]}`);
        }

        console.log("\nHCPCS Codes");
        for (const code of hcpcsCodes["result"]) {
            console.log(`${code["code"]} - ${code["description"]}`);
        }

        console.log("\nICD-10-PCS Codes");
        for (const code of pcsCodes["result"]) {
            console.log(`${code["code"]} - ${code["description"]}`);
        }

        console.log("\nICD-CPT Linkage");
        for (const [cpt, data] of Object.entries(icdCptLinkage)) {
            console.log(`${cpt} → ${icdSummary(data.icd)}`);
        }

        console.log("\nICD-HCPCS Linkage");
        for (const [hcpcs, data] of Object.entries(icdHcpcsLinkage)) {
            console.log(`${hcpcs} → ${icdSummary(data.icd)}`);
        }

        console.log("\nICD-PCS Linkage");
        for (const [pcs, data] of Object.entries(icdPcsLinkage)) {
            console.log(`${pcs} → ${icdSummary(data.icd)}`);
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
