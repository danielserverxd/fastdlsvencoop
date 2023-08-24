/**
 * Ragemap 2022: Trempler's part (speaking)
 */

#include "trempler"

namespace Ragemap2022TremplerSpeak
{
    /*
     * -------------------------------------------------------------------------
     * Constants & enumerators
     * -------------------------------------------------------------------------
     */

    // sound files gman
    array<string>	voiceGman = {       "+ragemap2022/trempler/gman/g_i_want_to_order.wav",
                                        "+ragemap2022/trempler/gman/g_i_would_like_to_order.wav",
                                        "+ragemap2022/trempler/gman/g_one.wav",
                                        "+ragemap2022/trempler/gman/g_two.wav",
                                        "+ragemap2022/trempler/gman/g_thank_you.wav",
                                        "+ragemap2022/trempler/gman/g_about_time.wav",
                                        "+ragemap2022/trempler/gman/g_leave.wav",

                                        "+ragemap2022/trempler/gman/g_xen_burger.wav",
                                        "+ragemap2022/trempler/gman/g_big_chicken.wav",
                                        "+ragemap2022/trempler/gman/g_lambda_cookie.wav",
                                        "+ragemap2022/trempler/gman/g_donut.wav",
                                        "+ragemap2022/trempler/gman/g_sweet_ham.wav",
                                        "+ragemap2022/trempler/gman/g_mesa_soup.wav",
                                        "+ragemap2022/trempler/gman/g_tesla_taco.wav",

                                        "+ragemap2022/trempler/gman/g_dante.wav",
                                        "+ragemap2022/trempler/gman/g_glub_cola.wav",
                                        "+ragemap2022/trempler/gman/g_grope_soda.wav",
                                        "+ragemap2022/trempler/gman/g_hal_lemon.wav",
                                        "+ragemap2022/trempler/gman/g_outher_light.wav",
                                        "+ragemap2022/trempler/gman/g_yuck.wav"	};

    array<string>	voiceBarney = {     "+ragemap2022/trempler/barney/b_i_want_to_order.wav",
                                        "+ragemap2022/trempler/barney/b_i_would_like_to_order.wav",
                                        "+ragemap2022/trempler/barney/b_one.wav",
                                        "+ragemap2022/trempler/barney/b_two.wav",
                                        "+ragemap2022/trempler/barney/b_thank_you.wav",
                                        "+ragemap2022/trempler/barney/b_about_time.wav",
                                        "+ragemap2022/trempler/barney/b_leave.wav",

                                        "+ragemap2022/trempler/barney/b_xen_burger.wav",
                                        "+ragemap2022/trempler/barney/b_big_chicken.wav",
                                        "+ragemap2022/trempler/barney/b_lambda_cookie.wav",
                                        "+ragemap2022/trempler/barney/b_donut.wav",
                                        "+ragemap2022/trempler/barney/b_sweet_ham.wav",
                                        "+ragemap2022/trempler/barney/b_mesa_soup.wav",
                                        "+ragemap2022/trempler/barney/b_tesla_taco.wav",

                                        "+ragemap2022/trempler/barney/b_dante.wav",
                                        "+ragemap2022/trempler/barney/b_glub_cola.wav",
                                        "+ragemap2022/trempler/barney/b_grope_soda.wav",
                                        "+ragemap2022/trempler/barney/b_hal_lemon.wav",
                                        "+ragemap2022/trempler/barney/b_outher_light.wav",
                                        "+ragemap2022/trempler/barney/b_yuck.wav"	};

