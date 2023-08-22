/**
 * Ragemap 2022: Trempler's part
 */

#include "trempler_speak"

namespace Ragemap2022Trempler
{
    /*
     * -------------------------------------------------------------------------
     * Constants & enumerators
     * -------------------------------------------------------------------------
     */

    const uint CUSTOMERS = 4;
    const uint MAX_WAVES = 8;
    const float MAX_TIME = 60.0;

    enum voiceLines
    {
        order1 = 0,
        order2,
        one,
        two,
        good,
        medium,
        bad,
        burger,
        chicken,
        cookie,
        donut,
        ham,
        soup,
        taco
    }

    // all item_inventory item names that can be delivered to a customer
    array<string>   invItemNames = {        "Item0", "Item1", "Item2", "Item3", "Item4", "Item5", "Item6", "Item7", "Item8", "Item9", "Item10", "Item11", "Item12" };

    // the corresponding item_inventory targetnames
    array<string>   invItemTargetNames = {  "trempler_item0_entity", "trempler_item1_entity", "trempler_item2_entity", "trempler_item3_entity", "trempler_item4_entity", "trempler_item5_entity", "trempler_item6_entity",
                                            "trempler_item7_entity", "trempler_item8_entity", "trempler_item9_entity", "trempler_item10_entity", "trempler_item11_entity", "trempler_item12_entity",};

    // model file names
    array<string>   invItemModels = {   "models/ragemap2022/trempler/burger.mdl",
                                        "models/ragemap2022/trempler/chicken.mdl",
                                        "models/ragemap2022/trempler/cookie.mdl",
                                        "models/ragemap2022/trempler/g_donut.mdl",
                                        "models/ragemap2022/trempler/ham.mdl",
                                        "models/ragemap2022/trempler/soup.mdl",
                                        "models/ragemap2022/trempler/taco.mdl",
                                        "models/ragemap2022/hezus/can.mdl",
                                        "models/ragemap2022/hezus/can.mdl",
                                        "models/ragemap2022/hezus/can.mdl",
                                        "models/ragemap2022/hezus/can.mdl",
                                        "models/ragemap2022/hezus/can.mdl",
                                        "models/ragemap2022/hezus/can.mdl" };

    array<array<int>> itemsPlaced = {   { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 } };

    array<array<int>> itemsWanted = {   { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 },
                                        { -1, -1, -1, -1 } };

    array<float> timeLeft = { 0.0, 0.0, 0.0, 0.0 };



    /*
     * -------------------------------------------------------------------------
     * Variables
     * -------------------------------------------------------------------------
     */

    int     wave                = 0;
    bool    waveActive          = false;
    int     waveCustomers       = 2;
    int     waveCustomersInBus  = 0;
    int     done                = 0;
    int     doneCorrect         = 0;

    HUDTextParams msgParams0;
    HUDTextParams msgParams1;
    HUDTextParams msgParams2;
    HUDTextParams msgParams3;

