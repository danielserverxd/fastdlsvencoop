#include "weapon_knife"
#include "weapon_ofshockrifle"
#include "weapon_penguin"

void RegisterOpforClassicWeapons()
{
  RegisterKnife();
  CPenguin::Register();
  CShockRifle::Register();
}

array<ItemMapping@> g_OpforClassicWeapons = 
{
  ItemMapping('weapon_shockrifle', CShockRifle::GetName())
};