    array<string>	voiceScientist = {  "+ragemap2022/trempler/scientist/s_i_want_to_order.wav",
                                        "+ragemap2022/trempler/scientist/s_i_would_like_to_order.wav",
                                        "+ragemap2022/trempler/scientist/s_one.wav",
                                        "+ragemap2022/trempler/scientist/s_two.wav",
                                        "+ragemap2022/trempler/scientist/s_thank_you.wav",
                                        "+ragemap2022/trempler/scientist/s_about_time.wav",
                                        "+ragemap2022/trempler/scientist/s_leave.wav",

                                        "+ragemap2022/trempler/scientist/s_xen_burger.wav",
                                        "+ragemap2022/trempler/scientist/s_big_chicken.wav",
                                        "+ragemap2022/trempler/scientist/s_lambda_cookie.wav",
                                        "+ragemap2022/trempler/scientist/s_donut.wav",
                                        "+ragemap2022/trempler/scientist/s_sweet_ham.wav",
                                        "+ragemap2022/trempler/scientist/s_mesa_soup.wav",
                                        "+ragemap2022/trempler/scientist/s_tesla_taco.wav",

                                        "+ragemap2022/trempler/scientist/s_dante.wav",
                                        "+ragemap2022/trempler/scientist/s_glub_cola.wav",
                                        "+ragemap2022/trempler/scientist/s_grope_soda.wav",
                                        "+ragemap2022/trempler/scientist/s_hal_lemon.wav",
                                        "+ragemap2022/trempler/scientist/s_outher_light.wav",
                                        "+ragemap2022/trempler/scientist/s_yuck.wav"	};

    array<string> textLines = {         "I want to order",
                                        "I would like to order",
                                        "one",
                                        "two",
                                        "Thank you",
                                        "About time ..",
                                        "I'm gonna leave this place. I wont come back!",

                                        "xen burger",
                                        "big chicken",
                                        "lambda cookie",
                                        "donut",
                                        "sweet ham",
                                        "mesa soup",
                                        "tesla taco",

                                        "dante",
                                        "glub cola",
                                        "grope soda",
                                        "hal lemonade",
                                        "outher light",
                                        "yuck" };

    array<string> textLinesBarney = {   "Hey! I wana order",
                                        "I would like to order",
                                        "one",
                                        "two",
                                        "Thank you",
                                        "About time ..",
                                        "Time to go, and never come back!",

                                        "xen burger",
                                        "big chicken",
                                        "lambda cookie",
                                        "donut",
                                        "sweet ham",
                                        "mesa soup",
                                        "tesla taco",

                                        "dante",
                                        "glub cola",
                                        "grope soda",
                                        "hal lemonade",
                                        "outher light",
                                        "yuck" };

    array<string> textLinesScientist = {"Excuse me, i want to order",
                                        "Hello! I would like to order",
                                        "one",
                                        "two",
                                        "Thank you",
                                        "About time ..",
                                        "Even Gorden Freeman wasn't this slow .. i better go!",

                                        "xen burger",
                                        "big chicken",
                                        "lambda cookie",
                                        "donut",
                                        "sweet ham",
                                        "mesa soup",
                                        "tesla taco",

                                        "dante",
                                        "glub cola",
                                        "grope soda",
                                        "hal lemonade",
                                        "outher light",
                                        "yuck" };

    array<float>	lengthGman = {      1.9, 2.1, 0.7, 0.6, 1.0, 2.0, 3.6,
                                        1.7, 1.6, 1.5, 0.9, 1.9, 1.2, 1.3,
                                        0.9, 1.7, 1.7, 1.8, 1.3, 0.6 };

    array<float>	lengthBarney = {    1.6, 1.3, 0.5, 0.6, 1.0, 1.2, 3.6,
                                        1.0, 1.6, 1.0, 0.7, 0.9, 1.0, 1.6,
                                        0.6, 0.9, 0.9, 1.4, 0.7, 0.6 };

    array<float>	lengthScientist = { 2.4, 2.3, 0.5, 0.6, 1.0, 1.0, 3.6,
                                        1.0, 0.7, 0.9, 0.5, 1.0, 0.8, 1.3,
                                        0.6, 0.8, 0.8, 0.9, 0.9, 0.6 };


