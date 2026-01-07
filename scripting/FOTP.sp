#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#define PLUGIN_VERSION "1.2.0"

// Cookie and cvar names
#define FOV_COOKIE     "sm_player_fov"
#define TP_COOKIE      "sm_player_tp"

// FOV settings
#define MIN_FOV        20
#define MAX_FOV        200
#define DEFAULT_FOV    90

// Plugin handles
Handle FovCookie = null;
Handle TpCookie  = null;

public Plugin myinfo =
{
  name        = "FOTP",
  author      = "Tolfx",
  description = "FOV and FP/TP",
  version     = PLUGIN_VERSION,
  url         = "https://github.com/UDL-TF/FOV-TP"
};

public void OnPluginStart()
{
  RegConsoleCmd("sm_fov", CommandSetFov, "Set your preferred FOV (75-90).");
  RegConsoleCmd("fov", CommandSetFov);  // Alias

  RegConsoleCmd("sm_tp", CommandThirdPerson, "Toggle third-person view.");
  RegConsoleCmd("sm_fp", CommandFirstPerson, "Toggle third-person view.");

  FovCookie = RegClientCookie(FOV_COOKIE, "Player's preferred FOV", CookieAccess_Public);
  TpCookie  = RegClientCookie(TP_COOKIE, "Player's third-person state (0=off, 1=on)", CookieAccess_Public);

  HookEvent("player_spawn", OnPlayerSpawn);
  HookEvent("player_class", OnPlayerSpawn);
}

public void OnClientCookiesCached(int client)
{
  char FovValue[8];
  GetClientCookie(client, FovCookie, FovValue, sizeof(FovValue));

  int fov = StringToInt(FovValue);

  if (fov < MIN_FOV || fov > MAX_FOV)
  {
    fov = DEFAULT_FOV;
  }
  SetPlayerFov(client, fov);

  char tpState[4];
  GetClientCookie(client, TpCookie, tpState, sizeof(tpState));

  bool TpEnabled = (StringToInt(tpState) == 1);

  ApplyThirdPersonState(client, TpEnabled);
}

public Action CommandSetFov(int client, int args)
{
  if (client == 0)  // Block from server console
  {
    ReplyToCommand(client, "[SM] This command can only be used by a player.");
    return Plugin_Handled;
  }

  if (args < 1)
  {
    SetClientCookie(client, FovCookie, "");
    QueryClientConVar(client, "fov_desired", OnFovDesiredQueried);
    ReplyToCommand(client, "[SM] Your FOV has been reset to your client settings.");
    return Plugin_Handled;
  }

  char arg[8];
  GetCmdArg(1, arg, sizeof(arg));
  int fov = StringToInt(arg);

  if (fov < MIN_FOV)
  {
    fov = MIN_FOV;
    ReplyToCommand(client, "[SM] FOV too low! Clamping to minimum: %d.", MIN_FOV);
  }
  else if (fov > MAX_FOV)
  {
    fov = MAX_FOV;
    ReplyToCommand(client, "[SM] FOV too high! TF2 limit is 90. Clamping to maximum: %d.", MAX_FOV);
  }

  SetPlayerFov(client, fov);

  char fovValue[8];
  IntToString(fov, fovValue, sizeof(fovValue));
  SetClientCookie(client, FovCookie, fovValue);

  ReplyToCommand(client, "[SM] Your FOV has been set to %d and saved.", fov);

  return Plugin_Handled;
}

public Action CommandThirdPerson(int client, int args)
{
  if (client == 0)  // Block from server console
  {
    ReplyToCommand(client, "[SM] This command can only be used by a player.");
    return Plugin_Handled;
  }

  ApplyThirdPersonState(client, true);
  SetClientCookie(client, TpCookie, "1");

  ReplyToCommand(client, "[SM] Third-person enabled.");

  return Plugin_Handled;
}

public Action CommandFirstPerson(int client, int args)
{
  if (client == 0)  // Block from server console
  {
    ReplyToCommand(client, "[SM] This command can only be used by a player.");
    return Plugin_Handled;
  }

  // Apply the new state
  ApplyThirdPersonState(client, false);

  // Save the new state to the cookie
  SetClientCookie(client, TpCookie, "0");

  ReplyToCommand(client, "[SM] Third-person disabled.");

  return Plugin_Handled;
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
  int  client = GetClientOfUserId(event.GetInt("userid"));
  bool inGame = IsClientInGame(client);
  if (!inGame)
  {
    return;
  }

  // Re-apply saved FOV
  char fovValue[8];
  GetClientCookie(client, FovCookie, fovValue, sizeof(fovValue));
  int fov = StringToInt(fovValue);
  if (fov < MIN_FOV || fov > MAX_FOV)
  {
    fov = DEFAULT_FOV;
  }

  SetPlayerFov(client, fov);

  CreateTimer(0.2, SetViewOnSpawn, client);
}

public void OnFovDesiredQueried(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
  if (!IsClientInGame(client))
  {
    return;
  }

  SetEntProp(client, Prop_Send, "m_iFOV", StringToInt(cvarValue));
  SetEntProp(client, Prop_Send, "m_iDefaultFOV", StringToInt(cvarValue));
}

void SetPlayerFov(int client, int fov)
{
  if (IsClientInGame(client))
  {
    char fovValue[8];
    IntToString(fov, fovValue, sizeof(fovValue));

    SetEntProp(client, Prop_Send, "m_iFOV", fov);
    SetEntProp(client, Prop_Send, "m_iDefaultFOV", fov);
  }
}

void ApplyThirdPersonState(int client, bool enable)
{
  if (IsClientInGame(client))
  {
    SetVariantInt(enable ? 1 : 0);
    AcceptEntityInput(client, "SetForcedTauntCam");
  }
}

Action SetViewOnSpawn(Handle handler, int client)
{
  char tpState[8];
  GetClientCookie(client, TpCookie, tpState, sizeof(tpState));
  bool tpEnabled = (StringToInt(tpState) == 1);
  ApplyThirdPersonState(client, tpEnabled);
  return Plugin_Handled;
}