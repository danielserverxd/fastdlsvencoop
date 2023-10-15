#include "weapon_knife"
#include "weapon_ofshockrifle"

void RegisterBlackOpsClassicWeapons()
{
  RegisterKnife();
  CShockRifle::Register();
}

array<ItemMapping@> g_BlackOpsClassicWeapons = 
{
  ItemMapping('weapon_shockrifle', CShockRifle::GetName())
};