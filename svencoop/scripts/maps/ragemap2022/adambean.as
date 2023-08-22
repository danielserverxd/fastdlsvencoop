/**
 * Ragemap 2022: Adambean's part
 */

namespace Ragemap2022Adambean
{
    /*
     * -------------------------------------------------------------------------
     * Constants & enumerators
     * -------------------------------------------------------------------------
     */

    const string        ENT_PREFIX                  = "adambean_";
    const uint          ROUNDS                      = 10;

    const array<string> ISO_7010_SIGNS              = {
        "biohazard",
        "chemical_weapon",
        "corrosive",
        "drop",
        "electricity",
        "explosive",
        "flammable",
        "harmful",
        "industrial_vhcls",
        "irritant",
        "laser",
        "low_temperature",
        "magnetic_field",
        "ni_radiation",
        "obstacles",
        "overhead_load",
        "oxidant",
        "radiation",
        "toxic",
        "general"
    };

    const string        PLATFORM_ENT_PREFIX         = "plat_";
    const uint          PLATFORM_COUNT              = 16;

    const string        SCREEN_ENT_PREFIX           = "screen_";

    enum eScreenIntroStages {
        Begin = 0,
        ShowAdambeanPresents,
        ShiftAdambeanPresents,
        ShowKnow,
        ShowYour,
        ShowIso7010,
        ShiftKnowYourIso7010,
        HideAdambeanPresents,
        ShowInstructions,
        Complete
    };

    enum eRoundStages {
        Begin = 0,
        RandomiseSignsAndShow,
        CycleScreenChosenSignText,
        LowerWrongPlatforms,
        RaiseWrongPlatforms,
        Complete
    };



    /*
     * -------------------------------------------------------------------------
     * Life cycle functions
     * -------------------------------------------------------------------------
     */

    /**
     * Map initialisation handler.
     * @return void
     */
    void MapInit()
    {
        // g_Module.ScriptInfo.SetAuthor("Adam \"Adambean\" Reece");
        // g_Module.ScriptInfo.SetContactInfo("www.reece.wales");

        g_SoundSystem.PrecacheSound("ragemap2022/adambean/drumroll.ogg");
        g_SoundSystem.PrecacheSound("ragemap2022/adambean/music.ogg");
        g_SoundSystem.PrecacheSound("buttons/bell1.wav");
        g_SoundSystem.PrecacheSound("buttons/blip1.wav");
        g_SoundSystem.PrecacheSound("buttons/blip3.wav");
        g_SoundSystem.PrecacheSound("buttons/button10.wav");
        g_SoundSystem.PrecacheSound("buttons/lightswitch2.wav");
        g_SoundSystem.PrecacheSound("debris/impact_crete.wav");
        g_SoundSystem.PrecacheSound("ragemap2022/adambean/getout.ogg");
        g_SoundSystem.PrecacheSound("ragemap2022/hezus/boo.mp3");
        g_SoundSystem.PrecacheSound("ragemap2022/hezus/cheer.mp3");

        g_Game.PrecacheModel("sprites/ragemap2022/adambean/gauna_3coa_sign.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/gauna_was_here.spr");
        //g_Game.PrecacheModel("sprites/ragemap2022/adambean/gauna_was_here_b.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-mascot-intro.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-presents.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-know.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-your.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-iso7010.spr");
        //g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-mascot-ins.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-ins1.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-ins2.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-ins3.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-ins4.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-winner.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-loser.spr");
        g_Game.PrecacheModel("sprites/ragemap2022/adambean/rm2022-ab-getout.spr");

        // For each sign...
        for (uint i = 0; i < ISO_7010_SIGNS.length(); i++) {
            g_Game.AlertMessage(at_aiconsole, "Precaching ISO-7010 sign %1 image \"%2\".\n", (i + 1), "sprites/ragemap2022/adambean/iso7010_" + ISO_7010_SIGNS[i] + ".spr");
            g_Game.PrecacheModel("sprites/ragemap2022/adambean/iso7010_" + ISO_7010_SIGNS[i] + ".spr");
            g_Game.AlertMessage(at_aiconsole, "Precaching ISO-7010 sign %1 text \"%2\".\n", (i + 1), "sprites/ragemap2022/adambean/iso7010_" + ISO_7010_SIGNS[i] + "_text.spr");
            g_Game.PrecacheModel("sprites/ragemap2022/adambean/iso7010_" + ISO_7010_SIGNS[i] + "_text.spr");
        }
    }

    /**
     * Map activation handler.
     * @return void
     */
    void MapActivate()
    {
        @g_pInstance = MapPart();

        if (!g_pInstance.Initialise()) {
            g_Game.AlertMessage(at_console, "Ragemap 2022: Adambean's part encountered errors initialising.\n");

            @g_pInstance = null;
            g_EntityFuncs.FireTargets(ENT_PREFIX + "start_mm", null, null, USE_KILL);
            g_EntityFuncs.FireTargets(ENT_PREFIX + "start_spr", null, null, USE_KILL);
            return;
        }

        g_Game.AlertMessage(at_console, "Ragemap 2022: Adambean's part ready.\n");
        g_EntityFuncs.FireTargets(ENT_PREFIX + "start_ok", null, null, USE_TOGGLE);
        g_EntityFuncs.FireTargets(ENT_PREFIX + "start_spr", null, null, USE_ON);
    }



    /**
     * Ragemap 2022: Adambean's part
     */
    final class MapPart
    {
        /*
         * -------------------------------------------------------------------------
         * Variables
         * -------------------------------------------------------------------------
         */

        /** @var uint m_uiScreenBorderStageAt Current screen border stage. */
        uint m_uiScreenBorderStageAt;



        // << Intro screen
        /** @var double m_flScreenIntroTime Start time of screen intro. */
        double m_flScreenIntroTime;

        /** @var uint m_uiScreenIntroStageAt Current screen intro stage. */
        uint m_uiScreenIntroStageAt;

        /** @var uint m_uiScreenIntroStageDone Done screen intro stage. */
        uint m_uiScreenIntroStageDone;

        /** @var uint m_uiScreenInstructionStageAt Current screen instruction stage. */
        uint m_uiScreenInstructionStageAt;

        /** @var uint m_uiScreenInstructionStageDone Done screen instruction stage. */
        uint m_uiScreenInstructionStageDone;

        /** @var array<Vector> m_szScreenIntroOrigins Original screen intro entity names. */
        array<string> m_szScreenIntroOrigins;

        /** @var array<Vector> m_vecScreenIntroOrigins Original screen intro entity vectors. */
        array<Vector> m_vecScreenIntroOrigins;
        // >> Intro screen



        // << Game round
        /** @var uint m_uiRound Round. */
        uint m_uiRound;

        /** @var double m_flRoundTime Start time of round. */
        double m_flRoundTime;

        /** @var uint m_uiRoundStageAt Current round stage. */
        uint m_uiRoundStageAt;

        /** @var uint m_uiRoundStageDone Done round stage. */
        uint m_uiRoundStageDone;

