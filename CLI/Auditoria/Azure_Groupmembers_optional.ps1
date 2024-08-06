<# 

'  ACTT Tool Extraction Code for Azure AD group Members
' 20/Mar/2023		Antony, Godwin 						Added code to extract AD group Members
'
Notice:
' ------------------------------------------------------------------------------------
'	The purpose of this "read only" script is to download data that can be analyzed as part of our audit.  
'	We expect that you will follow your company's regular change management policies and procedures prior to running the script.
'	To the extent permitted by law, regulation and our professional standards, this script is provided "as is," 
'	without any warranty, and the Deloitte Network and its contractors will not be liable for any damages relating to this script or its use.  
'	As used herein, "we" and "our" refers to the Deloitte Network entity that provided the script to you, and the "Deloitte Network" refers to 
'	Deloitte Touche Tohmatsu Limited ("DTTL"), the member firms of DTTL, and each of their affiliates and related entities.
'
'

#>


Function Module-Check
{
	import-module AzureAD
		if ($?)
		{
			Write-Host "Detected Azure AD module"
		}
		else
		{
			Write-Host "Kindly refer the instruction document to install Azure AD module and re-run the extractor"\
			exit
		}	
}

Function DataCollection
{

Write-Host "Extraction of azureadgroupmembers is started"
    Try{
        $adgrouplist = @()
        $adgrouplist = az ad group list --query [*].[displayName] --output tsv
        $adgrouplistcount = $adgrouplist.Count 
        Write-Output "[" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
        foreach($adgrp in $adgrouplist)
        {
	        Write-Host "Data extraction for group $adgrp"
            Write-Output "{" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
            Write-Output """ADGroupName"":""$adgrp""" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
	
	        $cnt8=az ad group member list --group $adgrp --output tsv
	        if ($cnt8.count -ne 0)
	        {
	        Write-Output ",""ADGroupMemberName"":" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
            az ad group member list --group $adgrp --output json | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
	        }
            $adgrouplistcount=$adgrouplistcount-1
            If($adgrouplistcount -ge 1){
                Write-Output "}," | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
                }
                Else{   
                Write-Output "}" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
                }
        }
        Write-Output "]" | out-file -Append -encoding unicode -filepath "adgroupmembers.json"
    }
    catch{
      Write-Output "Issue with GroupMembers Listing" | out-file -encoding unicode -filepath "adgroupmembers.json"
     
    }
}

Write-Host "Analyzing the environment where the script is being run"
IF($PSVersiontable.PSEdition.equals('Core'))
{
    Write-Host "Detected Environment Azure CloudShell"
	DataCollection
	Write-Host "********* IMPORTANT: The file has successfully generated as "adgroupmembers.json" **********" -ForegroundColor Green
	Write-Host "**********Please make sure to delete the generated file "adgroupmembers.json" from the console after you have provided the file to Deloitte Engagement Team********" -ForegroundColor Green

    
}
else
{
    Write-Host "Detected Environment is not Azure CloudShell"
	$checkcli=az --version | Select-String "azure-cli"
	if ($checkcli -ne 0)
	{
		Write-Host " Azure CLI is installed."
		Module-Check
		az login
   		DataCollection
		Write-Host "********* IMPORTANT: The file has successfully generated as "adgroupmembers.json" **********" -ForegroundColor Green
		Write-Host "**********Please make sure to delete the generated file "adgroupmembers.json" from the console after you have provided the file to Deloitte Engagement Team********" -ForegroundColor Green

	}
	else
	{
		Write-Host " Azure CLI is not installed.Kindly follow the instructions to install Azure CLI"
		exit
	}
}




