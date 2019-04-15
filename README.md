PICOLOVEPOTION
--------

A fork of the gamax92's fork of PICOLOVE, an implementation of PICO-8's API for the Löve Potion implementation of the LÖVE2D game engine

Original PICOLOVE is on github at: https://github.com/picolove/picolove  
gamax92's fork is on github at: https://github.com/gamax92/picolove  
Requires a homebrew cabaple Nintendo Switch

PICO-8: http://www.lexaloffle.com/pico-8.php  
Löve Potion: https://github.com/TurtleP/LovePotion
LÖVE: https://love2d.org/

##### What it is:

 * An implementation of PICO-8's api for Löve Potion

#### Current status:

 * Incomplete
 * Able to parse the cart's sprite sheet and set it to canvas for drawing
 * Switch gamepad input is able to be detected and should be usable by PICO-8 btn() calls
 * Basics of graphics API is working

#### Basic Roadmap:

 * Fix graphics incompatibilities
 * Fix other bugs
 * make both 30 and 60 fps work properly
 * add png cart support
 * Add SFX and music support
 * SPLORE support?
 * 3ds support?

##### Why:

 * For a fun challenge!
 * Allow standalone publishing of PICO-8 games on (Homebrew capable) Nintendo Switch (and maybe later 3ds)
 * Open source

##### What it isn't:

 * Fully functional
 * A replacement for PICO-8
 * A perfect replica
 * No dev tools, no image editor, map editor, sfx editor, music editor
 * No modifying or saving carts
 * No GIF recording
 * Not memory compatible with PICO-8

##### Differences/Known issues:

 * pget() does not work (will require an update to LovePotion or a very big refactor to graphics)
 * some graphics not rendering properly
 * floating point, not fixed point
 * no audio
