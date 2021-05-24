#pragma once
#include "Arduino.h"
#include "Enum.h"
#include "debug.h"

struct stPumpInfo
{
    int mlPerMinute;
    int beverageID;
    float remainingMl;
    bool testingMode = false;
    enPumpRunningDirection runningDirection;
    enMechanicalDirection mechanicalDirection;
    stPumpInfo()
    {
        mlPerMinute = 0;
        beverageID = 0;
        remainingMl = 0;
        runningDirection = enPumpRunningDirection::stop;
        mechanicalDirection = enMechanicalDirection::forward;
    }
    void print()
    {
        DEBUG_PRINTF("ml:%i,beverage:%i,remain:%f,state:%i\n", mlPerMinute, beverageID, remainingMl, (int)runningDirection);
    }
};

struct stDrink
{
    uint ID = 0;
    float amount[16] = {0.0};
};
