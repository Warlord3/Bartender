#include "../include/PumpController.h"
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
    Wire.begin();
}
void PumpController::run() {}
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
