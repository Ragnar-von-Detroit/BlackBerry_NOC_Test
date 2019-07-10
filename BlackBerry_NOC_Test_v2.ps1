# Script: BlackBerry NOC Test
# Version: 0.2 10.07.2019
# Blog: https://itgeeknotes.blogspot.com

# To-do:
# Direct Connect сервера

Remove-Variable * -ErrorAction SilentlyContinue

# VARIABLES
$date = (get-date).tostring(“yyyy-MM-dd_HH-mm-ss”)
$path = "C:/temp/BlackBerryNOCTest"
$HTMLReportFile = "$path/BlackBerryNOCTestReport_$date.html"
$IaminRussia = 1                                                          # <<<<< Set 0 if you are not in Russia. Установи 1 если ты находишься в России и проверять блокировку Роскомнадзором необходимо.
$DirectConnectServers = "gdweb.good.com,gdrelay.good.com"                                  # <<<<< Type here all your Direct Connect Servers comma separated
$DirectConnectPort = "443"                                                # <<<<< Type here a port that used on your Direct Connect Servers

# Create folder forreport
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}



# FUNCTIONS

function GetBlock
{
	Param ([string]$block_req)
	$block_result = (Invoke-WebRequest -Uri "http://api.antizapret.info/get.php?item=$block_req&type=small").Content
    if ($block_result -eq 0) {$block_result = "no"} else {$block_result = "YES"}
	return $block_result
}


function GetCNAME
{
	Param ([string]$cname_req)
	$cname_result = (Resolve-DnsName -Name $cname_req -Type CNAME).NameHost
	return $cname_result
}

function GetIP
{
	Param ([string]$ip_req)
	$ip_result = (Resolve-DnsName -Name $ip_req -Type A).IP4Address
	return $ip_result
}

function GetLatency
{
	Param ([string]$latency_req)
	$latency_result = [math]::Round((Test-Connection -IPAddress $latency_req -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Measure-Object -Property ResponseTime -Average).Average)
	return $latency_result
}

function GetPort
{
	Param ([string]$GetPort_ip, [string]$GetPort_port)
	$GetPort_result = (Test-NetConnection -Port $GetPort_port -ComputerName $GetPort_ip).TcpTestSucceeded
    $GetPort_result = $GetPort_port + " - " + $GetPort_result
	return $GetPort_result
}

function GetURL
{
	Param ([string]$GetURL_req)
	$GetURL_result = (Invoke-WebRequest -Uri $GetURL_req -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).Content
	return $GetURL_result
}

$MyExternalIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
$MyLANAdaters = Get-NetAdapter -physical | where status -eq 'up'
$MyDNSServers = ((Get-DnsClientServerAddress -InterfaceIndex $MyLANAdaters.InterfaceIndex -AddressFamily IPv4 | select ServerAddresses).ServerAddresses | Out-String).replace("`r`n","<br>")
$MyLANAdaters = ((((($MyLANAdaters | fl Name,InterfaceDescription,Status,LinkSpeed | Out-String).replace("`r`n","<br>")).replace("<br><br><br><br>","")).replace("<br><br><br>","")).replace("<br><br>","")).replace("<br>Name","")
$MyLatencyToRouter = (Test-Connection (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) | Measure-Object -Property ResponseTime -Average).Average
$MyTraceRoute = ((((Test-NetConnection "blackberry.com" -traceroute | fl | Out-String).replace("`r`n","<br>")).replace("<br><br><br><br>","")).replace("<br><br><br>","")).replace("<br><br>","")

