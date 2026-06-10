#!/usr/bin/env python3
import argparse
import json
import os
import tempfile
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload


def parse_args():
    parser = argparse.ArgumentParser(description="Upload an Android App Bundle to Google Play.")
    parser.add_argument("--package", required=True, help="Android package name, e.g. com.sarhny")
    parser.add_argument("--track", default="production", help="Google Play track, e.g. production")
    parser.add_argument("--aab", required=True, help="Path to .aab file")
    parser.add_argument("--service-account-json", required=True, help="Raw service account JSON")
    parser.add_argument("--release-name", required=True, help="Release name shown in Play Console")
    return parser.parse_args()


def main():
    args = parse_args()
    aab_path = Path(args.aab)
    if not aab_path.exists():
        raise SystemExit(f"AAB not found: {aab_path}")

    with tempfile.NamedTemporaryFile("w", delete=False) as f:
        f.write(args.service_account_json)
        service_account_path = f.name

    edit_id = None
    try:
        creds = service_account.Credentials.from_service_account_file(
            service_account_path,
            scopes=["https://www.googleapis.com/auth/androidpublisher"],
        )
        service = build("androidpublisher", "v3", credentials=creds, cache_discovery=False)

        edit = service.edits().insert(packageName=args.package, body={}).execute()
        edit_id = edit["id"]
        print(f"Created edit {edit_id}")

        media = MediaFileUpload(str(aab_path), mimetype="application/octet-stream", resumable=True)
        bundle = service.edits().bundles().upload(
            packageName=args.package,
            editId=edit_id,
            media_body=media,
        ).execute()
        version_code = int(bundle["versionCode"])
        print(f"Uploaded AAB versionCode={version_code}")

        release = {
            "name": args.release_name,
            "versionCodes": [str(version_code)],
            "status": "completed",
        }
        service.edits().tracks().update(
            packageName=args.package,
            editId=edit_id,
            track=args.track,
            body={"releases": [release]},
        ).execute()
        print(f"Assigned versionCode={version_code} to track={args.track}")

        service.edits().commit(
            packageName=args.package,
            editId=edit_id,
            changesInReviewBehavior="ERROR_IF_IN_REVIEW",
        ).execute()
        print("Committed Google Play edit")
    except HttpError as exc:
        print(exc.content.decode(errors="replace"))
        if edit_id:
            try:
                service.edits().delete(packageName=args.package, editId=edit_id).execute()
                print("Deleted failed edit")
            except Exception as cleanup_error:
                print(f"Failed to delete edit: {cleanup_error}")
        raise
    finally:
        try:
            os.unlink(service_account_path)
        except OSError:
            pass


if __name__ == "__main__":
    main()