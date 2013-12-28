Views
============
This document lists the views for the client, each view encapsulates the
front-end logic for a specific component of Jira Heroes.

HeroMenu
---------
This view allows the user to select an existing hero or create a new one.
1. If the user selects an existing hero and that hero is on a campaign
the user will be taken to the Campaign view with that hero.
2. If the user selects an existing hero and that hero is NOT on a campaign
then the user will be taken to the CampaignMenu view to join or create a campaign
3. If the user selects the option to create a new hero, the user is taken to the
CreateHero view.

CreateHero
-----------
This view allows the user to create a new hero. The user selects a hero class
and enters a name for the hero.
1. If the user confirms the creation of the hero, then the user is returned to the HeroMenu with the new hero selected
2. If the user cancels the creation of the hero, then the user is returned to the HeroMenu

CampaignMenu
------------
This view allows the user to join an existing campaign or create a new campaign
1. If the user joins an existing campaign then the user moves to the Campaign view.
2. If the user creates a new campaign then the user moves to the Campaign view
3. The user may go back to the HeroMenu from here without joining any campaign

Campaign
------------
This view presents the map of the campaign and allows the user to move his hero around
the map.  Additionally, the user can elect to spend story points on abilities and buy
items for their hero using gold from this view.

This view should make a connection to the socket server.

1. If the user enters a battle on the map then the user is taken to the Battle view
2. If the user leaves the campaign he is returned to the HeroMenu
