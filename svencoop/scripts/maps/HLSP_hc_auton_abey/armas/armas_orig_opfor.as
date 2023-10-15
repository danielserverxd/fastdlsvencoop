#include "weapon_knife"
#include "weapon_ofshockrifle"

void RegisterOpforClassicWeapons()
{
  RegisterKnife();
  CShockRifle::Register();
}

array<ItemMapping@> g_OpforClassicWeapons = 
{
  ItemMapping('weapon_shockrifle', CShockRifle::GetName())
};