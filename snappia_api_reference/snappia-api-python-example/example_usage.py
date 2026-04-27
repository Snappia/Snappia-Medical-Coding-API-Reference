from snappia_client import SnappiaClient

API_TOKEN = "<api-token-key>"

client = SnappiaClient(API_TOKEN)

patient_report = """
David, a 63-year-old established male patient, presents to Massachusetts General Hospital's ophthalmology clinic with progressive blurring of vision in his right eye over the past eight months, difficulty driving at night, and increased glare sensitivity. His past medical history includes type 2 diabetes mellitus with diabetic retinopathy in both eyes, well-controlled hypertension, and benign prostatic hyperplasia. Comprehensive ophthalmologic examination revealed a best-corrected visual acuity of 20/80 in the right eye and 20/30 in the left eye, with slit-lamp examination demonstrating a dense nuclear sclerotic cataract grade 3+ in the right eye. Intraocular pressures and dilated fundus examination were within acceptable limits for surgical intervention, with stable non-proliferative diabetic retinopathy noted. After failure of conservative management with updated refraction and glare-reducing lenses, the ophthalmologist recommended cataract extraction with intraocular lens implantation. The patient underwent outpatient phacoemulsification of the right eye cataract with insertion of a monofocal posterior chamber intraocular lens. Monitored anesthesia care with topical and intracameral anesthesia was administered personally by the attending anesthesiologist, with a total anesthesia time of 35 minutes. A separate problem-focused evaluation and management visit including interval history, complete ophthalmologic examination, and low-complexity medical decision-making was documented earlier on the same date of service prior to the procedure.
"""

# Submit Job
job_id = client.submit_job(patient_report)
print("Submitted Job:", job_id)

# Poll Job
job = client.poll_job(job_id)

if job["status"] == "failed":
    print("Job failed:", job["error_message"])
    exit()

# Extract Results
icd_codes = client.get_icd_codes(job)
cpt_codes = client.get_cpt_codes(job)
hcpcs_codes = client.get_hcpcs_codes(job)
pcs_codes = client.get_pcs_codes(job)
icd_cpt_linkage = client.get_icd_cpt_linkage(job)
icd_hcpcs_linkage = client.get_icd_hcpcs_linkage(job)
icd_pcs_linkage = client.get_icd_pcs_linkage(job)

print("\nICD Codes")
for code in icd_codes["result"]:
    print(code["ICD-10-CM Code"], "-", code["ICD Description"])

print("\nCPT Codes")
for code in cpt_codes["result"]:
    print(code["code"], "-", code["description"])

print("\nHCPCS Codes")
for code in hcpcs_codes["result"]:
    print(code["code"], "-", code["description"])

print("\nICD-10-PCS Codes")
for code in pcs_codes["result"]:
    print(code["code"], "-", code["description"])

def _icd_summary(icd_list):
    return [f"{i['ICD-10-CM Code']} - {i['ICD Description']}" for i in icd_list]

print("\nICD-CPT Linkage")
for cpt, data in icd_cpt_linkage.items():
    print(cpt, "→", _icd_summary(data["icd"]))

print("\nICD-HCPCS Linkage")
for hcpcs, data in icd_hcpcs_linkage.items():
    print(hcpcs, "→", _icd_summary(data["icd"]))

print("\nICD-PCS Linkage")
for pcs, data in icd_pcs_linkage.items():
    print(pcs, "→", _icd_summary(data["icd"]))
