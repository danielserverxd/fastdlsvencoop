#include "weapon_hlmp5"
#include "weapon_hlshotgun"
#include "weapon_ofshockrifle"

void RegisterHLClassicWeapons()
{
  RegisterHLMP5();
  RegisterHLShotgun();
  CShockRifle::Register();
}