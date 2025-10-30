#include <zombie_escape>
#include <nvault_util>
#include <ze_levels>
 
// Constants
new const g_szLevelsVault[] = "Levels"
new const g_szRanksVault[]  = "Ranks"
 
// Variables
new g_iLevelsVault, g_iRanksVault
 
// Cvars
new g_pCvarEnableTop, g_pCvarLevelsToShow, g_pCvarEnableRank
 
public plugin_init()
{
    register_plugin("[ZE] Level Top/Rank", "1.1", "Raheem")
   
    // Commands
    register_clcmd("say /top15", "Cmd_Top")
    register_clcmd("say_team /top15", "Cmd_Top")
    register_clcmd("say /rank", "Cmd_Rank")
    register_clcmd("say_team /rank", "Cmd_Rank")
   
    // Cvars
    g_pCvarEnableTop = register_cvar("ze_enable_top_system", "1")
    g_pCvarLevelsToShow = register_cvar("ze_levels_top_number", "10")
    g_pCvarEnableRank = register_cvar("ze_enable_rank_system", "1")
}
 
public Cmd_Top(id)
{
    if (get_pcvar_num(g_pCvarEnableTop) == 0)
        return
   
    // Open the two vaults using UTIL functions
    new iLevelsVault = nvault_util_open(g_szLevelsVault)
    new iRanksVault = nvault_util_open(g_szRanksVault)
   
    // Open Vaults
    g_iLevelsVault = nvault_open(g_szLevelsVault)
    g_iRanksVault = nvault_open(g_szRanksVault)
   
    // Max elements in Levels.vault and Rank.vault (They are same)
    new iTotal = nvault_util_count(iLevelsVault)
   
    new szKeyLevelSteam[32],    // To hold SteamID from Levels.vault
    szDataLevel[64],            // To hold Levels, XP, MaxXP from Levels.vault
    szKeyRankSteam[32],         // To hold SteamID from Ranks.vault
    szDataRank[64]              // To hold Names from Ranks.vault
   
    new Array:g_szMaxXP         // Dynamic Array to hold all MaxXP (szData) from Levels.vault
   
    // Useless Variables
    new szVal[64], iTimeStamp
   
    // Create Our Arrays with proper lengths [As we don't know iTotal Length so we use Dynamic]
    g_szMaxXP = ArrayCreate(70)
   
    // Tries
    new Trie:g_Level_MaxXP,
    Trie:g_XP_MaxXP,
    Trie:g_SteamID_MaxXP,
    Trie:g_Name_SteamID
   
    g_Level_MaxXP = TrieCreate()
    g_XP_MaxXP = TrieCreate()
    g_SteamID_MaxXP = TrieCreate()
    g_Name_SteamID = TrieCreate()
   
    // Some integer counters to be used down
    new i, iPos1 = 0, iPos2 = 0
   
    // Format motd Header
    new szMotd[3072], iLen

	iLen = formatex(szMotd, charsmax(szMotd), "<head><meta charset=utf-8><link rel=^"Stylesheet^" type=^"text/css^" href=^"http://ze-styles.gamer.gd/top15.css ^"></head><body><center><table><tr><td>#<td>Name<td>LEVEL<td>XP</tr>")
   
    // Loop through all elements in our Levels.vault and Rank.vault
    for(i = 0; i < iTotal; i++)
    {
        // Get SteamID from Levels.vault and save to szKey
        iPos1 = nvault_util_read(iLevelsVault, iPos1, szKeyLevelSteam, charsmax(szKeyLevelSteam), szVal, charsmax(szVal), iTimeStamp)
       
        // Get Levels, XP for every SteamID from Levels.vault and save to szData
        nvault_lookup(g_iLevelsVault, szKeyLevelSteam, szDataLevel, charsmax(szDataLevel), iTimeStamp)
       
        // Get SteamID from Ranks.vault and save to szKeyRank
        iPos2 = nvault_util_read(iRanksVault, iPos2, szKeyRankSteam, charsmax(szKeyRankSteam), szVal, charsmax(szVal), iTimeStamp)
       
        // Get Name from Ranks.vault and save to szDataRank
        nvault_lookup(g_iRanksVault, szKeyRankSteam, szDataRank, charsmax(szDataRank), iTimeStamp)
       
        // Spliting szData to Level and XP and Save them
        new szLevel[32], szXP[32], szMaxXP[70]
        parse(szDataLevel, szLevel, charsmax(szLevel), szXP, charsmax(szXP), szMaxXP, charsmax(szMaxXP))
       
        // Add XP+MAXXP+SteamID to be unique for every player
        formatex(szMaxXP, charsmax(szMaxXP), "%i %s", str_to_num(szMaxXP) + str_to_num(szXP), szKeyRankSteam)
       
        // Save MAX-XP As Key, Level as Key Value
        TrieSetCell(g_Level_MaxXP, szMaxXP, str_to_num(szLevel))
       
        // Save MAX-XP As Key, XP as Key Value
        TrieSetCell(g_XP_MaxXP, szMaxXP, str_to_num(szXP))
       
        // Save MAX-XP As Key, SteamID as Value
        TrieSetString(g_SteamID_MaxXP, szMaxXP, szKeyLevelSteam)
       
        // Save SteamID As Key, Name as Value
        TrieSetString(g_Name_SteamID, szKeyRankSteam, szDataRank)
       
        // Save our MaxXP to Dynamic Array
        ArrayPushString(g_szMaxXP, szMaxXP)
    }
   
    // Rank Max-XP + SteamID
    ArraySortEx(g_szMaxXP, "TopSorting")
   
    // Get Top Players Data
    for (i = 0; i < get_pcvar_num(g_pCvarLevelsToShow); i++)
    {
        // MaxXP+SteamID As Key
        new szMaxXP[70]
       
        ArrayGetString(g_szMaxXP, i, szMaxXP, charsmax(szMaxXP))
       
        // Get Level
        new Level; TrieGetCell(g_Level_MaxXP, szMaxXP, Level)
       
        // Get XP
        new XP; TrieGetCell(g_XP_MaxXP, szMaxXP, XP)
       
        // Get SteamID
        new szSteamID[36]; TrieGetString(g_SteamID_MaxXP, szMaxXP, szSteamID, charsmax(szSteamID))
       
        // Get Name
        new szName[32]; TrieGetString(g_Name_SteamID, szSteamID, szName, charsmax(szName))
 
        for (new j = 0; j < charsmax(szName); j++)
        {
            if (is_char_mb(szName[j]) > 0 || szName[j] == '<' || szName[j] == '>')
            {
                szName[j] = ' '
            }
        }
       
	    // Format Player as table row
	    iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "<tr><td>%d<td>%s<td>%d<td>%d</tr>", i + 1, szName, Level, XP)
	}
	
	// Format end of motd (close table)
	iLen += formatex(szMotd[iLen], charsmax(szMotd) - iLen, "</table></center></body>")
   
    // Finally Show motd to the player
    show_motd(id, szMotd, "Levels Rank")
   
    // Free our memory
    ArrayDestroy(g_szMaxXP)
    TrieDestroy(g_Level_MaxXP)
    TrieDestroy(g_XP_MaxXP)
    TrieDestroy(g_SteamID_MaxXP)
    TrieDestroy(g_Name_SteamID)
   
    // Closing UTIL Vaults
    nvault_util_close(iLevelsVault)
    nvault_util_close(iRanksVault)
   
    // Close Vaults
    nvault_close(g_iLevelsVault)
    nvault_close(g_iRanksVault)
}
 
