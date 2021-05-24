#include "State.h"

enMachineState machineState = enMachineState::boot;
enOperationMode operationMode;
enWiFiState wifiState;
String wifiSSID = "";
String wifiPassword = "";
String ipAddress = "";
String macAddress = "";
bool newDrinkPossible = true;
stDrink currentDrink;

bool drinkFinished = false;
bool drinkRunning = false;
bool testingMode = false;
bool WiFiConncted = false;

void initState(void)
{
    drinkFinished = false;
    WiFiConncted = false;
}
void checkDrinkFinished(void)
{
    if (!newDrinkPossible)
    {
        newDrinkPossible = true;
        drinkFinished = true;
        sendDrinkFinished();
    }
}
void reset(void)
{
    operationMode = enOperationMode::configMode;
    resetWiFi();
    ESP.restart();
}
