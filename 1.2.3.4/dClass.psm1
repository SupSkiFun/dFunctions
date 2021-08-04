class dSAN
{
    static $uri_login = 'api/login/'
    static $uri_show = 'api/show/'
    static $headers = @{'datatype'='json'}
    static $mesg1 = 'Terminating.  Login Unsuccessful.'
    static $mesg2 = 'Terminating.  Error Accessing:'

    # hashtable is key=api-all-word - value=json-object-key.  They don't always match.
    static $items = @{
        'controllers' = 'controllers';
        'disks' = 'drives' ;
        'dns-parameters' = 'dns-parameters';
        'email-parameters' = 'email-parameters' ;
        'enclosures' = 'enclosures' ;
        'events' = 'events' ;
        'host-groups' = 'host-group' ;
        'maps' = 'volume-view' ;
        'network-parameters' = 'network-parameters' ;
        'ntp-status' = 'ntp-status' ;
        'service-tag-info' = 'service-tag-info' ;
        'system' = 'system' ;
        'vdisks' = 'virtual-disks' ;
        'versions' = 'versions' ;
        'volumes' = 'volumes'
    }

    static [hashtable] GetSessionString ([uri] $uri, [PsCredential] $credential, [hashtable] $headers)
    {
        $auth_hash = [dSAN]::MakeAuthString($credential)
        $cred_info = [dSAN]::GetCreds($uri,$auth_hash,$headers)
        if ($cred_info.status.'response-type' -match 'Error')
        {
            return @{'status'='Error';'info'=$cred_info}
        }
        return @{'status'='OK';'info'=$cred_info.status.response}
    }
    
    static [string] MakeAuthString([PSObject] $Credential)
    {
        $user = $Credential.UserName
        $pswd = $Credential.GetNetworkCredential().Password
        $stringAsStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stringAsStream)
        $writer.write($user+"_"+$pswd)
        $writer.Flush()
        $stringAsStream.Position = 0
        $auth_hash = ((Get-FileHash -InputStream $stringAsStream -Algorithm SHA256).Hash).ToLower()
        return $auth_hash
    }

    static [psobject] GetCreds ([string] $uri, [string] $auth_hash, [hashtable] $headers)
    {
        # Needs Try / Catch
        $uric = $uri + [dSAN]::uri_login + $auth_hash
        $cred_info = Invoke-RestMethod -Uri $uric -SkipCertificateCheck -Headers $headers
        return $cred_info
    }

    static [psobject] GetItem ([string] $uri, [string] $item, [hashtable] $headers)
    {
        # Needs Try / Catch
        $urii = $uri + [dSAN]::uri_show + $item
        $resp2 = Invoke-RestMethod -Uri $urii -SkipCertificateCheck -Headers $headers
        return $resp2
    }
}