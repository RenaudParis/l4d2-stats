/**
 * Configuration settings
 */
::ADV_STATS_EXTRA_STATS <- true	    // Activate extra stats
::ADV_STATS_BOTS_ENABLED <- true    // Activate bots stats
::ADV_STATS_FF_BOTS_ENABLED <- true // Activate FF done to bots
::ADV_STATS_SELF_FF_ENABLED <- true	// Self FF taken into consideration
::ADV_STATS_LOG_LEVEL <- 2          // 0 = no debug, 1 = info level, 2 = debug level
::ADV_STATS_DUMP <- true            // Dump stats data at start/end of map
/**
 * End of configuration settings
 */

IncludeScript("logger.nut");
IncludeScript("hud.nut");
IncludeScript("events.nut");

::ADV_STATS_VERSION <- "1.1 beta";
::ADV_STATS_LOGGER <- Logger(::ADV_STATS_LOG_LEVEL);
::AdvStats <- {
	cache = {},
	welcome_hud_visible = false,
	hud_visible = false,
	endgame_hud_triggered = false,
	finale_win = false,
	current_map = null,
	specials = {
		killed = 0
	}
};
::ADV_STATS_BOTS <- {
	L4D1 = ["Louis", "Bill", "Francis", "Zoey"],
	L4D2 = ["Coach", "Ellis", "Rochelle", "Nick"]
};
::ADV_STATS_SI <- [
	"Boomer", "(1)Boomer", "(2)Boomer", "(3)Boomer",
	"Charger", "(1)Charger", "(2)Charger", "(3)Charger",
	"Hunter", "(1)Hunter", "(2)Hunter", "(3)Hunter",
	"Jockey", "(1)Jockey", "(2)Jockey", "(3)Jockey",
	"Smoker", "(1)Smoker", "(2)Smoker", "(3)Smoker",
	"Spitter", "(1)Spitter", "(2)Spitter", "(3)Spitter",
];
::ADV_STATS_MAP_PASSING_PORT <- "c6m3_port";
::ADV_STATS_HUD_MAX_PLAYERS <- 4;

/**
 * Add-on initialization
 */
function init()
{
	printl("#############################");
	printl("###                       ###");
	printl("###  Advanced Stats V " + ::ADV_STATS_VERSION + " ###");
	printl("###                       ###");
	printl("#############################");
	
	createStatsHUD();
}

/**
 * Stats cache debug
 */
function AdvStatsDebug()
{
	if (!::ADV_STATS_DUMP)
		return;

	printl("##############################");
	printl("###                        ###");
	printl("###  Advanced Stats - DUMP ###");
	printl("###                        ###");
	printl("##############################");
	DeepPrintTable(::AdvStats.cache);
	printl("##############################");
	DeepPrintTable(::AdvStats.specials);
	printl("##############################");
}

/**
 * Is the given name matching the name of a Special infected?
 */
function AdvStats::isSpecialInfected(sName)
{
	return ::ADV_STATS_SI.find(sName) != null;
}

/**
 * Is the given name matching the name of a bot?
 */
function AdvStats::isBot(sName)
{
	if (::ADV_STATS_BOTS.L4D1.find(sName) != null)
		return true;
	
	if (::ADV_STATS_BOTS.L4D2.find(sName) != null)
		return true;
	
	return false;
}

/**
 * Init stats data for a given player name
 */
function AdvStats::initPlayerCache(sPlayer)
{
	::ADV_STATS_LOGGER.debug("initPlayerCache");

	if (::AdvStats.cache.rawin(sPlayer))
		return;
	
	::AdvStats.cache[sPlayer] <- {
		ff = { 				// Friendly fire
			dmg = {},		// Damage dealt
			incap = {},		// Players incapacitated
			tk = {},		// Team kill
		},
		dmg = { 			// Damage dealt
			tanks = 0,		// Tanks
			witches = 0,	// Witches
		},
		hits = { 			// Hits/damage received
			infected = 0,	// By Common infected
			si_hits = 0,	// By Special infected hits
			si_dmg = 0,		// By Special infected damage
		},
		specials = {		// Special infected
			dmg = 0,		// Damage dealt
			kills = 0,		// Kills
			kills_hs = 0,	// Head shots
			spotted = {},	// identifiers list of Special infected which have been hit at least 1 time
		}
	};
}

/**
 * Save stats data between maps
 */
function AdvStats::save()
{
	::ADV_STATS_LOGGER.debug("Saving stats...");

	if (::AdvStats.finale_win == true)
	{
		::ADV_STATS_LOGGER.debug("FINALE WIN!! Clearing stats...");
		::AdvStats.cache = {};
		::AdvStats.specials = {
			killed = 0
		}
	}

	SaveTable("_adv_stats_cache", ::AdvStats.cache);
	SaveTable("_adv_stats_specials", ::AdvStats.specials);
}

/**
 * Load stats data after a map load
 */
function AdvStats::load()
{
	::ADV_STATS_LOGGER.debug("Loading stats...");
	
	RestoreTable("_adv_stats_cache", ::AdvStats.cache);
	if (::AdvStats.cache.len() == 0)
		::AdvStats.cache <- {};
	
	RestoreTable("_adv_stats_specials", ::AdvStats.specials);
}

/**
 * Has a player already spotted a special infected?
 */
function AdvStats::SIHasBeenSeen(sPlayer, userid)
{
	foreach (index, value in ::AdvStats.cache[sPlayer].specials.spotted)
	{
		if (value == userid)
			return true;
	}
	
	return false;
}

init();
