using module ./dClass.psm1

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
        [string] $Item = "system"   
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
        if ($($session_key.status) -match "Error")
        {
            Write-Output $([dSAN]::mesg1)`n$($session_key.info.status)
            break
        }
    }

    Process
    {
        $headers.'sessionKey' = $($session_key.info)
        $item_info = [dSAN]::GetItem($uri,$item,$headers)
        # Error Check Here

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