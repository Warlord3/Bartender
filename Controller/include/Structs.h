#pragma once
#include "Arduino.h"
#include "Enum.h"
#include "debug.h"

struct stPumpInfo
{
    int mlPerMinute;
    int beverageID;
    float remainingMl;
    enPumpDirection direction;
    stPumpInfo()
    {
        mlPerMinute = 0;
        beverageID = 0;
        remainingMl = 0;
        direction = enPumpDirection::stop;
    }
    void print()
    {
        DEBUG_PRINTF("ml:%i,beverage:%i,remain:%f,state:%i\n", mlPerMinute, beverageID, remainingMl, (int)direction);
    }
};

struct stDrink
{
    uint ID = 0;
    float amount[16] = {0.0};
};
