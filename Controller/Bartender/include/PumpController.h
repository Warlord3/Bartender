
#pragma once

#include "Enum.h"
#include "ControllerBoard.h"
#include "Arduino.h"
#include "Debug.h"

#define PUMPS_PER_CONTROLLER 8

class PumpController
{
private:
    ControllerBoard *_boards;

    uint8_t _numberAddresses;

    uint8_t getBoardID(uint8_t pumpID);

public:
    PumpController(uint8_t numberAddresses, int *_addresses);
    enMachineState machineState = enMachineState::idleState;

    void init();
    void run();
    void startCleaning();
    void stopCleaning();

    void stop(uint8_t pumpID);
    void stopAll();
    void forward(uint8_t pumpID);
    void backward(uint8_t pumpID);

    void status(uint8_t pumpID);
};
