#include "../include/PumpController.h"

PumpController *globalController;

PumpController::PumpController(uint8_t numberAddresses, int *_addresses)
{
    _boards = new ControllerBoard[numberAddresses];
    for (int i = 0; i < numberAddresses; i++)
    {
        this->_boards[i] = ControllerBoard(_addresses[i]);
    }
    this->_numberAddresses = numberAddresses;
}

uint8_t PumpController::getBoardID(uint8_t pumpID)
{
    return pumpID >> 4;
}

void PumpController::init()
{
    globalController = this;
    Wire.begin();
    startInterupt();
}
void PumpController::run()
{
    DEBUG_PRINTLN("Called from Interrupt");
}
byte PumpController::countBoards(void)
{
    return this->_numberAddresses;
}

void PumpController::startInterupt(void)
{
    if (!interuptStarted)
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
    //timer1_write(2500000); // 2500000 / 5 ticks per us from TIM_DIV16 == 500,000 us interval
}
void PumpController::updatePumps(void)
{
    for (int i = 0; i < globalController->_numberAddresses; i++)
    {
        this->_boards[i].updatePumps();
    }
}

void PumpController::startCleaning()
{
}

void PumpController::stopCleaning()
{
}

void PumpController::stop(uint8_t pumpID)
{
}

void PumpController::stopAll()
{
}

void PumpController::forward(uint8_t pumpID)
{
}

void PumpController::backward(uint8_t pumpID)
{
}

void PumpController::status(uint8_t pumpID)
{
}
