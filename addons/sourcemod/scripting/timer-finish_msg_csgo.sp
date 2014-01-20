#include <sourcemod>
#include <cstrike>
#include <timer>
#include <timer-stocks>
#include <timer-config_loader.sp>

new bool:g_timer = false;
new bool:g_timerPhysics = false;
//new bool:g_timerMapzones = false;
//new bool:g_timerCpMod = false;
//new bool:g_timerLjStats = false;
//new bool:g_timerLogging = false;
//new bool:g_timerMapTier = false;
//new bool:g_timerRankings = false;
//new bool:g_timerRankingsTopOnly = false;
//new bool:g_timerScripterDB = false;
new bool:g_timerStrafes = false;
//new bool:g_timerTeams = false;
//new bool:g_timerWeapons = false;
new bool:g_timerWorldRecord = false;

public Plugin:myinfo = 
{
	name = "[Timer] Finish Message",
	author = "Zipcore",
	description = "",
	version = "1.0",
	url = "zipcore#googlemail.com"
};

public OnPluginStart()
{
	g_timer = LibraryExists("timer");
	g_timerPhysics = LibraryExists("timer-physics");
	//g_timerMapzones = LibraryExists("timer-mapzones");
	//g_timerCpMod = LibraryExists("timer-cpmod");
	//g_timerLjStats = LibraryExists("timer-ljstats");
	//g_timerLogging = LibraryExists("timer-logging");
	//g_timerMapTier = LibraryExists("timer-maptier");
	//g_timerRankings = LibraryExists("timer-rankings");
	//g_timerRankingsTopOnly = LibraryExists("timer-rankings_top_only");
	//g_timerScripterDB = LibraryExists("timer-scripter_db");
	g_timerStrafes = LibraryExists("timer-strafes");
	//g_timerTeams = LibraryExists("timer-teams");
	//g_timerWeapons = LibraryExists("timer-weapons");
	g_timerWorldRecord = LibraryExists("timer-worldrecord");
	
	LoadPhysics();
	LoadTimerSettings();
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "timer"))
	{
		g_timer = true;
	}
	else if (StrEqual(name, "timer-physics"))
	{
		g_timerPhysics = true;
	}	
	else if (StrEqual(name, "timer-mapzones"))
	{
		//g_timerMapzones = true;
	}		
	else if (StrEqual(name, "timer-cpmod"))
	{
		//g_timerCpMod = true;
	}	
	else if (StrEqual(name, "timer-ljstats"))
	{
		//g_timerLjStats = true;
	}	
	else if (StrEqual(name, "timer-logging"))
	{
		//g_timerLogging = true;
	}	
	else if (StrEqual(name, "timer-maptier"))
	{
		//g_timerMapTier = true;
	}	
	else if (StrEqual(name, "timer-rankings"))
	{
		//g_timerRankings = true;
	}		
	else if (StrEqual(name, "timer-rankings_top_only"))
	{
		//g_timerRankingsTopOnly = true;
	}
	else if (StrEqual(name, "timer-scripter_db"))
	{
		//g_timerScripterDB = true;
	}
	else if (StrEqual(name, "timer-strafes"))
	{
		g_timerStrafes = true;
	}
	else if (StrEqual(name, "timer-teams"))
	{
		//g_timerTeams = true;
	}
	else if (StrEqual(name, "timer-weapons"))
	{
		//g_timerWeapons = true;
	}
	else if (StrEqual(name, "timer-worldrecord"))
	{
		g_timerWorldRecord = true;
	}
}

