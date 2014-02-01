Front-end Architecture
======================
This document describes the client-side code structure.

BattleAnimator
==============
This class is responsible for orchestrating all of the animation for the battle. Cards can be played, casted as spells, attack other cards and all of this
must be animated in a clear manner to the player so that the player knows the state of the battle at all times.
Additionally, heroes can attack and cast abilities.

The flexible nature of abilities on the server-side means that the client only receives "actions" which simply represent atomic changes to the battle's state.
There are higher-order actions (such as play-card, or cast-card) that help to encapsulate the lower-level actions by providing the source of the resulting actions.
For instance, a 'cast-card' higher-order action will be passed to the client, followed by multiple lower-level actions such as 'damage' or 'heal' which indicate
precisely the effects of the 'cast-card' action.

The client-side code must bundle the lower-level actions under the heading of a single higher-order action that is the responsible event for the actions.

FX
==
FX classes will be used to construct the particle effects, sounds, etc of a single higher-order action (such as casting a spell card).  The abilities themselves designate
which FX class should be used to present the resulting effects of casting a card.

Ideally the special FX system is flexible enough to handle all of the possible permutations of abilities and actions. This means each FX should be able to handle multiple targets,
a single target, or no target and present this to the user.  For instance, consider a simple attack effect that draws a bolt of electricity from the hero to a target.  If multiple targets are provided
then multiple bolts should be fired at each target. If a single target is provided, then a single bolt is animated. Additionally, if no targets are provided, then the effect should
animate some sort of "area of effect" animation, for instance an expanding ring of electricity emitted from the hero's position.
