#pragma once
#include "Enum.h"
#include "Arduino.h"
#include "Structs.h"
class StateController
{
private:
public:
    enMachineState machineState = enMachineState::boot;
    enOperationMode operationMode;
    enWiFiState wifiState;

    String wifiSSID = "";
    String wifiPassword = "";

    String ipAddress = "";
    String macAddress = "";

    bool newDrinkPossible = true;

    bool pumpsRunning = false;
    bool drinkFinished = false;

    bool WiFiConncted = false;

    StateController(/* args */);
    ~StateController();

    void init(void);
    void run(void);
};
