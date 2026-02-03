from ftplib import FTP
import os
import argparse

# Setup argument parser
parser = argparse.ArgumentParser(description="FTP file downloader")
parser.add_argument("host", help="FTP host or IP")
parser.add_argument("port", type=int, help="FTP port")
parser.add_argument("user", help="FTP username")
parser.add_argument("password", help="FTP password")
parser.add_argument("filelist", help="Path to txt file with remote file list")

args = parser.parse_args()

# FTP connection
ftp = FTP()
ftp.connect(args.host, args.port)
ftp.login(user=args.user, passwd=args.password)
print(f"✅ Connected to FTP server {args.host}:{args.port} as {args.user}")

# Local folder for downloads
local_dir = "downloads"
os.makedirs(local_dir, exist_ok=True)

# Read file paths from txt
with open(args.filelist) as f:
    for line in f:
        remote_path = line.strip()
        if not remote_path:
            continue

        # Replace backslashes with forward slashes
        remote_path = remote_path.replace("\\", "/")

        # Split to get filename only
        filename = os.path.basename(remote_path)

        # Local save path
        local_path = os.path.join(local_dir, filename)

        # Ensure we are in correct remote folder
        remote_dir = os.path.dirname(remote_path)
        if remote_dir:
            try:
                ftp.cwd(remote_dir)
            except Exception as e:
                print(f"❌ Cannot change to {remote_dir}: {e}")
                continue

        # Download the file
        try:
            with open(local_path, "wb") as lf:
                ftp.retrbinary(f"RETR {filename}", lf.write)
            print(f"✅ Downloaded {remote_path} -> {local_path}")
        except Exception as e:
            print(f"❌ Failed to download {remote_path}: {e}")

ftp.quit()
