#include "../include/PumpController.h"

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

bool PumpController::setDrink(char *newDrink)
{
    if (_state->newDrinkPossible)
    {
        DEBUG_PRINTLN("Set new Drink");
        stDrink drink = stDrink();
        char *ptr;
        char *rest;
        drink.ID = strtol(strtok_r(newDrink, ";", &rest), NULL, 10);
        ptr = strtok_r(newDrink, ";", &rest);
        while (ptr != NULL)
        {
            long beverageID = strtol(strtok(ptr, ":"), NULL, 10);
            long amount = strtol(strtok(NULL, ":"), NULL, 10);
            int index = getPumpID(beverageID);
            drink.amount[index] = amount;
            ptr = strtok_r(NULL, ";", &rest);
        }
        this->currentDrink = drink;
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

void PumpController::stop(uint8_t pumpID)
{
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
