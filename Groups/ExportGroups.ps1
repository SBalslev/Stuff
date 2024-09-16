[CmdletBinding()]
param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]
    $searchString,
    [parameter(Mandatory = $false)]
    [string]
    $connectToTenantId,
    [switch]
    $importModule
)

begin {
    if ($null -eq $searchString -or $searchString.Trim() -eq "") {
        Write-Error "Please provide a search string"
        return
    }
}

process {
    # Install-Module -Name Microsoft.Graph.Entra -Repository PSGallery -Scope CurrentUser -AllowPrerelease -Force
    if ($importModule) {
        Import-Module Microsoft.Graph.Entra
    }
    
    if ($null -ne $connectToTenantId -and $connectToTenantId.Trim() -ne "") {
        Connect-Entra -Scopes 'Directory.ReadWrite.All' -TenantId $connectToTenantId
    }

    $allGroups = Get-EntraGroup -SearchString $searchString

    # Create or overwrite the markdown file
    $mdFilePath = "GroupsAndMembers-$($searchString).md"
    $file = New-Item -Path $mdFilePath -ItemType File -Force
    # Loop through each group and get its members
    $allGroups | ForEach-Object {
        # Write the group name as a header
        Add-Content -Path $mdFilePath -Value "# $($_.DisplayName) ($($_.Mail))"
    
        # Get the members of the group
        Get-EntraGroupMember -ObjectId $_.Id | ForEach-Object {
            # Write each member as a list item
            Add-Content -Path $mdFilePath -Value "- $($_.DisplayName) ($($_.Mail))"
        }
    
        # Add a blank line between groups
        Add-Content -Path $mdFilePath -Value ""
    }
}

end {
    
}

