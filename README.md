PICOLOVEPOTION
--------

This project is no longer in development. Consider using https://github.com/jtothebell/fake-08 to play Pico 8 games on the Switch.

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

#### How to use
 * Get a homebrew capable switch (I can't offher help on this, but you can start here: https://nh-server.github.io/switch-guide/)
 * Download the latest LovePotion build (see the releases page: https://github.com/TurtleP/LovePotion/releases. Currently latest build is 1.1.0)
 * put the LovePotion build in the "switch" folder of you Switch's SD card, and then PicoLovePotion (all files from this repo) in the "switch/LovePotion/game" directory
 * add your own *.p8 cart and change the name of the in main.lua
 * cross your fingers

 If you want to build a standalone game, use the above instructions but follow the directions for distribution in the LovePotion wiki (https://turtlep.github.io/LovePotion/wiki/#/packaging)

#### Basic Roadmap:

 * Fix bugs
 * optimize slowness (palette shifting, other places to combine pixel setting calls)
 * add png cart support? (may need image data support from LovePotion for this)
 * Add SFX and music support (may need support for creating in memory sound objects from LovePotion)
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
 * pal() and palt() are very slow on initial use, and screen palette shifting is not supported
 * Based on Lua 5.1, so GOTO (and possible other pico 8 supported features) not working
 * memory functions (peek(), poke(), memcpy(), memset(), etc) not implemented
 * floating point, not fixed point numbers
 * no audio
