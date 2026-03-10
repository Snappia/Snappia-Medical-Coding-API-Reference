import time
import requests
from typing import Optional, Dict, List


class SnappiaClient:
    """
    Python client for the Snappia Medical Coding API.
    """

    def __init__(
        self,
        api_token: str,
        base_url: str = "https://api.snappia.claims/api/v1",
        timeout: int = 30,
    ):
        self.base_url = base_url
        self.timeout = timeout

        self.session = requests.Session()
        self.session.headers.update(
            {
                "Authorization": f"Bearer {api_token}",
                "Content-Type": "application/json",
            }
        )

    # ----------------------------
    # Submit Job
    # ----------------------------
    def submit_job(self, patient_report: str) -> str:
        """
        Submit a patient report for medical coding.
        Returns the job_id.
        """

        url = f"{self.base_url}/jobs"

        response = self.session.post(
            url,
            json={"patient_report": patient_report},
            timeout=self.timeout,
        )

        if response.status_code == 429:
            raise RuntimeError("Daily submission limit reached")

        response.raise_for_status()

        data = response.json()

        return data["job_id"]

    # ----------------------------
    # Get Job
    # ----------------------------
    def get_job(self, job_id: str) -> Dict:
        """
        Retrieve a job's status and result.
        """

        url = f"{self.base_url}/jobs/{job_id}"

        response = self.session.get(url, timeout=self.timeout)

        if response.status_code == 429:
            raise RuntimeError("Polling rate limit exceeded")

        response.raise_for_status()

        return response.json()

    # ----------------------------
    # Poll Job
    # ----------------------------
    def poll_job(
        self,
        job_id: str,
        interval: int = 10,
        max_wait: int = 600,
    ) -> Dict:
        """
        Poll until job is completed or failed.
        """

        start_time = time.time()

        while True:
            job = self.get_job(job_id)

            status = job["status"]
            print(f"Job status: {status}")

            if status in ["completed", "failed"]:
                return job

            if time.time() - start_time > max_wait:
                raise TimeoutError("Polling timed out")

            time.sleep(interval)

    # ----------------------------
    # List Jobs
    # ----------------------------
    def list_jobs(
        self,
        status_filter: Optional[str] = None,
        skip: int = 0,
        limit: int = 5,
    ) -> Dict:

        params = {
            "skip": skip,
            "limit": limit,
        }

        if status_filter:
            params["status_filter"] = status_filter

        response = self.session.get(
            f"{self.base_url}/jobs",
            params=params,
            timeout=self.timeout,
        )

        response.raise_for_status()

        return response.json()

    # ----------------------------
    # Extract ICD Codes
    # ----------------------------
    @staticmethod
    def get_icd_codes(job_result: Dict) -> List[Dict]:

        return job_result["medical_coding_result"]["icd"]

    # ----------------------------
    # Extract CPT Codes
    # ----------------------------
    @staticmethod
    def get_cpt_codes(job_result: Dict) -> List[Dict]:

        return job_result["medical_coding_result"]["cpt"]

    # ----------------------------
    # Extract Linkage
    # ----------------------------
    @staticmethod
    def get_linkages(job_result: Dict) -> Dict:

        return job_result["medical_coding_result"]["linkage"]
