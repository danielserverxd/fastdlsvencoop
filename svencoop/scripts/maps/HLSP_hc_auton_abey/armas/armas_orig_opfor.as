#include "weapon_knife"
#include "weapon_ofshockrifle"

void RegisterOpforClassicWeapons()
{
  RegisterKnife();
  CShockRifle::Register();
}