#pragma once

#include "Enum.h"
#include "ControllerBoard.h"
#include "Arduino.h"
#include "Debug.h"
#include "Network.h"
#include "CommunicationController.h"
#include "StateController.h"

#define PUMPS_PER_CONTROLLER 8
#define NUM_CONTROLLERS 2

#define BOARD_ADR_BOT 0x20
#define BOARD_ADR_TOP 0x21
class PumpController
{
private:
    bool _interuptStarted = false;
    ControllerBoard _boards[2] = {ControllerBoard(BOARD_ADR_BOT), ControllerBoard(BOARD_ADR_TOP)};

    CommunicationController *_communication;
    StateController *_state;
    uint8_t getBoardID(uint8_t pumpID);
    void startInterupt(void);

public:
    PumpController(CommunicationController *communication, StateController *_state);

    void init();
    void run();
    void startCleaning();
    void stopCleaning();

    void updatePumps(void);

    void stop(uint8_t pumpID);
    void stopAll();
    void forward(uint8_t pumpID);
    void backward(uint8_t pumpID);

    void status(uint8_t pumpID);
};
extern PumpController *globalController;
void ICACHE_RAM_ATTR interruptCallback();
