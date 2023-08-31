#include "weapons/weapon_hrpython"
#include "weapons/weapon_hrcrowbar"


void MapInit()
{ 	
        HR_PYTHON::RegisterPython();
        HR_CROWBAR::RegisterCrowbar();
}