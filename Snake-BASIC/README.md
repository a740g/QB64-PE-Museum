# SNAKE for MS-DOS
SNAKE written in QuickBASIC

The Snake source is split into two files. Each file compiles into a separate program.
* SNAKE.BAS contains the game code and compiles to SNAKE.EXE
* CONFIG.BAS contains the configuration editor and compiles to CONFIG.EXE

SNAKE.EXE will create two files on initial run, CONFIG.DAT and SCORES.DAT. The former contains the game's configuration while the latter contains the high score list. To reset the settings or scores to the defaults, simply delete the corresponding file.

CONFIG.EXE changes game settings. It expects the game to have been run once. The settings will determine the maximum point value received per food collected based on the difficulty of the chosen settings. The default settings allow for a maximum of 5 points per food collected, which is already set to the default.
