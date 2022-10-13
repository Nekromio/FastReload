#pragma semicolon 1

#include <sdkhooks>
#include <vip_core>

#pragma newdecls required

ConVar
	cvEnable,
	cvTimeReload;

bool
	bDebag;

static const char g_sFeature[] = "freload";

public Plugin myinfo = 
{
	name = "ViP Fast Reload",
	author = "Nek.'a 2x2",
	description = "Быстрая перезарядка",
	version = "1.2.1",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvEnable = CreateConVar("sm_core_freload_enable", "1", "Включить/выключить плагин быстрой перезарядки", _, true, _, true, 1.0);
	
	cvTimeReload = CreateConVar("sm_core_freload_time", "0.7", "Время перезарядки");
	
	AutoExecConfig(true, "vip_fast_reload", "vip");
	
	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void OnPluginEnd()
{
	if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available)
		VIP_UnregisterFeature(g_sFeature);
}

public void VIP_OnVIPLoaded()
{
	VIP_RegisterFeature(g_sFeature, BOOL);
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if(cvEnable.BoolValue && iEntity && (strncmp(sClassname, "weapon_", 7) == 0))
	{
		SDKHook(iEntity, SDKHook_Reload, Reload);
	}
}

public Action Reload(int iWeapon)
{
	CreateTimer(cvTimeReload.FloatValue, TimerFastReload, iWeapon);
}

public Action TimerFastReload(Handle hTimer, any iWeapon)
{
	if(IsValidEntity(iWeapon))
    {
		int iClient = GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity");
		
		if(iClient == -1 || !iClient || !IsClientInGame(iClient) && !IsFakeClient(iClient) && IsPlayerAlive(iClient) || !VIP_IsClientVIP(iClient) || !VIP_IsClientFeatureUse(iClient, g_sFeature))
			return Plugin_Continue;

		SetEntPropFloat(iWeapon, Prop_Send, "m_flTimeWeaponIdle", 0.0);
		SetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack", 0.0);
		SetEntPropFloat(iClient, Prop_Send, "m_flNextAttack", 0.0);
		if(bDebag)
		{
			PrintToChat(iClient, "Включена быстрая перезарядка");
			PrintToChatAll(g_sFeature);
		}
	}
	return Plugin_Stop;
}