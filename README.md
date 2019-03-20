PICOLOVEPOTION
--------

A fork of the gamax92's fork of PICOLOVE, an implementation of PICO-8's API for the Löve Potion implementation of the LÖVE 
Original is on github at: https://github.com/picolove/picolove  
Base of this fork is on github at: https://github.com/gamax92/picolove  
Requires LÖVE 11.x

PICO-8: http://www.lexaloffle.com/pico-8.php  
Löve Potion: https://github.com/TurtleP/LovePotion
LÖVE: https://love2d.org/

##### What it is:

 * An implementation of PICO-8's api for Löve Potion

#### Current status:

 * Very incomplete
 * Able to parse the cart's sprite sheet and set it to canvas for drawing
 * Switch gamepad input is able to be detected and should be usable by PICO-8 btn() calls

#### Basic Roadmap:

 * Load and parse cart (in progress)
 * Implement PICO-8's drawing and scale to match screen size
 * Add text support
 * Add SFX and music support
 * SPLORE support?

##### Why:

 * For a fun challenge!
 * Allow standalone publishing of PICO-8 games on (Homebrew capable) Nintendo Switch (and maybe later 3ds)
 * Open source

##### What it isn't:

 * A replacement for PICO-8
 * A perfect replica
 * No dev tools, no image editor, map editor, sfx editor, music editor
 * No modifying or saving carts
 * No GIF recording
 * Not memory compatible with PICO-8

##### Differences:

 * Uses floating point numbers not fixed point
 * Uses LuaJIT not lua 5.2
 * Memory layout is not complete

##### Extra features:

 * `ipairs()`, `pairs()` standard lua functions
 * `assert(expr,message)` if expr is not true then errors with message
 * `error(message)` bluescreens with an error message
 * `warning(message)` prints warning and stacktrace to console
 * `setfps(fps)` changes the consoles framerate
 * `_keyup`, `_keydown`, `_textinput` allow using direct keyboard input