# SIG # Begin signature block
# MIIx/gYJKoZIhvcNAQcCoIIx7zCCMesCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEuEr2qscu4Uij1Plf8cBoz4G
# IOaggixXMIIFfzCCA2egAwIBAgIQGLXChEOQEpdBrAmKM2WmEDANBgkqhkiG9w0B
# AQsFADBSMRMwEQYKCZImiZPyLGQBGRYDY29tMRgwFgYKCZImiZPyLGQBGRYIRGVs
# b2l0dGUxITAfBgNVBAMTGERlbG9pdHRlIFNIQTIgTGV2ZWwgMSBDQTAeFw0xNTA5
# MDExNTA3MjVaFw0zNTA5MDExNTA3MjVaMFIxEzARBgoJkiaJk/IsZAEZFgNjb20x
# GDAWBgoJkiaJk/IsZAEZFghEZWxvaXR0ZTEhMB8GA1UEAxMYRGVsb2l0dGUgU0hB
# MiBMZXZlbCAxIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlPqN
# qqVpE41dp1s1+neM+Xv5zfUAKTrD10RAF9epFFmIIMH62VgMXOYYWBryNQaUAYPZ
# lvv/Tt0cCKca5XAWKp4DbBeblCmxfHsqEz3R/kzn/CHRHnQ3YMZRMorAccq82Ddx
# Kiwnw9o0W5SGD5A+zNXh9DjcCx0G5ROAaqiv7m3HYz2HrEvqdIuMkMoj7Y2ieMiw
# /PuIjVU8wmodltkBmGoAeOOcVYaWBZTpKy0NC/xYL7eHfMKdgRaa30pFVeZliN8D
# MiN/exbfr6iu00fQAsNxiZleH/6CLHuODdh+7KK00Wp2Wi9qz/IeOAGkj8j0jXFn
# nX5PHQWcVVv8E8sIK1S95xDxmhOsrMGkGA6G3F7a1qfI1WntvYBT98eUgZQ3whDq
# jypj622jjXLkUxlfuUeuBHB2+T9kSbapQHIhjAE3f97A/FOuzG0aerr6eNC5doNj
# OX31Bfp5W0WkhbX8D0Aexf7v+OsboqFkAkaNzSS2oaX7+G3XAw2r+slDmyimr+bo
# aLEo4vM+oFzFUeBQOXvjGBEnGtxXmSIPwsLu+HlhOvjtXINLbsczl2QWzC2arRPx
# x6HLr1hPj0eiyz7bKDPQ+N+U9l5OetL6NNFgppVDoqSVo5FUwh47wZKaqXZ8b1jP
# j/SS+IRsbKnCJ37+YXfkA2Mid9x8oMyRfBfwed8CAwEAAaNRME8wCwYDVR0PBAQD
# AgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFL6LoCtmWVn6kHFRpaeoBkJO
# kDztMBAGCSsGAQQBgjcVAQQDAgEAMA0GCSqGSIb3DQEBCwUAA4ICAQCDTvRyLG76
# 375USpexKf0BGCuYfW+o/6G18GRqZeYls7lO251xn7hfXacfEZIHCPoizan0yvZJ
# tYUocXRMieo766Zwn8g4OgEZjJXsw81p0GlkylmdWhqO+sRuGyYvGY32MWZ16oz6
# x/CG+rseou2HsLLtlSV76D2XPnDutIAHI/S4is4A7F0V+oNX04aHpUXMb0Y1BkPK
# NF1gIlmf4rdtRh6+2r374QP+Ruw+nJiPNwF7TF28wkz1iUXWK9FSmM1Q6+/uXxpx
# 9qRFRwv+pCd/07IneZ3GmxxTNJxSzzEJxIfwoJIn6HL9NYPltAZ7CuWYsm5TFY+x
# 5TZ5qS/O6+nAHd30T7K/q+H5hjp9tisYah3RiBOOU+iZvtUsr1XaLT7zizxnmp4s
# sHHryLhNkYu2uh/dT1/iq8SbM3fKGElML+mE7ZPAg2q2B76kgbY+GrEtzNnzwNfI
# wkh/IDKYJ9n6JU2yQ4oa5sJjTf5uHUhxV9Zd8/BZK8L3H5S7Iy3yCVLyq98xuUZ3
# ChL4FoKeS89uMrgKADP2xnAdIw1nnd67ZSPrTVk3sZO/uJVKTzjpU0V10sc27VmV
# x9YByc4o4xDoQ6+eAlUbNpuoFpchzdL2dx5JUalLl2T4jg4UIzKcidPhEmyU1ApK
# UXFQTbx0N8v1WC2UXROwuc0YDLR7v6RCLjCCBY0wggR1oAMCAQICEA6bGI750C3n
# 79tQ4ghAGFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UE
# AxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoX
# DTMxMTEwOTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNl
# cnQgVHJ1c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAv+aQc2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQw
# H/MbpDgW61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6
# dZlqczKU0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXG
# XuxbGrzryc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXn
# Mcvak17cjo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy
# 19sEcypukQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFY
# F/ckXEaPZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+Skjqe
# PdwA5EUlibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFg
# qrFjGESVGnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJR
# R3S+Jqy2QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7Gr
# hotPwtZFX50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2
# MA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9P
# MB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIB
# hjB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0Eu
# Y3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV
# 5zhfoKN0Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8t
# tzjv9P+Aufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKh
# SLSZy51PpwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO
# 7KTVPeix3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WY
# IsGyWfVVa88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3
# AamfV6peKOK5lDCCBd4wggPGoAMCAQICEz4AAAAKdNVtyb8ulQIAAgAAAAowDQYJ
# KoZIhvcNAQELBQAwVDETMBEGCgmSJomT8ixkARkWA2NvbTEYMBYGCgmSJomT8ixk
# ARkWCERlbG9pdHRlMSMwIQYDVQQDExpEZWxvaXR0ZSBTSEEyIExldmVsIDIgQ0Eg
# MjAeFw0yMTA2MjkxOTM1MDFaFw0yNjA2MjkxOTQ1MDFaMGwxEzARBgoJkiaJk/Is
# ZAEZFgNjb20xGDAWBgoJkiaJk/IsZAEZFghkZWxvaXR0ZTEWMBQGCgmSJomT8ixk
# ARkWBmF0cmFtZTEjMCEGA1UEAxMaRGVsb2l0dGUgU0hBMiBMZXZlbCAzIENBIDIw
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCjBK7eN3UwSWRgwF4dqTZ3
# El/JIiq4rhpa9PFP92bSNZOmChLVKZ7N+LcLDekcJrqvGdhU8ZXxZQih4rXVpK+h
# EvoAv7odDAD4sdV2ZhKwAgto9q1Q19RC188LXcwiK86QWl18Q/pQsNHqLtAhJ0kF
# wH2CxGd/hKI+h43owy8LgQIU4rAuJsBMiKE1VLIJGZ7OJd19K18r2X7MTe5Ri1fc
# CA8z+96gJfgCelt70oRWzW+xs84ZZ+ar4aP8ueeNq84vksHALQi25i/p68UsjY3P
# qdcN6h1fmZpJ0+1bc99O9/JpZ/BfZ3tGb1qPTAWvTLbtx/xZhXMlv5vYZbGJ1dKR
# AgMBAAGjggGPMIIBizASBgkrBgEEAYI3FQEEBQIDAgACMCMGCSsGAQQBgjcVAgQW
# BBS8vokw1VAoJKLdJxkOj2Xnd1qcETAdBgNVHQ4EFgQUOKGpLhVw4kdhFAZtNuZr
# jw4uw2EwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAURy427rSc/1xeGHy4E+G+qSAe
# FLMwXAYDVR0fBFUwUzBRoE+gTYZLaHR0cDovL3BraS5kZWxvaXR0ZS5jb20vQ2Vy
# dEVucm9sbC9EZWxvaXR0ZSUyMFNIQTIlMjBMZXZlbCUyMDIlMjBDQSUyMDIuY3Js
# MHYGCCsGAQUFBwEBBGowaDBmBggrBgEFBQcwAoZaaHR0cDovL3BraS5kZWxvaXR0
# ZS5jb20vQ2VydEVucm9sbC9TSEEyTFZMMkNBMl9EZWxvaXR0ZSUyMFNIQTIlMjBM
# ZXZlbCUyMDIlMjBDQSUyMDIoMikuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQBm9NVB
# JXk77sQM0Qln9/XtirH6bJPIXy1aFhyr1ydTOuZ3TqgOWYxZYXd5rinskWrLWxEN
# ep9UVe+tMu9Daadi/GZqf7tBZpb3c07Z1nHOJp8vRTtIRTh0oaA8vmRrynbIpEp6
# HdNQ9HXOTghxlBDLHt8SbzqG818tNslZaPfBHALsj4Fj9tS20jjwD1PTiT7TZmwU
# ovU4HGs5fttOF/haRq0/ngZYeaeLEeYUmNh2KGWKZRhr0+TgAcEt1P3jF8N6Eh4J
# zMLY+jJlCR/zP0WWnssT7BE2fYrWpC1SNSZ2G8Cbkeg3ZV0A4EOSirpVR09yw0W3
# //hpiZ+enRpNpFlEM7G6mFX1gelmOiQ53V93i43ihPu7pFpkhOKwh5NIfTPcGglm
# mY57k6hKgzopvdS/1KBSSeCp6Tw6xnuXWY+hV1XTlT2W/ADvmT9EII8sUsLLAEKX
# 1CW1BSSNmPdUM+3VBMlsrpxyNYPwj1VFli9VFflasF6uwtHfEQHYttWhUWjEu5Xh
# 0u88zyBHbjEIBCK7wpWdK0cLjIx9k3ogvbeEGzRCRbiwhcC0wt7E4tqeLVneJ1VL
# +aELWEqjFIbm+KfslyKF+Y3tDqm+bPk+XHWpiLMOFiOEtdWZaLBmf168jlPDHaxi
# MiAaC/whoQx1r5pUTO6zkOGkX78OPiDrwUU0hDCCBq4wggSWoAMCAQICEAc2N7ck
# VHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoX
# DTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hB
# MjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJf
# pIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r
# 2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT2exp39mQh0YAe9tE
# QYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkS
# Z+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCw
# MROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vs
# gd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZz
# QmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJ
# UlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6z
# j9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ1
# 4mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIB
# WTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGog
# j57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8E
# BAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsG
# AQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0
# dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC
# 4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQg
# JTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequF
# zUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhU
# ifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g
# 55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7
# HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLX
# JmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvY
# fvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXA
# OimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQ
# I38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrn
# Ew4d2zc4GqEr9u3WfPwwggbAMIIEqKADAgECAhAMTWlyS5T6PCpKPSkHgD1aMA0G
# CSqGSIb3DQEBCwUAMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1
# NiBUaW1lU3RhbXBpbmcgQ0EwHhcNMjIwOTIxMDAwMDAwWhcNMzMxMTIxMjM1OTU5
# WjBGMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJDAiBgNVBAMTG0Rp
# Z2lDZXJ0IFRpbWVzdGFtcCAyMDIyIC0gMjCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAM/spSY6xqnya7uNwQ2a26HoFIV0MxomrNAcVR4eNm28klUMYfSd
# CXc9FZYIL2tkpP0GgxbXkZI4HDEClvtysZc6Va8z7GGK6aYo25BjXL2JU+A6LYyH
# Qq4mpOS7eHi5ehbhVsbAumRTuyoW51BIu4hpDIjG8b7gL307scpTjUCDHufLckko
# HkyAHoVW54Xt8mG8qjoHffarbuVm3eJc9S/tjdRNlYRo44DLannR0hCRRinrPiby
# tIzNTLlmyLuqUDgN5YyUXRlav/V7QG5vFqianJVHhoV5PgxeZowaCiS+nKrSnLb3
# T254xCg/oxwPUAY3ugjZNaa1Htp4WB056PhMkRCWfk3h3cKtpX74LRsf7CtGGKMZ
# 9jn39cFPcS6JAxGiS7uYv/pP5Hs27wZE5FX/NurlfDHn88JSxOYWe1p+pSVz28Bq
# mSEtY+VZ9U0vkB8nt9KrFOU4ZodRCGv7U0M50GT6Vs/g9ArmFG1keLuY/ZTDcyHz
# L8IuINeBrNPxB9ThvdldS24xlCmL5kGkZZTAWOXlLimQprdhZPrZIGwYUWC6poEP
# CSVT8b876asHDmoHOWIZydaFfxPZjXnPYsXs4Xu5zGcTB5rBeO3GiMiwbjJ5xwtZ
# g43G7vUsfHuOy2SJ8bHEuOdTXl9V0n0ZKVkDTvpd6kVzHIR+187i1Dp3AgMBAAGj
# ggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8E
# DDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# HwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8wHQYDVR0OBBYEFGKK3tBh
# /I8xFO2XC809KpQU31KcMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1lU3Rh
# bXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKGTGh0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQwOTZTSEEyNTZUaW1l
# U3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIBAFWqKhrzRvN4Vzcw/HXj
# T9aFI/H8+ZU5myXm93KKmMN31GT8Ffs2wklRLHiIY1UJRjkA/GnUypsp+6M/wMkA
# mxMdsJiJ3HjyzXyFzVOdr2LiYWajFCpFh0qYQitQ/Bu1nggwCfrkLdcJiXn5CeaI
# zn0buGqim8FTYAnoo7id160fHLjsmEHw9g6A++T/350Qp+sAul9Kjxo6UrTqvwlJ
# FTU2WZoPVNKyG39+XgmtdlSKdG3K0gVnK3br/5iyJpU4GYhEFOUKWaJr5yI+RCHS
# PxzAm+18SLLYkgyRTzxmlK9dAlPrnuKe5NMfhgFknADC6Vp0dQ094XmIvxwBl8kZ
# I4DXNlpflhaxYwzGRkA7zl011Fk+Q5oYrsPJy8P7mxNfarXH4PMFw1nfJ2Ir3kHJ
# U7n/NBBn9iYymHv+XEKUgZSCnawKi8ZLFUrTmJBFYDOA4CPe+AOk9kVH5c64A0JH
# 6EE2cXet/aLol3ROLtoeHYxayB6a1cLwxiKoT5u92ByaUcQvmvZfpyeXupYuhVfA
# YOd4Vn9q78KVmksRAsiCnMkaBXy6cbVOepls9Oie1FqYyJ+/jbsYXEP10Cro4mLu
# eATbvdH7WwqocH7wl4R44wgDXUcsY6glOJcB0j862uXl9uab3H4szP8XTE0AotjW
# AQ64i+7m4HJViSwnGWH2dwGMMIIGyTCCBLGgAwIBAgITNAAAAAeJIXWJc80n8gAA
# AAAABzANBgkqhkiG9w0BAQsFADBSMRMwEQYKCZImiZPyLGQBGRYDY29tMRgwFgYK
# CZImiZPyLGQBGRYIRGVsb2l0dGUxITAfBgNVBAMTGERlbG9pdHRlIFNIQTIgTGV2
# ZWwgMSBDQTAeFw0yMDA4MDUxNzMyNTZaFw0zMDA4MDUxNzQyNTZaMFQxEzARBgoJ
# kiaJk/IsZAEZFgNjb20xGDAWBgoJkiaJk/IsZAEZFghEZWxvaXR0ZTEjMCEGA1UE
# AxMaRGVsb2l0dGUgU0hBMiBMZXZlbCAyIENBIDIwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCY9vqwcsHbkkPbzo1/JHZF+42CZJdpHZ0uiPHus8OqIRYo
# zTWZJ2q7N5ePtC79VCyJAtX/2jHAwCtK+MkdGN5DYvuis8bK3FaI7qc0eQps9QKQ
# FOZEAtVxcrSJiZeFCNrKmPHnLxuLcrXcBHtrFNs2U8QXLfP1PAUZ+2Z4k4i+V7d0
# G84LEmt7WbGZ/nji2TOr4N/QQ0/ywDjVZ5BsDlnINrYLw9abxcvn1fTRSC0wlw6r
# h8Ib7GSOXuedtDj8A/uUYcaSXRudgTld3+dUDzr7A765NRyZuzR8n18o7durfCCJ
# RpHLIFtRDY3MaWBp9/GqB7aUzdYKaJB4crJ8qw6R+DjX7qHupQXLAOgOS+dUGMmz
# b62AiaqoPqLCaBlYe3o94iLAkD8ggoF/S3U7Xobf26Kbo1KJ6xIr7B84zHLFmKj8
# HMoY862/g/CiwGU8qWErltu8xZjZEWxZAnos+JFeUTk0hhuH8JPKeAh0zoOvCvnu
# whkZZsoIlz2c5G15WDHemByIUDE4UafWTfObEzzepjHGAqLp+qXwoKBuj6XqW5E4
# trmuxF+QY+1FfLUdYnvHBx/z8nEskaWnWu2cadmWO9vRNu3CjwbAOiKFIxKH0yga
# slOu2Ty2dh/hSkuAYqMbIY5QEUatEZBwSFZvMNMrmpk//R/fV3cKd3NA5FgBvwID
# AQABo4IBlDCCAZAwEAYJKwYBBAGCNxUBBAMCAQIwIwYJKwYBBAGCNxUCBBYEFBXh
# v+KL8O1azIV0T6na/7GPCLczMB0GA1UdDgQWBBRHLjbutJz/XF4YfLgT4b6pIB4U
# szARBgNVHSAECjAIMAYGBFUdIAAwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEw
# CwYDVR0PBAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHwYDVR0jBBgwFoAUvoug
# K2ZZWfqQcVGlp6gGQk6QPO0wWAYDVR0fBFEwTzBNoEugSYZHaHR0cDovL3BraS5k
# ZWxvaXR0ZS5jb20vQ2VydEVucm9sbC9EZWxvaXR0ZSUyMFNIQTIlMjBMZXZlbCUy
# MDElMjBDQS5jcmwwbgYIKwYBBQUHAQEEYjBgMF4GCCsGAQUFBzAChlJodHRwOi8v
# cGtpLmRlbG9pdHRlLmNvbS9DZXJ0RW5yb2xsL1NIQTJMVkwxQ0FfRGVsb2l0dGUl
# MjBTSEEyJTIwTGV2ZWwlMjAxJTIwQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCH
# noNRnnF5G9P8l0AzxuKos4jg8uUiEg+59F8w8mWajrh1j0b8lWQXuqHxIdabu6aN
# JO9vfnuRrIkKSzljdXBLXUD0cyxErXXTzd7EHbsdQF3ZbcjJG/YoFlP5KwCyeG1v
# ayUS4+qqukVkLe7ZFlrxeicpVVxffB8U3SrET7JeSNgxQ3GveRi5yVvaS3/j9GCC
# R9XTp0vRfaUeS0sxgguavxNvb95TZLv/+Gt1wf+1xZnb2GIjMvSprKnSPYwG5cAJ
# X9kM2F4QG8Prn2nXhp7bcKuBOldIsvrxHAeNpCoVV/YRY9eNHUxUlK+MHdAqIZ1d
# OW1S7UwGytEdsXCPzfGGJLWdNJZ8jFIz40bS762P1Inl85BIQyUJ7RpyF2hc+8Xn
# S4PBpMvFQ6gGgMrYMp3yckVr/Hz8aPfmOftE2n/9S7NuYiE6vthmp1+IHCcZ9+bi
# tLnvsScFKxCG46PO6Oslsl3c0/Zqvb3dm6mvx35BhRtTnWfL6ZRhsZDxVB5mCjvZ
# eQUCfPHW9nD1QrlVTukLTOUFkv8U1XqFuByfFDQr+pEC50m3HTcak0XmyqHIQLSd
# 28JJ2WMqx/ia+A3CsQNNrocu0Qo42KyctKDnoitw/Hlb94Pwqyh2XCl+DxQz8D3j
# ZXwlFkkuAWtz6erKw+L5wg0xN3+fjSHbDMZGVyMMTzCCBxowggYCoAMCAQICE2UA
# lPSp6W57Va6QlE8AAgCU9KkwDQYJKoZIhvcNAQELBQAwbDETMBEGCgmSJomT8ixk
# ARkWA2NvbTEYMBYGCgmSJomT8ixkARkWCGRlbG9pdHRlMRYwFAYKCZImiZPyLGQB
# GRYGYXRyYW1lMSMwIQYDVQQDExpEZWxvaXR0ZSBTSEEyIExldmVsIDMgQ0EgMjAe
# Fw0yMzA0MTQxNDEyMzVaFw0yNTA0MTMxNDEyMzVaMIG9MQswCQYDVQQGEwJVUzEL
# MAkGA1UECBMCVE4xEjAQBgNVBAcTCUhlcm1pdGFnZTEaMBgGA1UEChMRRGVsb2l0
# dGUgU2VydmljZXMxITAfBgNVBAsTGFVTIEN5YmVyIERhdGEgUHJvdGVjdGlvbjEo
# MCYGA1UEAxMfVVMgQ3liZXIgQ29kZSBTaWduaW5nIDIwMjMtMjAyNTEkMCIGCSqG
# SIb3DQEJARYVYm9iYnJvd25AZGVsb2l0dGUuY29tMIIBIjANBgkqhkiG9w0BAQEF
# AAOCAQ8AMIIBCgKCAQEAxTAvCOTtwllzOMGn2eKEV/v0qU8b4X36ZOogdSfHkIUU
# pcKORkSx/AkV/GfYZ9nBl3si1hnSkh9UoU9pwJmAymNaGS/FKN2kBstLe4d2IA5c
# 9ILg0xsxn9rR/UwPY/xW2t6ek3uQHS/FURXsH2XYf82LPK44ynYFOVwrQizZWdj6
# x0oqjMriJ7UTky+3++Px3BMIfiIVWK2m9et7omqMADrKioRp7SUmjekBcgnPrk++
# TzfUcGqtk9gDjjQRuIZUcgYS2ruY/q++fL/FsU9uP6RFsVBXiVBEZCLloK2d+meG
# tCVNbEhssfoHEluldp+mMPxAwWSGc12k98fDd0wJnQIDAQABo4IDYTCCA10wCwYD
# VR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGBvUmFvoUTgtWb
# PIPXjgeG8ckKXIPK9y3C8zICAWQCAR4wHQYDVR0OBBYEFMfBYqejeXBVp+SMS3Tg
# /fIHzZ1DMB8GA1UdIwQYMBaAFDihqS4VcOJHYRQGbTbma48OLsNhMIIBQQYDVR0f
# BIIBODCCATQwggEwoIIBLKCCASiGgdVsZGFwOi8vL0NOPURlbG9pdHRlJTIwU0hB
# MiUyMExldmVsJTIwMyUyMENBJTIwMigyKSxDTj11c2F0cmFtZWVtMDA0LENOPUNE
# UCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25m
# aWd1cmF0aW9uLERDPWRlbG9pdHRlLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRp
# b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnSGTmh0
# dHA6Ly9wa2kuZGVsb2l0dGUuY29tL0NlcnRlbnJvbGwvRGVsb2l0dGUlMjBTSEEy
# JTIwTGV2ZWwlMjAzJTIwQ0ElMjAyKDIpLmNybDCCAVcGCCsGAQUFBwEBBIIBSTCC
# AUUwgcQGCCsGAQUFBzAChoG3bGRhcDovLy9DTj1EZWxvaXR0ZSUyMFNIQTIlMjBM
# ZXZlbCUyMDMlMjBDQSUyMDIsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZp
# Y2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9ZGVsb2l0dGUsREM9
# Y29tP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9u
# QXV0aG9yaXR5MHwGCCsGAQUFBzAChnBodHRwOi8vcGtpLmRlbG9pdHRlLmNvbS9D
# ZXJ0ZW5yb2xsL3VzYXRyYW1lZW0wMDQuYXRyYW1lLmRlbG9pdHRlLmNvbV9EZWxv
# aXR0ZSUyMFNIQTIlMjBMZXZlbCUyMDMlMjBDQSUyMDIoMikuY3J0MBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwDQYJKoZI
# hvcNAQELBQADggEBAFd64KXqcGmmRRUF7ZFoimEIvXOJ1FgQCkVbDhzO50nkTpDw
# s1A+epg6J19s4yt3wB/Wl1cQNi1clER1E7loK/YwV80Tyi6Zna9FgKyh/FjCYvb7
# x/ahDIFX3qvNILOcY0Qc+QIF+J8DyNJrGOr6NoouttGb/qKS19Aj4alJLMlNISyi
# nSerJthbXOhambH4f97UA1qypIlizGpRJ+C0CUxhnUpWRy1IxUzZZrv+JpFBoPv7
# u51Yfr4G0ZtjMC8e8aukqTqzE8SfKf04vduOKA7dP4J6tvrcT8XCruBr3/Ag7lhl
# /YAkDPb2detPsI3gGG3aiU95M3q1D1DulZD4vR4xggURMIIFDQIBATCBgzBsMRMw
# EQYKCZImiZPyLGQBGRYDY29tMRgwFgYKCZImiZPyLGQBGRYIZGVsb2l0dGUxFjAU
# BgoJkiaJk/IsZAEZFgZhdHJhbWUxIzAhBgNVBAMTGkRlbG9pdHRlIFNIQTIgTGV2
# ZWwgMyBDQSAyAhNlAJT0qelue1WukJRPAAIAlPSpMAkGBSsOAwIaBQCgQDAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAjBgkqhkiG9w0BCQQxFgQUp3DxCwmAFKot
# eiO/rIrHHBN+rNowDQYJKoZIhvcNAQEBBQAEggEAse3YFVTSC8F63IwXetVfk0a6
# T4fKaPBmnm+6y7bV3VBYDtF8K3XKYERqghJ2p2kSNSOiu4FYeyLFTSxmwuRpyg7I
# 7UfobHW7AXD11e60LlblKTchsbEzTVg4Elx6dpKvY0DCOeNHOzw/z4v1TFg/YvlE
# GdWbIuQjwFlV6cPFx6FTOl9NsEhvY7c63VscFRUFUi70Nqx1hw2O5mQfrEUAlge9
# 1yavg79ZSI/rXzEPx+ZETfvF/9cEvjvbdY1THHPfbs+ZwAO3cD+nvaeNqMT7vUN5
# DiX5gNPT9+NYAFxivgFX3MTPDLN41v9j6v8TtZ3Pc+dQ5hmY0E/p/40Rdelw3aGC
# AyAwggMcBgkqhkiG9w0BCQYxggMNMIIDCQIBATB3MGMxCzAJBgNVBAYTAlVTMRcw
# FQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3Rl
# ZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9
# KQeAPVowDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
# MBwGCSqGSIb3DQEJBTEPFw0yMzA2MjExNjU2NTlaMC8GCSqGSIb3DQEJBDEiBCCa
# davLR7KlNOwCA3vxGiZ8sy5GwZHOKe8yYUVwk9agQjANBgkqhkiG9w0BAQEFAASC
# AgCJ+Y9DMfV7r4+jg8kRkV4eCjbdphMc3G5aPTE36vA0MS5f4+K/A5mZTuPmJfiw
# tWOHknNPFbxXHbVao5X9fq+3g5vXiNlvwyl6mhW9aJnZAAE5Mw1tTBC+VlXypX2K
# /cLwuRRLsdW3+zEDdNHAv1mewTmZEaRDKfb1QQs8knEVemXZqZx7CA9IlZX+Hhs7
# 5m9P9QOBRaQ/TZMRtVxskvRiU5T2TSOnBu/iBTzRSxRKTWuaElcCycjP8g3Y7nL3
# 9T3z7JK5FnZ04Ed4ilUEY6CNL3fuJVJDADQkY5M7D22tyDSZgSiaobnhXK6FyZZp
# pazFKDMSxiY19ge5gSh+OCanF0zIc2S9ogKejpKRO/W/wtoAomZgfpyH+rLTCcXD
# +TcCOoBkIlJNkdb278uxyXJmX705VqHImkUp3Es4n5zXVdt3RnCHjiTW9Ry5pUdi
# F6tatCLT10xbDdwSwk6zG1aE2mFTbzqUD7XTXEqJKOxabAdrb/o5ojcKH9RjPhe3
# ASnfrCyH9/voipwpVpq9wT3HVTsJBC28EBsxkupXIWXmDrRDRZot6t1G8IgxDFvl
# HgSaBOss9volKUZOyyoV7YawX8Lz6A0CvWK0p2MbChjKCCFizaJoxpy+MJKRm2zj
# 2A8Y2VX9IHg5zH/LIDuIfucR0Fhm616QHM/9oOWVl08jdQ==
# SIG # End signature block