    array<array<int>> sentenceQueue = {     { -1, -1, -1, -1,           -1, -1, -1, -1, -1 },
                                            { -1, -1, -1, -1,           -1, -1, -1, -1, -1 },
                                            { -1, -1, -1, -1,           -1, -1, -1, -1, -1 },
                                            { -1, -1, -1, -1,           -1, -1, -1, -1, -1 } };

    array<array<float>> sentenceLength = {  { 0.0, 0.0, 0.0, 0,0,   0.0, 0.0, 0.0, 0.0, 0.0 },
                                            { 0.0, 0.0, 0.0, 0,0,   0.0, 0.0, 0.0, 0.0, 0.0 },
                                            { 0.0, 0.0, 0.0, 0,0,   0.0, 0.0, 0.0, 0.0, 0.0 },
                                            { 0.0, 0.0, 0.0, 0,0,   0.0, 0.0, 0.0, 0.0, 0.0 } };

    array<string> customerTexts = { "", "", "", "" };

    array<bool> finishedSpeaking = { true, true, true, true };



    /*
     * -------------------------------------------------------------------------
     * Variables
     * -------------------------------------------------------------------------
     */

    float lastSpokenTime = 0.0;



    /*
     * -------------------------------------------------------------------------
     * Functions
     * -------------------------------------------------------------------------
     */

