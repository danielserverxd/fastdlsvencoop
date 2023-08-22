/**
 * Ragemap 2022: AlexCorrutor's part
 */

namespace Ragemap2022AlexCorruptor
{
    const int ALEXC_DIFFICULTY_EASY     = 0;
    const int ALEXC_DIFFICULTY_MEDIUM   = 1;
    const int ALEXC_DIFFICULTY_HARD     = 2;

    CCVar@ g_p_alexc_difficulty;

    int g_alexc_coincounter = 0;
    array<int> g_alexc_coins = {0, 0, 0};

    void MapInit()
    {
        g_CustomEntityFuncs.RegisterCustomEntity("Ragemap2022AlexCorruptor::alexc_coin", "alexc_coin");
        g_CustomEntityFuncs.RegisterCustomEntity("Ragemap2022AlexCorruptor::alexc_random", "alexc_random");

        @g_p_alexc_difficulty = CCVar(
            "ragemap2022_alexc_difficulty",
            0,
            "Difficulty. (0 = easy, 1 = medium, 2 = hard)",
            ConCommandFlag::None/*,
            CVarCallback(alexc_LoadSetting)*/
        );
    }

    void MapActivate()
    {
        g_Scheduler.SetTimeout("alexc_SpawnCoins", 0.5);
    }

    final class alexc_coin : ScriptBaseEntity
    {
        string szModel = "";
        string szTarget = "";
        string szTargetSpawn = "";

        bool KeyValue(const string& in szKey, const string& in szValue)
        {
            if (szKey == "modelpath") {
                szModel = szValue;
                return true;
            }

            if (szKey == "pickuptarget") {
                szTarget = szValue;
                return true;
            }

            if (szKey == "spawntarget") {
                szTargetSpawn = szValue;
                return true;
            }

            if (szKey == "difficulty") {
                self.pev.iuser1 = atoi(szValue);
                return true;
            }

            return BaseClass.KeyValue(szKey, szValue);
        }

        void Spawn()
        {
            Precache();

            self.pev.solid          = SOLID_TRIGGER;
            self.pev.movetype       = MOVETYPE_FLY;
            self.pev.renderamt      = 255;
            self.pev.sequence       = 0;
            self.pev.framerate      = 1;
            g_EntityFuncs.SetModel(self, szModel);
            g_EntityFuncs.SetSize(self.pev, Vector(-20,-20,-20) * self.pev.scale, Vector(20,20,20) * self.pev.scale);
            g_EntityFuncs.SetOrigin(self, self.pev.origin);

            g_EntityFuncs.FireTargets(szTargetSpawn, null, null, USE_TOGGLE, 0.0, 0.1);
        }

        void Precache()
        {
            g_Game.PrecacheModel(szModel);
            g_SoundSystem.PrecacheSound("turretfortress/coin.wav");
            BaseClass.Precache();
        }

        void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
        {
            g_EntityFuncs.FireTargets(szTarget, null, null, USE_TOGGLE);
        }

        void Touch(CBaseEntity@ pOther)
        {
            string szDebugMessage;

            if (pOther is null or not pOther.IsPlayer()) {
                return;
            }

            g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_AUTO, "turretfortress/coin.wav", 1, 0.3f, 0, Math.RandomLong(60,140));
            g_EntityFuncs.FireTargets(szTarget, null, null, USE_TOGGLE);
            g_EntityFuncs.Remove(self);
            g_alexc_coincounter--;

