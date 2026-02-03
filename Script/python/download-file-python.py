from ftplib import FTP
import os
import getpass

# Prompt input for FTP credentials
host = input("Enter FTP host/IP: ")
port = int(input("Enter FTP port: "))
user = input("Enter FTP username: ")
password = getpass.getpass("Enter FTP password: ")

# FTP connection
ftp = FTP()
ftp.connect(host, port)
ftp.login(user=user, passwd=password)

print(f"✅ Connected to FTP server {host}:{port} as {user}")

# Local folder for downloads
local_dir = "downloads"
os.makedirs(local_dir, exist_ok=True)

# Prompt input for txt file containing file list
txt_file = input("Enter path to txt file with remote file list: ")

# Read file paths from txt
with open(txt_file) as f:
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
