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
bool pumpsRunning = false;
bool drinkFinished = false;
bool WiFiConncted = false;

void initState(void)
{
    pumpsRunning = false;
    drinkFinished = false;
    WiFiConncted = false;
}
void runState(void)
{
}