# Data for server #1
$Server1Name = "gdweb.good.com"
$Server1CNAME = GetCNAME -cname_req $Server1Name
$Server1IP = GetIP -ip_req $Server1Name
$Server1Latency = GetLatency -latency_req $Server1IP
$Server1Port = GetPort -GetPort_ip $Server1IP -GetPort_port 443
$Server1URL = GetURL -GetURL_req "https://gdweb.good.com/depot/upload/"
if ($IaminRussia -eq 1)
{
    $Server1BlockIP = GetBlock -block_req $Server1IP
    $Server1BlockDomain = GetBlock -block_req $Server1Name
    if ($Server1BlockIP -eq "YES") {$Server1BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server1BlockDomain -eq "YES") {$Server1BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking1 = "<td $Server1BlockIPcolor style='padding: 5px;' align=center>$Server1BlockIP</td> <td $Server1BlockDomainColor style='padding: 5px;' align=center>$Server1BlockDomain</td>"
}
if ($Server1Latency -eq $null) {$Server1Latencycolor = "bgcolor='#F84A42'"; $Server1Latency = "-"}
if ($Server1Latency -ge 100) {$Server1Latencycolor = "bgcolor='#F6F675'"}
if ($Server1Latency -ge 200) {$Server1Latencycolor = "bgcolor='#F84A42'"}
if ($Server1Port -like "*FALSE") {$Server1PortColor = "bgcolor='#F84A42'"}
if ($Server1URL -notlike "*Yes, I am alive*") {$Server1URL = ":"; $Server1URLcolor = "bgcolor='#F84A42'"} else {$Server1URL = "Yes, I am alive";}

# Data for server #2
$Server2Name = "gdrelay.good.com"
$Server2CNAME = GetCNAME -cname_req $Server2Name
$Server2IP = GetIP -ip_req $Server2Name
$Server2Latency = GetLatency -latency_req $Server2IP
$Server2Port = GetPort -GetPort_ip $Server2IP -GetPort_port 443
$Server2Port2 = GetPort -GetPort_ip $Server2IP -GetPort_port 15000
if ($IaminRussia -eq 1)
{
    $Server2BlockIP = GetBlock -block_req $Server2IP
    $Server2BlockDomain = GetBlock -block_req $Server2Name
    if ($Server2BlockIP -eq "YES") {$Server2BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server2BlockDomain -eq "YES") {$Server2BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking2 = "<td $Server2BlockIPcolor style='padding: 5px;' align=center rowspan='2'>$Server2BlockIP</td> <td $Server2BlockDomainColor style='padding: 5px;' align=center rowspan='2'>$Server2BlockDomain</td>"
}
if ($Server2Latency -eq $null) {$Server2Latencycolor = "bgcolor='#F84A42'"; $Server2Latency = "-"}
if ($Server2Latency -ge 100) {$Server2Latencycolor = "bgcolor='#F6F675'"}
if ($Server2Latency -ge 200) {$Server2Latencycolor = "bgcolor='#F84A42'"}
if ($Server2Port -like "*FALSE") {$Server2PortColor = "bgcolor='#F84A42'"}
if ($Server2Port2 -like "*FALSE") {$Server2PortColor2 = "bgcolor='#F84A42'"}

# Data for server #3
$Server3Name = "gdmdc.good.com"
$Server3CNAME = GetCNAME -cname_req $Server3Name
$Server3IP = GetIP -ip_req $Server3Name
$Server3Latency = GetLatency -latency_req $Server3IP
$Server3Port = GetPort -GetPort_ip $Server3IP -GetPort_port 443
$Server3Port2 = GetPort -GetPort_ip $Server3IP -GetPort_port 49152
$Server3URL = GetURL -GetURL_req "https://gdmdc.good.com/depot/upload/"
if ($IaminRussia -eq 1)
{
    $Server3BlockIP = GetBlock -block_req $Server3IP
    $Server3BlockDomain = GetBlock -block_req $Server3Name
    if ($Server3BlockIP -eq "YES") {$Server3BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server3BlockDomain -eq "YES") {$Server3BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking3 = "<td $Server3BlockIPcolor style='padding: 5px;' align=center rowspan='2'>$Server3BlockIP</td> <td $Server3BlockDomainColor style='padding: 5px;' align=center rowspan='2'>$Server3BlockDomain</td>"
}
if ($Server3Latency -eq $null) {$Server3Latencycolor = "bgcolor='#F84A42'"; $Server3Latency = "-"}
if ($Server3Latency -ge 100) {$Server3Latencycolor = "bgcolor='#F6F675'"}
if ($Server3Latency -ge 200) {$Server3Latencycolor = "bgcolor='#F84A42'"}
if ($Server3Port -like "*FALSE") {$Server3PortColor = "bgcolor='#F84A42'"}
if ($Server3Port2 -like "*FALSE") {$Server3PortColor2 = "bgcolor='#F84A42'"}
if ($Server3URL -notlike "*Yes, I am alive*") {$Server3URL = ":"; $Server3URLcolor = "bgcolor='#F84A42'"} else {$Server3URL = "Yes, I am alive";}

# Data for server #4
$Server4Name = "gdentgw.good.com"
$Server4CNAME = GetCNAME -cname_req $Server4Name
$Server4IP = GetIP -ip_req $Server4Name
$Server4Latency = GetLatency -latency_req $Server4IP
$Server4Port = GetPort -GetPort_ip $Server4IP -GetPort_port 443
if ($IaminRussia -eq 1)
{
    $Server4BlockIP = GetBlock -block_req $Server4IP
    $Server4BlockDomain = GetBlock -block_req $Server4Name
    if ($Server4BlockIP -eq "YES") {$Server4BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server4BlockDomain -eq "YES") {$Server4BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking4 = "<td $Server4BlockIPcolor style='padding: 5px;' align=center>$Server4BlockIP</td> <td $Server4BlockDomainColor style='padding: 5px;' align=center>$Server4BlockDomain</td>"
}
if ($Server4Latency -eq $null) {$Server4Latencycolor = "bgcolor='#F84A42'"; $Server4Latency = "-"}
if ($Server4Latency -ge 100) {$Server4Latencycolor = "bgcolor='#F6F675'"}
if ($Server4Latency -ge 200) {$Server4Latencycolor = "bgcolor='#F84A42'"}
if ($Server4Port -like "*FALSE") {$Server4PortColor = "bgcolor='#F84A42'"}

# Data for server #5
$Server5Name = "bxenroll.good.com"
$Server5CNAME = GetCNAME -cname_req $Server5Name
$Server5IP = GetIP -ip_req $Server5Name
$Server5Latency = GetLatency -latency_req $Server5IP
$Server5Port = GetPort -GetPort_ip $Server5IP -GetPort_port 443
if ($IaminRussia -eq 1)
{
    $Server5BlockIP = GetBlock -block_req $Server5IP
    $Server5BlockDomain = GetBlock -block_req $Server5Name
    if ($Server5BlockIP -eq "YES") {$Server5BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server5BlockDomain -eq "YES") {$Server5BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking5 = "<td $Server5BlockIPcolor style='padding: 5px;' align=center>$Server5BlockIP</td> <td $Server5BlockDomainColor style='padding: 5px;' align=center>$Server5BlockDomain</td>"
}
if ($Server5Latency -eq $null) {$Server5Latencycolor = "bgcolor='#F84A42'"; $Server5Latency = "-"}
if ($Server5Latency -ge 100) {$Server5Latencycolor = "bgcolor='#F6F675'"}
if ($Server5Latency -ge 200) {$Server5Latencycolor = "bgcolor='#F84A42'"}
if ($Server5Port -like "*FALSE") {$Server5PortColor = "bgcolor='#F84A42'"}

# Data for server #6
$Server6Name = "bxcheckin.good.com"
$Server6CNAME = GetCNAME -cname_req $Server6Name
$Server6IP = GetIP -ip_req $Server6Name
$Server6Latency = GetLatency -latency_req $Server6IP
$Server6Port = GetPort -GetPort_ip $Server6IP -GetPort_port 443
if ($IaminRussia -eq 1)
{
    $Server6BlockIP = GetBlock -block_req $Server6IP
    $Server6BlockDomain = GetBlock -block_req $Server6Name
    if ($Server6BlockIP -eq "YES") {$Server6BlockIPcolor = "bgcolor='#F84A42'"}
    if ($Server6BlockDomain -eq "YES") {$Server6BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking6 = "<td $Server6BlockIPcolor style='padding: 5px;' align=center>$Server6BlockIP</td> <td $Server6BlockDomainColor style='padding: 5px;' align=center>$Server6BlockDomain</td>"
}
if ($Server6Latency -eq $null) {$Server6Latencycolor = "bgcolor='#F84A42'"; $Server6Latency = "-"}
if ($Server6Latency -ge 100) {$Server6Latencycolor = "bgcolor='#F6F675'"}
if ($Server6Latency -ge 200) {$Server6Latencycolor = "bgcolor='#F84A42'"}
if ($Server6Port -like "*FALSE") {$Server6PortColor = "bgcolor='#F84A42'"}

# Data for server #7
$Server7Name = "blackberry.com"
$Server7CNAME = GetCNAME -cname_req $Server7Name
$Server7IP = GetIP -ip_req $Server7Name
$Server7IP1 = $Server7IP[0]
$Server7IP2 = $Server7IP[1]
$Server7Latency1 = GetLatency -latency_req $Server7IP1
$Server7Latency2 = GetLatency -latency_req $Server7IP2
$Server7Port1 = GetPort -GetPort_ip $Server7IP1 -GetPort_port 443
$Server7Port2 = GetPort -GetPort_ip $Server7IP2 -GetPort_port 443
if ($IaminRussia -eq 1)
{
    $Server7BlockIP1 = GetBlock -block_req $Server7IP1
    $Server7BlockIP2 = GetBlock -block_req $Server7IP2
    $Server7BlockDomain = GetBlock -block_req $Server7Name
    if ($Server7BlockIP1 -eq "YES") {$Server7BlockIPcolor1 = "bgcolor='#F84A42'"}
    if ($Server7BlockIP2 -eq "YES") {$Server7BlockIPcolor2 = "bgcolor='#F84A42'"}
    if ($Server7BlockDomain -eq "YES") {$Server7BlockDomainColor = "bgcolor='#F84A42'"}
    $Blocking71 = "<td $Server7BlockIPcolor1 style='padding: 5px;' align=center>$Server7BlockIP1</td> <td $Server7BlockDomainColor style='padding: 5px;' align=center rowspan='2'>$Server7BlockDomain</td>"
    $Blocking72 = "<td $Server7BlockIPcolor2 style='padding: 5px;' align=center>$Server7BlockIP2</td>"
}
if ($Server7Latency1 -eq $null) {$Server7Latencycolor1 = "bgcolor='#F84A42'"; $Server7Latency1 = "-"}
if ($Server7Latency1 -ge 100) {$Server7Latencycolor1 = "bgcolor='#F6F675'"}
if ($Server7Latency1 -ge 200) {$Server7Latencycolor1 = "bgcolor='#F84A42'"}
if ($Server7Latency2 -eq $null) {$Server7Latencycolor2 = "bgcolor='#F84A42'"; $Server7Latency2 = "-"}
if ($Server7Latency2 -ge 100) {$Server7Latencycolor2 = "bgcolor='#F6F675'"}
if ($Server7Latency2 -ge 200) {$Server7Latencycolor2 = "bgcolor='#F84A42'"}
if ($Server7Port1 -like "*FALSE") {$Server7PortColor1 = "bgcolor='#F84A42'"}
if ($Server7Port2 -like "*FALSE") {$Server7PortColor2 = "bgcolor='#F84A42'"}

# Data for Direct Connect Servers
if ($DirectConnectServers -ne $null) {
    $DirectConnectServers = $DirectConnectServers.split(',')
    foreach ($i in $DirectConnectServers)
    {
        $DCS_CNAME = GetCNAME -cname_req $i
        $DCS_IP = GetIP -ip_req $i
        $DCS_Latency = GetLatency -latency_req $DCS_IP
        $DCS_Port = GetPort -GetPort_ip $DCS_IP -GetPort_port 443
        if ($IaminRussia -eq 1)
        {
            $DCS_BlockIP = GetBlock -block_req $DCS_IP
            $DCS_BlockDomain = GetBlock -block_req $i
            if ($DCS_BlockIP -eq "YES") {$DCS_BlockIPcolor = "bgcolor='#F84A42'"}
            if ($DCS_BlockDomain -eq "YES") {$DCS_BlockDomainColor = "bgcolor='#F84A42'"}
            $Blocking = "<td $DCS_BlockIPcolor style='padding: 5px;' align=center>$DCS_BlockIP</td> <td $DCS_BlockDomainColor style='padding: 5px;' align=center>$DCS_BlockDomain</td>"
        }
        if ($DCS_Latency -eq $null) {$DCS_Latencycolor = "bgcolor='#F84A42'"; $DCS_Latency = "-"}
        if ($DCS_Latency -ge 100) {$DCS_Latencycolor = "bgcolor='#F6F675'"}
        if ($DCS_Latency -ge 200) {$DCS_Latencycolor = "bgcolor='#F84A42'"}
        if ($DCS_Port -like "*FALSE") {$DCS_PortColor = "bgcolor='#F84A42'"}
        $DirectConnectHTML += "<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center><b>$i</b></td> <td style='padding: 5px;' align=center>$DCS_CNAME</td><td style='padding: 5px;' align=center>$DCS_IP</td> <td $DCS_Latencycolor style='padding: 5px;' align=center>$DCS_Latency ms</td> <td $DCS_PortColor style='padding: 5px;' align=center>$DCS_Port</td> <td style='padding: 5px;' align=center></td>$Blocking</tr>"
    }
}

# HTML Generation
if ($IaminRussia -eq 1)
{
    $BlockingHeaders = "<td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Is IP Blocked in Russia?</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Is Domain Blocked in Russia?</b></td>"
}

$Report = New-Object System.Collections.ArrayList
$Report.Add("<!DOCTYPE html><html><head><title>BlackBerry NOC Test</title><style>html * { font-family: Calibri}</style></head><body>")
$Report.Add("<h1>Result</h1>")
$Report.Add("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse;'>")
$Report.Add("<tr><td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Server</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>CNAME</b></td><td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>IP</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Ping</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Telnet</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Special URL check</b></td>$BlockingHeaders</tr>")
$Report.Add("<tr><td colspan='100%' bgcolor='#B7F0FA' style='padding: 5px;' align=center>BlackBerry NOC Servers</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center><b>$Server1Name</b></td> <td style='padding: 5px;' align=center>$Server1CNAME</td><td style='padding: 5px;' align=center>$Server1IP</td> <td $Server1Latencycolor style='padding: 5px;' align=center>$Server1Latency ms</td> <td $Server1PortColor style='padding: 5px;' align=center>$Server1Port</td> <td $Server1URLcolor style='padding: 5px;' align=center>$Server1URL</td>$Blocking1</tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center rowspan='2'><b>$Server2Name</b></td> <td style='padding: 5px;' align=center rowspan='2'>$Server2CNAME</td><td style='padding: 5px;' align=center rowspan='2'>$Server2IP</td> <td $Server2Latencycolor style='padding: 5px;' align=center rowspan='2'>$Server2Latency ms</td> <td $Server2PortColor style='padding: 5px;' align=center>$Server2Port</td> <td style='padding: 5px;' align=center rowspan='2'></td> $Blocking2</tr>")
$Report.Add("<tr><td $Server2PortColor2 style='padding: 5px;' align=center>$Server2Port2</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center rowspan='2'><b>$Server3Name</b></td> <td style='padding: 5px;' align=center rowspan='2'>$Server3CNAME</td><td style='padding: 5px;' align=center rowspan='2'>$Server3IP</td> <td $Server3Latencycolor style='padding: 5px;' align=center rowspan='2'>$Server3Latency ms</td> <td $Server3PortColor style='padding: 5px;' align=center>$Server3Port</td> <td $Server3URLcolor style='padding: 5px;' align=center rowspan='2'>$Server3URL</td>$Blocking3</tr>")
$Report.Add("<tr><td $Server3PortColor2 style='padding: 5px;' align=center>$Server3Port2</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center><b>$Server4Name</b></td> <td style='padding: 5px;' align=center>$Server4CNAME</td><td style='padding: 5px;' align=center>$Server4IP</td> <td $Server4Latencycolor style='padding: 5px;' align=center>$Server4Latency ms</td> <td $Server4PortColor style='padding: 5px;' align=center>$Server4Port</td> <td style='padding: 5px;' align=center></td>$Blocking4</tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center><b>$Server5Name</b></td> <td style='padding: 5px;' align=center>$Server5CNAME</td><td style='padding: 5px;' align=center>$Server5IP</td> <td $Server5Latencycolor style='padding: 5px;' align=center>$Server5Latency ms</td> <td $Server5PortColor style='padding: 5px;' align=center>$Server5Port</td> <td style='padding: 5px;' align=center></td>$Blocking5</tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center><b>$Server6Name</b></td> <td style='padding: 5px;' align=center>$Server6CNAME</td><td style='padding: 5px;' align=center>$Server6IP</td> <td $Server6Latencycolor style='padding: 5px;' align=center>$Server6Latency ms</td> <td $Server6PortColor style='padding: 5px;' align=center>$Server6Port</td> <td style='padding: 5px;' align=center></td>$Blocking6</tr>")
$Report.Add("<tr><td colspan='100%' bgcolor='#B7F0FA' style='padding: 5px;' align=center>BlackBerry Website</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align=center rowspan='2'><b>$Server7Name</b></td> <td style='padding: 5px;' align=center rowspan='2'>$Server7CNAME</td><td style='padding: 5px;' align=center>$Server7IP1</td> <td $Server7Latencycolor1 style='padding: 5px;' align=center>$Server7Latency1 ms</td> <td $Server7PortColor1 style='padding: 5px;' align=center>$Server7Port1</td> <td style='padding: 5px;' align=center rowspan='2'></td>$Blocking71</tr>")
$Report.Add("<tr><td style='padding: 5px;' align=center>$Server7IP2</td> <td $Server7Latencycolor2 style='padding: 5px;' align=center>$Server7Latency2 ms</td> <td $Server7PortColor2 style='padding: 5px;' align=center>$Server7Port2</td> $Blocking72</tr>")
if ($DirectConnectServers -ne $null) {
    $Report.Add("<tr><td colspan='100%' bgcolor='#B7F0FA' style='padding: 5px;' align=center>Direct Connect Servers</td></tr>")
    $Report.Add($DirectConnectHTML)
}
$Report.Add("</table>")
$Report.Add("<h1>Internet Connection</h1>")
$Report.Add("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse;'>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>External IP</td><td style='padding: 5px;'>$MyExternalIP</td>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>LAN Adapters</td><td style='padding: 5px;'>$MyLANAdaters</td>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>DNS Servers</td><td style='padding: 5px;'>$MyDNSServers</td>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>Average latency to router</td><td style='padding: 5px;'>$MyLatencyToRouter ms</td>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>Traceroute to blackberry.com</td><td style='padding: 5px;'>$MyTraceRoute</td>")
$Report.Add("</table></body></html>")


Add-Content $HTMLReportFile $Report
Invoke-Item $HTMLReportFile