public OnLibraryRemoved(const String:name[])
{	
	if (StrEqual(name, "timer"))
	{
		g_timer = false;
	}
	else if (StrEqual(name, "timer-physics"))
	{
		g_timerPhysics = false;
	}	
	else if (StrEqual(name, "timer-mapzones"))
	{
		//g_timerMapzones = false;
	}		
	else if (StrEqual(name, "timer-cpmod"))
	{
		//g_timerCpMod = false;
	}	
	else if (StrEqual(name, "timer-ljstats"))
	{
		//g_timerLjStats = false;
	}	
	else if (StrEqual(name, "timer-logging"))
	{
		//g_timerLogging = false;
	}	
	else if (StrEqual(name, "timer-maptier"))
	{
		//g_timerMapTier = false;
	}	
	else if (StrEqual(name, "timer-rankings"))
	{
		//g_timerRankings = false;
	}		
	else if (StrEqual(name, "timer-rankings_top_only"))
	{
		//g_timerRankingsTopOnly = false;
	}
	else if (StrEqual(name, "timer-scripter_db"))
	{
		//g_timerScripterDB = false;
	}
	else if (StrEqual(name, "timer-strafes"))
	{
		g_timerStrafes = false;
	}
	else if (StrEqual(name, "timer-teams"))
	{
		//g_timerTeams = false;
	}
	else if (StrEqual(name, "timer-weapons"))
	{
		//g_timerWeapons = false;
	}
	else if (StrEqual(name, "timer-worldrecord"))
	{
		g_timerWorldRecord = false;
	}
}


public OnMapStart()
{
	LoadPhysics();
	LoadTimerSettings();
}

