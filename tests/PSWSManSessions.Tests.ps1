BeforeDiscovery {
    . ([IO.Path]::Combine($PSScriptRoot, 'common.ps1'))
}

BeforeAll {
    if ($PSWSManSettings.CACert -and -not $IsMacOS) {
        $location = if ($IsWindows) {
            [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
        }
        else {
            [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser
        }
        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new(
            [System.Security.Cryptography.X509Certificates.StoreName]::Root,
            $location,
            [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        try {
            $store.Add($PSWSManSettings.CACert)
        }
        finally {
            $store.Dispose()
        }
    }
}

AfterAll {
    if ($PSWSManSettings.CACert -and -not $IsMacOS) {
        $location = if ($IsWindows) {
            [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
        }
        else {
            [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser
        }
        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new(
            [System.Security.Cryptography.X509Certificates.StoreName]::Root,
            $location,
            [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        try {
            $store.Remove($PSWSManSettings.CACert)
        }
        finally {
            $store.Dispose()
        }
    }
}

Describe "PSWSMan Connection tests" -Skip:(-not $PSWSManSettings.GetScenarioServer('default')) {
    It "Connects over HTTP with <AuthMethod>" -TestCases @(
        @{AuthMethod = "Negotiate" }
        @{AuthMethod = "Ntlm" }
        @{AuthMethod = "CredSSP" }
    ) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod $AuthMethod

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Negotiate - Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Negotiate - NTLM" -Skip:(-not $PSWSManSettings.GetScenarioServer('local_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('local_auth')

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with CredSSP + Negotiate - Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.Authentication = 'Credssp'

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with CredSSP + Keberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod CredSSP -CredSSPAuthMethod Kerberos

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with CredSSP + Negotiate - NTLM" -Skip:(-not $PSWSManSettings.GetScenarioServer('local_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('local_auth')
        $sessionParams.Authentication = 'Credssp'

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with CredSSP + NTLM" -Skip:(-not $PSWSManSettings.GetScenarioServer('local_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('local_auth')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod CredSSP -CredSSPAuthMethod NTLM

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Devolutions <AuthMethod>" -TestCases @(
        @{AuthMethod = "Negotiate" }
        @{AuthMethod = "Ntlm" }
        # @{AuthMethod = "CredSSP" }  # https://github.com/Devolutions/sspi-rs/issues/84
    ) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod $AuthMethod -AuthProvider Devolutions

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Devolutions Negotiate - Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthProvider Devolutions

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Devolutions Negotiate - NTLM" -Skip:(-not $PSWSManSettings.GetScenarioServer('local_auth')) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('local_auth')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthProvider Devolutions

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Fails to connect over HTTP with Basic without -NoEncryption" {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod Basic

        { New-PSSession @sessionParams } | Should -Throw '*Cannot encrypt WSMan payload as BasicAuthContext does not support message encryption*'
    }

    It "Connects over HTTP with Basic" -Skip:(-not $PSWSManSettings.GetScenarioServer('local_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('local_auth') -ForBasicAuth
        $sessionParams.SessionOption = New-PSWSManSessionOption -NoEncryption

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.Authentication = 'Kerberos'

        $s = New-PSSession @sessionParams -Authentication Kerberos
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTP with Devolutions Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.Authentication = 'Kerberos'
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthProvider Devolutions

        $s = New-PSSession @sessionParams -Authentication Kerberos
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over CredSSP with handshake failure" {
        $tlsOption = [System.Net.Security.SslClientAuthenticationOptions]@{
            EnabledSslProtocols = 'Ssl3'
            TargetHost = $sessionParams.ComputerName
            RemoteCertificateValidationCallback = New-PSWSManCertValidationCallback { $true }
        }

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.Authentication = 'Credssp'
        $sessionParams.SessionOption = New-PSWSManSessionOption -CredSSPTlsOption $tlsOption

        $out = New-PSSession @sessionParams -ErrorAction SilentlyContinue -ErrorVariable err
        $out | Should -BeNullOrEmpty
        $err.Count | Should -Be 1

        $expected = if ($IsWindows) {
            'CredSSP authentication failure during the stage TlsHandshake'
        }
        else {
            'WinRM authentication failure - server did not response to token during the stage TlsHandshake'
        }
        [string]$err[0] | Should -BeLike "*$expected*"
    }

    It "Connects with invalid credential" {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.Authentication = 'Basic'
        $sessionParams.Credential = [PSCredential]::new('fake', (ConvertTo-SecureString -AsPlainText -Force -String 'fake'))
        $sessionParams.SessionOption = New-PSWSManSessionOption -NoEncryption

        $out = New-PSSession @sessionParams -ErrorAction SilentlyContinue -ErrorVariable err
        $out | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        [string]$err[0] | Should -BeLike '*WinRM authentication failure*'
    }

    It "Connects with invalid hostname and timeout" {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.Port = 12658
        $sessionParams.SessionOption = New-PSWSManSessionOption -OpenTimeout 1 -NoEncryption
        $out = New-PSSession @sessionParams -ErrorAction SilentlyContinue -ErrorVariable err
        $out | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        [string]$err[0] | Should -BeLike '*A connection could not be established within the configured ConnectTimeout*'
    }

    It "Connects over HTTPS with <AuthMethod>" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_trusted')) -TestCases @(
        @{AuthMethod = "Negotiate" }
        @{AuthMethod = "Ntlm" }
        @{AuthMethod = "CredSSP" }
    ) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
        $sessionParams.UseSSL = $true
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod $AuthMethod

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with Devolutions <AuthMethod>" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_trusted')) -TestCases @(
        @{AuthMethod = "Negotiate" }
        @{AuthMethod = "Ntlm" }
        # @{AuthMethod = "CredSSP" }  # https://github.com/Devolutions/sspi-rs/issues/84
    ) {
        param ($AuthMethod)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
        $sessionParams.UseSSL = $true
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthMethod $AuthMethod -AuthProvider Devolutions

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with Basic" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_local_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_local_auth') -ForBasicAuth
        $sessionParams.UseSSL = $true

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_domain_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_domain_auth')
        $sessionParams.UseSSL = $true
        $sessionParams.Authentication = 'Kerberos'

        $s = New-PSSession @sessionParams -Authentication Kerberos
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with Devolutions Kerberos" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_domain_auth')) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_domain_auth')
        $sessionParams.UseSSL = $true
        $sessionParams.Authentication = 'Kerberos'
        $sessionParams.SessionOption = New-PSWSManSessionOption -AuthProvider Devolutions

        $s = New-PSSession @sessionParams -Authentication Kerberos
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with CBT hash <HashType>" -TestCases @(
        @{HashType = "sha1" }
        @{HashType = "sha256" }
        @{HashType = "sha256_pss" }
        @{HashType = "sha384" }
        @{HashType = "sha512" }
        @{HashType = "sha512_pss" }
    ) {
        param ($HashType)

        $server = $PSWSManSettings.GetScenarioServer("https_$HashType")
        if (-not $server) {
            Set-ItResult -Skipped -Because "scenario host for https_$HashType not defined in settings"
        }

        $sessionParams = Get-PSSessionSplat -Server $server
        $sessionParams.UseSSL = $true

        if ($IsMacOS -and $HashType -eq 'sha1') {
            # macOS doesn't trust SHA1 signed certs now
            $sessionParams.SessionOption = New-PSWSManSessionOption -SkipCNCheck
        }
        if ($IsMacOS -and $HashType.EndsWith('_pss')) {
            # macOS doesn't trust RSA-PSS cert chains
            $sessionParams.SessionOption = New-PSWSManSessionOption -SkipCACheck
        }

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with invalid cert - <Method>" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_untrusted')) -TestCases @(
        @{Method = "Skip" }
        @{Method = "TlsOption" }
    ) {
        param ($Method)

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_untrusted')
        $sessionParams.UseSSL = $true

        $out = New-PSSession @sessionParams -ErrorAction SilentlyContinue -ErrorVariable err
        $out | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        [string]$err[0] | Should -BeLike '*The remote certificate is invalid because of errors in the certificate chain: UntrustedRoot*'

        $psoParams = @{}
        if ($Method -eq 'Skip') {
            $psoParams.SkipCACheck = $true
            $psoParams.SkipCNCheck = $true
        }
        else {
            $tlsOption = [System.Net.Security.SslClientAuthenticationOptions]@{
                TargetHost = $sessionParams.ComputerName
                RemoteCertificateValidationCallback = New-PSWSManCertValidationCallback { $true }
            }
            $psoParams.TlsOption = $tlsOption
        }
        $sessionParams.SessionOption = New-PSWSManSessionOption @psoParams

        $s = New-PSSession @sessionParams
        try {
            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with Certificate auth by thumbprint" -Skip:(
        # macOS doesn't let you import into the My store without user interaction
        # Cert auth is tested below on macOS through the cert object
        $IsMacOS -or
        -not $PSWSManSettings.GetScenarioServer('https_trusted') -or
        -not $PSWSManSettings.ClientCertificate
    ) {
        if ($IsLinux -and [Environment]::Version -lt [Version]'7.0') {
            Set-ItResult -Skipped -Because "Cert auth on Linux over TLS 1.3 only supported since dotnet 7.0"
        }

        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new(
            [System.Security.Cryptography.X509Certificates.StoreName]::My,
            [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser,
            [System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        try {
            $store.Add($PSWSManSettings.ClientCertificate)

            $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
            $sessionParams.Remove('Credential')
            $sessionParams.UseSSL = $true
            $sessionParams.CertificateThumbprint = $PSWSManSettings.ClientCertificate.Thumbprint

            $s = New-PSSession @sessionParams
            try {
                $s.ComputerName | Should -Be $sessionParams.ComputerName
                $s.State | Should -Be 'Opened'
                $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
            }
            finally {
                $s | Remove-PSSession
            }

            $s.State | Should -Be 'Closed'
        }
        finally {
            $store.Remove($PSWSManSettings.ClientCertificate)
            $store.Dispose()
        }
    }

    It "Failed to find certificate thumbprint" {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
        $sessionParams.Remove('Credential')
        $sessionParams.UseSSL = $true
        $sessionParams.CertificateThumbprint = '0000000000000000000000000000000000000000'

        {
            New-PSSession @sessionParams
        } | Should -Throw "*WinRM failed to find certificate with the thumbprint requested '0000000000000000000000000000000000000000'*"
    }

    It "Connects over HTTPS with Certificate auth by cert object" -Skip:(
        -not $PSWSManSettings.GetScenarioServer('https_trusted') -or
        -not $PSWSManSettings.ClientCertificate
    ) {
        if ($IsLinux -and [Environment]::Version -lt [Version]'7.0') {
            Set-ItResult -Skipped -Because "Cert auth on Linux over TLS 1.3 only supported since dotnet 7.0"
        }

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
        $sessionParams.Remove('Credential')
        $sessionParams.UseSSL = $true
        $sessionParams.SessionOption = New-PSWSManSessionOption -ClientCertificate $PSWSManSettings.ClientCertificate

        $s = New-PSSession @sessionParams
        try {

            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with cert auth and explicit TLS options" -Skip:(
        -not $PSWSManSettings.GetScenarioServer('https_trusted') -or
        -not $PSWSManSettings.ClientCertificate
    ) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
        $sessionParams.Remove('Credential')
        $sessionParams.UseSSL = $true

        $tlsOption = [System.Net.Security.SslClientAuthenticationOptions]@{
            TargetHost = $sessionParams.ComputerName
            RemoteCertificateValidationCallback = New-PSWSManCertValidationCallback { $true }
            ClientCertificates = [System.Security.Cryptography.X509Certificates.X509CertificateCollection]::new(
                @($PSWSManSettings.ClientCertificate))
        }

        if ($IsLinux -and [Environment]::Version -lt [Version]'7.0') {
            # Linux only supports post handshake cert auth on TLS 1.3 since dotnet 7. For older hosts restrict the
            # protocol to TLS 1.2 in this test.
            $tlsOption.EnabledSslProtocols = [System.Security.Authentication.SslProtocols]::Tls12
        }

        $sessionParams.SessionOption = New-PSWSManSessionOption -TlsOption $tlsOption

        $s = New-PSSession @sessionParams
        try {

            $s.ComputerName | Should -Be $sessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be 'Microsoft.PowerShell'
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects over HTTPS with handshake failure" -Skip:(-not $PSWSManSettings.GetScenarioServer('https_trusted')) {
        $tlsOption = [System.Net.Security.SslClientAuthenticationOptions]@{
            EnabledSslProtocols = 'Ssl3'
            TargetHost = $sessionParams.ComputerName
            RemoteCertificateValidationCallback = New-PSWSManCertValidationCallback { $true }
        }

        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('https_trusted')
        $sessionParams.UseSSL = $true
        $sessionParams.SessionOption = New-PSWSManSessionOption -TlsOption $tlsOption

        $out = New-PSSession @sessionParams -ErrorAction SilentlyContinue -ErrorVariable err
        $out | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        if ($IsMacOS) {
            [string]$err[0] | Should -BeLike '*Connection reset by peer*'
        }
        else {
            [string]$err[0] | Should -BeLike '*Authentication failed, see inner exception*'
        }

        # Unfortunately the true error is hidden deep within the stack, nothing we can do about that
        $expected = if ($IsWindows) {
            'The client and server cannot communicate, because they do not possess a common algorithm'
        }
        elseif ($IsMacOS) {
            'Connection reset by peer'
        }
        else {
            'SSL handshake failed'
        }
        $err[0].Exception.InnerException.InnerException.InnerException.Message | Should -BeLike "*$expected*"
    }
}

Describe "PSWSMan Kerberos tests" -Skip:(-not $PSWSManSettings.GetScenarioServer('domain_auth')) {
    It "Connects with implicit credential with Linux" -Skip:$IsWindows {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        Invoke-Kinit -Credential $sessionParams.Credential

        try {
            $sessionParams.Remove('Credential')

            $actual = Invoke-Command @sessionParams {
                klist.exe |
                    Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                    ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
            }
            $actual | Should -Not -Contain 'forwarded'
        }
        finally {
            kdestroy
        }
    }

    It "Connects with implicit forwardable credential with Linux" -Skip:$IsWindows {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        Invoke-Kinit -Credential $sessionParams.Credential -Forwardable

        try {
            $sessionParams.Remove('Credential')

            $actual = Invoke-Command @sessionParams {
                klist.exe |
                    Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                    ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
            }
            $actual | Should -Not -Contain 'forwarded'
        }
        finally {
            kdestroy
        }
    }

    It "Connects with implicit forwardable credential with delegation Linux" -Skip:$IsWindows {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        Invoke-Kinit -Credential $sessionParams.Credential -Forwardable

        try {
            $sessionParams.Remove('Credential')
            $sessionParams.SessionOption = (New-PSWSManSessionOption -RequestKerberosDelegate)

            $actual = Invoke-Command @sessionParams {
                klist.exe |
                    Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                    ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
            }
            $actual | Should -Contain 'forwarded'
        }
        finally {
            kdestroy
        }
    }

    It "Connects with implicit credentials with Windows" -Skip:(-not $IsWindows) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')
        $sessionParams.Remove('Credential')

        $actual = Invoke-Command @sessionParams {
            klist.exe |
                Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
        }
        $actual | Should -Not -Contain 'forwarded'
    }

    It "Connects with implicit credentials with Windows and delegate" -Skip:(
        -not $IsWindows -or
        -not $PSWSManSettings.GetScenarioServer('trusted_for_delegation')
    ) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('trusted_for_delegation')
        $sessionParams.Remove('Credential')
        $sessionParams.SessionOption = (New-PSWSManSessionOption -RequestKerberosDelegate)

        $actual = Invoke-Command @sessionParams {
            klist.exe |
                Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
        }
        $actual | Should -Contain 'forwarded'
    }

    It "Connects with explicit credentials with Windows" -Skip:(-not $IsWindows) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('domain_auth')

        $actual = Invoke-Command @sessionParams {
            klist.exe |
                Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
        }
        $actual | Should -Not -Contain 'forwarded'
    }

    It "Connects with explicit credentials with Windows and delegate" -Skip:(
        -not $IsWindows -or
        -not $PSWSManSettings.GetScenarioServer('trusted_for_delegation')
    ) {
        $sessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('trusted_for_delegation')
        $sessionParams.SessionOption = (New-PSWSManSessionOption -RequestKerberosDelegate)

        $actual = Invoke-Command @sessionParams {
            klist.exe |
                Select-String -Pattern 'Ticket Flags.*->\s*(.*)' |
                ForEach-Object { ($_.Matches.Groups[1].Value -split '\s+') -ne '' }
        }
        $actual | Should -Contain 'forwarded'
    }
}

Describe "PSWSMan Exchange Online tests" -Skip:(-not $PSWSManSettings.EXOConfiguration) {
    BeforeAll {
        $exoParams = @{
            Organization = $PSWSManSettings.EXOConfiguration.Organization
            AppId = $PSWSManSettings.EXOConfiguration.AppId
            UseRPSSession = $true
            ShowBanner = $false
        }
    }

    It "Connects using certificate" -Skip:(-not $PSWSManSettings.EXOConfiguration.Certificate) {
        Connect-ExchangeOnline @exoParams -Certificate $PSWSManSettings.EXOConfiguration.Certificate -CommandName Get-Mailbox
        Get-Module -Name Get-Mailbox -ErrorAction Stop
    }
}

Describe "PSWSMan PSRemoting tests" -Skip:(-not $PSWSManSettings.GetScenarioServer('default')) {
    BeforeEach {
        $SessionParams = Get-PSSessionSplat -Server $PSWSManSettings.GetScenarioServer('default')
    }

    It "Connects to JEA configuration" -Skip:(-not $PSWSManSettings.JEAConfiguration) {
        $SessionParams.ConfigurationName = $PSWSManSettings.JEAConfiguration.Name

        $s = New-PSSession @SessionParams
        try {
            $s.ComputerName | Should -Be $SessionParams.ComputerName
            $s.State | Should -Be 'Opened'
            $s.ConfigurationName | Should -Be $PSWSManSettings.JEAConfiguration.Name
            $out = Invoke-Command -Session $s -ScriptBlock { [Environment]::UserName }
            $out | Should -Be $PSWSManSettings.JEAConfiguration.ExpectedUserName
        }
        finally {
            $s | Remove-PSSession
        }

        $s.State | Should -Be 'Closed'
    }

    It "Connects with large ApplicationArguments data" {
        $appArgs = @{Key = 'a' * 1MB }

        $SessionParams.SessionOption = New-PSWSManSessionOption -ApplicationArguments $appArgs
        $actual = Invoke-Command @sessionparams -ScriptBlock { $PSSenderInfo.ApplicationArguments }

        $actual.Key.Length | Should -Be 1MB
        $actual.Key | Should -Be ('a' * 1MB)
    }

    It "Runs command with large Command data" {
        $actual = Invoke-Command @sessionparams -ScriptBlock { $args[0] } -ArgumentList ('a' * 1MB)

        $actual.Length | Should -Be 1MB
        $actual | Should -Be ('a' * 1MB)
    }

    It "Pipes data into command" {
        $actual = ('a' * 1MB) | Invoke-Command @sessionparams -ScriptBlock { process { $_ } }

        $actual.Length | Should -Be 1MB
        $actual | Should -Be ('a' * 1MB)
    }

    It "Responds to user events" {
        $eventParams = @{
            EventName = "PSEventReceived"
            SourceIdentifier = "PSWSMan.UserEvent"
        }

        $session = New-PSSession @sessionParams
        try {
            $customEvent = Register-ObjectEvent -InputObject $session.Runspace.Events.ReceivedEvents @eventParams

            Invoke-Command -Session $session -ScriptBlock {
                $null = $Host.Runspace.Events.SubscribeEvent(
                    $null,
                    "PSWSManEvent",
                    "PSWSManEvent",
                    $null,
                    $null,
                    $true,
                    $true)
                $null = $Host.Runspace.Events.GenerateEvent(
                    "PSWSManEvent",
                    "sender",
                    @("my", "args"),
                    "extra data")
            }

            $actual = Wait-Event -SourceIdentifier $eventParams.SourceIdentifier -Timeout 1 | Select-Object *
        }
        finally {
            if ($customEvent) {
                Unregister-Event -SourceIdentifier $eventParams.SourceIdentifier
            }
            $session | Remove-PSSession
        }

        $actual | Should -Not -BeNullOrEmpty
        $actual.Sender.ComputerName | Should -Be $session.ComputerName
        $actual.SourceIdentifier | Should -Be PSWSMan.UserEvent
        $actual.SourceArgs[0] | Should -Be sender
        $actual.SourceArgs[1].RunspaceId | Should -Be $session.Runspace.InstanceId
        $actual.SourceArgs[1].SourceArgs | Should -Be @('my', 'args')
    }

    It "Receives a SecureString" {
        $actual = Invoke-Command @sessionParams -ScriptBlock { ConvertTo-SecureString -AsPlainText -Force -String secret }

        $actual.Length | Should -Be 6
        [PSCredential]::new('dummy', $actual).GetNetworkCredential().Password | Should -Be secret
    }

    It "Sends a SecureString" {
        $ss = ConvertTo-SecureString -AsPlainText -Force -String secret
        $actual = Invoke-Command @sessionParams -ScriptBlock {
            param([securestring]$obj)

            $obj.GetType().FullName
            [PSCredential]::new('dummy', $obj).GetNetworkCredential().Password
        } -ArgumentList $ss

        $actual[0] | Should -Be System.Security.SecureString
        $actual[1] | Should -Be secret
    }

    It "Sets max and min runspaces" {
        $connInfo = [System.Management.Automation.Runspaces.WSManConnectionInfo]@{
            ComputerName = $sessionParams.ComputerName
        }
        if ($sessionParams.ContainsKey('Credential')) {
            $connInfo.Credential = $sessionParams.Credential
        }

        $rp = [runspacefactory]::CreateRunspacePool(2, 5, $connInfo)
        $rp.Open()
        try {
            $rp.SetMaxRunspaces(1) | Should -BeFalse
            $rp.SetMaxRunspaces(5) | Should -BeFalse
            $rp.SetMaxRunspaces(4) | Should -BeTrue

            $rp.SetMinRunspaces(6) | Should -BeFalse
            $rp.SetMinRunspaces(2) | Should -BeFalse
            $rp.SetMinRunspaces(1) | Should -BeTrue

            $rp.GetAvailableRunspaces() | Should -Be 4
        }
        finally {
            $rp.Dispose()
        }
    }

    It "Resets runspace" {
        $session = New-PSSession @sessionParams

        try {
            Invoke-Command -Session $session -ScriptBlock { $global:test = 'foo' }

            $out = Invoke-Command -Session $session -ScriptBlock { $global:test }
            $out | Should -Be foo

            $session.Runspace.ResetRunspaceState()

            $out = Invoke-Command -Session $session -ScriptBlock { $global:test }
            $out | Should -BeNullOrEmpty
        }
        finally {
            $session | Remove-PSSession
        }
    }

    It "Stops a pipeline" {
        $session = New-PSSession @sessionParams

        try {
            $ps = [PowerShell]::Create()
            $ps.Runspace = $session.Runspace
            $null = $ps.AddScript('sleep 10')

            $start = Get-Date
            $task = $ps.BeginInvoke()

            $ps.Stop()

            $err = $null
            try {
                $ps.EndInvoke($task)
            }
            catch {
                $err = $_
            }

            $elapsed = (Get-Date) - $start

            $ps.InvocationStateInfo.State | Should -Be Stopped
        }
        finally {
            $session | Remove-PSSession
        }

        $elapsed.TotalSeconds | Should -BeLessThan 10
        $err | Should -Not -BeNullOrEmpty
        [string]$err | Should -BeLike '*The remote pipeline has been stopped*'
    }
}
