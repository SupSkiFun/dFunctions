using module ./dClass.psm1

<#
.SYNOPSIS
Retrieves items from Dell ME4024
.DESCRIPTION
Retrieves items from Dell ME4024 via REST API
.PARAMETER Credential
PSCredential of SAN User and Password.  Use $MyCreds = Get-Credential.  See Examples.
.PARAMETER Uri
HTTPS URI for the SAN.  Example:  https://MySAN.MyDomain.Org
.PARAMETER Item
SAN Item to query.  Defaults to 'system'.  Tab through or type a valid selection if preferred:
configuration,controllers,disks,dns-parameters,email-parameters,enclosures,events,host-groups,
maps,network-parameters,ntp-status,service-tag-info,system,vdisks,versions, or volumes.
.NOTES
1. Item 'configuration' returns a large object of multiple properties.
2. Item defaults to 'system'.  Tab through or type a valid selection if preferred:
configuration,controllers,disks,dns-parameters,email-parameters,enclosures,events,host-groups,
maps,network-parameters,ntp-status,service-tag-info,system,vdisks,versions, or volumes.
3. Limited error handling.  A future update will be more robust.
4. HTTPS certificate checking is disabled.
.EXAMPLE
Retrieve default output (system):

$u = https://MySAN.MyDomain.Org
$MyCreds = Get-Credential -UserName SanUser     <Enter Password>
$MyVar = Show-SANItem -Credential $MyCreds -Uri $u
.EXAMPLE
Retrieve vdisks output:

$u = https://MySAN.MyDomain.Org
$MyCreds = Get-Credential -UserName SanUser     <Enter Password>
$MyVar = Show-SANItem -Credential $MyCreds -Uri $u -Item vdisks
.EXAMPLE
Retrieve configuration output (lots of info):

$u = https://MySAN.MyDomain.Org
$MyCreds = Get-Credential -UserName SanUser     <Enter Password>
$MyVar = Show-SANItem -Credential $MyCreds -Uri $u -Item configuration
#>

function Show-SANItem
{
    [cmdletbinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $true , ValueFromPipeline = $true)]
        [Uri] $Uri,

        [Parameter(Mandatory = $False)]
        [ValidateSet('configuration','controllers','disks','dns-parameters','email-parameters','enclosures','events',
        'host-groups','maps','network-parameters','ntp-status','service-tag-info','system','vdisks','versions','volumes')]
        [string] $Item = 'system'  
    )

    Begin
    {
        if ( ([uri] $uri).IsAbsoluteUri -eq $false )
        {
            Write-Output "Terminating.  Non-valid URL detected.  Submitted URL:  $uri"
            break
        }

        $headers = [dSAN]::headers
        $session_key = [dSAN]::GetSessionString($uri, $credential, $headers)

        if ($($session_key.status) -eq "Error")
        {
            Write-Output $([dSAN]::mesg1)`n$($session_key.info.status)
            break
        }
        elseif (-not $(($session_key.status)))
        {
            $mesg3 = [dSAN]::mesg2,$uri.AbsoluteUri -join "  "
            Write-Output $mesg3
            break
        }
    }

    Process
    {
        $headers.'sessionKey' = $($session_key.info)
        $item_info = [dSAN]::GetItem($uri,$item,$headers)
        if ($item -eq 'configuration') 
        { 
            $item_info
        }
        else
        {
            $item_info.$([dSAN]::items.$item)
        }
    }
}