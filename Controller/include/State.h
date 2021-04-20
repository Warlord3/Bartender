#pragma once
#include "Enum.h"
#include "Arduino.h"
#include "Structs.h"
#include "Network.h"

extern enMachineState machineState;
extern enOperationMode operationMode;
extern enWiFiState wifiState;

extern String wifiSSID;
extern String wifiPassword;

extern String ipAddress;
extern String macAddress;

extern bool newDrinkPossible;
extern stDrink currentDrink;

extern uint numberPumpsRunning;
extern bool drinkFinished;
extern bool drinkRunning;

extern bool WiFiConncted;

void initState(void);
void checkDrinkFinished(void);

void reset(void);
