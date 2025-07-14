
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
Invoke-WebRequest $downloadURI -OutFile C:\bundle.zip -UserAgent "OpenTelecom/I2-Bundle-Downloader-v1"
Start-Sleep 5
cd 'C:\Program Files\TWC\I2'
.\exec "stageStarBundle(File=C:\bundle.zip)"
Start-Sleep 5
.\exec "applyStarBundle()"
