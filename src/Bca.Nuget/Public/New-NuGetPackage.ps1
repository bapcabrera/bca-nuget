function New-NuGetPackage
{
    <#
        .SYNOPSIS
            Builds a NuGet package.
        .DESCRIPTION
            Builds a NuGet package from Nuspec manifest.
        .PARAMETER Manifest
            A string containing the path to the Nuspec manifest.
        .PARAMETER NuGetPath
            A string containing the path to the NuGet executable.
        .PARAMETER OutputPath
            A string containing the output path for the NuGet package.
            If 'OutputDirectory' is specified in 'Parameters' the value of 'OutputPath' - if specified - will override 'OutputDirectory'.
        .PARAMETER Parameters
            An hashtable containing the additionnal parameters to specify to NuGet.
            If 'OutputDirectory' is specified in 'Parameters' the value of 'OutputPath' - if specified - will override 'OutputDirectory'.
        .INPUTS
        .OUTPUTS
            PsObject
            Returns the output that is generated by the invoked command (nuget pack).
        .EXAMPLE
            New-NuGetPackage -Manifest .\package.nuspec

            Description
            -----------
            This example will build the package from the manifest.
        .EXAMPLE
            New-NuGetPackage -Manifest .\package.nuspec -OutputPath D:\packages

            Description
            -----------
            This example will build the package from the manifest and output it to D:\packages.
        .EXAMPLE
            New-NuGetPackage -Manifest .\package.nuspec -Parameters @{ "NoDefaultExcludes" = $true ; "OutputDirectory" = "D:\packages" }

            Description
            -----------
            This example will build the package from the manifest, not excluding default content, and output it to D:\packages.
        .NOTES
            This CmdLet does not stop on nuget pack error, output should be parsed.
        .LINK
            Invoke-NuGetCommand
        .LINK
            https://docs.microsoft.com/en-us/nuget/tools/cli-ref-pack
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Manifest,
        [Parameter(Mandatory = $false)]
        [ValidateScript( { Test-Path $_ } )]
        [string] $NuGetPath = (Get-NuGetPath),
        [Parameter(Mandatory = $false)]
        [ValidateScript( { Test-Path $_ } )]
        [alias("OutputDirectory")]
        [string] $OutputPath = "",
        [Parameter(Mandatory = $false)]
        [alias("Options")]
        [hashtable] $Parameters = @{}
    )
    
    try 
    {
        if ($OutputPath) { $OutputPath = (Get-Item $OutputPath).FullName }
        if ($Parameters.Keys.Count -gt 0)
        {
            if ($OutputPath)
            {
                if ($Parameters.Keys -notcontains "OutputDirectory") { $Parameters.Add("OutputDirectory", $OutputPath) }
                else { $Parameters["OutputDirectory"] = $OutputPath }
            }
        }
        elseif (($Parameters.Keys.Count -eq 0) -and $OutputPath) { $Parameters.Add("OutputDirectory", $OutputPath) }

        Invoke-NuGetCommand -NuGetPath $NuGetPath -Command "pack" -Target "'$($Manifest)'" -Parameters $Parameters
    }
    catch
    {
        Write-Error $_
    }
}