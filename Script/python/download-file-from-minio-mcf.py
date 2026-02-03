import csv
import os
import argparse
import requests

API_BASE = "https://mobile.mcf.co.id/mcf/minio-service/api/Files/download"

def download_file(bucket: str, filename: str, out_dir: str):
    url = f"{API_BASE}/{filename}?bucketName={bucket}"
    local_path = os.path.join(out_dir, filename)
    os.makedirs(out_dir, exist_ok=True)

    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_path, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
    print(f"Downloaded {local_path}")

def main():
    parser = argparse.ArgumentParser(description="Download files listed in a CSV.")
    parser.add_argument("csv_file", help="Path to CSV file containing Bucket and FileName columns")
    parser.add_argument("-o", "--output", default="downloads",
                        help="Directory to save downloaded files (default: downloads)")
    # parser.add_argument("--delimiter", default="\t",
    #                     help="CSV delimiter (default: tab)")
    parser.add_argument("--delimiter", default=";",
                        help="CSV delimiter (default: ;)")

    args = parser.parse_args()

    with open(args.csv_file, newline='', encoding="utf-8") as f:
        reader = csv.DictReader(f, delimiter=args.delimiter)
        for row in reader:
            # print("Detected columns:", reader.fieldnames) ## debug 
            bucket = row["Bucket"].strip()
            filename = row["FileName"].strip()
            # print("Bucket Name: ", bucket + " " + "FileName: " +filename) ## Debug from each files
            download_file(bucket, filename, args.output)

if __name__ == "__main__":
    main()
