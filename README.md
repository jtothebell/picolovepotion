PICOLOVE
--------

A fork of the original PICOLOVE, an implementation of PICO-8's API in LÖVE

Original is on github at: https://github.com/ftsf/picolove

Requires Love 0.10.x

What it is:

 * An implementation of PICO-8's api in LÖVE

What is PICO-8:

 * See http://www.lexaloffle.com/pico-8.php

What is LÖVE:

 * See https://love2d.org/

Why:

 * For a fun challenge!
 * Allow standalone publishing of pico-8 games on other platforms
  * should work on mobile devices
 * Configurable controls
 * Extendable
 * No arbitrary cpu or memory limitations
 * No arbitrary code size limitations
 * Better debugging tools available
 * Open source

What it isn't:

 * A replacement for PICO-8
 * A perfect replica
 * No dev tools, no image editor, map editor, sfx editor, music editor
 * No modifying or saving carts
 * Not memory compatible with PICO-8

Not Yet Implemented:

 * Memory modification/reading

Differences:

 * Uses floating point numbers not fixed point
 * Uses luajit not lua 5.2

Extra features:

 * `ipairs()`, `pairs()` standard lua functions
 * `assert(expr,message)` if expr is not true then errors with message
 * `error(message)` bluescreens with an error message
 * `warning(message)` prints warning and stacktrace to console
 * `setfps(fps)` changes the consoles framerate
 * `_keyup`, `_keydown`, `_textinput` allow using direct keyboard input
