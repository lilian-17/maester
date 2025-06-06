# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()


<#

ORCA-109 Checks if the allowed senders list is empty in Anti-spam policies

#>



class ORCA109 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA109()
    {
        $this.Control="ORCA-109"
        $this.Area="Anti-Spam Policies"
        $this.Name="Allowed Senders"
        $this.PassText="Senders are not being allow listed in an unsafe manner"
        $this.FailRecommendation="Remove allow listing on senders"
        $this.Importance="Emails coming from allow listed senders bypass several layers of protection within Exchange Online Protection. If senders are allow listed, they are open to being spoofed from malicious actors."
        $this.ExpandResults=$True
        $this.ItemName="Anti-Spam Policy"
        $this.DataType="Allowed Senders"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
            "Use Anti-Spam Policy Sender/Domain Allow lists"="https://aka.ms/orca-antispam-docs-4"
            "Recommended settings for EOP and Office 365 Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"]).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"])
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $AllowedSenders = $($Policy.AllowedSenders)

            $IsBuiltIn = $false
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
            if($null -eq $AllowedSenders)
            {
                $AllowedSenders = "No Sender Detected"
            }

            $ConfigObject.ConfigData = $AllowedSenders
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            <#
            
            Important! Do not apply read-only on preset/default policies here.
            
            #>

            If(($AllowedSenders).Count -eq 0 -or $AllowedSenders -eq "No Sender Detected")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Add config to check
            $this.AddConfig($ConfigObject)
        }        
    }

}
