Windows Terminal Config
- [Command Line Args](#command-line-args)
  - [Commands](#commands)
  - [User Settings and Config Paths](#user-settings-and-config-paths)
  - [Special Requirements for WindowsStore AppInstalls](#special-requirements-for-windowsstore-appinstalls)
  - [To Experiment](#to-experiment)
  - [See more](#see-more)
  - [specs? like PEP maybe?](#specs-like-pep-maybe)

# Command Line Args

- [docs: cli-args](https://docs.microsoft.com/en-us/windows/terminal/command-line-arguments?tabs=windows)

## Commands

- [Wt Commands](https://docs.microsoft.com/en-us/windows/terminal/customize-settings/actions)
- [Custom Commands on Command Palette](https://docs.microsoft.com/en-us/windows/terminal/command-palette)


## User Settings and Config Paths

- main [Profiles.Schema.Json](https://github.com/microsoft/terminal/blob/main/doc/cascadia/profiles.schema.json)
- [docs: settings.json](https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file)
- [docs: json-fragment-extensions](https://docs.microsoft.com/en-us/windows/terminal/json-fragment-extensions)
- [ColorSchemes.xaml](https://github.com/microsoft/terminal/blob/main/src/cascadia/TerminalSettingsEditor/ColorSchemes.xaml)
- [ProfileAppearance.xml](https://github.com/microsoft/terminal/blob/main/src/cascadia/TerminalSettingsEditor/Profiles_Appearance.xaml)

> Tip: it is possible to create a [JSON fragment extension](https://docs.microsoft.com/en-us/windows/terminal/json-fragment-extensions) in order to store profile data and color schemes in a separate file, which can be useful to prevent excessively large configuration files.

## Special Requirements for WindowsStore AppInstalls

> Note: For applications installed through the **Microsoft Store** (or similar), the application must *declare itself* to be an **app extension**. Learn more about how to Create and host an **app extension**. The necessary section is replicated here. The `appxmanifest` file of the package must include:

- [docs: Create and host app extension](https://docs.microsoft.com/en-us/windows/uwp/launch-resume/how-to-create-an-extension) at /uwp/launch-resume/how-to-create-an-extension

```xml
<Package
  ...
  xmlns:uap3="http://schemas.microsoft.com/appx/manifest/uap/windows10/3"
  IgnorableNamespaces="uap uap3 mp">
  ...
    <Applications>
      <Application Id="App" ... >
        ...
        <Extensions>
          ...
          <uap3:Extension Category="windows.appExtension">
            <uap3:AppExtension Name="com.microsoft.windows.terminal.settings"
                               Id="<id>"
                               PublicFolder="Public">
            </uap3:AppExtension>
          </uap3:Extension>
        </Extensions>
      </Application>
    </Applications>
    ...
</Package>
```


## To Experiment

- [experimental.useBackgroundImageForWindow]jhttps://docs.microsoft.com/en-us/windows/terminal/customize-settings/appearance)

## See more

- <https://docs.microsoft.com/en-us/windows/terminal/customize-settings/startup>
- <https://docs.microsoft.com/en-us/windows/terminal/install#settings-json-file>
- [Json Util API](https://github.com/microsoft/terminal/blob/main/doc/cascadia/Json-Utility-API.md)
- [scheme parse .cs](https://github.com/microsoft/terminal/blob/main/src/tools/ColorTool/ColorTool/SchemeParsers/IniSchemeParser.cs#L15)


## specs? like PEP maybe?

- [#2325 - Default Profile Settings.md](https://github.com/microsoft/terminal/blob/main/doc/specs/%232325%20-%20Default%20Profile%20Settings.md)