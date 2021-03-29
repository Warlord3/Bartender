#include "Pumps.h"

stPumpInfo pumps[NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER];
uint8_t addresses[NUM_CONTROLLERS] = {BOARD_ADR_BOT, BOARD_ADR_TOP};
uint16_t pumpDataRegister[NUM_CONTROLLERS] = {0};
unsigned long lastUpdatedMillis = 0;
float remainingPumpTime = 0.0;
bool interuptStarted = false;
byte currentBiggestIngredient = 0;
void initPumps()
{

    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS; i++)
    {
        pumps[i].ID = i;
    }
    if (operationMode != enOperationMode::configMode)
    {
        DEBUG_PRINTLN("Start I2C");
        Wire.begin();
    }

    if (!loadPumpConfig())
    {
        sendData("Configurate Pumps");
    }
}
void runPumps()
{
    //updatePumps();
    if (wifiState == enWiFiState::monitorWiFi)
    {
        startInterupt();
    }
}

uint8_t getBoardID(uint8_t pumpID)
{
    return pumpID >> 3;
}

int getPumpID(uint beverageID)
{
    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS; i++)
    {
        if (pumps[i].beverageID == (int)beverageID)
        {
            return i;
        }
    }
    return -1;
}
void startInterupt(void)
{
    if (!interuptStarted && operationMode != enOperationMode::configMode)
    {
        interuptStarted = true;
        DEBUG_PRINTLN("Start Interrupt Timer");
        timer1_disable();
        timer1_attachInterrupt(updatePumps); // Add ISR Function
        timer1_isr_init();

        timer1_enable(TIM_DIV256, TIM_EDGE, TIM_LOOP);
        timer1_write(31250); // 2500000 / 5 ticks per us from TIM_DIV16 == 500,000 us interval
    }
}

//Cofiguration of Pumps
bool isConfigurated(void)
{
    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS; i++)
    {
        if (pumps[i].beverageID < 0)
        {
            return false;
        }
    }
    return true;
}

void setConfiguration(DynamicJsonDocument &doc)
{
    //https://github.com/Warlord3/Bartender/wiki/Data-structures#pump-configuration
    JsonArray array = doc["config"].as<JsonArray>();
    for (JsonObject object : array)
    {
        uint pumpID = object["ID"].as<uint>();
        setBeverageID(object["beverageID"].as<int>(), pumpID);
        setMlPerMinute(object["mlPerMinute"].as<int>(), pumpID);
    }

    savePumpConfig();
}

void setMlPerMinute(int mlPerMinute, uint8_t pumpID)
{
    DEBUG_PRINTF("Set ml/min: %i for Pump: %i\n", mlPerMinute, pumpID);
    pumps[pumpID].mlPerMinute = mlPerMinute;
}
void setBeverageID(int beverageID, uint8_t pumpID)
{
    DEBUG_PRINTF("Set BeverageID: %i for Pump: %i\n", beverageID, pumpID);
    pumps[pumpID].beverageID = beverageID;
}
void setRemainingMl(float remainingMl, uint8_t pumpID)
{
    DEBUG_PRINTF("Set Remaining ml: %f for Pump: %i\n", remainingMl, pumpID);
    pumps[pumpID].remainingMl = remainingMl;
}

//Status
bool pumpsAreRunning(void)
{
    for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
    {
        if (pumpIsRunning(i))
        {
            return true;
        }
    }
    return false;
}
bool pumpIsRunning(uint8_t pumpID)
{
    return pumps[pumpID].direction != enPumpDirection::stop;
}
void status(void);
int progress()
{
    return (currentDrink.amount[currentBiggestIngredient]-pumps[currentBiggestIngredient].remainingMl )/ currentDrink.amount[currentBiggestIngredient] * 100;
}

uint8_t getDirection(enPumpDirection direction)
{
    switch (direction)
    {
    case enPumpDirection::stop:
        return 0;
        break;
    case enPumpDirection::forward:
        return 1;
        break;
    case enPumpDirection::backward:
        return 1 >> 1;
        break;

    default:
        return 0;
        break;
    }
}

void startCleaning(void)
{
}
void stopCleaning(void)
{
}

void startPump(enPumpDirection direction, uint8_t pumpID)
{
    if (direction == enPumpDirection::stop)
    {
        stopPump(pumpID);
        return;
    }
    numberPumpsRunning += 1;
    if (numberPumpsRunning > NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS)
    {
        numberPumpsRunning = NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS;
    }
    DEBUG_PRINTF("Start Pump %i \n", pumpID);

    if (pumps[pumpID].direction != direction)
    {
        pumps[pumpID].direction = direction;
    }
}
void stopPump(uint8_t pumpID)
{
    numberPumpsRunning -= 1;
    if (numberPumpsRunning < 0)
    {
        numberPumpsRunning = 0;
    }
    DEBUG_PRINTF("Stop Pump %i \n", pumpID);
    pumps[pumpID].direction = enPumpDirection::stop;
}

