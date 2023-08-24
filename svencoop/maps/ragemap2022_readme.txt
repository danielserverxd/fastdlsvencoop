Ragemap 2022
------------

4-16 players recommended.


Map by:
- Hezus
- BonkTurnip
- Descen
- SV BOY
- I_ka
- Erty
- AlexCorruptor
- Adambean
- grunt
- Trempler


Special thanks to:
- Hezus for organising the project and putting up with all our crap mapping.
- Gauna for an epic collection of models and sprites.
- Erty for also fixing mistakes in our crap mapping.
- RC for scripting Templer's part.
- Project scripting by RC and Adambean.


CHANGELOG:
==========

Release (4th December 2022)
----------------------------

Adambean:
- (I_ka's part) Added a player medkit to the 4 spawn rooms

Grunt:
- Wood fence model in the trial by perseverance


Version RC6 (4th December 2022)
----------------------------

Adambean:
- (Config) No longer spawn with a medkit, parts that want this provide it
- (Script) Force weapon strip at the end of each part
- (AlexCorruptor's part) Improved music reliablity (some more)
- (I_ka's part) Aligned SUV glass


Version RC5 (3rd December 2022)
----------------------------

Adambean:
- (AlexCorruptor's part) Improved music reliablity (hopefully)
- (AlexCorruptor's part) Moved song text higher up the screen so the player medkit doesn't make it unreadable
- (BonkTurnip's part) Fixed janitor shelving sometimes being moved by the door
- (BonkTurnip's part) Prevented shock troopers falling down the drain (again)
- (SV BOY's part) Fixed purchased weapons sometimes disappearing from the table
- (Trempler's part) Fixed Z-fighting on the back of the neon DINER sign


Version RC4 (27th November 2022)
----------------------------

Adambean:
- Added audible tick to the get out timer
- (SV BOY's part) Corrected many spelling mistakes
- (SV BOY's part) Temporarily only use multiplative mode as additive mode isn't working
- (Trempler's part) Coloured the bells to indicate which customer they're for
- (Trempler's part) New classy bell sound

Erty:
- Fix for emergency meeting alarm playing after part finishes
- Reduced hold time for win/lose text
- (Outro) Fixed players sometimes not spawning near stage when credits starts

I_ka:
- Added signs for navigation guide
- Gagged Zombies/Aslaves that spawns behind barricaded door
- Tweaked objectives visual guide


Version RC3 (26th November 2022)
----------------------------

Adambean:
- Added weaponstrip area
- (Descen's part) Reduced lighting by request


Version RC2 (26th November 2022)
----------------------------

Adambean:
- (BonkTurnip's part) Added medkits to spawn
- (Hezus' part) All the swing doors now move one way and have crush damage to prevent blocking
- (I_ka's part) Added push to exit teleporter and raised it to prevent blocking


Version RC1 (25th November 2022)
----------------------------

AlexCorruptor:
- Changed trigger_condition frequency check to 0.9 from 1 when the timer hits 0 to prevent the timer LCD showing up as 001
- Delayed the music trigger by 0.03 seconds, potentially fixing the music problem
- Removed the debug music button behind spawns

Erty:
- (Trempler's part) updated script to use the proper skins from Hezus' can model

Hezus:
- Made new hint legend for room 7
- Added more visual feedback to room 7
- Added reset button to room 7
- Added extra ammo crates in room 7
- Fixed visible NULL face in room 6


Version 0.09 (19th November 2022)
----------------------------

Adambean:
- (BonkTurnip's part) prevented shock troopers falling down the drain

Erty:
- (Trempler's part) reduced friction modifier of Dante by 50%
- (Trempler's part) env_shooters now use Hezus' can models
- (AlexC's part) removed unused info_nodes

Grunt:
- added 2 trigger brushes near the Taog's lobby and event portal area
- replaced maxspeed cvars with changevalues instead


Version 0.08 (11th November 2022 🏵️)
----------------------------

Adambean:
- workaround for completed spawn points not being switched off
- (Descen's part) sky applied immediately on spawn

Erty:
- changed RC name secret to Trempler
- made Trempler's start box more stylish (all black now)
- AlexC's spawns have now Start Off checked
- set Embed Light Map to 1 for all glass in AlexC's part
- fixed typo in amogus intro text
- replaced Trempler's bus in outro with new version with fixed brushwork

Grunt:
- saved us 5% clipnodes!
- changed vote condition needed from 99% to 1%
- sky will apply immediately after spawning
- the ghost pillars can block decals now
- lowered the portal stair models so now they're even with the ground

Hezus:
- added numbers to room 7 puzzle hint
- created 6 individual weapon_strip triggers in room 6 puzzle

SV BOY:
- you can now choose between either 1x or 2x money mode
- upgrading health now always divides
- the cockroach buy cooldown gets reduced to 0.5 seconds if you have at least 750 credits or more
- the cockroach buy no longer announces to everyone
- updated the ballon model so they don't spam the console with developer 1 (sequence out of range)
- moved rock bonson by 1 unit
- the crowbar now also swings faster at upgrade level 3 (omg secret upgrade!!!)
- reduced the health of the secret cause it takes too long


Version 0.07 (6th Nov 2022)
----------------------------
Adambean:
- double confirmed fixes from previous build are really in place
- (BonkTurnip's part) brightened the sun
- (BonkTurnip's part) added smooth clipping to stairs
- (SV BOY's part) added assurance the right sky is in place for late joiners
- (SV BOY's part) brightened the sun

Erty:
- removed RC from outro credits
- made urgency music in AlexC's part trigger more reliably

Hezus:
- area 7 doors are now in sync
- respawn on displacer in boss area set to 1 sec


Version 0.06 (5th Nov 2022)
----------------------------
Adambean:
- (All parts) script revolutions
- delayed activation of automatic "prep" logic until this part is entered
- corrected entrance portal sprite and lighting not being active
- fixed part not ending due to a classic Hezus error :p
- (I_ka's part) fixed sunken dead scientist on the counter
- (SV BOY's part) realigned a few geometry verticies to avoid micro-leaks

AlexCorruptor:
- fixed sky not changing to intention
- fixed music not always playing

Erty:
- fixed ambient noise not stopping when part finishes
- fixed the stylisation of a name in a secret
- adjusted delays before starting next part

Grunt:
- fixed the lighting and rendering of the cliffs in spawn area
- fixed the sounds that didn't work properly
- lowered the mist height in the first event
- fixed spawn points
- added new logo

SV BOY:
- removed some invisible optimization celling due to map splitting into 3

Trempler:
- cut out pre-start spawn box
- fixed bus rear polygons
- actually triggers part_finished when finished now
- added missing button for placing products for customer0

Outro:
- fixed scripts for SV BOY's weapons for first stage of the boss fight


Version 0.05 (25th Oct 2022)
----------------------------
- project is now 3 maps (a,b,c)

Hezus:
- players can no longer bring displacer into the puzzle 6 room
- fixed door buttons being retriggered in room 7
- fixed teleporter shortcut to room 9
- fixed custom sky not triggering
- fixed ending doors alignment in room 3

Trempler:
- fixed initial spawn name error


Version 0.04 (24th Oct 2022)
----------------------------
- added tremplers part


Version 0.03 (23th Oct 2022)
----------------------------
- added boss battle to map B
- added integrated weapon scripts for SV-BOY's part
- added updated channel icons for Adambean and SV BOY
- added missing sky for Hezus' part
- added fixed balloon models for SVBOYs part


Version 0.02 (19th Oct 2022)
----------------------------
- added channel sprites for grunt, ika
- updated AlexC's part
- fixed music playing from grunt's part on spawn
- updated script files for AlexC's part
- Adambean hud sprite is now 96x96
- removed unused textures in WAD
- svboys part has light now
- fixed no model lighting on grunts part


Version 0.01 (16 Oct 2022)
--------------------------
- First internal version






Credits:
--------
BONKTURNIP:
Credits for the double barrel shotgun model and sprites:
Model: Tripwire Interactive
Textures: Tripwire Interactive, Norman The Lolo Pirate (Edits)
Animations: MyZombieKillerz
Sounds: GSC Game World (Reload), Navaro (Reload), Tripwire Interactive (Shoot), D.N.I.O. 071 (Conversion to .ogg format)
Sprites: D.N.I.O. 071 (Model Render), R4to0 (Vector), KernCore (.spr Compile)
Misc: Norman The Loli Pirate (UV Chop, World Model), D.N.I.O. 071 (Compile)

DESCEN:
=Sounds=
mk_frenship.ogg - Mortal Kombat
dragons_legend_loop.ogg - KOTO
dsflame.ogg, dsblst.ogg - Shadow Man PC game
foe_hub.ogg - Fragments of Euclid PC game (https://nusan.itch.io/fragments-of-euclid)
dsbell.ogg, dstlprt.ogg, dsstnmov.ogg, dsstnmov2.ogg, dsstnstp.ogg, dsgong.ogg - RNG
dssndfdb.ogg - Cocyx

=Sprites=
dsgameover.spr - Gauna
dsportal.spr + flames - Google search


SV BOY:
Secret art by Gauna
weapon_custom script by w00tguy
Models:
Most P and W converted models by SV BOY
Hitman Colt - Flewda, snrk
Painkiller Bonegun - KoSHak
HL2 EP2 Sniper Rifle - Jaanus , Biodude
Red Faction 2 Styled Models - Dr.ABC, THQ
Radiation Bionic Gun - Nicksven
Adambean for fixing all your ruddy script integrations
Hezus for making an awesome balloon model and generally being a nice bloke


ERTY:
Boss part & ending.


ADAMBEAN:
=Scripting=
Upgraded project scripts to be more modular.

=Other=
Generally being giant knob by constantly getting in Hezus' way.