            snprintf(szDebugMessage, "Coins left: %1\n", g_alexc_coincounter);
            g_EngineFuncs.ServerPrint(szDebugMessage);
        }
    }

    final class alexc_random : ScriptBaseEntity
    {
        int targets = 0;
        int maxTargets = 64;
        int unique = 0;

        array<string> szTarget(maxTargets);
        array<bool> fired(maxTargets);

        bool KeyValue( const string& in szKey, const string& in szValue)
        {
            for (int i = 1; i <= maxTargets; i++) {
                string szKeyName = "target" + i;

                if (szKey == szKeyName) {
                    g_Game.AlertMessage(at_console, "Found target " + i + ".\n");
                    targets++;
                    szTarget[i-1] = szValue;
                }
            }

            if (szKey == "unique") {
                unique = atoi(szValue);
                return true;
            }

            return BaseClass.KeyValue(szKey, szValue);
        }

        void Spawn()
        {
            for (int i = 0; i < maxTargets; i++) {
                // szTarget[i] = "";
                fired[i] = false;
            }

            g_Game.AlertMessage(at_console, "Spawn()\n");
        }

        void Precache()
        {
            BaseClass.Precache();
        }

        void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
        {
            g_Game.AlertMessage(at_console, "Use()\n");

            if (targets == 0) {
                return;
            }

            g_Game.AlertMessage(at_console, "It has targets.\n");

            if (unique == 1) {
                g_Game.AlertMessage(at_console, "Unique is set.\n");

                int alreadyFired = 0;

                for (int i = 0; i < maxTargets; i++) {
                    if (fired[i] == true) {
                        alreadyFired++;
                    }
                }

                if (alreadyFired >= targets) {
                    return;
                }

                g_Game.AlertMessage(at_console, "There are unfired targets.\n");

                while (true) {
                    g_Game.AlertMessage(at_console, "Trying to find an unfired target . .\n");
                    int randomTarget = Math.RandomLong(0, targets-1);

                    if (fired[randomTarget] == false) {
                        g_Game.AlertMessage(at_console, "Firing target: " + randomTarget + ", targetname: " + szTarget[randomTarget] + ".\n");
                        fired[randomTarget] = true;
                        g_EntityFuncs.FireTargets(szTarget[randomTarget], null, null, USE_TOGGLE);
                        return;
                    }
                }
            }
        }
    }

    void alexc_LoadSetting(CCVar@ cvar, const string& in szOldValue, float flOldValue)
    {
        if (cvar.GetName() == "ragemap2022_alexc_difficulty") {
            if (cvar.GetInt() < ALEXC_DIFFICULTY_EASY or cvar.GetInt() > ALEXC_DIFFICULTY_HARD) {
                cvar.SetInt(Math.clamp(ALEXC_DIFFICULTY_EASY, ALEXC_DIFFICULTY_HARD, cvar.GetInt()));
            }
            return;
        }
    }

    void alexc_SpawnCoins()
    {
        string szDebugMessage;
        int iDifficulty = g_p_alexc_difficulty.GetInt();

        CBaseEntity@ eCoin;
        array<float> coinsToDelete = {0.0, 0.0, 0.0};

        CBaseEntity@ eTimer = g_EntityFuncs.FindEntityByTargetname(null, "alexc_timer");
        if (eTimer is null) {
            g_Game.AlertMessage(at_error, "[Ragemap2022:AlexCorruptor] Timer entity not found.\n");
            return;
        }

        // Count coins
        while ((@eCoin = g_EntityFuncs.FindEntityByClassname(eCoin, "alexc_coin")) !is null) {
            g_alexc_coins[eCoin.pev.iuser1]++;
            g_alexc_coincounter++;
        }

        snprintf(
            szDebugMessage,
            "Coins found easy: %1 | Coins found medium: %2 | Coins found hard: %3 (Total: %4)\n",
            g_alexc_coins[ALEXC_DIFFICULTY_EASY],
            g_alexc_coins[ALEXC_DIFFICULTY_MEDIUM],
            g_alexc_coins[ALEXC_DIFFICULTY_HARD],
            g_alexc_coincounter
        );
        g_EngineFuncs.ServerPrint(szDebugMessage);

        switch (iDifficulty) {
            case ALEXC_DIFFICULTY_EASY:
                // delete   25% random coins in easy positions
                coinsToDelete[ALEXC_DIFFICULTY_EASY] = g_alexc_coins[ALEXC_DIFFICULTY_EASY] * 0.25;

                // delete   50% random coins in medium positions
                coinsToDelete[ALEXC_DIFFICULTY_MEDIUM] = g_alexc_coins[ALEXC_DIFFICULTY_MEDIUM] * 0.5;

                // delete   75% random coins in hard positions
                coinsToDelete[ALEXC_DIFFICULTY_HARD] = g_alexc_coins[ALEXC_DIFFICULTY_HARD] * 0.75;

                // -> delete 150% of 300% -> 50% of all coins get deleted

                // set difficulty time
                eTimer.pev.frags = 300;
                break;

            case ALEXC_DIFFICULTY_MEDIUM:
                // delete   30% random coins in easy positions
                coinsToDelete[ALEXC_DIFFICULTY_EASY] = g_alexc_coins[ALEXC_DIFFICULTY_EASY] * 0.3;

                // delete   30% random coins in medium positions
                coinsToDelete[ALEXC_DIFFICULTY_MEDIUM] = g_alexc_coins[ALEXC_DIFFICULTY_MEDIUM] * 0.3;

                // delete   30% random coins in hard positions
                coinsToDelete[ALEXC_DIFFICULTY_HARD] = g_alexc_coins[ALEXC_DIFFICULTY_HARD] * 0.3;

                // -> delete 90% of 300% -> 30.00% of all coins get deleted

                // set difficulty time
                eTimer.pev.frags = 270;
                break;

            case ALEXC_DIFFICULTY_HARD:
                // delete   10% random coins in easy positions
                coinsToDelete[ALEXC_DIFFICULTY_EASY] = g_alexc_coins[ALEXC_DIFFICULTY_EASY] * 0.1;

                // delete   10% random coins in medium positions
                coinsToDelete[ALEXC_DIFFICULTY_MEDIUM] = g_alexc_coins[ALEXC_DIFFICULTY_MEDIUM] * 0.1;

                // delete   20% random coins in hard positions
                coinsToDelete[ALEXC_DIFFICULTY_HARD] = g_alexc_coins[ALEXC_DIFFICULTY_HARD] * 0.2;

                // -> delete 40% of 300% -> 13.33% of all coins get deleted

                // set difficulty time
                eTimer.pev.frags = 240;
                break;
        }

        snprintf(szDebugMessage, "Difficulty is %1.\n", iDifficulty);
        g_EngineFuncs.ServerPrint(szDebugMessage);
        snprintf(szDebugMessage, "Deleting %1 of %2 easy coins.\n", coinsToDelete[ALEXC_DIFFICULTY_EASY], g_alexc_coins[ALEXC_DIFFICULTY_EASY]);
        g_EngineFuncs.ServerPrint(szDebugMessage);
        snprintf(szDebugMessage, "Deleting %1 of %2 medium coins.\n", coinsToDelete[ALEXC_DIFFICULTY_MEDIUM], g_alexc_coins[ALEXC_DIFFICULTY_MEDIUM]);
        g_EngineFuncs.ServerPrint(szDebugMessage);
        snprintf(szDebugMessage, "Deleting %1 of %2 hard coins.\n", coinsToDelete[ALEXC_DIFFICULTY_HARD], g_alexc_coins[ALEXC_DIFFICULTY_HARD]);
        g_EngineFuncs.ServerPrint(szDebugMessage);

        // Delete unwanted coins
        for (int d = 0; d < int(coinsToDelete.length()); d++) {
            while (coinsToDelete[d] >= 0.5) {
                while ((@eCoin = g_EntityFuncs.FindEntityByClassname(eCoin, "alexc_coin")) !is null) {
                    if (eCoin.pev.iuser1 != d or eCoin.pev.flags == FL_KILLME) {
                        continue;
                    }

                    if (Math.RandomFloat(0.0, 100.0) < (100 / g_alexc_coins[d])) {
                        eCoin.Use(null, null, USE_ON, 0.0);
                        g_EntityFuncs.Remove(eCoin);
                        g_alexc_coins[d]--;
                        coinsToDelete[d]--;
                        g_alexc_coincounter--;

                        snprintf(szDebugMessage, "Coins left: %1\n", g_alexc_coincounter);
                        g_EngineFuncs.ServerPrint(szDebugMessage);
                        break;
                    }
                }
            }
        }
    }
}

