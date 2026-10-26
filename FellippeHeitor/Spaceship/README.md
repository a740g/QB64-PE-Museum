# Spaceship

A text-mode space shooter written in QB64. Everything on screen is drawn with the 80×25 text screen and the CP437 character set.

The original 2016 game had three chapters and one boss. This edition expands it into a full campaign:

- **5 sectors, 20 chapters and 4 bonus stages.** The first four chapters are the original ones, with their names, enemies, goals and radio chatter intact.
- **20+ enemy types and 6 bosses:** the Space Amoeba, the Roach, the Carrier, the Nebula Leviathan, the Dreadnought and the Hive Mind.
- **Weapon upgrades, four specials, combos, chapter tallies, high scores, continues, three difficulty levels** and remappable keyboard and gamepad controls.
- **A data-driven engine.** Levels, enemies and sprites are plain text files you can edit without recompiling.

## Building and running

You need [QB64 Phoenix Edition](https://www.qb64phoenix.com/) 4.x. Open `Spaceship.bas` and compile, or run this from the command line:

```
qb64pe -x Spaceship.bas -o Spaceship
```

Keep the `data/` and `Audio/` folders next to the executable.

## How to play

| Action | Keyboard (default) | Gamepad (default) |
|---|---|---|
| Move | Arrows or WASD | Left stick |
| Fire | Z or Space | Button 1 |
| Use special | X or Left Shift | Button 2 |
| Switch special | C or Tab | Button 7 |
| Pause | Enter, P or Esc | Button 8 |
| Mute | M | |

All of these can be changed under **Controls** on the title screen.

- **Watch your energy.** Every shot drains your ship's energy cell. It refills once you stop firing for a second, and if it runs dry your guns go quiet until it does. A green energy pickup refills it straight away.
- **Your ship takes two hits.** The first hit shrinks it to a smaller, damaged ship. The next hit destroys it. A green **heart** repairs the ship; if it's already whole, the heart gives an extra life.
- **Weapons (W pickup) go up to level 4:** single laser, twin lasers, spread shot (twin plus diagonals), then piercing beam. The GUN gauge on the HUD shows your level. Taking damage drops you one level.
- **Specials:** Time **F**reeze, smart **B**omb, homing **M**issiles and **O**verdrive (fast fire at no energy cost). They appear as the campaign progresses, and the HUD shows how many of each you carry.
- **Combos:** kills in quick succession raise your score multiplier, up to ×8.
- **Enemies hold their fire until you attack first.** That rule from the original game still applies on Easy and Normal; on Hard they shoot on sight.

**Zen mode** (on the title menu) has no enemies, no damage and no score. You drift through a deep starfield to slow ambient music while planets, comets and stations float by. The map is many screens tall: up and down scroll the view (the ship stays centered until the map runs out) into new areas, from deep space down to the hive, each with its own scenery. Right speeds up, left slows down, and Esc returns to the menu. Somewhere out there is a **portal** that drifts by every so often at its own height. A pulsing arrow at the screen edge means it's passing just above or below you, and after a while the altitude gauge marks its height. Touch it to engage overdrive, blast off and see your tally.

Leave the title screen alone for 15 seconds and the autopilot plays a demo of a chapter from a sector you have already reached. Press any key to get back to the menu. Demos never save scores or progress.

## Project layout

```
Spaceship.bas        startup, main loop, logo
src/types.bi         constants, types and shared state
src/*.bm             engine modules: player, enemies, bosses, bullets, pickups,
                     levels, world (stars/terrain), render, fx, input, audio,
                     config, states (menus and screens), demo (attract mode),
                     zen (zen mode), test (autopilot)
data/sprites.txt     all sprites, as plain ASCII art
data/enemies.txt     enemy definitions
data/campaign.txt    sectors, briefings and chapter order
data/levels/*.lvl    one script per chapter
data/zen.txt         the zen mode map: areas and their scenery
Audio/               music and sound effects
tools/               make_zen_music.py writes Audio/zen.mid
```

## Making levels and enemies

Every data file starts with a comment block that documents its format. In short:

**Sprites** (`data/sprites.txt`) are drawn between `|` fences. A few ASCII characters stand in for CP437 blocks, so the file stays plain text:
`#` full block, `^` and `_` upper and lower half blocks, `[` and `]` left and right half blocks, and `.` `:` `%` for the three shade levels. You can add an optional `COLORS` grid to color individual cells.

**Enemies** (`data/enemies.txt`) are one line each:

```
ENEMY GUNSHIP sprite=GUNSHIP hp=6 pts=300 color=7 move=HOVER speed=12 fire=SPREAD3 firerate=1.4 drop=WEAPON:15
```

**Levels** (`data/levels/*.lvl`) combine settings with a timeline:

```
NAME ROCK ALLEY
MUSIC SECTOR2
GOAL SURVIVE 90
POOL 4 ROCK_L:3 FIGHTER:1          ; keep 4 enemies alive, weighted mix
AT 1 TIP BASE:ASTEROID FIELD AHEAD!
EVERY 14 FROM 10 WAVE FIGHTER x4 V
AT 50 POOL 5 ROCK_L:3 SAUCER:1 FIGHTER:1
```

Goals can be `KILLS`, `SURVIVE`, `DISTANCE`, `COLLECT` or `BOSS`. Other settings include `TERRAIN`, `FOG`, `STORM`, `BACKDROP` and `LOOP`. The full list is in the comments at the top of `src/levels.bm`.

**Zen map** (`data/zen.txt`) is a stack of `AREA <from> <to> <name>` blocks, each followed by `SCENE <gap> <sprite> <depth> <color> <row>` lines that loop while you fly. From and to are view positions in rows (a screen is 24, negative is up). Depth runs from 0 (far away, crawls past) to 1 (close, rushes by). The portal is placed at random in any area except the one you start in.

## Command-line options and autotest

```
Spaceship -chapter 9            start straight at a chapter (bonus stages count too)
Spaceship -god                  invincible ship and cheat keys: L ends the chapter,
                                W weapon up, B refills specials, F freezes
Spaceship -difficulty 3         1 easy, 2 normal, 3 hard
Spaceship -parallax             the starfield slides up and down as the ship climbs and dives
Spaceship -autotest 600 -fast -shots shots/ -every 10
                                the game plays itself for 600 seconds of game time,
                                saves screenshots and writes autotest.log
```

F1 shows a debug overlay with FPS and entity counts while you play.

Autotest runs are muted unless you add `-sound`. The log lists chapter starts and goals, boss fights, every hit the ship takes and what caused it, deaths, tallies and any runtime errors.

## Credits

Original game and engine (2016): Fellippe Heitor. Original sounds and music are in `Audio/`. The new sector, bonus, final-boss and ending themes are MIDI files, and the new sound effects were synthesized for this edition.
