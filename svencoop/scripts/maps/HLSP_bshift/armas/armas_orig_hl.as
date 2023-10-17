//#include "weapon_hlmp5"
//#include "weapon_hlshotgun"
#include "weapon_ofshockrifle"

void RegisterHLClassicWeapons()
{
  //RegisterHLMP5();
  //RegisterHLShotgun();
  CShockRifle::Register();
}

array<ItemMapping@> g_HLClassicWeapons = 
{
  //ItemMapping('weapon_9mmar', 'weapon_hlmp5'),
  //ItemMapping('weapon_mp5', 'weapon_hlmp5'),
  //ItemMapping('weapon_m16', 'weapon_hlmp5'),
  //ItemMapping('weapon_shotgun', 'weapon_hlshotgun'),
  ItemMapping('weapon_shockrifle', CShockRifle::GetName())
};