public OnTimerRecord(client, bonus, mode, Float:time, Float:lasttime, currentrank, newrank)
{
	decl String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	//Record Info
	new RecordId;
	new Float:RecordTime;
	new RankTotal;
	new Float:LastTime;
	new Float:LastTimeStatic;
	new LastJumps;
	decl String:TimeDiff[32];
	decl String:buffer[32];
	
	new bool:NewPersonalRecord = false;
	new bool:NewWorldRecord = false;
	new bool:FirstRecord = false;
	
	new bool:ranked;
	if(g_timerPhysics) ranked = bool:Timer_IsModeRanked(mode);
	
	new strafes;
	if(g_timerStrafes)  strafes = Timer_GetStrafeCount(client);
	
	new Float:jumpacc;
	if(g_timerPhysics) Timer_GetJumpAccuracy(client, jumpacc);
	
	new bool:enabled = false;
	new jumps = 0;
	new fpsmax;

	if(g_timer) Timer_GetClientTimer(client, enabled, time, jumps, fpsmax);
	
	if(g_timerWorldRecord) 
	{
		/* Get Personal Record */
		if(Timer_GetBestRound(client, mode, bonus, LastTime, LastJumps))
		{
			LastTimeStatic = LastTime;
			LastTime -= time;			
			if(LastTime < 0.0)
			{
				LastTime *= -1.0;
				Timer_SecondsToTime(LastTime, buffer, sizeof(buffer), 3);
				Format(TimeDiff, sizeof(TimeDiff), "+%s", buffer);
			}
			else if(LastTime > 0.0)
			{
				Timer_SecondsToTime(LastTime, buffer, sizeof(buffer), 3);
				Format(TimeDiff, sizeof(TimeDiff), "-%s", buffer);
			}
			else if(LastTime == 0.0)
			{
				Timer_SecondsToTime(LastTime, buffer, sizeof(buffer), 3);
				Format(TimeDiff, sizeof(TimeDiff), "%s", buffer);
			}
		}
		else
		{
			//No personal record, this is his first record
			FirstRecord = true;
			LastTime = 0.0;
			Timer_SecondsToTime(LastTime, buffer, sizeof(buffer), 3);
			Format(TimeDiff, sizeof(TimeDiff), "%s", buffer);
			RankTotal++;
		}
	}
	
	decl String:TimeString[32];
	Format(TimeString, sizeof(TimeString), "");
	Timer_SecondsToTime(time, TimeString, sizeof(TimeString), 2);
	
	decl String:WrName[32];
	Format(WrName, sizeof(WrName), "");
	decl String:WrTime[32];
	Format(WrTime, sizeof(WrTime), "");
	new Float:wrtime;
	
	if(g_timerWorldRecord) Timer_GetRecordTimeInfo(mode, bonus, newrank, wrtime, WrTime, 32);
	if(g_timerWorldRecord) Timer_GetRecordHolderName(mode, bonus, newrank, WrName, 32);
	
	/* Get World Record */
	if(g_timerWorldRecord) Timer_GetDifficultyRecordTime(mode, bonus, RecordId, RecordTime, RankTotal);
	
	/* Detect Record Type */
	if(RecordTime == 0.0 || time < RecordTime)
	{
		NewWorldRecord = true;
	}
	
	if(LastTimeStatic == 0.0 || time < LastTimeStatic)
	{
		NewPersonalRecord = true;
	}
	
	new bool:self = false;
	
	if(currentrank == newrank)
	{
		self = true;
	}
	
	if(FirstRecord) RankTotal++;
	
	new Float:wrdiff = time-wrtime;
	
	decl String:BonusString[32];
	
	if(bonus == 1)
	{
		Format(BonusString, sizeof(BonusString), " {olive}bonus");
	}
	else if(bonus == 2)
	{
		Format(BonusString, sizeof(BonusString), " {olive}short");
	}	
	else
	{
		//Format(BonusString, sizeof(BonusString), " {olive}normal");
		Format(BonusString, sizeof(BonusString), "");
	}		
	
	decl String:RankString[128];
	Format(RankString, sizeof(RankString), "");
	
	decl String:RankPwndString[128];
	Format(RankPwndString, sizeof(RankPwndString), "");

	decl String:JumpString[128];
	new bool:bAll = false;
	
	decl String:StyleString[128];
	if(g_Settings[MultimodeEnable]) 
		Format(StyleString, sizeof(StyleString), " on {olive}%s", g_Physics[mode][ModeName]);
	else 
		Format(StyleString, sizeof(StyleString), "");
	
	if(NewWorldRecord)
	{
		bAll = true;
		Format(RankString, sizeof(RankString), "{lightred}NEW WORLD RECORD");
		
		if(wrtime > 0.0)
		{
			if(self)
				Format(RankPwndString, sizeof(RankPwndString), "{olive}Improved {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", "himself", wrdiff, WrTime);
			else
				Format(RankPwndString, sizeof(RankPwndString), "{olive}Beaten {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", WrName, wrdiff, WrTime);
		}
	}
	else if(newrank > 5000)
	{
		Format(RankString, sizeof(RankString), "{lightred}#%d+ / %d", newrank, RankTotal);
	}
	else if(NewPersonalRecord || FirstRecord)
	{
		bAll = true;
		Format(RankString, sizeof(RankString), "{lightred}#%d / %d", newrank, RankTotal);
		
		if(newrank < currentrank) Format(RankPwndString, sizeof(RankPwndString), "{olive}Beaten {lightred}%s{olive}! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", WrName, wrdiff, WrTime);
	}	
	else if(NewPersonalRecord)
	{
		Format(RankString, sizeof(RankString), "{orange}#%d / %d", newrank, RankTotal);
		
		Format(RankPwndString, sizeof(RankPwndString), "You have improved {lightred}yourself! {lightred}[%.2fs]{olive} diff, old time was {lightred}[%s]", wrdiff, WrTime);
	}
	
	if(g_Settings[JumpsEnable])
	{
		Format(JumpString, sizeof(JumpString), "{olive} and {lightred}%d jumps [%.2f ⁰⁄₀]", jumps, jumpacc);
	}
	
	if(g_Settings[StrafesEnable])
	{
		Format(JumpString, sizeof(JumpString), "{olive} and {lightred}%d strafes", strafes);
	}
	
	if(ranked)
	{
		if(FirstRecord || NewPersonalRecord)
		{
			if(bAll)
			{
				CPrintToChatAll("%s {olive}Player {lightred}%s{olive} has finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, name, BonusString, StyleString);
				CPrintToChatAll("{olive}Time: {lightred}[%ss] %s %s", TimeString, JumpString, RankString);
				CPrintToChatAll("%s", RankPwndString);
			}
			else
			{
				CPrintToChat(client, "%s {lightred}You{olive} have finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, BonusString, StyleString);
				CPrintToChat(client, "{olive}Time: {lightred}[%ss] %s %s", TimeString, JumpString, RankString);
				CPrintToChat(client, "%s", RankPwndString);
			}
		}
		else
		{
			CPrintToChat(client, "%s {lightred}You{olive} have finished%s{olive}%s{olive}. Time: {lightred}[%ss] %s %s", PLUGIN_PREFIX2, BonusString, StyleString, TimeString, JumpString, RankString);
		}
	}
	else
	{
		CPrintToChat(client, "{lightred}You{olive} have finished%s{olive}%s{olive}.", PLUGIN_PREFIX2, BonusString, StyleString);
		CPrintToChat(client, "{olive}Time: {lightred}[%ss] %s", TimeString, JumpString);
	}
}