$manifest = @{}

# H:\data\2023\dotfiles.2023\pwsh\dots_psmodules\Nin.Posh\Nin.Posh.psd1

$newModuleManifestSplat = @{
    Path              = Join-Path $PSScriptRoot 'Nin.Posh.psd1'
    RootModule        = 'Nin.Posh.psm1'
    Author            = 'Jake Bolton'
    CompanyName       = 'Jake Bolton'
    Copyright         = '2023'
    Description       = 'examples that modify the module: Posh'
    Guid              = New-Guid
    ModuleVersion     = '0.0.1'
    RequiredModules   = @('Posh')
    PowerShellVersion = '7.0'


    PassThru          = $true

    # Prerelease = 'beta'
    Tags              = @(
        'ninmonkey', 'console',
        'Posh', 'experimental', 'crazy'
    )


    # HelpInfoUri = '.'
    FormatsToProcess  = @()

    AliasesToExport   = @(
        '*'
    )
    FunctionsToExport = @(
        '*'
    )
    CmdletsToExport   = @()
    TypesToProcess    = @()
    VariablesToExport = @()
    PrivateData       = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @()




        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''



New-ModuleManifest @newModuleManifestSplat -PassThru
Import-Module Nin.Posh -force -verbose -PassThru