# Script: BlackBerry NOC Test
# Version: 5 (14.11.2019)
# Blog: https://itgeeknotes.blogspot.com

Remove-Variable * -ErrorAction SilentlyContinue

###############################################################################################

# VARIABLES #
$version = 5
$date = (get-date).tostring("yyyy-MM-dd_HH-mm-ss")
$title = "BlackBerry NOC Test | Version $version | " + (get-date).tostring("yyyy.MM.dd HH:mm:ss")

$path = "C:/temp/BlackBerryNOCTest"
$HTMLReportFile = "$path/BlackBerryNOCTestReport_$date.html"

$country = "ru"                                                            # <<<<<< 'ca' = Canada | 'ru' = Russia | 'us' = United States only (US)
$ShowBlocking = "yes"                                                      # <<<<<< Set 'yes' if you want to check blocking IP and domain in Russia.
$ShowPush = "no"                                                           # <<<<<< Set 'yes' if you want to see Push Notification servers (a lot).
$ShowCloud = "no"                                                          # <<<<<< Set 'yes' if you want to see BlackBerry UEM Cloud servers.
$ShowDirectConnect = "no"                                                  # <<<<<< Set 'yes' if you want to set dedicated BlackBerry Direct Connect servers.
$ShowBlackberryConnectivityNode = "yes"                                    # <<<<<< Set 'yes' if you want to see BlackBerry Connectivity Nodes.
$ShowBlackberrySite = "yes"                                                # <<<<<< Set 'yes' if you want to see BlackBerry site.
$ShowBEMS = "yes"                                                          # <<<<<< Set 'yes' if you want to see which serevers needed for BlackBerry Enterprise Mobility Server (BEMS).