        /** @var uint m_uiRoundChosenPlatform Chosen sign for round. */
        uint m_uiRoundChosenPlatform;

        /** @var double m_flRoundTextLastCycleTime Text last cycle time. */
        double m_flRoundTextLastCycleTime;
        // >> Game round



        /*
         * -------------------------------------------------------------------------
         * Life cycle functions
         * -------------------------------------------------------------------------
         */

        /**
         * Constructor.
         */
        MapPart()
        {
            m_uiScreenBorderStageAt         = 0;

            m_flScreenIntroTime             = 0.0;
            m_uiScreenIntroStageAt          = 0;
            m_uiScreenIntroStageDone        = 0;
            m_uiScreenInstructionStageAt    = 0;
            m_uiScreenInstructionStageDone  = 0;

            m_uiRound                       = 0;
            m_flRoundTime                   = 0.0;
            m_uiRoundStageAt                = 0;
            m_uiRoundStageDone              = 0;
            m_uiRoundChosenPlatform         = 0;
            m_flRoundTextLastCycleTime      = 0.0;
        }



        /*
         * -------------------------------------------------------------------------
         * Helper functions
         * -------------------------------------------------------------------------
         */

        /**
         * Toggle platform signs.
         * @param  USE_TYPE useType
         * @return void
         */
        void TogglePlatformSigns(USE_TYPE useType)
        {
            for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++) {
                string szPlatformSprite = ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(uiPlatform) + "_spr";

                CBaseEntity@ pPlatformSprite;
                if ((@pPlatformSprite = g_EntityFuncs.FindEntityByTargetname(null, szPlatformSprite)) is null) {
                    continue;
                }

                pPlatformSprite.Use(null, null, useType);
                if (USE_KILL != useType) {
                    g_SoundSystem.EmitSoundDyn(pPlatformSprite.edict(), CHAN_AUTO, "buttons/lightswitch2.wav", 0.25, 0.0, 0, PITCH_NORM);
                }
            }
        }

