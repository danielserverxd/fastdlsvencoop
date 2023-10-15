#include "weapon_ofshockrifle"

void RegisterHLClassicWeapons()
{
  CShockRifle::Register();
}

array<ItemMapping@> g_HLClassicWeapons = 
{
  ItemMapping('weapon_shockrifle', CShockRifle::GetName())
};