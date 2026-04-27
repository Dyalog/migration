# Dyalog Migration Tools

_(Currently just for migrating from APL+Win to Dyalog)_

This repository is intended to make it as easy as possible to do a first-pass migration from APL+Win to Dyalog.

Requires Dyalog v20.0 or newer.

## Basic process

1. Download the tools.
2. From within APL+Win:
    1. Load your APL+Win workspace
    2. Establish the provided `APWtoDyalog` function there
    3. Export raw APL+Win source text files
3. From Dyalog:
    1. Establish migrate.dyalog into `⎕SE` or add the migration directory to SALT's cmddir
    2. Run the migration

## Downloading the tool

1. [Download and unzip](https://github.com/Dyalog/migration/archive/refs/heads/main.zip) to a location of your choice. In the following, the location will be referred to as `migration-folder`. Unless otherwise stated, files will be found in this folder.
2. Alternatively, if you think you might want to contribute enhancements to the tools, clone the github repository dyalog/migration.

## Exporting from APL+Win

1. Open the provided APWtoDyalog.txt file in a text editor, then select all and copy to clipboard.
2. In APL+Win, enter `∇` to open an editor.
3. Paste the function definition and press <kbd>Ctrl</kbd>+<kbd>e</kbd> to save.
4. Run `APLWtoDyalog 'path\for\raw\source`.

## Importing to Dyalog

1. `]set cmddir ,path\to\migration`
2. `]MIGRATE.APLPlusWin path\for\raw\source` or `]MIGRATE.APLPlusWin path\for\raw\source -out=path\for\converted\source`

This puts covers for APL+Win built-ins into a namespace `_` since that character cannot begin a name in APL+Win. Add `-pre=_.` to instead keep the workspace flat by prefixing all cover names with the `_` character.

See `MIGRATE.APLPlusWin -??` for details.
