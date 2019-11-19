# MESECK-CSC-240-final-project
Final Project for CSC-240 (Arduino/Assembly)

Hardware Selection:
    1) 1x Potentiometer
    2) 2x Button
    3) 1x Adafruit 128x64 OLED screen

-------------------------------------------------Pre-Alpha Design Framework------------------------------------------------------

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


-----------------------------------As other problems arise they will be recorded below------------------------------------------



------------------------------------------Alpha Updates to Project Framework----------------------------------------------------



-------------------------------------------Beta Updates to Project Framework----------------------------------------------------



--------------------------------------------------Release Version Notes---------------------------------------------------------

