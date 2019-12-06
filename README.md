# MESECK-CSC-240-final-project
Final Project for CSC-240 (Arduino/Assembly)

Hardware Selection:

    1) 1x Potentiometer
    2) 1x Adafruit 128x64 OLED screen

-------------------------------------------------Pre-Alpha Design Framework OFFICIAL------------------------------------------------------

After the initial failed attempt to make a reasonably paired down version of tetris on the ATtiny416 Xplained (not enough program memory to store all necessary information about pieces, positions, and rotation data), I have determined in order to finish this project that I will create a game with similar hardware, but less memory requirements. The Hardware organization will not change from the previous project, just the software implementation.

This game will be similar to most basket catching mini-games in party style games in which fruit falls from a tree and must be caught in a basket controlled by the player. The twist on this is that it is framed a bit more urgently, requiring the player to move a "Planetary Defense Sheild" in order to stop oncoming attacks. In a style similar to Space Invaders, but without the ability to fight back directly you are tasked with delaying the inevitable demise of the planet earth (a metaphor for trying to program Tetris on an ATtiny416) while the rest of humanity attempts to "abandon ship" (a metaphor for abandoning the original Tetris idea to hopefully land on greener pastures). 

Gameplay will consist of a potentiometer (working as it originally intended) to control the "sheild" which will be a combination of 2 solid blocks. The potentiometer will be twisted left and right to move the blocks in a corresponding fashion. These blocks will be tasked with catching descending projectiles too many missed of which will cause the player to lose, and enough caught of which will cause the player to win. The simplistic gameplay will be made harder by tweaking the generation mechanics of the projectiles as well as the speed of their descent.

This project will still implement both the Hardware Timer and the ADC in interrupt mode. 

    -The Hardware timer will be responsible for controlling the refreshing of the screen at 60Hz.

    -The ADC will be responsible for positioning the shield in synchronous timing with the refreshing of the screen.




-------------------------------------------------**NON-FEASIBLE FIRST PROJECT**------------------------------------------------------

Largely, my game seeks to emulate Alexey Pajitnov's Soviet classic Tetris. Much like his orignial version, this game will be
monochromatic and have very few of the polished features that make modern Tetris distinct from its most primal form. The primary mechanics that this project seeks to implement are as follows: 

    1) Random Generation of Pieces (Tetrominos)
    2) Left-right translation of pieces using a Potentiometer
    3) 90 degree rotation both clockwise
    4) Steady drop of piece towards bottom of the board
    5) When a line is filled, clear the line
    6) when a piece would go off the top of the screen, loss condition is met

The unique aspect of this project as opposed to most other versions of Tetris is the implemetation of the left-right translation being in a dial rather than button form. This will use the ADC (in interrupt mode) to update the X position of the piece. The rotations will be handled through one of the remaining buttons. I anticipate the the most time consuming issue I will have will be the consistent rotation of each piece as well as ensuring I have enough memory to ensure the consistency of the pieces. This will be accomplished in 2 parts:

    1) Every piece will exist within a 4x4 page area that will be moved along the screen. The left right translation of the piece will be stopped when a block in that 4x4 page area is adjacent to a wall.
    2) Each iteration of every piece will be stored as a 16-bit integer that reference each page with an offset corresponding to an array of at most 4 16-bit integers. This array will be cycled through and each new rotation will be rewritten to the 4x4 page area that the block resides in. 

**********This project has been found to be impossible with the level of required program memory for all of the pieces to either be written to other parts of memory and to refer to them dynamically as intended. If there was a different display framework available this could largely be avoided, but the Adafruit Libraries take up too much of the array space in program memory. A new project has been worked out, and all relevant files will be updated.***********

------------------------------------------Alpha Updates to Project Framework----------------------------------------------------
Changed quite literally the whole project other than the hardware design. 
Can display the Paddle and an Arrow.


-------------------------------------------Beta Updates to Project Framework----------------------------------------------------
CURRENT FEATURES:
    Full movment of the paddle established (its actually very smooth and consistent too).
    TECHNICALLY the movement of the arrow down works (it should and when I step through it it should work) but there is an issue between the delay for the game timer and the refreshing of the screen so it gets stuck somehow I have no idea how.
    I did sacrifice a bit as the ADC only kind of runs in interrupt mode (technically it still does but it only starts and stops within the confines of setting array positions in the refresh interrupt so it is kind of cheating).

STILL LEFT:
    Fixing the arrows movement
    Implement random x position generation for the arrows
    Check win/loss state
    win/loss screens that end the game.
    Minor aesthetic fixes.


--------------------------------------------------Release Version Notes---------------------------------------------------------

