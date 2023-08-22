/*======================================*/
/*==== Ragemap 2022 Script - v 1.00 ====*/
/*======================================*/



/*
 * -------------------------------------------------------------------------
 * Includes
 * -------------------------------------------------------------------------
 */

#include "ragemap2022"
#include "alexc"
#include "trempler"



/*
 * -------------------------------------------------------------------------
 * Globals
 * -------------------------------------------------------------------------
 */

/** @global string[] mappers These are the mapper's names if the script needs to print it on screen or something. */
array<string> mappers = {
    "Intro",
    "AlexCorruptor",
    "Erty",
    "Trempler",
    "Outro"
};

/** @global string[] mapperTags A more simple version of the mappers's name, in case they have special characters in them. These should be used in all mapper related entity names. */
array<string> mapperTags = {
    "intro",
    "alexc",
    "erty",
    "trempler",
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

    // AlexCorruptor's part
    Ragemap2022AlexCorruptor::MapInit();

    // Trempler's part
    Ragemap2022Trempler::MapInit();
}

/**
 * Map activation handler.
 * @return void
 */
void MapActivate()
{
    // Shared script
    Ragemap2022::MapActivate();

    // AlexCorruptor's part
    Ragemap2022AlexCorruptor::MapActivate();

    // Trempler's part
    Ragemap2022Trempler::MapActivate();
}
