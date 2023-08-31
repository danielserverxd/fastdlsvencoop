//format: #include "AFBaseExpansions/<expansionfilename>"
//example: #inclue "AFBaseExpansions/BasicExpansion"
#include "AFBaseExpansions/AF2Player"
#include "AFBaseExpansions/AF2Entity"
#include "AFBaseExpansions/AF2Fun"
#include "AFBaseExpansions/AF2EKI"
#include "AFBaseExpansions/AF2Menu"
#include "AFBaseExpansions/balloonmod"
#include "AFBaseExpansions/hookmod"
#include "AFBaseExpansions/hats"
#include "AFBaseExpansions/simpletrail"



//add includes above this line

void AFBaseCallExpansions()
{
	//add calls below this line
	//format: <expansionname>_Call();
	//example: BasicExpansion_Call();
	AF2Player_Call(); // adminfuckery 2 player commands
	AF2Entity_Call(); // adminfuckery 2 entity commands
	AF2Fun_Call(); // adminfuckery 2 fun commands
	AF2Menu_Call(); // adminfuckery 2 menu system
	HookMod_Call();
	BalloonMod_Call();
	Hats_Call();
	SimpleTrail_Call();
	
	
	
}