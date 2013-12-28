Game Flow
=========

Most of the Jira Heroes game takes place within an HTML5 canvas element rendered on the webpage.  This allows re-use of various components that are necessary
for the ingame logic to be used in menus (such as rendering heroes).

1. User goes to website
Upon first loading the Jira Heroes homepage, if the user is not logged in he will be redirected to the login page.
After logging in the user will be redirected to the homepage.

2. Main menu
The main menu displays options to view/edit/create decks, view the card library, host a battle or join a battle.

	2.1 Deck Menu
	The deck menu displays all of the decks the user has built as well as an option to create a new deck.
	If the user clicks on an existing deck, it will send the user to the deck editor for that deck.
	If the user clicks on the create a deck option, the user will be asked to pick a hero and a name for the deck.
		Then the user will be taken to the deck editor for the newly created deck.

		2.1.1 Deck Editor
		The deck editor displays a list of all of the cards currently in the deck (with their mana cost).
		From this menu the user can add new cards to the deck or remove cards currently in the deck.

	2.2 Host a Battle
	The host battle menu will display a spinner while waiting for another player to join the battle.
	Once another player joins the battle the user is taken to the battle screen.
	The user may also choose to cancel the battle and be taken back to the Main Menu

	2.3 Join a Battle
	The join battle menu displays all battles that are currently open and waiting for an opponent.
	The user can click on a battle to immediately join that battle.

3. Battle Screen
The battle screen displays the current battle and is repsonsible for presenting the state of the battle
as well as allowing the user to play the game
