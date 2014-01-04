Battle Flow
===========
This is the flow of an in-game battle, assuming the battle has already been hosted and another player has joined.

1. User connects to battle for the first time
	a. User sends *ready* event
	b. Server sends *phase* event from *initial* to *game*
	c. Server sends *your-turn* event
	d. Server send *draw-card* event with initial drawn cards
