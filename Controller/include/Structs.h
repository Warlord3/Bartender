#pragma once
#include "Arduino.h"
#include "Enum.h"
#include "debug.h"
struct stConfig
{
    String wifiSSID = "";
    String wifiPassword = "";
    enOperationMode operationMode = enOperationMode::normalMode;
    stConfig()
    {
        wifiSSID = "";
        wifiPassword = "";
        operationMode = enOperationMode::normalMode;
    }
};

struct stPumpInfo
{
    uint8_t ID;
    int mlPerMinute;
    int beverageID;
    float remainingMl;
    enPumpState state;
    stPumpInfo()
    {
        ID = 0;
        mlPerMinute = 0;
        beverageID = 0;
        remainingMl = 0;
        state = enPumpState::stop;
    }
    void print()
    {
        DEBUG_PRINTF("ID:%i,ml:%i,beverage:%i,remain:%f,state:%i\n", ID, mlPerMinute, beverageID, remainingMl, (int)state);
    }
};

struct stDrink
{
    uint ID = 0;
    float amount[16] = {0.0};
};

struct stPumpStatus
{
    int numberPumpsRunning = 0;
    float remainingPumpTime = 0.0;
};