import csv
import os
import argparse
import time
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

API_BASE = "https://mobile.maf.co.id/maf/minio-service/api/Files/download"

def download_file(row, out_dir, retries=3, delay=2):
    """Download a single file and return a tuple (success_bool, message, bucket, filename)."""
    bucket = row["Bucket"].strip()
    filename = row["FileName"].strip()
    url = f"{API_BASE}/{filename}?bucketName={bucket}"
    local_path = os.path.join(out_dir, filename)
    os.makedirs(out_dir, exist_ok=True)

    for attempt in range(retries):
        try:
            with requests.get(url, stream=True, timeout=60) as r:
                r.raise_for_status()
                with open(local_path, "wb") as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
            return True, f"SUCCESS: {filename}", bucket, filename
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(delay * (attempt + 1))  # exponential back-off
                continue
            return False, f"FAILED: {filename} -> {e}", bucket, filename

def main():
    parser = argparse.ArgumentParser(description="Download files in parallel from a CSV list.")
    parser.add_argument("csv_file", help="Path to CSV file containing Bucket and FileName columns")
    parser.add_argument("-o", "--output", default="downloads",
                        help="Directory to save downloaded files (default: downloads)")
    parser.add_argument("--delimiter", default=";", help="CSV delimiter (default: ;)")
    parser.add_argument("-w", "--workers", type=int, default=20,
                        help="Number of concurrent downloads (default: 20)")
    parser.add_argument("--log", default="failed.logs",
                        help="Path to log file for failures (default: failed.logs)")
    args = parser.parse_args()


    # # DEBUG: open without utf-8-sig first / cek nama kolom mengandung: ['\ufeffBucket', 'FileName']  
    # with open(args.csv_file, newline='', encoding="utf-8") as f:
    #     reader = csv.DictReader(f, delimiter=";")
    #     print("Raw detected fieldnames:", reader.fieldnames)   # <--- key info
    #     # Peek at first few rows
    #     for i, row in enumerate(reader):
    #         print(f"Row {i} keys:", list(row.keys()))
    #         print(f"Row {i} values:", list(row.values()))
    #         if i >= 2:     # only show first 3 rows
    #             break

    with open(args.csv_file, newline='', encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f, delimiter=args.delimiter))

    total = len(rows)
    print(f"Starting parallel download of {total} files using {args.workers} workers...\n")

    failed_rows = []

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = [executor.submit(download_file, row, args.output) for row in rows]
        for i, future in enumerate(as_completed(futures), start=1):
            success, msg, bucket, filename = future.result()
            print(f"[{i}/{total}] {msg}")
            if not success:
                # keep raw data so we can retry later
                failed_rows.append({"Bucket": bucket, "FileName": filename})

    if failed_rows:
        log_path = os.path.abspath(args.log)
        # Write as CSV for easier retry
        with open(log_path, "w", newline="", encoding="utf-8-sig") as logf:
            writer = csv.DictWriter(logf, fieldnames=["Bucket", "FileName"], delimiter=";")
            writer.writeheader()
            writer.writerows(failed_rows)
        print(f"\n{len(failed_rows)} failures logged to {log_path}")
    else:
        print("\nAll downloads completed successfully.")

if __name__ == "__main__":
    main()