void Ragemap2022AlexCorruptor_Loop(CBaseEntity@ pActivator)
{
    HUDTextParams sStatusMsgParams;
    string szStatusMessage;

    CBaseEntity@ eTimer = g_EntityFuncs.FindEntityByTargetname(null, "alexc_timer");
    if (eTimer is null) {
        return;
    }

    Vector vColour = Vector(255, 255, 255);
    if (eTimer.pev.frags <= 80) {
        vColour = Vector(255, 0, 0);
    }

    sStatusMsgParams.channel        = 5;
    sStatusMsgParams.x              = -1;
    sStatusMsgParams.y              = 0.1;
    sStatusMsgParams.effect         = 1;
    sStatusMsgParams.r1             = int(vColour.x);
    sStatusMsgParams.g1             = int(vColour.y);
    sStatusMsgParams.b1             = int(vColour.z);
    sStatusMsgParams.r2             = int(vColour.x);
    sStatusMsgParams.g2             = int(vColour.y);
    sStatusMsgParams.b2             = int(vColour.z);
    sStatusMsgParams.fadeinTime     = 0;
    sStatusMsgParams.fadeoutTime    = 0;
    sStatusMsgParams.holdTime       = 1.0;
    sStatusMsgParams.fxTime         = 0.1;

    snprintf(
        szStatusMessage,
        "Time left: %1\nCoins left: %2",
        eTimer.pev.frags,
        Ragemap2022AlexCorruptor::g_alexc_coincounter
    );
    g_PlayerFuncs.HudMessageAll(sStatusMsgParams, szStatusMessage);
}