    array<CBaseEntity@> eCustomers(CUSTOMERS);



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
        g_Game.PrecacheModel("models/barney.mdl");
    }

    /**
     * Map activation handler.
     * @return void
     */
    void MapActivate()
    {
        msgParams0.x            = -1;
        msgParams0.y            = 0.05;
        msgParams0.effect       = 0;
        msgParams0.r1           = 255;
        msgParams0.g1           = 255;
        msgParams0.b1           = 255;
        msgParams0.a1           = 0;
        msgParams0.r2           = 255;
        msgParams0.g2           = 255;
        msgParams0.b2           = 255;
        msgParams0.a2           = 0;
        msgParams0.fadeinTime   = 0;
        msgParams0.fadeoutTime  = 1;
        msgParams0.holdTime     = 1;
        msgParams0.fxTime       = 0;
        msgParams0.channel      = 5;

        // Cheeky copy
        msgParams1 = msgParams0;
        msgParams2 = msgParams0;
        msgParams3 = msgParams0;

        msgParams1.channel = 6;
        msgParams2.channel = 7;
        msgParams3.channel = 8;

        msgParams1.y = 0.1;
        msgParams2.y = 0.15;
        msgParams3.y = 0.2;

        msgParams1.r1 = 255;
        msgParams1.g1 = 50;
        msgParams1.b1 = 50;

        msgParams2.r1 = 50;
        msgParams2.g1 = 255;
        msgParams2.b1 = 50;

        msgParams3.r1 = 50;
        msgParams3.g1 = 50;
        msgParams3.b1 = 255;
    }



    /*
     * -------------------------------------------------------------------------
     * Helper functions
     * -------------------------------------------------------------------------
     */

    /**
     * Validate a customer index.
     * @param  int  customer Customer index
     * @return bool silent   Do not show error message if invalid
     * @return bool          True if valid, false if invalid
     */
    bool IsCustomerValid(int customer, bool silent = false)
    {
        if (customer < 0 || customer > 3) {
            if (!silent) {
                g_Game.AlertMessage(at_error, "Ragemap2022Trempler::IsCustomerValid(): Invalid customer %1 specified. (Must be 0-3!)\n", customer);
            }
            return false;
        }

        return true;
    }



    /*
     * -------------------------------------------------------------------------
     * Functions
     * -------------------------------------------------------------------------
     */

    /**
     * A customer went the counter and is now ordering something.
     * @param  int  customer Customer index
     * @return void
     */
    void Order(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        // Another customer is speaking? Try again in 1 second
        for (uint i = 0; i < CUSTOMERS; i++) {
            if (Ragemap2022TremplerSpeak::finishedSpeaking[i] == false) {
                g_Scheduler.SetTimeout("Order", 1.0, customer);
                return;
            }
        }

        string customerName = "customer" + customer;
        @eCustomers[customer] = g_EntityFuncs.FindEntityByTargetname(null, customerName);

        // How many items are getting ordered
        uint orderCount = Math.RandomLong(1, CUSTOMERS);

        // What gets ordered
        for (uint i = 0; i < itemsWanted[0].length(); i++) {
            if (i >= orderCount) {
                itemsWanted[customer][i] = -1;
                continue;
            }

            itemsWanted[customer][i] = Math.RandomLong(0, invItemNames.length()-1);
        }

        // Make NPC talk!
        Ragemap2022TremplerSpeak::GenerateSpeakOrder(customer);
        Ragemap2022TremplerSpeak::CustomerSpeak(customer);
        timeLeft[customer] = MAX_TIME;
    }

    /**
     * A product is being placed on a counter.
     * @param  int          customer Customer index
     * @param  CBaseEntity@ ePlayer  Player
     * @return void
     */
    void ProductPlaced(int customer, CBaseEntity@ ePlayer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        // Is there even a customer waiting???
        if (eCustomers[customer] is null) {
            return;
        }

        uint slot = 999;

        // Get next free slot
        for (uint i = 0; i < itemsPlaced[0].length(); i++) {
            if (itemsPlaced[customer][i] == -1) {
                slot = i;
                break;
            }
        }

        //g_Game.AlertMessage(at_console, "Slot selected: " + slot + ".\n");

        // No free slot
        if (slot > itemsPlaced[0].length() - 1) {
            g_Game.AlertMessage(at_console, "No free slot!\n");
            return;
        }

        CBasePlayer@ pPlayer = cast<CBasePlayer@>(ePlayer);
        InventoryList@ invList = @pPlayer.m_pInventory;
        uint itemPlaced = 999;

        CItemInventory@ invItem = cast<CItemInventory@>(invList.hItem.GetEntity());
        string sItemName = string(invItem.m_szItemName);

        for (uint i = 0; i < invItemNames.length(); i++) {
            if (sItemName == invItemNames[i]) {
                itemPlaced = i;
                g_EntityFuncs.FireTargets(invItemTargetNames[i], ePlayer, ePlayer, USE_OFF);
                break;
            }
        }

        /*
        while (invList !is null) {
            g_Game.AlertMessage(at_console, "Found an item.\n");

            CItemInventory@ invItem = cast<CItemInventory@>(invList.hItem.GetEntity());
            string sItemName = string(invItem.m_szItemName);

            for (uint i = 0; i < invItemNames.length(); i++) {
                if (sItemName == invItemNames[i]) {
                    itemPlaced = i;
                    g_Game.AlertMessage(at_console, "Dropping.\n");
                    if (invItem !is null) {
                        g_Game.AlertMessage(at_console, "Not null.\n");
                    }
                    invList.hItem.GetEntity().Return();
                    break;
                }
            }

            if (itemPlaced >= 0 && itemPlaced < 999) {
                break;
            }

            @invList = @invList.pNext;
        }
         */

        // Something went wrong
        if (itemPlaced > invItemNames.length() - 1) {
            g_Game.AlertMessage(at_console, "Error: This is not a valid item.\n");
            return;
        }

        itemsPlaced[customer][slot] = itemPlaced;

        //g_Game.AlertMessage(at_console, "Product placed. Customer: " + customer + ". Slot: " + slot + ". By: " + pPlayer.pev.netname + ". What: " + itemPlaced + ".\n");

        // Make placed item visible
        UpdateModels(customer);
    }

    /**
     * A customer is done with your shit.
     * @param  int  customer Customer index
     * @return void
     */
    void Done(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        // Is there even a customer waiting???
        if (eCustomers[customer] is null) {
            return;
        }

        // Has the customer even finished speaking?
        if (!Ragemap2022TremplerSpeak::finishedSpeaking[customer]) {
            return;
        }

        int success = 0;
        int itemCountOrder = 0;
        int itemCountPlaced = 0;

        // Check all placed items
        for (uint p = 0; p < itemsPlaced[0].length(); p++) {
            // skip empty placed slots
            if (itemsPlaced[customer][p] == -1) {
                continue;
            }

            // find that placed item in the wanted list
            for (uint w = 0; w < itemsWanted[0].length(); w++) {
                // skip empty slots in the order
                if (itemsWanted[customer][w] == -1) {
                    continue;
                }

                // players delivered what was ordered, remove both from their list
                if (itemsPlaced[customer][p] == itemsWanted[customer][w]) {
                    itemsPlaced[customer][p] = -1;
                    itemsWanted[customer][w] = -1;
                }
            }
        }

        // Count items in order
        for (uint i = 0; i < itemsWanted[customer].length(); i++) {
            if (itemsWanted[customer][i] != -1) {
                itemCountOrder++;
            }
        }

        // Count items in placed
        for (uint i = 0; i < itemsPlaced[customer].length(); i++) {
            if (itemsPlaced[customer][i] != -1) {
                itemCountPlaced++;
            }
        }

        // All matching items have been removed, everything left is a mistake
        success = CUSTOMERS - itemCountOrder - itemCountPlaced;

        // Clear it
        for (uint i = 0; i < CUSTOMERS; i++) {
            itemsPlaced[customer][i] = -1;
            itemsWanted[customer][i] = -1;
        }

        UpdateModels(customer);

        // Results have consequences
        //g_Game.AlertMessage(at_console, "Customer " + customer + " says: I am " + (25*success) + "% satisfied, bitch.\n");

        done++;

        if (success == CUSTOMERS) {
            doneCorrect++;
        }

        Ragemap2022TremplerSpeak::GenerateSpeakBye(customer, success);
        Ragemap2022TremplerSpeak::CustomerSpeak(customer);

        g_Scheduler.SetTimeout("CustomerLeave", 1.0, customer);
    }

    /**
     * Customer leaving.
     * @param  int  customer Customer index
     * @return void
     */
    void CustomerLeave(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        // Rename the customer
        eCustomers[customer].pev.targetname = "" + eCustomers[customer].pev.targetname + "_exit";

        // Make the customer leave
        string sequenceName = "trempler_customer" + customer + "_leave";
        CBaseEntity@ eSequence = g_EntityFuncs.FindEntityByTargetname(null, sequenceName);

        g_EntityFuncs.FireTargets(sequenceName, null, null, USE_TOGGLE, 0.0, 1.0);

        g_Scheduler.SetTimeout("BusEnter", 40.0, customer);

        @eCustomers[customer] = null;
    }

    /**
     * The timer.
     * @return void
     */
    void Timer()
    {
        CBaseEntity@ eSprite;
        string spriteName;

        // Time left on orders
        for (int i = 0; i < CUSTOMERS; i++) {
            spriteName = "trempler_customer" + i + "_sprite";
            @eSprite = g_EntityFuncs.FindEntityByTargetname(null, spriteName);

            if (eSprite is null) {
                continue;
            }

            // No customer? Hide the status sprite
            if (eCustomers[i] is null) {
                //g_Game.AlertMessage(at_console, "Disabling sprite " + i + "\n");
                eSprite.pev.renderamt = 0;
                continue;
            }

            //g_Game.AlertMessage(at_console, "Time left " + i + ": " + timeLeft[i] + "\n");
            eSprite.pev.renderamt = 255;

            eSprite.pev.frame = (timeLeft[i] / MAX_TIME) * 9;

            if (timeLeft[i] <= 0) {
                Done(i);
            }

            timeLeft[i] -= 0.1;
        }

        // Wave system

        // Start wave
        if (waveActive == false) {
            wave++;
            g_EntityFuncs.FireTargets("trempler_bus", null, null, USE_ON);
            waveActive = true;
            waveCustomersInBus = 0;

            msgParams0.holdTime = 6.0;
            g_PlayerFuncs.HudMessageAll(msgParams0, "Wave " + wave + " of " + MAX_WAVES);
        }

        g_Scheduler.SetTimeout("Timer", 0.1);
    }

    /**
     * Update customer model.
     * @param  int  customer Customer index
     * @return void
     */
    void UpdateModels(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        for (uint i = 0; i < CUSTOMERS; i++) {
            string entityName = "trempler_customer" + customer + "_model" + i;
            CBaseEntity@ eModel = g_EntityFuncs.FindEntityByTargetname(null, entityName);

            if (itemsPlaced[customer][i] == -1) {
                eModel.pev.renderamt = 0;
                continue;
            }

            eModel.pev.renderamt = 255;
            eModel.pev.model = invItemModels[ itemsPlaced[customer][i] ];
            g_EntityFuncs.SetModel(eModel, eModel.pev.model);

            switch (itemsPlaced[customer][i]) {
                case 5:
                    g_Game.AlertMessage(at_console, "Settig skin to 5, wow.\n");
                    eModel.pev.skin = 5;
                    break;

                case 7:
                    eModel.pev.skin = 3;
                    break;

                case 8:
                    eModel.pev.skin = 1;
                    break;

                case 9:
                    eModel.pev.skin = 5;
                    break;

                case 10:
                    eModel.pev.skin = 0;
                    break;

                case 11:
                    eModel.pev.skin = 4;
                    break;

                case 12:
                    eModel.pev.skin = 2;
                    break;

                default:
                    eModel.pev.skin = 0;
            }

            //g_Game.AlertMessage(at_console, "Customer " + customer + ". Slot: " + i + ". Item: " + itemsPlaced[customer][i] + ". Model: " + invItemModels[ itemsPlaced[customer][i] ] + ".\n" );]);
        }
    }

    /**
     * End of the game. Show how badly the players have failed.
     * @return void
     */
    void EndGame()
    {
        array<string> marks = { "F-", "F+", "E-", "E+", "D-", "D+", "C-", "C+", "B-", "B+", "A-", "A+" };
        float correct   = doneCorrect;
        float total     = done;

        int mark = int((correct / total) * 11.0f);

        msgParams0.holdTime = 30.0;
        msgParams0.y = -1;
        string txt = "Game over!\n Orders done correct:\n" + doneCorrect + " of " + done + "\n I give you a " + marks[mark] + " for that.";

        g_PlayerFuncs.HudMessageAll(msgParams0, txt);

        g_EntityFuncs.FireTargets("trempler_over_part_mm", null, null, USE_ON);

        if (mark >= 6) {
            g_Game.AlertMessage(at_console, "Triggering: trempler_won_sound\n");
            g_EntityFuncs.FireTargets("trempler_won_sound", null, null, USE_ON);
        } else {
            g_Game.AlertMessage(at_console, "Triggering: trempler_lost_sound\n");
            g_EntityFuncs.FireTargets("trempler_lost_sound", null, null, USE_ON);
            g_Game.AlertMessage(at_console, "Triggering: trempler_over_part_mm_bad_event\n");
            g_EntityFuncs.FireTargets("trempler_over_part_mm_bad_event", null, null, USE_ON);
        }
    }

    /**
     * Bus is entering.
     * @param  int  customer Customer index
     * @return void
     */
    void BusEnter(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        CBaseEntity@ eCustomer = g_EntityFuncs.FindEntityByTargetname(null, "customer" + customer + "_exit");

        // Kill the guy
        if (eCustomer is null) {
            return;
        }

        waveCustomersInBus++;
        g_EntityFuncs.Remove(eCustomer);

        if (waveCustomersInBus >= waveCustomers) {
            g_EntityFuncs.FireTargets("trempler_bus", null, null, USE_ON);
            return;
        }

        // Find the next customer
        int customerNumber = 3 + waveCustomersInBus;
        @eCustomer = g_EntityFuncs.FindEntityByTargetname(null, "customer" + customerNumber);

        if (eCustomer is null) {
            return;
        }

        // Rename it
        eCustomer.pev.targetname = "customer" + customer;

        // Make it go inside and order
        g_EntityFuncs.FireTargets("trempler_customer" + customer + "_sequence", null, null, USE_TOGGLE, 0.0, 1.0);
    }

    /**
     * Gib a customer.
     * @param  int  customer Customer index
     * @return void
     */
    void GibCustomer(int customer)
    {
        if (!IsCustomerValid(customer)) {
            return;
        }

        g_Game.AlertMessage(at_console, "Gib customer " + customer + ".\n");

        CBaseEntity@ eEntity = g_EntityFuncs.FindEntityByTargetname(null, "customer" + customer + "_exit");

        if (eEntity is null) {
            return;
        }

        g_Game.AlertMessage(at_console, "Really gib customer" + customer + ".\n");

        NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        m.WriteByte(TE_MODEL);
        m.WriteCoord(eEntity.pev.origin.x);
        m.WriteCoord(eEntity.pev.origin.x);
        m.WriteCoord(eEntity.pev.origin.z);
        m.WriteCoord(1);
        m.WriteCoord(1);
        m.WriteCoord(1);
        m.WriteAngle(0);
        m.WriteShort(g_EngineFuncs.ModelIndex("models/agibs.mdl"));
        m.WriteByte(2);
        m.WriteByte(32);
        m.End();

        g_EntityFuncs.Remove(eEntity);
    }
}

