#pragma once

#include <Wire.h>
#include "Enum.h"
#include <Arduino.h>
#include "Debug.h"

class ControllerBoard
{

    struct PumpInfo
    {
        uint8_t ID;
        float mlPerMinute;
        int beverageID;
        float remainingMl;
        enPumpState state;
    };

private:
    PumpInfo _pumps[8];
    uint8_t _address;
    TwoWire *_wire;
    uint16_t _dataRegister;
    unsigned long lastUpdated = 0;
    void updateRegister(void);
    uint8_t getDirection(enPumpState direction);

public:
    ControllerBoard();
    ControllerBoard(uint8_t address);
    ~ControllerBoard();

    void update(bool force);
    void setMlPerMinute(float mlPerMinute, uint8_t pumpID);
    void setBeverageID(int beverageID, uint8_t pumpID);
    void setRemainingMl(float remainingMl, uint8_t pumpID);

    void startPump(enPumpState direction, uint8_t pumpID);
    void stopPump(uint8_t pumpID);
    void startAllPumps(enPumpState direction);
    void stopAllPumps(bool force);
};
