# Parameters
$username = "your_username"
$password = "your_password"

# Start FortiClient
Start-Process "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"
Start-Sleep -Seconds 5  # Wait for GUI to load

# Load Windows Forms for SendKeys
Add-Type -AssemblyName System.Windows.Forms

# Activate FortiClient window (optional: may need third-party tool like AutoHotkey for reliability)
# This example assumes it's the active window.

# Send Username
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")       # Move to username field
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait($username)

# Send Password
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")       # Move to password field
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait($password)

# Send Connect
[System.Windows.Forms.SendKeys]::SendWait("{TAB}")       # Move to Connect button
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
