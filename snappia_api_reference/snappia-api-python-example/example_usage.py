from snappia_client import SnappiaClient

API_TOKEN = "<api-token-key>"

client = SnappiaClient(API_TOKEN)

patient_report = """
Henry is a 40-year-old male patient, who presents to California Orthopedic Hospital after severe pain in his joints. For the past few years, he has been suffering from a chronic condition called rheumatoid arthritis. Now, he is undergoing a therapeutic procedure for the treatment of this disorder. He is also receiving regular monitoring of his medication levels. A therapeutic drug assay used to measure adalimumab levels is prescribed by a physician. The main purpose of this assay is to limit the amount of the drug so that it may not exceed its therapeutic range. The patient is also taking oxcarbazepine routinely and a separate test is also conducted to monitor this medication levels in blood. Both essays prescribed by the physician are performed by laboratory, during the same visit. The laboratory also provided a detailed special report of results.
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
for code in icd_codes["result"]:
    print(code["ICD-10-CM Code"], "-", code["ICD Description"])

print("\nCPT Codes")
for code in cpt_codes["result"]:
    print(code["code"], "-", code["description"])

print("\nLinkages")
for cpt, data in linkages["linkage"].items():
    print(cpt, "→", data["icd"])