public Cmd_Rank(id)
{
    if (get_pcvar_num(g_pCvarEnableRank) == 0)
        return
   
    // Open Levels vault via UTIL function
    new iLevelsVault = nvault_util_open(g_szLevelsVault)
   
    // Open Vault
    g_iLevelsVault = nvault_open(g_szLevelsVault)
   
    // Max elements in Levels.vault and Rank.vault (They are same)
    new iTotal = nvault_util_count(iLevelsVault)
   
    new szKey[32],  // To hold SteamID from Levels.vault
    szData[64]      // To hold Levels, XP from Levels.vault
   
    new Array:iMaxXP    // Dynamic Array to hold all MaxXP (szData) from Levels.vault
   
    // Useless Variables
    new szVal[64], iTimeStamp
   
    // Create Our Arrays with proper lengths [As we don't iTotal Length so we use Dynamic]
    iMaxXP = ArrayCreate(1)
   
    // Some integer counters to be used down
    new i, iPos = 0
   
    // Loop through all elements in our Levels.vault and Rank.vault
    for(i = 0; i < iTotal; i++)
    {
        // Get SteamID from Levels.vault and save to szKey
        iPos = nvault_util_read(iLevelsVault, iPos, szKey, charsmax(szKey), szVal, charsmax(szVal), iTimeStamp)
       
        // Get Levels, XP for every SteamID from Levels.vault and save to szData
        nvault_lookup(g_iLevelsVault, szKey, szData, charsmax(szData), iTimeStamp)
 
        // Spliting szData to Level and XP and Save them
        new szLevel[32], szXP[32], szMaxXP[32]
        parse(szData, szLevel, 31, szXP, 31, szMaxXP, 31)
 
        // Save our MaxXP to Dynamic Array
        ArrayPushCell(iMaxXP, ze_get_user_max_xp(id) + str_to_num(szXP))
    }
   
    // Rank Max-XP
    ArraySortEx(iMaxXP, "RankSorting")
   
    // Get Player rank
    new iIndex = 0;
   
    for (i = 0; i < ArraySize(iMaxXP); i++)
    {
        if (ArrayGetCell(iMaxXP, i) == (ze_get_user_max_xp(id) + ze_get_user_xp(id)))
        {
            iIndex = i
            break;
        }
    }
   
    ze_colored_print(id, "!tYour rank is !g%i !tof !g%i!y.", iIndex + 1, iTotal - 1)
   
    // Free our memory
    ArrayDestroy(iMaxXP)
   
    // Closing UTIL Vault
    nvault_util_close(iLevelsVault)
   
    // Close Vaults
    nvault_close(g_iLevelsVault)
}
 
public TopSorting(Array:g_szMaxXP, szItem1[], szItem2[])
{
    // 2D arrays to hold max-xp and steam id for both item1 and item2
    new szMaxXP[2][32], szSteamID[2][36]
   
    // Split item1 to Max-XP and SteamID, same for item 2
    parse(szItem1, szMaxXP[0], 31, szSteamID[0], 36)
    parse(szItem2, szMaxXP[1], 31, szSteamID[1], 36)
   
    // Start ranking
    if (str_to_num(szMaxXP[0]) > str_to_num(szMaxXP[1]))
    {
        return -1
    }
    else if (str_to_num(szMaxXP[0]) < str_to_num(szMaxXP[1]))
    {
        return 1
    }
   
    return 0
}
 
public RankSorting(Array:iMaxXP, iItem1, iItem2)
{
    if (iItem1 > iItem2)
    {
        return -1
    }
    else if (iItem1 < iItem2)
    {
        return 1
    }
   
    return 0
}