void startAllPumps(enPumpDirection direction)
{
    numberPumpsRunning = NUM_PUMPS_PER_CONTROLLER;
    DEBUG_PRINTLN("Start All Pumps");

    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER; i++)
    {
        pumps[i].direction = direction;
    }
}
void stopAllPumps(bool force = false)
{
    numberPumpsRunning = 0;
    DEBUG_PRINTLN("Stop All Pumps");
    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER; i++)
    {
        pumps[i].direction = enPumpDirection::stop;
    }
    if (force)
    {
        updateRegister();
    }
}
void forward(uint8_t pumpID)
{
    startPump(enPumpDirection::forward, pumpID);
}
void backward(uint8_t pumpID)
{
    startPump(enPumpDirection::backward, pumpID);
}

///Start Pumps With Current set Drink
void startPumpsWithCurrentDrink(void)
{
    for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
    {
        if (pumps[i].remainingMl > 0)
        {
            startPump(enPumpDirection::forward, i);
        }
    }
}

//Update
void ICACHE_RAM_ATTR updatePumps(void)
{
    if (numberPumpsRunning == 0)
    {
        return;
    }
    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS; i++)
    {

        if (pumps[i].direction == enPumpDirection::stop)
        {
            continue;
        }
        if (pumps[i].remainingMl <= 0 || pumps[i].mlPerMinute <= 0)
        {
            pumps[i].remainingMl = 0;
            stopPump(i);
        }
        else
        {
            pumps[i].remainingMl -= pumps[i].mlPerMinute * 100.0f / (60.0f * 1000.0f);
        }
    }
    sendData(getPumpStatus());
    updateRegister();
}
void updateRegister(void)
{
    for (int i = 0; i < NUM_CONTROLLERS; i++)
    {
        pumpDataRegister[i] = 0x00;
        for (int j = 0; j < NUM_PUMPS_PER_CONTROLLER; j++)
        {
            pumpDataRegister[i] |= getDirection(pumps[j + i * NUM_PUMPS_PER_CONTROLLER].direction) >> j * 2;
        }
    }

    for (int i = 0; i < NUM_CONTROLLERS; i++)
    {

        Wire.beginTransmission(addresses[i]);
        Wire.write((uint8_t)pumpDataRegister[i]);
        Wire.write((uint8_t)pumpDataRegister[i] >> 8);
        Wire.endTransmission();
    }
}

//Commands
void start(DynamicJsonDocument &doc)
{
    for (JsonVariant value : doc["IDs"].as<JsonArray>())
    {
        forward(value.as<int>());
    }
}
void stop(DynamicJsonDocument &doc)
{
    for (JsonVariant value : doc["IDs"].as<JsonArray>())
    {
        stopPump(value.as<int>());
    }
}
int8_t setDrink(DynamicJsonDocument &doc)
{
    currentBiggestIngredient = 0;

    if (newDrinkPossible)
    {
        newDrinkPossible = false;
        DEBUG_PRINTLN("Set new Drink");
        stDrink drink = stDrink();
        drink.ID = doc["ID"].as<uint>();
        JsonArray array = doc["ingredients"].as<JsonArray>();

        for (JsonVariant value : array)
        {
            JsonObject object = value.as<JsonObject>();
            int index = getPumpID(object["beverageID"].as<int>());
            drink.amount[index] = object["amount"].as<int>();
            if (drink.amount[index] > drink.amount[currentBiggestIngredient])
            {
                currentBiggestIngredient = index;
            }
        }
        currentDrink = drink;
        for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
        {
            setRemainingMl(drink.amount[i], i);
        }
        startPumpsWithCurrentDrink();
        return true;
    }
    DEBUG_PRINTLN("New Drink was declined");
    return false;
}
String getConfiguration(void)
{
    DEBUG_PRINTLN("Get Pump Configuration");
    DynamicJsonDocument doc(1500);
    doc["commnad"] = "pump_config";
    JsonArray array = doc["config"].to<JsonArray>();
    for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
    {
        JsonObject object = array.createNestedObject();
        object["ID"] = pumps[i].ID;
        object["beverageID"] = pumps[i].beverageID;
        object["mlPerMinute"] = pumps[i].mlPerMinute;
    }
    String result;
    serializeJson(doc, result);
    return result;
}

String getPumpStatus()
{
    DynamicJsonDocument doc(2000);
    doc["command"] = "status";
    doc["numberPumpsRunning"] = numberPumpsRunning;
    doc["currentDrinkID"] = currentDrink.ID;
    doc["progress"] = progress();
    JsonArray array = doc.createNestedArray("pumps");
    for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
    {
        JsonObject object = array.createNestedObject();
        object["ID"] = pumps[i].ID;
        object["beverageID"] = pumps[i].beverageID;
        int amount = currentDrink.amount[i] - pumps[i].remainingMl;
        object["amount"] = amount;
        if (currentDrink.amount[i] > 0) 
        {
            object["percent"] = (int)(((float)amount / currentDrink.amount[i]) * 100);
        }
        else
        {
            object["percent"] = 0;
        }
    }
    String result;
    serializeJson(doc, result);
    return result;
}