        /**
         * Randomise platform signs.
         * @return uint Randomly chosen platform number
         */
        uint RandomisePlatformSigns()
        {
            array<string>   a_szSprites(PLATFORM_COUNT);
            uint            s = 0;
            while (s < a_szSprites.length()) {
                uint uiSprite = Math.RandomLong(0, ISO_7010_SIGNS.length() - 1);

                if (a_szSprites.find(ISO_7010_SIGNS[uiSprite]) >= 0) {
                    continue;
                }

                a_szSprites[s] = ISO_7010_SIGNS[uiSprite];

                ++s;
            }

            string szSprites;
            for (uint i = 0; i < a_szSprites.length(); i++) {
                szSprites += a_szSprites[i];
                if ((i + 1) < a_szSprites.length()) {
                    szSprites += ", ";
                }
            }
            g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RandomisePlatformSigns(): Randomised to: %1\n", szSprites);

            for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++) {
                string szPlatformSprite = ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(uiPlatform) + "_spr";

                CBaseEntity@ pPlatformSprite;
                if ((@pPlatformSprite = g_EntityFuncs.FindEntityByTargetname(null, szPlatformSprite)) is null) {
                    continue;
                }

                g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RandomisePlatformSigns(): Platform %1 sprite changing to \"%2\".\n", uiPlatform, a_szSprites[uiPlatform - 1]);
                g_EntityFuncs.SetModel(pPlatformSprite, "sprites/ragemap2022/adambean/iso7010_" + a_szSprites[uiPlatform - 1] + ".spr");
            }

            return Math.RandomLong(1, PLATFORM_COUNT);
        }



        /*
         * -------------------------------------------------------------------------
         * Functions
         * -------------------------------------------------------------------------
         */

        /**
         * Initialise.
         * @return bool Success
         */
        bool Initialise()
        {
            uint uiErrors = 0;



            // << Misc
            string szAutoMm                         = ENT_PREFIX + "auto_mm";

            // Find auto MM
            CBaseEntity@ pAutoMm;
            if ((@pAutoMm = g_EntityFuncs.FindEntityByTargetname(null, szAutoMm)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Game auto MM \"%1\" not found. (Probably running on the wrong map.)\n", szAutoMm);
                ++uiErrors;
                return false;
            }

            string szGameZone                       = ENT_PREFIX + "game_zone";

            // Find template platform sprite
            CBaseEntity@ pGameZone;
            if ((@pGameZone = g_EntityFuncs.FindEntityByTargetname(null, szGameZone)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Game zone entity \"%1\" not found.\n", szGameZone);
                ++uiErrors;
            }
            // >> Misc



            // << Platforms
            string szPlatformFriction               = ENT_PREFIX + PLATFORM_ENT_PREFIX + "friction";
            string szPlatformSpriteTmpl             = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_spr";
            string szPlatformPointUpTmpl            = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_up";
            string szPlatformPointDownTmpl          = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_down";
            string szPlatformPistonAPointUpTmpl     = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_pistonA_up";
            string szPlatformPistonAPointDownTmpl   = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_pistonA_down";
            string szPlatformPistonBPointUpTmpl     = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_pistonB_up";
            string szPlatformPistonBPointDownTmpl   = ENT_PREFIX + PLATFORM_ENT_PREFIX + "X_pistonB_down";

            // Find platform friction
            CBaseEntity@ pPlatformFriction;
            if ((@pPlatformFriction = g_EntityFuncs.FindEntityByTargetname(null, szPlatformFriction)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Platform friction entity \"%1\" not found.\n", szPlatformFriction);
                ++uiErrors;
            }

            // Find template platform sprite
            CBaseEntity@ pPlatformSpriteTmpl;
            if ((@pPlatformSpriteTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformSpriteTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform sprite entity \"%1\" not found.\n", szPlatformSpriteTmpl);
                ++uiErrors;
            }

            // Find template platform up point
            CBaseEntity@ pPlatformPointUpTmpl;
            if ((@pPlatformPointUpTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPointUpTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform up point entity \"%1\" not found.\n", szPlatformPointUpTmpl);
                ++uiErrors;
            }

            // Find template platform down point
            CBaseEntity@ pPlatformPointDownTmpl;
            if ((@pPlatformPointDownTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPointDownTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform down point entity \"%1\" not found.\n", szPlatformPointDownTmpl);
                ++uiErrors;
            }

            // Find template platform piston A up point
            CBaseEntity@ pPlatformPistonAPointUpTmpl;
            if ((@pPlatformPistonAPointUpTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonAPointUpTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform piston A up point entity \"%1\" not found.\n", szPlatformPistonAPointUpTmpl);
                ++uiErrors;
            }

            // Find template platform piston A down point
            CBaseEntity@ pPlatformPistonAPointDownTmpl;
            if ((@pPlatformPistonAPointDownTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonAPointDownTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform piston A down point entity \"%1\" not found.\n", szPlatformPistonAPointDownTmpl);
                ++uiErrors;
            }

            // Find template platform piston A up point
            CBaseEntity@ pPlatformPistonBPointUpTmpl;
            if ((@pPlatformPistonBPointUpTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonBPointUpTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform piston A up point entity \"%1\" not found.\n", szPlatformPistonBPointUpTmpl);
                ++uiErrors;
            }

            // Find template platform piston A down point
            CBaseEntity@ pPlatformPistonBPointDownTmpl;
            if ((@pPlatformPistonBPointDownTmpl = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonBPointDownTmpl)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Template platform piston A down point entity \"%1\" not found.\n", szPlatformPistonBPointDownTmpl);
                ++uiErrors;
            }

            // For each platform...
            for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++) {
                bool fPlatformHasErrors = false;

                // Entity strings
                string szPlatform                   = ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(uiPlatform);
                string szPlatformPistonA            = szPlatform + "_pistonA";
                string szPlatformPistonB            = szPlatform + "_pistonB";
                string szPlatformOrigin             = szPlatform + "_origin";
                string szPlatformSprite             = szPlatform + "_spr";
                string szPlatformPointUp            = szPlatform + "_up";
                string szPlatformPointDown          = szPlatform + "_down";
                string szPlatformPistonAPointUp     = szPlatform + "_pistonA_up";
                string szPlatformPistonAPointDown   = szPlatform + "_pistonA_down";
                string szPlatformPistonBPointUp     = szPlatform + "_pistonB_up";
                string szPlatformPistonBPointDown   = szPlatform + "_pistonB_down";
                string szPlatformMultiManager       = szPlatform + "_mm";

                // Find platform origin
                CBaseEntity@ pPlatformOrigin;
                if ((@pPlatformOrigin = g_EntityFuncs.FindEntityByTargetname(null, szPlatformOrigin)) is null) {
                    g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 origin entity \"%2\" not found.\n", uiPlatform, szPlatformOrigin);
                    ++uiErrors;
                    fPlatformHasErrors = true;
                }

                // Find platform
                CBaseEntity@ pPlatform;
                if ((@pPlatform = g_EntityFuncs.FindEntityByTargetname(null, szPlatform)) is null) {
                    g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 entity \"%2\" not found.\n", uiPlatform, szPlatform);
                    ++uiErrors;
                    fPlatformHasErrors = true;
                }

                // Find platform piston A
                CBaseEntity@ pPlatformPistonA;
                if ((@pPlatformPistonA = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonA)) is null) {
                    g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston A entity \"%2\" not found.\n", uiPlatform, szPlatformPistonA);
                    ++uiErrors;
                    fPlatformHasErrors = true;
                }

                // Find platform piston B
                CBaseEntity@ pPlatformPistonB;
                if ((@pPlatformPistonB = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonB)) is null) {
                    g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston B entity \"%2\" not found.\n", uiPlatform, szPlatformPistonB);
                    ++uiErrors;
                    fPlatformHasErrors = true;
                }

                // Any problems so far?
                if (fPlatformHasErrors) {
                    continue;
                }

                // Create platform sprite
                CBaseEntity@ pPlatformSprite;
                if ((@pPlatformSprite = g_EntityFuncs.FindEntityByTargetname(null, szPlatformSprite)) is null) {
                    dictionary oPlatformSprite = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x)             + " " + formatFloat(pPlatformOrigin.pev.origin.y)             + " " + formatFloat(pPlatformSpriteTmpl.pev.origin.z + 0.75)},
                        {"angles",      formatFloat(pPlatformSpriteTmpl.pev.angles.x)   + " " + formatFloat(pPlatformSpriteTmpl.pev.angles.y)   + " " + formatFloat(pPlatformSpriteTmpl.pev.angles.z)},
                        {"targetname",  szPlatformSprite},
                        {"renderfx",    formatUInt(pPlatformSpriteTmpl.pev.renderfx)},
                        {"rendermode",  formatUInt(pPlatformSpriteTmpl.pev.rendermode)},
                        {"renderamt",   formatFloat(pPlatformSpriteTmpl.pev.renderamt)},
                        {"rendercolor", pPlatformSpriteTmpl.pev.rendercolor},
                        {"framerate",   formatFloat(pPlatformSpriteTmpl.pev.framerate)},
                        {"model",       "sprites/ragemap2022/adambean/iso7010_general.spr"},
                        {"scale",       "0.33333"}, // formatFloat(pPlatformSpriteTmpl.pev.scale)
                        {"vp_type",     "4"},
                        {"spawnflags",  formatUInt(pPlatformSpriteTmpl.pev.spawnflags)}
                    };
                    @pPlatformSprite = g_EntityFuncs.CreateEntity("env_sprite", oPlatformSprite);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 sprite entity created.\n", uiPlatform);
                }

                // Create platform up point
                CBaseEntity@ pPlatformPointUp;
                if ((@pPlatformPointUp = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPointUp)) is null) {
                    dictionary oPlatformPointUp = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPointUpTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPointUp},
                        {"target",      szPlatformPointDown},
                        {"spawnflags",  formatUInt(pPlatformPointUpTmpl.pev.spawnflags)}
                    };
                    @pPlatformPointUp = g_EntityFuncs.CreateEntity("path_corner", oPlatformPointUp);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 up point entity created.\n", uiPlatform);
                }

                // Create platform down point
                CBaseEntity@ pPlatformPointDown;
                if ((@pPlatformPointDown = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPointDown)) is null) {
                    dictionary oPlatformPointDown = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPointDownTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPointDown},
                        {"target",      szPlatformPointUp},
                        {"spawnflags",  formatUInt(pPlatformPointDownTmpl.pev.spawnflags)}
                    };
                    @pPlatformPointDown = g_EntityFuncs.CreateEntity("path_corner", oPlatformPointDown);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 down point entity created.\n", uiPlatform);
                }

                // Create platform piston A up point
                CBaseEntity@ pPlatformPistonAPointUp;
                if ((@pPlatformPistonAPointUp = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonAPointUp)) is null) {
                    dictionary oPlatformPistonAPointUp = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPistonAPointUpTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPistonAPointUp},
                        {"target",      szPlatformPistonAPointDown},
                        {"spawnflags",  formatUInt(pPlatformPistonAPointUpTmpl.pev.spawnflags)}
                    };
                    @pPlatformPistonAPointUp = g_EntityFuncs.CreateEntity("path_corner", oPlatformPistonAPointUp);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston A up point entity created.\n", uiPlatform);
                }

                // Create platform piston A down point
                CBaseEntity@ pPlatformPistonAPointDown;
                if ((@pPlatformPistonAPointDown = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonAPointDown)) is null) {
                    dictionary oPlatformPistonAPointDown = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPistonAPointDownTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPistonAPointDown},
                        {"target",      szPlatformPistonAPointUp},
                        {"spawnflags",  formatUInt(pPlatformPistonAPointDownTmpl.pev.spawnflags)}
                    };
                    @pPlatformPistonAPointDown = g_EntityFuncs.CreateEntity("path_corner", oPlatformPistonAPointDown);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston A down point entity created.\n", uiPlatform);
                }

                // Create platform piston B up point
                CBaseEntity@ pPlatformPistonBPointUp;
                if ((@pPlatformPistonBPointUp = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonBPointUp)) is null) {
                    dictionary oPlatformPistonBPointUp = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPistonBPointUpTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPistonBPointUp},
                        {"target",      szPlatformPistonBPointDown},
                        {"spawnflags",  formatUInt(pPlatformPistonBPointUpTmpl.pev.spawnflags)}
                    };
                    @pPlatformPistonBPointUp = g_EntityFuncs.CreateEntity("path_corner", oPlatformPistonBPointUp);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston A up point entity created.\n", uiPlatform);
                }

                // Create platform piston B down point
                CBaseEntity@ pPlatformPistonBPointDown;
                if ((@pPlatformPistonBPointDown = g_EntityFuncs.FindEntityByTargetname(null, szPlatformPistonBPointDown)) is null) {
                    dictionary oPlatformPistonBPointDown = {
                        {"origin",      formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformPistonBPointDownTmpl.pev.origin.z)},
                        {"targetname",  szPlatformPistonBPointDown},
                        {"target",      szPlatformPistonBPointUp},
                        {"spawnflags",  formatUInt(pPlatformPistonBPointDownTmpl.pev.spawnflags)}
                    };
                    @pPlatformPistonBPointDown = g_EntityFuncs.CreateEntity("path_corner", oPlatformPistonBPointDown);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 piston A down point entity created.\n", uiPlatform);
                }

                // Create platform multi-manager
                CBaseEntity@ pPlatformMultiManager;
                if ((@pPlatformMultiManager = g_EntityFuncs.FindEntityByTargetname(null, szPlatformMultiManager)) is null) {
                    dictionary oPlatformMultiManager = {
                        {"origin",          formatFloat(pPlatformOrigin.pev.origin.x) + " " + formatFloat(pPlatformOrigin.pev.origin.y) + " " + formatFloat(pPlatformOrigin.pev.origin.z + 16)},
                        {"targetname",      szPlatformMultiManager},
                        {szPlatform,        "0"},
                        {szPlatformPistonA, "0"},
                        {szPlatformPistonB, "0"},
                        {"spawnflags",      "0"}
                    };
                    @pPlatformMultiManager = g_EntityFuncs.CreateEntity("multi_manager", oPlatformMultiManager);

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->Initialise(): Platform %1 multi-manager entity created.\n", uiPlatform);
                }

                // Link platform segments to paths
                g_EntityFuncs.SetOrigin(pPlatform, pPlatformPointUp.pev.origin);
                g_EntityFuncs.SetOrigin(pPlatformPistonA, pPlatformPistonAPointUp.pev.origin);
                g_EntityFuncs.SetOrigin(pPlatformPistonB, pPlatformPistonBPointUp.pev.origin);
                pPlatform.pev.target        = pPlatformPointUp.pev.target;
                pPlatformPistonA.pev.target = pPlatformPistonAPointUp.pev.target;
                pPlatformPistonB.pev.target = pPlatformPistonBPointUp.pev.target;
            } // for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++)
            // >> Platforms



            // << Screen
            string szScreenCentre               = ENT_PREFIX + SCREEN_ENT_PREFIX + "centre";
            string szScreenIntroPresentsSprite  = ENT_PREFIX + SCREEN_ENT_PREFIX + "presents_spr";
            string szScreenIntroPresentsMSprite = ENT_PREFIX + SCREEN_ENT_PREFIX + "presents_mascot_spr";
            string szScreenIntroKnowSprite      = ENT_PREFIX + SCREEN_ENT_PREFIX + "know_spr";
            string szScreenIntroYourSprite      = ENT_PREFIX + SCREEN_ENT_PREFIX + "your_spr";
            string szScreenIntroIso7010Sprite   = ENT_PREFIX + SCREEN_ENT_PREFIX + "iso7010_spr";
            string szScreenIntroInsSprite       = ENT_PREFIX + SCREEN_ENT_PREFIX + "ins_spr";
            string szScreenIntroInsMSprite      = ENT_PREFIX + SCREEN_ENT_PREFIX + "ins_mascot_spr";
            string szScreenSpriteChosen         = ENT_PREFIX + SCREEN_ENT_PREFIX + "chosen_spr";

            // Find screen centre
            CBaseEntity@ pScreenCentre;
            if ((@pScreenCentre = g_EntityFuncs.FindEntityByTargetname(null, szScreenCentre)) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen centre point entity \"%1\" not found.\n", szScreenCentre);
                ++uiErrors;
            }

            // Find screen intro presents sprite
            CBaseEntity@ pScreenIntroPresentsSprite;
            if ((@pScreenIntroPresentsSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroPresentsSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroPresentsSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroPresentsSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro presents sprite point entity \"%1\" not found.\n", szScreenIntroPresentsSprite);
                ++uiErrors;
            }

            // Find screen intro presents mascot sprite
            CBaseEntity@ pScreenIntroPresentsMSprite;
            if ((@pScreenIntroPresentsMSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroPresentsMSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroPresentsMSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroPresentsMSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro presents mascot sprite point entity \"%1\" not found.\n", szScreenIntroPresentsMSprite);
                ++uiErrors;
            }

            // Find screen intro "know" sprite
            CBaseEntity@ pScreenIntroKnowSprite;
            if ((@pScreenIntroKnowSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroKnowSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroKnowSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroKnowSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro \"know\" sprite point entity \"%1\" not found.\n", szScreenIntroKnowSprite);
                ++uiErrors;
            }

            // Find screen intro "your" sprite
            CBaseEntity@ pScreenIntroYourSprite;
            if ((@pScreenIntroYourSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroYourSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroYourSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroYourSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro \"your\" sprite point entity \"%1\" not found.\n", szScreenIntroYourSprite);
                ++uiErrors;
            }

            // Find screen intro "ISO 7010" sprite
            CBaseEntity@ pScreenIntroIso7010Sprite;
            if ((@pScreenIntroIso7010Sprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroIso7010Sprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroIso7010Sprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroIso7010Sprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro \"ISO 7010\" sprite point entity \"%1\" not found.\n", szScreenIntroIso7010Sprite);
                ++uiErrors;
            }

            // Find screen intro instruction sprite
            CBaseEntity@ pScreenIntroInsSprite;
            if ((@pScreenIntroInsSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroInsSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroInsSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroInsSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro instruction sprite point entity \"%1\" not found.\n", szScreenIntroInsSprite);
                ++uiErrors;
            }

            // Find screen intro instruction mascot sprite
            CBaseEntity@ pScreenIntroInsMSprite;
            if ((@pScreenIntroInsMSprite = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroInsMSprite)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenIntroInsMSprite.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenIntroInsMSprite.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen intro instruction mascot sprite point entity \"%1\" not found.\n", szScreenIntroInsMSprite);
                ++uiErrors;
            }

            // Find screen chosen sprite
            CBaseEntity@ pScreenSpriteChosen;
            if ((@pScreenSpriteChosen = g_EntityFuncs.FindEntityByTargetname(null, szScreenSpriteChosen)) !is null) {
                m_szScreenIntroOrigins.insertLast(pScreenSpriteChosen.pev.targetname);
                m_vecScreenIntroOrigins.insertLast(pScreenSpriteChosen.pev.origin);
            } else {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->Initialise(): Screen chosen sprite point entity \"%1\" not found.\n", szScreenSpriteChosen);
                ++uiErrors;
            }
            // >> Screen



            return (0 == uiErrors);
        }

        /**
         * Respawn players outside the game zone.
         * @return void
         */
        void RespawnPlayersOutsideGameZone()
        {
            CBaseEntity@ pGameZone;
            if ((@pGameZone = g_EntityFuncs.FindEntityByTargetname(null, ENT_PREFIX + "game_zone")) is null) {
                g_Game.AlertMessage(at_error, "Ragemap2022Adambean::MapPart->RespawnPlayersOutsideGameZone(): Game zone entity not found.\n");
                return;
            }

            for (int i = 1; i <= g_Engine.maxClients; i++) {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
                if (
                    pPlayer is null
                    or !pPlayer.IsPlayer()
                    or !pPlayer.IsConnected()
                ) {
                    continue;
                }

                if (pPlayer.IsAlive() and g_Utility.IsPlayerInVolume(pPlayer, pGameZone)) {
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RespawnPlayersOutsideGameZone(): Skipping player \"%1\".\n", g_Utility.GetPlayerLog(pPlayer.edict()));
                } else {
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RespawnPlayersOutsideGameZone(): Respawning player \"%1\".\n", g_Utility.GetPlayerLog(pPlayer.edict()));

                    pPlayer.Respawn();
                    g_EntityFuncs.FireTargets(ENT_PREFIX + "respawn_one", pPlayer, null, USE_TOGGLE);
                }
            }
        }

        /**
         * Run screen border.
         * @return void
         */
        void RunScreenBorder()
        {
            switch (m_uiScreenBorderStageAt) {
                case 0:
                    g_EntityFuncs.FireTargets(ENT_PREFIX + SCREEN_ENT_PREFIX + "border_spr1", null, null, USE_ON);
                    g_EntityFuncs.FireTargets(ENT_PREFIX + SCREEN_ENT_PREFIX + "border_spr2", null, null, USE_OFF);
                    m_uiScreenBorderStageAt = 1;
                    break;

                case 1:
                    g_EntityFuncs.FireTargets(ENT_PREFIX + SCREEN_ENT_PREFIX + "border_spr1", null, null, USE_OFF);
                    g_EntityFuncs.FireTargets(ENT_PREFIX + SCREEN_ENT_PREFIX + "border_spr2", null, null, USE_ON);
                    m_uiScreenBorderStageAt = 0;
                    break;

                default:
                    m_uiScreenBorderStageAt = 0;
            }
        }

        /**
         * Run intro sprites.
         * @return void
         */
        void RunIntro()
        {
            double flRunningTime    = (g_Engine.time - m_flScreenIntroTime);
            double flInsStartTime   = 0.0;
            double flInsEndTime     = 0.0;

            if (m_uiScreenIntroStageAt < 1) {
                g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Starting intro.\n");
            }

            string szScreenCentre                       = ENT_PREFIX + SCREEN_ENT_PREFIX + "centre";
            string szScreenIntroPresentsSprite          = ENT_PREFIX + SCREEN_ENT_PREFIX + "presents_spr";
            string szScreenIntroPresentsMSprite         = ENT_PREFIX + SCREEN_ENT_PREFIX + "presents_mascot_spr";
            string szScreenIntroKnowSprite              = ENT_PREFIX + SCREEN_ENT_PREFIX + "know_spr";
            string szScreenIntroYourSprite              = ENT_PREFIX + SCREEN_ENT_PREFIX + "your_spr";
            string szScreenIntroIso7010Sprite           = ENT_PREFIX + SCREEN_ENT_PREFIX + "iso7010_spr";
            string szScreenIntroInsSprite               = ENT_PREFIX + SCREEN_ENT_PREFIX + "ins_spr";
            string szScreenIntroInsMSprite              = ENT_PREFIX + SCREEN_ENT_PREFIX + "ins_mascot_spr";
            string szScreenSpriteChosen                 = ENT_PREFIX + SCREEN_ENT_PREFIX + "chosen_spr";

            CBaseEntity@ pScreenCentre                  = g_EntityFuncs.FindEntityByTargetname(null, szScreenCentre);
            CBaseEntity@ pScreenIntroPresentsSprite     = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroPresentsSprite);
            CBaseEntity@ pScreenIntroPresentsMSprite    = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroPresentsMSprite);
            CBaseEntity@ pScreenIntroKnowSprite         = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroKnowSprite);
            CBaseEntity@ pScreenIntroYourSprite         = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroYourSprite);
            CBaseEntity@ pScreenIntroIso7010Sprite      = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroIso7010Sprite);
            CBaseEntity@ pScreenIntroInsSprite          = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroInsSprite);
            CBaseEntity@ pScreenIntroInsMSprite         = g_EntityFuncs.FindEntityByTargetname(null, szScreenIntroInsMSprite);
            CBaseEntity@ pScreenSpriteChosen            = g_EntityFuncs.FindEntityByTargetname(null, szScreenSpriteChosen);

            Vector vecScreenCentre                      = pScreenCentre.pev.origin;
            Vector vecScreenIntroPresentsSpriteOriginal = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroPresentsSprite.pev.targetname)];
            Vector vecScreenIntroPresentsMSpriteOriginal= m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroPresentsMSprite.pev.targetname)];
            Vector vecScreenIntroKnowSpriteOriginal     = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroKnowSprite.pev.targetname)];
            Vector vecScreenIntroYourSpriteOriginal     = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroYourSprite.pev.targetname)];
            Vector vecScreenIntroIso7010SpriteOriginal  = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroIso7010Sprite.pev.targetname)];
            Vector vecScreenIntroInsSpriteOriginal      = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroInsSprite.pev.targetname)];
            Vector vecScreenIntroInsMSpriteOriginal     = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenIntroInsMSprite.pev.targetname)];
            Vector vecScreenSpriteChosenOriginal        = m_vecScreenIntroOrigins[m_szScreenIntroOrigins.find(pScreenSpriteChosen.pev.targetname)];

            // << Handle screen intro stage
            switch (m_uiScreenIntroStageAt) {
                case eScreenIntroStages::Begin:
                    m_flScreenIntroTime = g_Engine.time;

                    pScreenIntroPresentsSprite.Use(null, null, USE_OFF);
                    pScreenIntroPresentsMSprite.Use(null, null, USE_OFF);
                    pScreenIntroKnowSprite.Use(null, null, USE_OFF);
                    pScreenIntroYourSprite.Use(null, null, USE_OFF);
                    pScreenIntroIso7010Sprite.Use(null, null, USE_OFF);
                    pScreenIntroInsSprite.Use(null, null, USE_OFF);
                    pScreenIntroInsMSprite.Use(null, null, USE_OFF);
                    pScreenSpriteChosen.Use(null, null, USE_OFF);

                    pScreenIntroPresentsSprite.pev.origin   = vecScreenIntroPresentsSpriteOriginal;
                    pScreenIntroPresentsMSprite.pev.origin  = vecScreenIntroPresentsMSpriteOriginal;
                    pScreenIntroKnowSprite.pev.origin       = vecScreenIntroKnowSpriteOriginal;
                    pScreenIntroYourSprite.pev.origin       = vecScreenIntroYourSpriteOriginal;
                    pScreenIntroIso7010Sprite.pev.origin    = vecScreenIntroIso7010SpriteOriginal;
                    pScreenIntroInsSprite.pev.origin        = vecScreenIntroInsSpriteOriginal;
                    pScreenIntroInsMSprite.pev.origin       = vecScreenIntroInsMSpriteOriginal;
                    pScreenSpriteChosen.pev.origin          = vecScreenSpriteChosenOriginal;

                    ++m_uiScreenIntroStageAt;
                    m_uiScreenInstructionStageAt    = 0;
                    m_uiScreenInstructionStageDone  = 0;

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Started intro.\n");
                    break;

                case eScreenIntroStages::ShowAdambeanPresents:
                    if (flRunningTime >= 0.0 && m_uiScreenIntroStageDone < m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroPresentsSprite.Use(null, null, USE_ON);
                        pScreenIntroPresentsMSprite.Use(null, null, USE_ON);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "ragemap2022/adambean/drumroll.ogg", 0.75, 0.0, 0, PITCH_NORM);
                        ++m_uiScreenIntroStageDone;
                    }

                    if (flRunningTime >= 3.0 && m_uiScreenIntroStageDone >= m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::ShiftAdambeanPresents:
                    if (flRunningTime >= 3.0 && pScreenIntroPresentsSprite.pev.origin.z < (vecScreenIntroPresentsSpriteOriginal.z + 40)) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroPresentsSprite.pev.origin.z += 2.0;
                    } else {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroPresentsSprite.pev.origin.z = vecScreenIntroPresentsSpriteOriginal.z + 40;

                        ++m_uiScreenIntroStageDone;
                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::ShowKnow:
                    if (flRunningTime >= 6.0 && m_uiScreenIntroStageDone < m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroKnowSprite.Use(null, null, USE_ON);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "debris/impact_crete.wav", 0.5, 0.0, 0, PITCH_NORM);

                        ++m_uiScreenIntroStageDone;
                    }

                    if (flRunningTime >= 7.0 && m_uiScreenIntroStageDone >= m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::ShowYour:
                    if (flRunningTime >= 7.0 && m_uiScreenIntroStageDone < m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroYourSprite.Use(null, null, USE_ON);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "debris/impact_crete.wav", 0.5, 0.0, 0, PITCH_NORM);

                        ++m_uiScreenIntroStageDone;
                    }

                    if (flRunningTime >= 8.0) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::ShowIso7010:
                    if (flRunningTime >= 8.0 && m_uiScreenIntroStageDone < m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroIso7010Sprite.Use(null, null, USE_ON);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "debris/impact_crete.wav", 0.5, 0.0, 0, PITCH_NORM);

                        ++m_uiScreenIntroStageDone;
                    }

                    if (flRunningTime >= 9.0 && m_uiScreenIntroStageDone >= m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroPresentsMSprite.Use(null, null, USE_OFF);

                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::ShiftKnowYourIso7010:
                    if (
                        flRunningTime >= 9.0
                        && pScreenIntroKnowSprite.pev.origin.z > (vecScreenIntroKnowSpriteOriginal.z - 68)
                        && pScreenIntroYourSprite.pev.origin.z > (vecScreenIntroYourSpriteOriginal.z - 68)
                        && pScreenIntroIso7010Sprite.pev.origin.z > (vecScreenIntroIso7010SpriteOriginal.z - 68)
                    ) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroKnowSprite.pev.origin.z    -= 2.0;
                        pScreenIntroYourSprite.pev.origin.z    -= 2.0;
                        pScreenIntroIso7010Sprite.pev.origin.z -= 2.0;
                    } else {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroKnowSprite.pev.origin.z     = vecScreenIntroKnowSpriteOriginal.z - 68;
                        pScreenIntroYourSprite.pev.origin.z     = vecScreenIntroYourSpriteOriginal.z - 68;
                        pScreenIntroIso7010Sprite.pev.origin.z  = vecScreenIntroIso7010SpriteOriginal.z - 68;

                        ++m_uiScreenIntroStageDone;
                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::HideAdambeanPresents:
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                    pScreenIntroPresentsSprite.Use(null, null, USE_OFF);
                    pScreenIntroPresentsSprite.pev.origin = vecScreenIntroPresentsSpriteOriginal;

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                    ++m_uiScreenIntroStageDone;
                    ++m_uiScreenIntroStageAt;
                    break;

                case eScreenIntroStages::ShowInstructions:
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                    if (m_uiScreenInstructionStageAt < 1) {
                        pScreenIntroInsMSprite.Use(null, null, USE_ON);
                        m_uiScreenInstructionStageAt = 1;
                    }

                    flInsStartTime  = (4.0 + (8.0 * m_uiScreenInstructionStageAt));
                    flInsEndTime    = flInsStartTime + 7.5;

                    if (flRunningTime >= flInsStartTime && m_uiScreenInstructionStageDone < m_uiScreenInstructionStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Showing instruction %1.\n", m_uiScreenInstructionStageAt);

                        g_EntityFuncs.SetModel(pScreenIntroInsSprite, "sprites/ragemap2022/adambean/rm2022-ab-ins" + m_uiScreenInstructionStageAt + ".spr");
                        pScreenIntroInsSprite.Use(null, null, USE_ON);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "buttons/blip3.wav", 0.75, 0.0, 0, PITCH_NORM);

                        ++m_uiScreenInstructionStageDone;
                    }

                    if (flRunningTime >= flInsEndTime && m_uiScreenInstructionStageDone >= m_uiScreenInstructionStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Hiding instruction %1.\n", m_uiScreenInstructionStageAt);

                        pScreenIntroInsSprite.Use(null, null, USE_OFF);
                        g_EntityFuncs.SetModel(pScreenIntroInsSprite, "sprites/error.spr");

                        ++m_uiScreenInstructionStageAt;
                    }

                    if (m_uiScreenInstructionStageAt > 4) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroInsSprite.Use(null, null, USE_OFF);
                        g_EntityFuncs.SetModel(pScreenIntroInsSprite, "sprites/error.spr");

                        ++m_uiScreenIntroStageDone;
                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                case eScreenIntroStages::Complete:
                    if (flRunningTime >= 45.0 && m_uiScreenIntroStageDone < m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Running intro stage %1.\n", m_uiScreenIntroStageAt);

                        pScreenIntroInsMSprite.Use(null, null, USE_OFF);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "buttons/bell1.wav", 0.75, 0.0, 0, PITCH_NORM);

                        ++m_uiScreenIntroStageDone;
                    }

                    if (flRunningTime >= 50.0 && m_uiScreenIntroStageDone >= m_uiScreenIntroStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Completed intro stage %1.\n", m_uiScreenIntroStageAt);

                        ++m_uiScreenIntroStageAt;
                    }
                    break;

                default: // End
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Finishing intro.\n");

                    m_uiScreenIntroStageAt          = 0;
                    m_uiScreenIntroStageDone        = 0;
                    m_uiScreenInstructionStageAt    = 0;
                    m_uiScreenInstructionStageDone  = 0;
                    break;
            }
            // >> Handle screen intro stage

            // Intro ended
            if (m_uiScreenIntroStageAt < 1 && flRunningTime >= 50.0) {
                g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunIntro(): Finished intro.\n");

                // Stop
                m_flScreenIntroTime = 0.0;
                g_EntityFuncs.FireTargets(ENT_PREFIX + "run_intro", null, null, USE_OFF);

                // Start game
                g_EntityFuncs.FireTargets(ENT_PREFIX + "game_started_mm", null, null, USE_TOGGLE);
            }
        }

        /**
         * Run game.
         * @return void
         */
        void RunGame()
        {
            double flRound          = (double(m_uiRound) - 1);
            double flRunningTime    = (g_Engine.time - m_flRoundTime);
            double flStartTime      = 1.0;
            double flCycleTime      = (flStartTime + (10.0 - (flRound / 2)));
            double flDropTime       = (flCycleTime + (8.0 - (flRound / 2)));
            double flRaiseTime      = (flDropTime + (6.0 - (flRound / 3)));
            double flCompleteTime   = (flRaiseTime + (6.0 - (flRound / 3)));

            bool fExit = false;

            g_Game.AlertMessage(
                at_aiconsole,
                "Ragemap2022Adambean::MapPart->RunGame(): Round %1 of %2, stage %3 (done %4), chosen platform is %5.\n",
                m_uiRound,
                ROUNDS,
                m_uiRoundStageAt,
                m_uiRoundStageDone,
                m_uiRoundChosenPlatform
            );
            g_Game.AlertMessage(
                at_aiconsole,
                "Ragemap2022Adambean::MapPart->RunGame(): Times:\n* Now = %1\n* Start at = %2\n* Running = %3\n* Cycle until = %4\n* Drop at = %5\n* Raise at = %6\n* Complete at = %7\n",
                g_Engine.time,
                m_flRoundTime,
                flRunningTime,
                flCycleTime,
                flDropTime,
                flRaiseTime,
                flCompleteTime
            );

            if (m_uiRound < 1) {
                g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Starting game.\n");
            }

            string szGameZone                   = ENT_PREFIX + "game_zone";
            string szPlatformFriction           = ENT_PREFIX + PLATFORM_ENT_PREFIX + "friction";
            string szScreenCentre               = ENT_PREFIX + SCREEN_ENT_PREFIX + "centre";
            string szScreenSpriteChosen         = ENT_PREFIX + SCREEN_ENT_PREFIX + "chosen_spr";

            CBaseEntity@ pGameZone              = g_EntityFuncs.FindEntityByTargetname(null, szGameZone);
            CBaseEntity@ pPlatformFriction      = g_EntityFuncs.FindEntityByTargetname(null, szPlatformFriction);
            CBaseEntity@ pScreenCentre          = g_EntityFuncs.FindEntityByTargetname(null, szScreenCentre);
            CBaseEntity@ pScreenSpriteChosen    = g_EntityFuncs.FindEntityByTargetname(null, szScreenSpriteChosen);

            Vector vecScreenCentre              = pScreenCentre.pev.origin;

            // << Handle round stage
            switch (m_uiRoundStageAt) {
                case eRoundStages::Begin:
                    m_flRoundTime = g_Engine.time;

                    ++m_uiRound;

                    pScreenSpriteChosen.Use(null, null, USE_OFF);
                    pScreenSpriteChosen.pev.renderfx    = kRenderFxNone;
                    pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 255.0, 255.0);

                    if (m_uiRound > ROUNDS) {
                        m_uiRoundStageAt = eRoundStages::Complete + 1;
                        fExit = true;
                        break;
                    }

                    ++m_uiRoundStageAt;

                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Started game round %1.\n", m_uiRound);
                    break;

                case eRoundStages::RandomiseSignsAndShow:
                    if (flRunningTime >= flStartTime && m_uiRoundStageDone < m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Running round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        m_uiRoundChosenPlatform = RandomisePlatformSigns();
                        TogglePlatformSigns(USE_ON);

                        pScreenSpriteChosen.pev.renderfx    = kRenderFxNone;
                        pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 255.0, 255.0);
                        pScreenSpriteChosen.Use(null, null, USE_ON);

                        ++m_uiRoundStageDone;
                    }

                    if (flRunningTime >= flStartTime && m_uiRoundStageDone >= m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Completed round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        ++m_uiRoundStageAt;
                    }
                    break;

                case eRoundStages::CycleScreenChosenSignText:
                    if (flRunningTime >= flStartTime && m_uiRoundStageDone < m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Running round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        if (0.125 < (g_Engine.time - m_flRoundTextLastCycleTime)) {
                            g_EntityFuncs.SetModel(pScreenSpriteChosen, "sprites/ragemap2022/adambean/iso7010_" + ISO_7010_SIGNS[Math.RandomLong(0, ISO_7010_SIGNS.length() - 1)] + "_text.spr");
                            g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "buttons/blip1.wav", 0.75, 0.0, 0, PITCH_NORM);
                            m_flRoundTextLastCycleTime = g_Engine.time;
                        }

                        if (flRunningTime >= flCycleTime) {
                            ++m_uiRoundStageDone;
                        }
                    }

                    if (flRunningTime >= flCycleTime && m_uiRoundStageDone >= m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Completed round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        CBaseEntity@ pChosenPlatformSprite;
                        if ((@pChosenPlatformSprite = g_EntityFuncs.FindEntityByTargetname(null, ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(m_uiRoundChosenPlatform) + "_spr")) !is null) {
                            string szChosenPlatformSprite = pChosenPlatformSprite.pev.model;
                            g_EntityFuncs.SetModel(
                                pScreenSpriteChosen,
                                szChosenPlatformSprite.SubString(0, szChosenPlatformSprite.Length() - 4) + "_text.spr"
                            );
                        }

                        pScreenSpriteChosen.pev.renderfx    = kRenderFxStrobeFast;
                        pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 255.0, 0.0);
                        g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "buttons/button10.wav", 0.75, 0.0, 0, PITCH_NORM);

                        ++m_uiRoundStageAt;
                    }
                    break;

                case eRoundStages::LowerWrongPlatforms:
                    if (flRunningTime >= flDropTime && m_uiRoundStageDone < m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Running round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        TogglePlatformSigns(USE_OFF);

                        pScreenSpriteChosen.pev.renderfx    = kRenderFxNone;
                        pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 0.0, 0.0);

                        for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++) {
                            if (uiPlatform == m_uiRoundChosenPlatform) {
                                continue;
                            }

                            g_EntityFuncs.FireTargets(ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(uiPlatform) + "_mm", null, null, USE_TOGGLE);
                        }

                        ++m_uiRoundStageDone;
                    }

                    if (flRunningTime >= flDropTime && m_uiRoundStageDone >= m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Completed round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        ++m_uiRoundStageAt;
                    }
                    break;

                case eRoundStages::RaiseWrongPlatforms:
                    if (flRunningTime >= flRaiseTime && m_uiRoundStageDone < m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Running round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        pScreenSpriteChosen.Use(null, null, USE_OFF);
                        pScreenSpriteChosen.pev.renderfx    = kRenderFxNone;
                        pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 255.0, 255.0);

                        for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++) {
                            if (uiPlatform == m_uiRoundChosenPlatform) {
                                continue;
                            }

                            g_EntityFuncs.FireTargets(ENT_PREFIX + PLATFORM_ENT_PREFIX + formatUInt(uiPlatform) + "_mm", null, null, USE_TOGGLE);
                        } // for (uint uiPlatform = 1; uiPlatform <= PLATFORM_COUNT; uiPlatform++)

                        ++m_uiRoundStageDone;
                    }

                    if (flRunningTime >= flRaiseTime && m_uiRoundStageDone >= m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Completed round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        //pPlatformFriction.pev.renderamt = (double(m_uiRound) * 8.0);
                        pPlatformFriction.pev.friction  = ((100.0 - (7.5 * double(m_uiRound))) / 100.0);
                        pPlatformFriction.Use(null, null, USE_ON);

                        ++m_uiRoundStageAt;
                    }
                    break;

                case eRoundStages::Complete:
                    if (flRunningTime >= flCompleteTime && m_uiRoundStageDone < m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Running round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        array<CBasePlayer@> a_pRemainingPlayers;
                        for (int i = 1; i <= g_Engine.maxClients; i++) {
                            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
                            if (
                                pPlayer is null
                                or !pPlayer.IsPlayer()
                                or !pPlayer.IsConnected()
                                or !pPlayer.IsAlive()
                                or !g_Utility.IsPlayerInVolume(pPlayer, pGameZone)
                            ) {
                                continue;
                            }

                            a_pRemainingPlayers.insertLast(pPlayer);
                        }

                        if (a_pRemainingPlayers.length() >= 1) {
                            g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Round %1: %2 player(s) left.\n", m_uiRound, a_pRemainingPlayers.length());

                            if (m_uiRound < ROUNDS) {
                                g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "buttons/bell1.wav", 0.75, 0.0, 0, PITCH_NORM);
                            } else {
                                for (uint i = 0; i < a_pRemainingPlayers.length(); i++) {
                                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Player \"%1\" won.\n", g_Utility.GetPlayerLog(a_pRemainingPlayers[i].edict()));
                                    a_pRemainingPlayers[i].pev.frags += 7010;
                                }

                                g_EntityFuncs.SetModel(pScreenSpriteChosen, "sprites/ragemap2022/adambean/rm2022-ab-winner.spr");
                                pScreenSpriteChosen.pev.renderfx    = kRenderFxPulseFastWide;
                                pScreenSpriteChosen.pev.rendercolor = Vector(0.0, 191.0, 255.0);
                                pScreenSpriteChosen.Use(null, null, USE_ON);
                                g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "ragemap2022/hezus/cheer.mp3", 0.75, 0.0, 0, PITCH_NORM);

                                fExit = true;
                            }
                        } else {
                            g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Round %1: No players left.\n", m_uiRound);

                            g_EntityFuncs.SetModel(pScreenSpriteChosen, "sprites/ragemap2022/adambean/rm2022-ab-loser.spr");
                            pScreenSpriteChosen.pev.renderfx    = kRenderFxStrobeFaster;
                            pScreenSpriteChosen.pev.rendercolor = Vector(255.0, 95.0, 0.0);
                            pScreenSpriteChosen.Use(null, null, USE_ON);
                            g_SoundSystem.EmitSoundDyn(pScreenCentre.edict(), CHAN_AUTO, "ragemap2022/hezus/boo.mp3", 0.75, 0.0, 0, PITCH_NORM);

                            fExit = true;
                        }

                        ++m_uiRoundStageDone;
                    }

                    if (flRunningTime >= flCompleteTime && m_uiRoundStageDone >= m_uiRoundStageAt) {
                        g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Completed round %1 stage %2.\n", m_uiRound, m_uiRoundStageAt);

                        ++m_uiRoundStageAt;
                    }
                    break;

                default: // End
                    g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Finishing game round %1.\n", m_uiRound);

                    m_uiRoundStageAt    = 0;
                    m_uiRoundStageDone  = 0;
            }
            // >> Handle round stage

            // Game ended
            if (fExit || (m_uiRoundStageAt < 1 && m_uiRound > ROUNDS)) {
                g_Game.AlertMessage(at_aiconsole, "Ragemap2022Adambean::MapPart->RunGame(): Finished game.\n");

                // Stop
                m_flRoundTime = 0.0;
                g_EntityFuncs.FireTargets(ENT_PREFIX + "run_game", null, null, USE_OFF);

                // Exit
                g_EntityFuncs.FireTargets(ENT_PREFIX + "game_ended_mm", null, null, USE_OFF);
                return;
            }
        }
    }

    MapPart@ g_pInstance;
}