# SERVERS #
$BlackBerryServers = @(
    [PSCustomObject]@{Type = "BlackBerry Dynamics NOC" ; Name = "gdweb.good.com";  Port1 = "443"; Port2 = ""; URL = "https://gdweb.good.com/depot/upload/"; Description = "BlackBerry Control, BlackBerry Proxy, BlackBerry Enterprise Mobility Server (BEMS) (Starting with BlackBerry UEM version 12.6)"}
    [PSCustomObject]@{Type = "BlackBerry Dynamics NOC" ; Name = "gdrelay.good.com";  Port1 = "443"; Port2 = "15000"; URL = ""; Description = "BlackBerry Proxy (Starting with BlackBerry UEM version 12.6)"}
    [PSCustomObject]@{Type = "BlackBerry Dynamics NOC" ; Name = "gdmdc.good.com";  Port1 = "443"; Port2 = "49152"; URL = "https://gdmdc.good.com/depot/upload/"; Description = "BlackBerry Control, BlackBerry Proxy, Application Servers (Starting with BlackBerry UEM version 12.6)"}
    [PSCustomObject]@{Type = "BlackBerry Dynamics NOC" ; Name = "gdentgw.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "BlackBerry Proxy (Starting with BlackBerry UEM version 12.6)"}
    # [PSCustomObject]@{Type = "BlackBerry NOC" ; Name = "bxenroll.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "BlackBerry Control (Starting with BlackBerry UEM version 12.6)"}      <--- The server bxenroll.good.com (http://bxenroll.good.com) has now been taken offline and is no longer required.
    # [PSCustomObject]@{Type = "BlackBerry NOC" ; Name = "bxcheckin.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "BlackBerry Dynamics Applications"}
    if ($ShowBEMS -eq "yes") {
        [PSCustomObject]@{Type = "BlackBerry Enterprise Mobility Server" ; Name = "login.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "Upload logs"}
        [PSCustomObject]@{Type = "BlackBerry Enterprise Mobility Server" ; Name = "gwupload.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "Upload logs"}
        [PSCustomObject]@{Type = "BlackBerry Enterprise Mobility Server" ; Name = "gwmonitor.good.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "Upload BEMS statistics to the BlackBerry Dynamics NOC"}
    }
    if ($ShowBlackberryConnectivityNode -eq "yes") {
        [PSCustomObject]@{Type = "BlackBerry Connectivity Node" ; Name = "$country.srp.blackberry.com";  Port1 = "3101"; Port2 = ""; URL = ""; Description = "Affinity Manager / Dispatcher"}
        [PSCustomObject]@{Type = "BlackBerry Connectivity Node" ; Name = "$country.bbsecure.com";  Port1 = "443"; Port2 = "3101"; URL = ""; Description = "BlackBerry Connectivity Node (Starting with BES12 version 12.5)"}
        [PSCustomObject]@{Type = "BlackBerry Connectivity Node" ; Name = "$country.turnb.bbsecure.com";  Port1 = "3101"; Port2 = ""; URL = ""; Description = "BlackBerry Secure Connect Plus (Starting with BES12 version 12.2)"}
        [PSCustomObject]@{Type = "BlackBerry Connectivity Node" ; Name = "api.samsungapps.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "BlackBerry Secure Connect Plus (Starting with BES12 version 12.2) - only if Knox Workspace is used *"}
    }
    if ($ShowDirectConnect -eq "yes") {
        [PSCustomObject]@{Type = "Direct Connect" ; Name = "gdweb.good.com";  Port1 = "17433"; Port2 = ""; URL = ""; Description = "Direct Connect Server #1"}     # <<<<<< Set your BlackBerry Direct Connect servers name.
        [PSCustomObject]@{Type = "Direct Connect" ; Name = "gdrelay.good.com";  Port1 = "17433"; Port2 = ""; URL = ""; Description = "Direct Connect Server #2"}   # <<<<<< Set your BlackBerry Direct Connect servers name.
    }
    if ($ShowBlackberrySite -eq "yes") {
        [PSCustomObject]@{Type = "BlackBerry Website" ; Name = "blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "Official site"}
    }
    if ($ShowPush -eq "yes") {
        [PSCustomObject]@{Type = "Push Notification" ; Name = "gateway.push.apple.com";  Port1 = "5223"; Port2 = "2195"; URL = ""; Description = "Apple iOS"}
        [PSCustomObject]@{Type = "Push Notification" ; Name = "fcm.googleapis.com";  Port1 = "5228"; Port2 = "5229"; URL = ""; Description = "Android (Google Firebase Cloud Messaging)"}
        [PSCustomObject]@{Type = "Push Notification" ; Name = "fcm-xmpp.googleapis.com";  Port1 = "5228"; Port2 = "5229"; URL = ""; Description = "Android (Google Firebase Cloud Messaging)"}
    }
    if ($ShowCloud -eq "yes") {
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p05002.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "USA"}
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p07002.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "EMEA"}
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p07003.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "EMEA"}
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p11002.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "Americas"}
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p12002.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "APAC"}
        [PSCustomObject]@{Type = "BlackBerry UEM Cloud" ; Name = "p12003.cp1.uem.blackberry.com";  Port1 = "443"; Port2 = ""; URL = ""; Description = "APAC"}
    }
)

###############################################################################################

# Create folder for report
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

# FUNCTIONS
function GetBlock
{
	Param ([string]$block_req)
	$block_result = (Invoke-WebRequest -Uri "http://api.antizapret.info/get.php?item=$block_req&type=small" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).Content
    if ($block_result -eq 0) {$block_result = "no"} else {$block_result = "yes"}
	return $block_result
}

function GetCNAME
{
	Param ([string]$cname_req)
	$cname_result = (Resolve-DnsName -Name $cname_req -Type CNAME -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).NameHost
	return $cname_result
}

function GetIP
{
	Param ([string]$ip_req)
	$ip_result = (Resolve-DnsName -Name $ip_req -Type A -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).IP4Address
	return $ip_result
}

function GetLatency
{
	Param ([string]$latency_req)
    $Intermediate_result = Test-Connection -IPAddress $latency_req -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Count 2
    if ($Intermediate_result -ne $null) {
	    $latency_result = [math]::Round(($Intermediate_result | Measure-Object -Property ResponseTime -Average).Average)
    }
    else
    {
        $latency_result = "error"
    }
	return $latency_result
}

function GetPort
{
	Param ([string]$GetPort_ip, [string]$GetPort_port)
	$GetPort_result = (Test-NetConnection -Port $GetPort_port -ComputerName $GetPort_ip -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded
    $GetPort_result = $GetPort_port + " - " + $GetPort_result
	return $GetPort_result
}

function GetURL
{
	Param ([string]$GetURL_req)
	$GetURL_result = (Invoke-WebRequest -Uri $GetURL_req -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).Content
	return $GetURL_result
}

$MyExternalIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).Content
$MyLANAdaters = Get-NetAdapter -physical | where status -eq 'up'
$MyDNSServers = ((Get-DnsClientServerAddress -InterfaceIndex $MyLANAdaters.InterfaceIndex -AddressFamily IPv4 | select ServerAddresses).ServerAddresses | Out-String).replace("`r`n","<br>")
$MyLANAdaters = ((((($MyLANAdaters | fl Name,InterfaceDescription,Status,LinkSpeed | Out-String).replace("`r`n","<br>")).replace("<br><br><br><br>","")).replace("<br><br><br>","")).replace("<br><br>","")).replace("<br>Name","")
$MyLatencyToRouter = (Test-Connection (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Count 2 | Measure-Object -Property ResponseTime -Average).Average
$MyTraceRoute = ((((Test-NetConnection "blackberry.com" -traceroute | fl | Out-String).replace("`r`n","<br>")).replace("<br><br><br><br>","")).replace("<br><br><br>","")).replace("<br><br>","")

# HTML Generation
if ($ShowBlocking -eq "yes")
{
    $BlockingHeaders = "<td bgcolor='#69B7C8' style='padding: 5px;' align=center width=150><b>Is IP Blocked in Russia?</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align=center><b>Is Domain Blocked in Russia?</b></td>"
}

$Report = New-Object System.Collections.ArrayList
$Report.Add("<!DOCTYPE html><html><head><title>BlackBerry NOC Test</title><style>html * { font-family: Calibri}; table, tr, td {border-collapse: collapse; border: 1px solid;}; .style1 {border-collapse: collapse; border: 0px solid;}</style></head><body>")
$Report.Add("<h1>$title</h1>")
$Report.Add("<table border='1' cellpadding='0' cellspacing='0'>")
$Report.Add("<tr><td bgcolor='#69B7C8' style='padding: 5px;' align='center'><b>Server</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align='center'><b>CNAME</b></td><td bgcolor='#69B7C8' style='padding: 5px;' align='center' width='150'><b>IP</b></td><td bgcolor='#69B7C8' style='padding: 5px;' align='center' width='150'><b>Ping</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align='center' width='150'><b>Port</b></td> $BlockingHeaders <td bgcolor='#69B7C8' style='padding: 5px;' align='center'><b>Depot URL</b></td> <td bgcolor='#69B7C8' style='padding: 5px;' align='center'><b>Description</b></td></tr>")

foreach ($server in $BlackBerryServers) {
    # Clean variables
    $ServerURLcolor = ""; $ServerURL = ""; $ServerPort1 = ""; $ServerPort2 = ""; $ServerBlockIP = ""; $ServerBlockDomain = ""; $ServerBlockIPcolor = ""; $ServerBlockDomainColor = ""; $Blocking = ""; $ServerLatencycolor = ""; $ServerPortColor1 = ""; $ServerPortColor2 = ""; $PortRowSpan = "";

    if ($PreviousTitle -ne $server.Type) {
        $ServerType = $server.Type
        $Report.Add("<tr><td colspan='100%' bgcolor='#B7F0FA' style='padding: 5px;' align=center>$ServerType</td></tr>")
        $PreviousTitle = $server.Type
    }

    if ($ShowBlocking -eq "yes")
    {
        #$Blocking = "<td $ServerBlockDomainColor style='padding: 5px;' align=center>$ServerBlockDomain</td>";
        $IPRowspan = "colspan=4"
    }
    else {$IPRowspan = "colspan=3"}

    if ($server.Port2 -ne "") {$PortRowSpan = "rowspan='2'"} else {$PortRowSpan = ""}

    $ServerName = $server.Name
    $ServerCNAME = GetCNAME -cname_req $server.Name
    
    # IP & ping
    $ServerIP = GetIP -ip_req $server.Name    

    $ReportSummUP = New-Object System.Collections.ArrayList
    $ReportSummUP.Add("<td $IPRowspan style='padding: 0px;' align=center><table class='style1' style='padding: 0px; height:100%; border: none;' border='0' cellpadding='0' cellspacing='0' width='100%' height='100%'>")
    
    # If server has several IP
    foreach ($ip in $ServerIP)
    {
        $ServerLatencycolor = ""; $ServerPortColor1 = ""; $ServerPortColor2 = ""; $ServerURLcolor = ""; $ServerLatency = ""
        
        # Add IP
        $ReportSummUP.Add("<tr><td $PortRowSpan style='padding: 5px; border-right: solid 1px;' align=center width=150>$ip</td>")

        # Add ping / latency
        $ServerLatency = GetLatency -latency_req $ip
        if (($ServerLatency -eq "error") -or ($ServerLatency -eq $null))
        {
            $ReportSummUP.Add("<td $PortRowSpan bgcolor='#F84A42' style='padding: 5px;border-right: solid 1px;' align=center width=150>ERROR</td>")
        }
        else
        {
            if ($ServerLatency -ge 100) {$ServerLatencycolor = "bgcolor='#F6F675'"}
            if ($ServerLatency -ge 200) {$ServerLatencycolor = "bgcolor='#F84A42'"}
            $ReportSummUP.Add("<td  $PortRowSpan $ServerLatencycolor style='padding: 5px; border-right: solid 1px;' align=center width=150>$ServerLatency ms</td>")
        }

        # telnet / port
        if ($server.Port1 -ne "") {
            $ServerPort1 = GetPort -GetPort_ip $ip -GetPort_port $server.Port1
            if ($ServerPort1 -like "*FALSE") {$ServerPortColor1 = "bgcolor='#F84A42'"}
            $ReportSummUP.Add("<td $ServerPortColor1 style='padding: 5px;' align=center width=150>:$ServerPort1</td>")
        }

        # Blocking
        if ($ShowBlocking -eq "yes" )
        {
            $ServerBlockIP = GetBlock -block_req $ServerIP
            $ServerBlockDomain = GetBlock -block_req $server.Name
            $Blocking = "<td $ServerBlockDomainColor style='padding: 5px;' align=center>$ServerBlockDomain</td>";
            if ($ServerBlockIP -eq "yes") {$ServerBlockIPcolor = "bgcolor='#F84A42'"}
            if ($ServerBlockDomain -eq "yes") {$ServerBlockDomainColor = "bgcolor='#F84A42'"}
            $ReportSummUP.Add("<td $PortRowSpan $ServerBlockIPcolor style='padding: 5px; border-left: solid 1px' align=center width=150>$ServerBlockIP</td></tr>")
        }

        if ($server.Port2 -ne "") {
            $ServerPort2 = GetPort -GetPort_ip $ip -GetPort_port $server.Port2
            if ($ServerPort2 -like "*FALSE") {$ServerPortColor2 = "bgcolor='#F84A42'"}
            $ReportSummUP.Add("<tr><td $ServerPortColor2 style='padding: 5px;' align=center width=150>:$ServerPort2</td></tr>")
        }
    }
    $ReportSummUP.Add("</table></td>")
    $ServerIPHTML = $ReportSummUP
    
    #URL
    if ($server.URL -ne "") {
        $ServerURL = GetURL -GetURL_req $server.URL
        if ($ServerURL -notlike "*Yes, I am alive*") {$ServerURL = ":"; $ServerURLcolor = "bgcolor='#F84A42'"} else {$ServerURL = "Yes, I am alive";}
    }
    else {$ServerURL = "-"}

    $ServerDescription = $server.Description
    
    $Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;' align='center'><b>$ServerName</b></td> <td style='padding: 5px;' align='center'>$ServerCNAME</td> $ServerIPHTML $Blocking<td $ServerURLcolor style='padding: 5px;' align='center'>$ServerURL</td><td style='padding: 5px;' align='center'>$ServerDescription</td></tr>")
}

$Report.Add("</table>")
$Report.Add("<h1>Internet Connection</h1>")
$Report.Add("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse;'>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>External IP</td><td style='padding: 5px;'>$MyExternalIP</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>LAN Adapters</td><td style='padding: 5px;'>$MyLANAdaters</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>DNS Servers</td><td style='padding: 5px;'>$MyDNSServers</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>Average latency to router</td><td style='padding: 5px;'>$MyLatencyToRouter ms</td></tr>")
$Report.Add("<tr><td bgcolor='#7FCEDF' style='padding: 5px;'>Traceroute to blackberry.com</td><td style='padding: 5px;'>$MyTraceRoute</td></tr>")
$Report.Add("</table></body></html>")

Add-Content $HTMLReportFile $Report
Invoke-Item $HTMLReportFile