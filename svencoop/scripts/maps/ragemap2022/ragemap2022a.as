/*======================================*/
/*==== Ragemap 2022 Script - v 1.00 ====*/
/*======================================*/



/*
 * -------------------------------------------------------------------------
 * Includes
 * -------------------------------------------------------------------------
 */

#include "ragemap2022"
#include "adambean"



/*
 * -------------------------------------------------------------------------
 * Globals
 * -------------------------------------------------------------------------
 */

/** @global string[] mappers These are the mapper's names if the script needs to print it on screen or something. */
array<string> mappers = {
    "Intro",
    "Ika",
    "BonkTurnip",
    "Adambean",
    "SV BOY",
    "Outro"
};

/** @global string[] mapperTags A more simple version of the mappers's name, in case they have special characters in them. These should be used in all mapper related entity names. */
array<string> mapperTags = {
    "intro",
    "ika",
    "bonk",
    "adambean",
    "svboy",
    "outro"
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
    // Shared script
    Ragemap2022::MapInit();

    // Adambean's part
    Ragemap2022Adambean::MapInit();
}

/**
 * Map activation handler.
 * @return void
 */
void MapActivate()
{
    // Shared script
    Ragemap2022::MapActivate();

    // Adambean's part
    Ragemap2022Adambean::MapActivate();
}
