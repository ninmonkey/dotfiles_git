## Prettier config


- VS Code specific config: [VS Code specific config](https://github.com/prettier/prettier-vscode#configuration)
- [Prettier: Configuration](https://prettier.io/docs/en/configuration.html)
- [Prettier: Options](https://prettier.io/docs/en/options.html)
- Config uses [Cosmic config](https://github.com/davidtheclark/cosmiconfig)
- [Config to Work with other linters](https://prettier.io/docs/en/integrating-with-linters.html)
- the [`prettier` cli](https://prettier.io/docs/en/cli.html) or for **editor integrations**

<hr/>


- [Prettier config](#prettier-config)
- [Config Overrides](#config-overrides)
  - [`.json`](#json)
  - [`.yaml`](#yaml)
- [Config Examples](#config-examples)
  - [VS Code Notes](#vs-code-notes)
  - [`.json`](#json-1)
  - [`.js`](#js)
  - [`.yaml`](#yaml-1)
  - [`.toml`](#toml)
- [Configs to Work With Linters](#configs-to-work-with-linters)
  - [`eslint`](#eslint)
  - [`tslint`](#tslint)
  - [`stytlelint`](#stytlelint)



## Config Overrides

> Overrides let you have different configuration for certain file extensions, folders and specific files. [Prettier borrows ESLint's override format](https://eslint.org/docs/user-guide/configuring/#example-configuration)

### `.json`

```json
{
  "semi": false,
  "overrides": [
    {
      "files": "*.test.js",
      "options": {
        "semi": true
      }
    },
    {
      "files": ["*.html", "legacy/**/*.js"],
      "options": {
        "tabWidth": 4
      }
    }
  ]
}
```

### `.yaml`

```yml
emi: false
overrides:
  - files: "*.test.js"
    options:
      semi: true
  - files:
      - "*.html"
      - "legacy/**/*.js"
    options:
      tabWidth: 4
```

## Config Examples

**warning**:
> config key `prettier.configPath` If set, this value will always be used and local configuration files will be ignored. A **better** option for global **defaults** is to create a `~/.prettierrc`


### VS Code Notes

### `.json`

```json
{
  "trailingComma": "es5",
  "tabWidth": 4,
  "semi": false,
  "singleQuote": true
}
```

### `.js`

```js
// prettier.config.js or .prettierrc.js
module.exports = {
  trailingComma: "es5",
  tabWidth: 4,
  semi: false,
  singleQuote: true,
};
```

### `.yaml`

```yml
# .prettierrc or .prettierrc.yaml
trailingComma: "es5"
tabWidth: 4
semi: false
singleQuote: true
```

### `.toml`

```ini
# .prettierrc.toml
trailingComma = "es5"
tabWidth = 4
semi = false
singleQuote = true
```

## Configs to Work With Linters

### `eslint`

- [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier)

```ps1
> npm install --save-dev eslint-config-prettier
```

> Then, **add "prettier"** to the **"extends" array** in your **.eslintrc.* file**. Make sure to put it **last**, so it gets the chance to override other configs.
> 
```json
{
  "extends": [
    "some-other-config-you-use",
    "prettier"
  ]
}
```

### `tslint`

- [tslint-config-prettier](https://github.com/prettier/tslint-config-prettier)

### `stytlelint`

- [stylelint-config-prettier](https://github.com/prettier/stylelint-config-prettier)