Option Explicit

Dim oHTTP
Dim sURL
Dim iStatus

' Replace "http://www.example.com" with the URL you want to check
sURL = "http://macf-efin1/EProcess"

Set oHTTP = CreateObject("MSXML2.ServerXMLHTTP")
oHTTP.open "HEAD", sURL, False
oHTTP.send

iStatus = oHTTP.Status

If iStatus = 200 Then
    WScript.Echo "Website is up and running."
Else
    WScript.Echo "Website is down or unreachable. HTTP response code: " & iStatus
End If
