# Dyalog Migration Tools

_(Currently just for migrating from APL+Win to Dyalog)_

This repository is intended to make it as easy as possible to do a first-pass migration from APL+Win to Dyalog.

Requires Dyalog v20.0 or newer.

## Basic process

1. From within APL+Win:
    1. Load your APL+Win workspace
    2. Establish the provided `APWtoDyalog` function there
    3. Export raw APL+Win source text files
2. From Dyalog:
    1. Establish migrate.dyalog into `⎕SE` or add the migration directory to SALT's cmddir
    2. Run the migration

## Details about the APL+Win side

1. Open the provided APWtoDyalog.txt file in a text editor, then select all and copy to clipboard.
2. In APL+Win, enter `∇` to open an editor.
3. Paste the function definition and press <kbd>Ctrl</kbd>+<kbd>e</kbd> to save.
4. Run `APLWtoDyalog 'path\for\raw\source`.

## Details about the Dyalog side

1. `]set cmddir ,path\to\migration`
2. `]MIGRATE.APLPlusWin path\for\raw\source` or `]MIGRATE.APLPlusWin path\for\raw\source -out=path\for\converted\source`

This keeps a flat workspace where covers for APL+Win built-ins are prefixed with `_` since that character cannot begin a name in APL+Win. Add `-pre=_.` to instead put the covers into a namespace `_`.

See `MIGRATE.APLPlusWin -??` for details.
