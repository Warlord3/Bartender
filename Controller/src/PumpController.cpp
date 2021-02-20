#include "../include/PumpController.h"

PumpController *globalController;

PumpController::PumpController(CommunicationController *communication, StateController *state)
{
    this->_communication = communication;
    this->_state = state;
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