    /**
     * Generate speech for an order.
     * @param  int  customer Customer index
     * @return void
     */
    void GenerateSpeakOrder(int customer)
    {
        if (!Ragemap2022Trempler::IsCustomerValid(customer)) {
            return;
        }

        int randomResult;

        string monstertype;

        if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
            monstertype = "gman";
        } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
            monstertype = "barney";
        } else {
            monstertype = "scientist";
        }

        // Clear previous data
        for (uint i = 0; i < sentenceQueue[0].length(); i++) {
            sentenceQueue[customer][i] = -1;
            sentenceLength[customer][i] = 0.0;
        }

        // hello
        randomResult = Math.RandomLong(0, 1);
        sentenceQueue[customer][0] = randomResult;

        if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
            sentenceLength[customer][0] = lengthGman[randomResult];
            customerTexts[customer] = textLines[randomResult];
        } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
            sentenceLength[customer][0] = lengthBarney[randomResult];
            customerTexts[customer] = textLinesBarney[randomResult];
        } else {
            sentenceLength[customer][0] = lengthScientist[randomResult];
            customerTexts[customer] = textLinesScientist[randomResult];
        }

        // numbers
        for (uint i = 0; i < Ragemap2022Trempler::CUSTOMERS; i++) {
            if (Ragemap2022Trempler::itemsWanted[customer][i] == -1) {
                break;
            }

            sentenceQueue[customer][(i*2)+1] = 2;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
                sentenceLength[customer][(i*2)+1] = lengthGman[2];
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
                sentenceLength[customer][(i*2)+1] = lengthBarney[2];
            } else {
                sentenceLength[customer][(i*2)+1] = lengthScientist[2];
            }
        }

        // product names
        for (uint i = 0; i < Ragemap2022Trempler::CUSTOMERS; i++) {
            if (Ragemap2022Trempler::itemsWanted[customer][i] == -1) {
                break;
            }

            sentenceQueue[customer][(i*2)+2] = Ragemap2022Trempler::itemsWanted[customer][i] + 7;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
                sentenceLength[customer][(i*2)+2] = lengthGman[Ragemap2022Trempler::itemsWanted[customer][i] + 7];
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
                sentenceLength[customer][(i*2)+2] = lengthBarney[Ragemap2022Trempler::itemsWanted[customer][i] + 7];
            } else {
                sentenceLength[customer][(i*2)+2] = lengthScientist[Ragemap2022Trempler::itemsWanted[customer][i] + 7];
            }
        }

        for (uint i = 1; i < sentenceQueue[0].length(); i++) {
            if (sentenceQueue[customer][i] == -1)
                break;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
                customerTexts[customer] = customerTexts[customer] + " " + textLines[sentenceQueue[customer][i]];
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
                customerTexts[customer] = customerTexts[customer] + " " + textLinesBarney[sentenceQueue[customer][i]];
            } else {
                customerTexts[customer] = customerTexts[customer] + " " + textLinesScientist[sentenceQueue[customer][i]];
            }
        }

        customerTexts[customer] = customerTexts[customer] + ".";
    }

    /**
     * Generate speech for an order.
     * @param  int  customer Customer index
     * @param  int  success  Number of correct products
     * @return void
     */
    void GenerateSpeakBye(int customer, int success)
    {
        if (!Ragemap2022Trempler::IsCustomerValid(customer)) {
            return;
        }

        // Clear previous data
        for (uint i = 0; i < sentenceQueue[0].length(); i++) {
            sentenceQueue[customer][i] = -1;
            sentenceLength[customer][i] = 0.0;
        }

        // Fail
        if (success < 4) {
            sentenceQueue[customer][0] = 6;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman")
            {
                sentenceLength[customer][0] = lengthGman[6];
                customerTexts[customer] = textLines[6];
            }
            else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney")
            {
                sentenceLength[customer][0] = lengthBarney[6];
                customerTexts[customer] = textLinesBarney[6];
            }
            else
            {
                sentenceLength[customer][0] = lengthScientist[6];
                customerTexts[customer] = textLinesScientist[6];
            }
        } else {
            // Not fail
            sentenceQueue[customer][0] = 4;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
                sentenceLength[customer][0] = lengthGman[4];
                customerTexts[customer] = textLines[4];
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
                sentenceLength[customer][0] = lengthBarney[4];
                customerTexts[customer] = textLinesBarney[4];
            } else {
                sentenceLength[customer][0] = lengthScientist[4];
                customerTexts[customer] = textLinesScientist[4];
            }
        }
    }

    /**
     * Make a customer speak.
     * @param  int  customer Customer index
     * @return void
     */
    void CustomerSpeak(int customer)
    {
        if (!Ragemap2022Trempler::IsCustomerValid(customer)) {
            return;
        }

        finishedSpeaking[customer] = false;

        float delay = 0.0;

        for (uint i = 0; i < sentenceQueue[0].length(); i++) {
            if (sentenceQueue[customer][i] == -1) {
                continue;
            }

            string monstertype;

            if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_gman") {
                monstertype = "gman";
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_barney") {
                monstertype = "barney";
            } else if (Ragemap2022Trempler::eCustomers[customer].pev.classname == "monster_scientist") {
                monstertype = "scientist";
            } else {
                return;
            }

            string sentenceName = "trempler_sentence" + sentenceQueue[customer][i] + "_" + monstertype;

            CBaseEntity@ eSentence = g_EntityFuncs.FindEntityByTargetname(null, sentenceName);
            g_EntityFuncs.DispatchKeyValue(eSentence.edict(), "entity", Ragemap2022Trempler::eCustomers[customer].pev.targetname);
            g_EntityFuncs.FireTargets(sentenceName, null, null, USE_ON, 0.0, delay);
            //g_EngineFuncs.ServerPrint("Triggering: " + sentenceName + " in " + delay + " seconds.\n");
            delay += sentenceLength[customer][i] + 0.1;
            delay += 0.1;
            sentenceQueue[customer][i] = -1;
        }

        g_Scheduler.SetTimeout("FinishSpeaking" + customer, delay);

        // Text output
        DistortText(customer);
        TremplerShowText(customer, delay);
    }

    /**
     * Distort a customer's text.
     * @param  int  customer Customer index
     * @return void
     */
    void DistortText(int customer)
    {
        if (!Ragemap2022Trempler::IsCustomerValid(customer)) {
            return;
        }

        int randomResult;

        for (uint i = 0; i < customerTexts[customer].Length(); i++) {
            if (Math.RandomLong(0,100) > 15) {
                continue;
            }

            if (
                customerTexts[customer].opIndex(i) == 'a'
                || customerTexts[customer].opIndex(i) == 'e'
                || customerTexts[customer].opIndex(i) == 'i'
                || customerTexts[customer].opIndex(i) == 'o'
                || customerTexts[customer].opIndex(i) == 'u'
            ) {
                // aeiou
                randomResult = Math.RandomLong(0, 4);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'a');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'e');
                        break;

                    case 2:
                        customerTexts[customer].SetCharAt(i, 'i');
                        break;

                    case 3:
                        customerTexts[customer].SetCharAt(i, 'o');
                        break;

                    case 4:
                        customerTexts[customer].SetCharAt(i, 'u');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'm' || customerTexts[customer].opIndex(i) == 'n') {
                // mn
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'm');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'n');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'p' || customerTexts[customer].opIndex(i) == 'b') {
                // pb
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'p');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'b');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'c' || customerTexts[customer].opIndex(i) == 'k') {
                // ck
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'c');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'k');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'd' || customerTexts[customer].opIndex(i) == 't') {
                // dt
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'd');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 't');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'f' || customerTexts[customer].opIndex(i) == 'v') {
                // fv
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'f');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'v');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'j' || customerTexts[customer].opIndex(i) == 'y') {
                // jy
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'j');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'y');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == 'r' || customerTexts[customer].opIndex(i) == 'l') {
                // rl
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, 'r');
                        break;

                    case 1:
                        customerTexts[customer].SetCharAt(i, 'l');
                        break;
                }
            } else if (customerTexts[customer].opIndex(i) == ' ') {
                // skip space
                continue;
            } else {
                randomResult = Math.RandomLong(0, 1);
                switch (randomResult) {
                    case 0:
                        customerTexts[customer].SetCharAt(i, '*');
                        break;
                    case 1:
                        customerTexts[customer].SetCharAt(i, '~');
                        break;
                }
            }
        }
    }

    /**
     * Show a customer's text.
     * @param  int   customer Customer index
     * @param  float hold     Hold time on screen
     * @return void
     */
    void TremplerShowText(int customer, float hold)
    {
        if (!Ragemap2022Trempler::IsCustomerValid(customer)) {
            return;
        }

        //g_EngineFuncs.ServerPrint("" + customerTexts[customer] + "\n");

        switch (customer) {
            case 0:
                Ragemap2022Trempler::msgParams0.holdTime = hold;
                g_PlayerFuncs.HudMessageAll(Ragemap2022Trempler::msgParams0, customerTexts[customer]);
                break;

            case 1:
                Ragemap2022Trempler::msgParams1.holdTime = hold;
                g_PlayerFuncs.HudMessageAll(Ragemap2022Trempler::msgParams1, customerTexts[customer]);
                break;

            case 2:
                Ragemap2022Trempler::msgParams2.holdTime = hold;
                g_PlayerFuncs.HudMessageAll(Ragemap2022Trempler::msgParams2, customerTexts[customer]);
                break;

            case 3:
                Ragemap2022Trempler::msgParams3.holdTime = hold;
                g_PlayerFuncs.HudMessageAll(Ragemap2022Trempler::msgParams3, customerTexts[customer]);
                break;
        }
    }

    /**
     * Finished speaking for customer 0.
     * @return void
     */
    void FinishSpeaking0()
    {
        finishedSpeaking[0] = true;
    }

    /**
     * Finished speaking for customer 1.
     * @return void
     */
    void FinishSpeaking1()
    {
        finishedSpeaking[1] = true;
    }

    /**
     * Finished speaking for customer 2.
     * @return void
     */
    void FinishSpeaking2()
    {
        finishedSpeaking[2] = true;
    }

    /**
     * Finished speaking for customer 3.
     * @return void
     */
    void FinishSpeaking3()
    {
        finishedSpeaking[3] = true;
    }
}
