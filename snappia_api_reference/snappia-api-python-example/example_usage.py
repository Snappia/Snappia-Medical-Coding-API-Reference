from snappia_client import SnappiaClient

API_TOKEN = "<your_api_token>"

client = SnappiaClient(API_TOKEN)

patient_report = """
Patient is a 55-year-old male presenting with chest pain
and shortness of breath for the past 2 hours.
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
linkages = client.get_linkages(job)

print("\nICD Codes")
for code in icd_codes:
    print(code["ICD-10-CM Code"], "-", code["ICD Description"])

print("\nCPT Codes")
for code in cpt_codes:
    print(code["code"], "-", code["description"])

print("\nLinkages")
for cpt, data in linkages.items():
    print(cpt, "→", data["icd"])