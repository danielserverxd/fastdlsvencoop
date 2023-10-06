#include "weapon_knife"
#include "weapon_ofshockrifle"
#include "weapon_penguin"

void RegisterOpforClassicWeapons()
{
  RegisterKnife();
  CPenguin::Register();
  CShockRifle::Register();
}