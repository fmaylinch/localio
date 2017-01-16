# Localio

Localio generates automatically localizable files for many platforms like Rails, Android, iOS, Java .properties files and JSON files using a centralized spreadsheet as source. The spreadsheet can be in Google Drive or a simple local Excel file.

## Prepare Ruby

I've had problems with default Ruby in Mac.
I recommend installing Ruby `2.0.0-p247`, for example via [rbenv](https://github.com/rbenv/rbenv).
Make sure you're using that version: `ruby -v`.


## Installation

    gem uninstall localio
    gem build localio.gemspec
    gem install --local localio-0.5.gem

If it complains about missing gems try using bundler (from `rbenv` doc) and then retry the previous commands.

    gem install bundler
    bundle install
    

## Usage

You have to create a custom file, Locfile, similar to Rakefile or Gemfile, with some information for this to work. Also you must have some spreadsheet with a particular format, either in CSV, Google Drive or in Excel (XLS or XLSX) format.

In your Locfile directory you can then execute

    localize


and your localizable files will be created with the parameters specified in the Locfile. 

You can also specify in the first parameter a file with another name, and it will work as well.

### The Spreadsheet

You will need a little spreadsheet with all the localization literals and their intended keys for internal use while coding.

There is a basic example in this Google Drive link: [https://docs.google.com/spreadsheets/d/1b5tp1KfMty_MqyBECXlzfS6t2vQAXIOZqJO51OH3BD8/edit?usp=sharing](https://docs.google.com/spreadsheets/d/1b5tp1KfMty_MqyBECXlzfS6t2vQAXIOZqJO51OH3BD8/edit?usp=sharing). You just have to duplicate and save to your account, or download and save it as XLS file.

**NOTE** Localio will only search for translations on the first worksheet of the spreadsheet. 

### Locfile

A minimal `Locfile` example could be:

````ruby
platform :ios

output_path 'out/'

source :google_drive,
       :spreadsheet => '[Localizables] My Project!',
       :login => 'your_email@gmail.com',
       :password => 'your_password'

formatting :smart # This is optional, formatting :smart is used by default.
````

This would connect localio to your Google Drive and process the spreadsheet with title "[Localizables] My Project!".

The list of possible commands is this.

Option                      | Description                                                      | Default
----------------------------|------------------------------------------------------------------|--------
`platform`                  | (Req.) Target platform for the localizable files.                | `nil`
`source`                    | (Req.) Information on where to find the spreadsheet w/ the info  | `nil`
`output_path`               | (Req.) Target directory for the localizables.                    | `out/`
`formatting`                | The formatter that will be used for key processing.              | `smart`
`except`                    | Filter applied to the keys, process all except the matches.      | `nil`
`only`                      | Filter applied to the keys, only process the matches.            | `nil`

#### Supported platforms

* `:android` for Android string.xml files. The `output_path` needed is the path for the `res` directory.
* `:ios` for iOS Localizable.strings files. The `output_path` needed is base directory where `en.lproj/` and such would go. Also creates header file with Objective-C macros.
* `:swift` for iOS Localizable.strings files. The `output_path` needed is base directory where `en.lproj/` and such would go. Also creates source file with Swift constants.
* `:rails` for Rails YAML files. The `output_path` needed is your `config/locales` directory.
* `:json` for an easy JSON format for localizables. The `output_path` is yours to decide :)
* `:java_properties` for .properties files used mainly in Java. Files named language_(lang).properties will be generated in `output_path`'s root directory.
* `:play_framework` for messages files used in Play Framework. Files named messages.(lang) will be generated in `output_path`'s root directory.

#### Supported sources

##### CSV

`source :csv` will use a local CSV file. In the parameter's hash you should specify a `:path`.

Option                      | Description
----------------------------|-------------------------------------------------------------------------
`:path`                     | (Req.) Path for your CSV file.

````ruby
source :csv,
       :path => 'YourCsvFileWithTranslations.csv'
````

##### Google Drive

`source :google_drive` will get the translation strings from Google Drive.

You will have to provide some required parameters too. Here is a list of all the parameters.

Option                      | Description
----------------------------|-------------------------------------------------------------------------
`:spreadsheet`              | (Req.) Title of the spreadsheet you want to use. Can be a partial match.
`:login`                    | (Req.) Your Google login.
`:password`                 | (Req.) Your Google password.

**NOTE** As it is a very bad practice to put your login and your password in a plain file, specially when you would want to upload your project to some repository, it is **VERY RECOMMENDED** that you use environment variables in here. Ruby syntax is accepted so you can use `ENV['GOOGLE_LOGIN']` and `ENV['GOOGLE_PASSWORD']` in here.

For example, this.

````ruby
source :google_drive,
       :spreadsheet => '[Localizables] My Project!',
       :login => ENV['GOOGLE_LOGIN'],
       :password => ENV['GOOGLE_PASSWORD']
````

And in your .bashrc (or .bash_profile, .zshrc or whatever), you could export those environment variables like this:

````ruby
export GOOGLE_LOGIN="your_login"
export GOOGLE_PASSWORD="your_password"
````

##### XLS

`source :xls` will use a local XLS file. In the parameter's hash you should specify a `:path`.

Option                      | Description
----------------------------|-------------------------------------------------------------------------
`:path`                     | (Req.) Path for your XLS file.

````ruby
source :xls,
       :path => 'YourExcelFileWithTranslations.xls'
````

##### XLSX

`source :xlsx` will use a local XLSX file. In the parameter's hash you should specify a `:path`.

Option                      | Description
----------------------------|-------------------------------------------------------------------------
`:path`                     | (Req.) Path for your XLSX file.

````ruby
source :xlsx,
       :path => 'YourExcelFileWithTranslations.xlsx'
````

#### Key formatters

If you don't specify a formatter for keys, :smart will be used.

* `:none` for no formatting.
* `:snake_case` for snake case formatting (ie "this_kind_of_key").
* `:camel_case` for camel case formatting (ie "ThisKindOfKey").
* `:smart` use a different formatting depending on the platform.

Here you have some examples on how the behavior would be:

Platform             | "App name"   | "ANOTHER_KIND_OF_KEY"
---------------------|--------------|----------------------
`:none`              | `App name`   | `ANOTHER_KIND_OF_KEY`
`:snake_case`        | `app_name`   | `another_kind_of_key`
`:camel_case`        | `appName`    | `AnotherKindOfKey`
`:smart` (ios/swift) | `_App_name`  | `_Another_kind_of_key`
`:smart` (android)   | `app_name`   | `another_kind_of_key`
`:smart` (ruby)      | `app_name`   | `another_kind_of_key`
`:smart` (json)      | `app_name`   | `another_kind_of_key`

Example of use:

````ruby
formatting :camel_case
````

Normally you would want a smart formatter, because it is adjusted (or tries to) to the usual code conventions of each platform for localizable strings.

### Advanced options

#### Filtering content

We can establish filters to the keys by using regular expressions.

The exclusions are managed with the `except` command. For example, if we don't want to include the translations where the key has the "[a]" string, we could include this in the Locfile.

````ruby
except :keys => '[\[][a][\]]'
````

We can filter inversely too, with the command `only`. For example, if we only want the translations that contain the '[a]' token, we should use:

````ruby
only :keys => '[\[][a][\]]'
````

#### Overriding default language

This only makes sense with `platform :android` at the moment. If we want to override (for whatever reason) the default language flag in the source spreadsheet, we can use `:override_default => 'language'`.

For example, if we wanted to override the default (english) and use spanish instead, we could do this:

```ruby
platform :android, :override_default => 'es'
```

## Contributing

Please read the [contributing guide](https://github.com/mrmans0n/localio/blob/master/CONTRIBUTING.md).
