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

uint numberPumpsRunning = 0;
bool drinkFinished = false;
bool WiFiConncted = false;

void initState(void)
{ 
    drinkFinished = false;
    WiFiConncted = false;
}
void runState(void)
{
    if (numberPumpsRunning == 0 && !newDrinkPossible)
    {
        newDrinkPossible = true;
        drinkFinished = true;
    }
}