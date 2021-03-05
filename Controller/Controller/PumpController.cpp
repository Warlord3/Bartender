#include "PumpController.h"

PumpController *globalController;

PumpController::PumpController()
{
}
PumpController::~PumpController()
{
}
void PumpController::setReferences(CommunicationController *communication, StateController *state)
{
    this->_communication = communication;
    this->_state = state;
}

uint8_t PumpController::getBoardID(uint8_t pumpID)
{
    return pumpID >> 4;
}
int PumpController::getPumpID(uint beverageID)
{
    for (int i = 0; i < NUM_CONTROLLERS; i++)
    {
        int value = _boards[i].getPumpID(beverageID);
        if (value >= 0)
        {
            return value + i * 8;
        }
    }
    return -1;
}

void PumpController::init()
{
    globalController = this;
    Wire.begin();
    startInterupt();
}
void PumpController::run()
{
}

void PumpController::startInterupt(void)
{
    if (!_interuptStarted)
    {
        DEBUG_PRINTLN("Start Interrupt Timer");
        timer1_attachInterrupt(interruptCallback); // Add ISR Function
        timer1_enable(TIM_DIV256, TIM_EDGE, TIM_LOOP);
        timer1_write(62500); // 2500000 / 5 ticks per us from TIM_DIV16 == 500,000 us interval
    }
}
void ICACHE_RAM_ATTR interruptCallback()
{
    if (globalController)
    {
        globalController->updatePumps();
    }
}

bool PumpController::pumpsRunning(void)
{
    return _boards[0].pumpStatus.numberPumpsRunning + _boards[1].pumpStatus.numberPumpsRunning != 0;
}
void PumpController::updatePumps(void)
{
    for (int i = 0; i < NUM_CONTROLLERS; i++)
    {
        this->_boards[i].updatePumps();
    }
}

void PumpController::setConfiguration(char *newConfig)
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
        uint8_t boardID = getBoardID(pumpID);
        _boards[boardID].setBeverageID(beverageID, pumpID);
        _boards[boardID].setMlPerMinute(amount, pumpID);
        ptr = strtok_r(NULL, ";", &rest);
    }
}

String PumpController::getConfiguration(void)
{
    String result = "pump_config";
    for (int i = 0; i < NUM_CONTROLLERS; i++)
    {
        for (int j = 0; j < PUMP_NUM; j++)
        {
            stPumpInfo info = _boards[i].pumpInfo(j);
            result += info.ID;
            result += ":";
            result += info.beverageID;
            result += ":";
            result += info.mlPerMinute;
            result += ";";
        }
    }
    return result;
}

bool PumpController::setDrink(char *newDrink)
{
    if (_state->newDrinkPossible)
    {
        _state->newDrinkPossible = false;
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
        _state->currentDrink = drink;
        for (int i = 0; i < NUM_CONTROLLERS; i++)
        {
            for (int j = 0; j < PUMPS_PER_CONTROLLER; j++)
            {
                DEBUG_PRINTLN(drink.amount[j + PUMPS_PER_CONTROLLER * i]);
                _boards[i].setRemainingMl(drink.amount[j + PUMPS_PER_CONTROLLER * i], j);
            }
        }
        return true;
    }
    DEBUG_PRINTLN("New Drink was declined");
    return false;
}

void PumpController::startCleaning()
{
}

void PumpController::stopCleaning()
{
}

void PumpController::start(char *data)
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
void PumpController::startAll(void)
{
    _boards[0].startAllPumps(enPumpState::forward);
    _boards[1].startAllPumps(enPumpState::forward);
}
void PumpController::stop(char *data)
{
    char *ptr;
    char *rest;
    ptr = strtok_r(data, ":", &rest);
    while (ptr != NULL)
    {
        stop(strtol(ptr, NULL, 10));
        ptr = strtok_r(NULL, ":", &rest);
    }
}

void PumpController::stop(uint8_t pumpID)
{
    DEBUG_PRINTF("Stop Drink %i \n", pumpID);
    _boards[getBoardID(pumpID)].stopPump(pumpID);
}

void PumpController::stopAll()
{
    _boards[0].stopAllPumps(true);
    _boards[1].stopAllPumps(true);
}

void PumpController::forward(uint8_t pumpID)
{
    _boards[getBoardID(pumpID)].startPump(enPumpState::forward, pumpID);
}

void PumpController::backward(uint8_t pumpID)
{
    _boards[getBoardID(pumpID)].startPump(enPumpState::backward, pumpID);
}

void PumpController::status(uint8_t pumpID)
{
    //  _boards[getBoardID(pumpID)].
}