/**
 * Map hook: Timer.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerTimer(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Timer();
}

/**
 * Map hook: Bus stop.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusStop(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    //g_Game.AlertMessage(at_console, "The bus arrived.\n");
    for (int i = 0; i < Ragemap2022Trempler::waveCustomers; i++) {
        string spawnerName = "trempler_spawncustomer" + i;
        CBaseEntity@ eSpawner = g_EntityFuncs.FindEntityByTargetname(null, spawnerName);

        // Select random npcs
        int randomResult = Math.RandomLong(0,2);

        switch (randomResult) {
            case 0:
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "monstertype", "monster_gman");
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "respawn_as_playerally", "1");
                break;

            case 1:
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "monstertype", "monster_barney");
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "respawn_as_playerally", "0");
                break;

            default:
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "monstertype", "monster_scientist");
                g_EntityFuncs.DispatchKeyValue(eSpawner.edict(), "respawn_as_playerally", "0");
        }

        // Spawn npcs
        g_EntityFuncs.FireTargets(spawnerName, null, null, USE_ON);

        // Make them go inside and order
        g_EntityFuncs.FireTargets("trempler_customer" + i + "_sequence", null, null, USE_TOGGLE, 0.0, 2.0);
    }
}

/**
 * Map hook: Bus stop. (2?)
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusStop2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    if (Ragemap2022Trempler::wave >= Ragemap2022Trempler::MAX_WAVES) {
        Ragemap2022Trempler::EndGame();
        return;
    }

    Ragemap2022Trempler::waveActive = false;
    Ragemap2022Trempler::waveCustomers++;

    if (Ragemap2022Trempler::waveCustomers > 8) {
        Ragemap2022Trempler::waveCustomers = 8;
    }
}

/**
 * Map hook: Bus enter for customer 0.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusEnter0(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::BusEnter(0);
}

/**
 * Map hook: Bus enter for customer 1.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusEnter1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::BusEnter(1);
}

/**
 * Map hook: Bus enter for customer 2.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusEnter2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::BusEnter(2);
}

/**
 * Map hook: Bus enter for customer 3.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerBusEnter3(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::BusEnter(3);
}

/**
 * Map hook: Product placed for customer 1.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void ProductPlaced0(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::ProductPlaced(0, pActivator);
}

/**
 * Map hook: Product placed for customer 2.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void ProductPlaced1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::ProductPlaced(1, pActivator);
}

/**
 * Map hook: Product placed for customer 3.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void ProductPlaced2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::ProductPlaced(2, pActivator);
}

/**
 * Map hook: Product placed for customer 0.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void ProductPlaced3(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::ProductPlaced(3, pActivator);
}

/**
 * Map hook: Order placed from customer 0.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerOrder0(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Order(0);
}

/**
 * Map hook: Order placed from customer 1.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerOrder1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Order(1);
}

/**
 * Map hook: Order placed from customer 2.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerOrder2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Order(2);
}

/**
 * Map hook: Order placed from customer 3.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerOrder3(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Order(3);
}

/**
 * Map hook: Order complete from customer 0.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerDone0(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Done(0);
}

/**
 * Map hook: Order complete from customer 1.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerDone1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Done(1);
}

/**
 * Map hook: Order complete from customer 2.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerDone2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Done(2);
}

/**
 * Map hook: Order complete from customer 3.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerDone3(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    Ragemap2022Trempler::Done(3);
}

/**
 * Map hook: Special debug function for customer 0.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerCustomer0(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    /*
    if (pActivator !is null) {
        g_Game.AlertMessage(at_console, "Customer 0 is now: " + pActivator.pev.targetname + "\n");
        @Ragemap2022Trempler::eCustomer[0] = g_EntityFuncs.FindEntityByTargetname(null, "customer0");
        @Ragemap2022Trempler::eCustomers[0] = pActivator;
    }
     */
}

