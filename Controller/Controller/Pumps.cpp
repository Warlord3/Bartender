#include "Pumps.h"

stPumpInfo pumps[NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER];
uint8_t addresses[NUM_CONTROLLERS] = {BOARD_ADR_BOT, BOARD_ADR_TOP};
uint16_t pumpDataRegister[NUM_CONTROLLERS] = {0};
unsigned long lastUpdatedMillis = 0;
int numberPumpsRunning = 0;
float remainingPumpTime = 0.0;
bool interuptStarted = false;

void initPumps()
{
    if (operationMode != enOperationMode::configMode)
    {
        DEBUG_PRINTLN("Start I2C");
        Wire.begin();
        startInterupt();
    }

    if (!loadPumpConfig())
    {
        sendData("Configurate Pumps");
    }
}
void runPumps()
{
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
        DEBUG_PRINTLN("Start Interrupt Timer");
        timer1_isr_init();
        timer1_attachInterrupt(updatePumps); // Add ISR Function
        timer1_enable(TIM_DIV256, TIM_EDGE, TIM_LOOP);
        timer1_write(62500); // 2500000 / 5 ticks per us from TIM_DIV16 == 500,000 us interval
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

void setConfiguration(char *newConfig)
{
    //https://github.com/Warlord3/Bartender/wiki/Data-structures#pump-configuration
    char *ptr;
    char *rest;

    ptr = strtok_r(newConfig, ";", &rest);
    while (ptr != NULL)
    {
        long pumpID = strtol(strtok(ptr, ":"), NULL, 10);
        long beverageID = strtol(strtok(NULL, ":"), NULL, 10);
        long amount = strtol(strtok(NULL, ":"), NULL, 10);
        setBeverageID(beverageID, pumpID);
        setMlPerMinute(amount, pumpID);
        ptr = strtok_r(NULL, ";", &rest);
    }

    savePumpConfig();
}
String getConfiguration(void)
{
    DEBUG_PRINTLN("Get Pump Configuration");
    String result = "pump_config";
    for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
    {
        result += pumps[i].ID;
        result += ":";
        result += pumps[i].beverageID;
        result += ":";
        result += pumps[i].mlPerMinute;
        result += ";";
    }
    return result;
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
int8_t setDrink(char *newDrink)
{
    if (newDrinkPossible)
    {
        newDrinkPossible = false;
        DEBUG_PRINTLN("Set new Drink");
        stDrink drink = stDrink();
        char *ptr;
        char *rest;
        drink.ID = strtol(strtok_r(newDrink, ";", &rest), NULL, 10);
        DEBUG_PRINTF("Drink ID:%i\n", drink.ID);
        ptr = strtok_r(NULL, ";", &rest);
        while (ptr != NULL)
        {
            long beverageID = strtol(strtok(ptr, ":"), NULL, 10);
            long amount = strtol(strtok(NULL, ":"), NULL, 10);
            int index = getPumpID(beverageID);
            DEBUG_PRINTF("Beverage ID: %i with amount of %i\n", beverageID, amount);

            DEBUG_PRINTLN(index);
            if (index >= 0)
            {
                drink.amount[index] = (float)amount;
            }
            ptr = strtok_r(NULL, ";", &rest);
        }
        currentDrink = drink;
        for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
        {
            setRemainingMl(drink.amount[i], i);
        }
        return true;
    }
    DEBUG_PRINTLN("New Drink was declined");
    return false;
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
    DEBUG_PRINTF("Start Pump %i \n", pumpID);

    if (pumps[pumpID].direction != direction)
    {
        pumps[pumpID].direction = direction;
    }
}
void stopPump(uint8_t pumpID)
{
    numberPumpsRunning -= 1;
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

//Update
void ICACHE_RAM_ATTR updatePumps(void)
{
    if (numberPumpsRunning == 0)
    {
        return;
    }
    for (int i = 0; i < NUM_PUMPS_PER_CONTROLLER * NUM_CONTROLLERS; i++)
    {
        if (pumps[i].remainingMl <= 0 || pumps[i].mlPerMinute <= 0)
        {
            stopPump(i);
            numberPumpsRunning -= 1;
            if (numberPumpsRunning < 0)
            {
                numberPumpsRunning = 0;
            }
            continue;
        }
        pumps[i].remainingMl -= pumps[i].mlPerMinute * 100 / (60 * 1000);
        if (pumps[i].remainingMl <= 0)
        {
            pumps[i].remainingMl = 0;
            numberPumpsRunning -= 1;
            if (numberPumpsRunning < 0)
            {
                numberPumpsRunning = 0;
            }

            stopPump(i);
        }
    }
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
void start(char *data)
{
    char *ptr;
    char *rest;
    ptr = strtok_r(data, ":", &rest);
    while (ptr != NULL)
    {
        forward(strtol(ptr, NULL, 10));
        ptr = strtok_r(NULL, ":", &rest);
    }
}
void stop(char *data)
{
    char *ptr;
    char *rest;
    ptr = strtok_r(data, ":", &rest);
    while (ptr != NULL)
    {
        stopPump(strtol(ptr, NULL, 10));
        ptr = strtok_r(NULL, ":", &rest);
    }
}