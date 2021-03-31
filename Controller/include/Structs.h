#pragma once
#include "Arduino.h"
#include "Enum.h"
#include "debug.h"

struct stPumpInfo
{
    uint8_t ID;
    int mlPerMinute;
    int beverageID;
    float remainingMl;
    enPumpDirection direction;
    stPumpInfo()
    {
        ID = 0;
        mlPerMinute = 0;
        beverageID = 0;
        remainingMl = 0;
        direction = enPumpDirection::stop;
    }
    void print()
    {
        DEBUG_PRINTF("ID:%i,ml:%i,beverage:%i,remain:%f,state:%i\n", ID, mlPerMinute, beverageID, remainingMl, (int)direction);
    }
};

struct stDrink
{
    uint ID = 0;
    float amount[16] = {0.0};
};
