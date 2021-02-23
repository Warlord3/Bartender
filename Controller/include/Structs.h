#pragma once
#include "Arduino.h"
#include "Enum.h"
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
    float mlPerMinute;
    int beverageID;
    float remainingMl;
    enPumpState state;
    stPumpInfo()
    {
        ID = 0;
        mlPerMinute = 0;
        beverageID = 0;
        remainingMl = 0;
        enPumpState state = enPumpState::stop;
    }
};

struct stDrink
{
    uint ID;
    float amount[16];
    stDrink()
    {
        ID = 0;
        amount[16] = {0};
    }
};

struct stPumpStatus
{
    int numberPumpsRunning = 0;
    float remainingPumpTime = 0.0;
};