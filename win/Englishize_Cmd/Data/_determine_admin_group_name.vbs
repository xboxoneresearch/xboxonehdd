' For more info, see below web page:
' http://blogs.technet.com/b/heyscriptingguy/archive/2005/11/02/how-can-i-determine-the-name-of-the-local-administrators-group.aspx

Dim strComputer, objWMIService, colAccounts, objAccount
On Error Resume Next

strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colAccounts = objWMIService.ExecQuery _
    ("Select * From Win32_Group Where LocalAccount = TRUE And SID = 'S-1-5-32-544'")

For Each objAccount in colAccounts
    Wscript.Echo objAccount.Name
Next