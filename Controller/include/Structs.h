#pragma once
#include "Arduino.h"
#include "Enum.h"
struct stConfig
{
    String wifiSSID = "";
    String wifiPassword = "";
    enOperationMode operationMode = enOperationMode::normalMode;
};

struct PumpInfo
{
    uint8_t ID;
    float mlPerMinute;
    int beverageID;
    float remainingMl;
    enPumpState state;
};