/**
 * Map hook: Respawn players outside the game zone.
 * @return void
 */
void Ragemap2022_Adambean_RespawnPlayersOutsideGameZone(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    if (Ragemap2022Adambean::g_pInstance is null) {
        return;
    }

    Ragemap2022Adambean::g_pInstance.RespawnPlayersOutsideGameZone();
}

/**
 * Map hook: Run screen border.
 * @return void
 */
void Ragemap2022_Adambean_RunScreenBorder(CBaseEntity@ pActivator)
{
    if (Ragemap2022Adambean::g_pInstance is null) {
        return;
    }

    Ragemap2022Adambean::g_pInstance.RunScreenBorder();
}

/**
 * Map hook: Run intro.
 * @return void
 */
void Ragemap2022_Adambean_RunIntro(CBaseEntity@ pActivator)
{
    if (Ragemap2022Adambean::g_pInstance is null) {
        return;
    }

    Ragemap2022Adambean::g_pInstance.RunIntro();
}

/**
 * Map hook: Run game.
 * @return void
 */
void Ragemap2022_Adambean_RunGame(CBaseEntity@ pActivator)
{
    if (Ragemap2022Adambean::g_pInstance is null) {
        return;
    }

    Ragemap2022Adambean::g_pInstance.RunGame();
}
