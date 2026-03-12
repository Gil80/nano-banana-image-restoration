#!/usr/bin/env python3
"""
Nano Banana 2 image generator via Kie.ai API.
Usage: python scripts/generate_kie.py <prompt.json> <output.jpg> [aspect_ratio]
"""

import sys
import json
import os
import time
import base64
import mimetypes
import requests
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

KIE_API_KEY = os.getenv("KIE_API_KEY")
BASE_URL = "https://api.kie.ai"
CREATE_ENDPOINT = f"{BASE_URL}/api/v1/jobs/createTask"
STATUS_ENDPOINT = f"{BASE_URL}/api/v1/jobs/recordInfo"
UPLOAD_ENDPOINT = "https://kieai.redpandaai.co/api/file-base64-upload"


def load_prompt(prompt_file: str) -> dict:
    with open(prompt_file) as f:
        return json.load(f)


def upload_local_file(path: Path) -> str:
    mime, _ = mimetypes.guess_type(str(path))
    mime = mime or "image/png"
    b64 = base64.b64encode(path.read_bytes()).decode()
    headers = {
        "Authorization": f"Bearer {KIE_API_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "base64Data": f"data:{mime};base64,{b64}",
        "uploadPath": "images/input",
        "fileName": path.name,
    }
    print(f"Uploading {path.name} to kie.ai file service...")
    response = requests.post(UPLOAD_ENDPOINT, headers=headers, json=payload)
    response.raise_for_status()
    data = response.json()
    print(f"Upload response: {json.dumps(data, indent=2)}")
    url = data.get("data", {}).get("downloadUrl")
    if not url:
        raise ValueError(f"No downloadUrl in upload response: {data}")
    print(f"Uploaded: {url}")
    return url


def create_task(prompt_data: dict, aspect_ratio: str) -> str:
    headers = {
        "Authorization": f"Bearer {KIE_API_KEY}",
        "Content-Type": "application/json",
    }

    api_params = prompt_data.get("api_parameters", {})
    input_data = {
        "prompt": prompt_data["prompt"],
        "negative_prompt": prompt_data.get("negative_prompt", ""),
        "aspect_ratio": aspect_ratio or api_params.get("aspect_ratio", "auto"),
        "resolution": api_params.get("resolution", "1K"),
        "output_format": api_params.get("output_format", "jpg"),
        "google_search": api_params.get("google_search", False),
    }

    if prompt_data.get("image_input"):
        resolved = []
        for item in prompt_data["image_input"]:
            p = Path(item)
            if p.exists() and p.is_file():
                url = upload_local_file(p)
                resolved.append(url)
            else:
                resolved.append(item)
        input_data["image_input"] = resolved

    payload = {
        "model": "nano-banana-2",
        "input": input_data,
    }

    print(f"Creating task with aspect ratio: {payload['input']['aspect_ratio']}, resolution: {payload['input']['resolution']}")
    response = requests.post(CREATE_ENDPOINT, headers=headers, json=payload)
    response.raise_for_status()

    data = response.json()
    print(f"Response: {json.dumps(data, indent=2)}")

    if data.get("code") not in (200, None) or data.get("data") is None:
        raise RuntimeError(f"API error {data.get('code')}: {data.get('msg', data)}")

    task_id = (
        data["data"].get("taskId")
        or data["data"].get("task_id")
    )
    if not task_id:
        raise ValueError(f"No task ID in response: {data}")

    print(f"Task created: {task_id}")
    return task_id


def poll_task(task_id: str, max_wait: int = 300) -> str:
    headers = {"Authorization": f"Bearer {KIE_API_KEY}"}
    params = {"taskId": task_id}

    start = time.time()
    interval = 5

    while time.time() - start < max_wait:
        response = requests.get(STATUS_ENDPOINT, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()

        task_data = data.get("data", {})
        status = task_data.get("state") or data.get("status")
        print(f"Status: {status}")

        if status == "success":
            result_json_str = task_data.get("resultJson", "{}")
            result = json.loads(result_json_str) if isinstance(result_json_str, str) else result_json_str
            urls = result.get("resultUrls", [])
            if urls:
                return urls[0]
            raise ValueError(f"Task succeeded but no image URL found: {data}")

        if status in ("fail", "failed", "error"):
            raise RuntimeError(f"Task failed: {task_data.get('failMsg', data)}")

        time.sleep(interval)

    raise TimeoutError(f"Task {task_id} did not complete within {max_wait}s")


def download_image(url: str, output_path: str):
    print(f"Downloading image from: {url}")
    response = requests.get(url, stream=True)
    response.raise_for_status()

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    print(f"Image saved to: {output_path}")


def main():
    if len(sys.argv) < 3:
        print("Usage: python scripts/generate_kie.py <prompt.json> <output.jpg> [aspect_ratio]")
        sys.exit(1)

    if not KIE_API_KEY:
        print("Error: KIE_API_KEY not set. Add it to your .env file.")
        sys.exit(1)

    prompt_file = sys.argv[1]
    output_file = sys.argv[2]
    aspect_ratio = sys.argv[3] if len(sys.argv) > 3 else "auto"

    prompt_data = load_prompt(prompt_file)
    task_id = create_task(prompt_data, aspect_ratio)
    image_url = poll_task(task_id)
    download_image(image_url, output_file)
    print(f"Done! Image saved to {output_file}")


if __name__ == "__main__":
    main()
