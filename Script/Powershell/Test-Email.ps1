$EmailFrom = "po_maf@maf.co.id"
$EmailPass = "2NStIKyb83VCJ6pZ3foa"
$EmailTo = "aditio.prabowo@maf.co.id"
$Port = 587
$Subject = "Test From PowerShell by Aditio Agung Prabowo"
$Body = "Did this work brody?"
$SMTPServer = "zmta4.mcf.co.id"

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $Port)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $EmailPass);
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)