/**
 * Map hook: Special debug function for customer 1.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerCustomer1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    /*
    if (pActivator !is null) {
        g_Game.AlertMessage(at_console, "Customer 1 is now: " + pActivator.pev.targetname + "\n");
        @Ragemap2022Trempler::eCustomer[0] = g_EntityFuncs.FindEntityByTargetname(null, "customer1");
        @Ragemap2022Trempler::eCustomers[1] = pActivator;
    }
     */
}

/**
 * Map hook: Special debug function for customer 2.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerCustomer2(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    /*
    if (pActivator !is null) {
        g_Game.AlertMessage(at_console, "Customer 2 is now: " + pActivator.pev.targetname + "\n");
        @Ragemap2022Trempler::eCustomer[0] = g_EntityFuncs.FindEntityByTargetname(null, "customer2");
        @Ragemap2022Trempler::eCustomers[2] = pActivator;
    }
     */
}

/**
 * Map hook: Special debug function for customer 3.
 * @param  CBaseEntity@|null pActivator Activator entity, typically a "trigger_script"
 * @param  CBaseEntity@|null pCaller    Caller entity
 * @param  USE_TYPE          useType    Use type, or unspecified to assume `USE_TOGGLE`
 * @param  float             flValue    Use value, or unspecified to assume `0.0f`
 * @return void
 */
void TremplerCustomer3(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    /*
    if (pActivator !is null) {
        g_Game.AlertMessage(at_console, "Customer 3 is now: " + pActivator.pev.targetname + "\n");
        @Ragemap2022Trempler::eCustomer[0] = g_EntityFuncs.FindEntityByTargetname(null, "customer3");
        @Ragemap2022Trempler::eCustomers[3] = pActivator;
    }
     */
}
