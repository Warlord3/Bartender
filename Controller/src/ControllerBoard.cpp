#include "../include/ControllerBoard.h"
ControllerBoard::ControllerBoard(uint8_t address)
{
    _address = address;
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i] = PumpInfo();
        _pumps[i].ID = i;
        _pumps[i].beverageID = -1;
        _pumps[i].remainingMl = 0.0;
        _pumps[i].mlPerMinute = 0;
        _pumps[i].state = enPumpState::stop;
    }
}

ControllerBoard::ControllerBoard()
{
}

ControllerBoard::~ControllerBoard()
{
}

uint8_t ControllerBoard::getDirection(enPumpState direction)
{
    switch (direction)
    {
    case enPumpState::stop:
        return 0;
        break;
    case enPumpState::forward:
        return 1;
        break;
    case enPumpState::backward:
        return 1 >> 1;
        break;

    default:
        return 0;
        break;
    }
}

void ControllerBoard::updatePumps(void)
{
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i].remainingMl -= _pumps[i & 0x0F].mlPerMinute * 100 / (60 * 1000);
        if (_pumps[i].remainingMl <= 0)
        {
            _pumps[i].remainingMl = 0;
            stopPump(i);
        }
    }
}

void ControllerBoard::update(bool force = false)
{
    unsigned long currentMillis = millis();
    if (currentMillis - lastUpdated <= 100)
    {
        DEBUG_PRINTLN("Calling Update too frequently");
        lastUpdated = currentMillis;
    }
    updateRegister();
}

void ControllerBoard::updateRegister()
{

    _dataRegister = 0x00;
    for (int i = 0; i < PUMP_NUM; i++)
    {
        uint8_t direction = getDirection(_pumps[i].state);
        _dataRegister |= direction >> i * 2;
    }
    _wire->beginTransmission(_address);
    _wire->write((uint8_t)_dataRegister);
    _wire->write((uint8_t)_dataRegister >> 8);
    _wire->endTransmission();
}

void ControllerBoard::startPump(enPumpState direction, uint8_t pumpID)
{
    if (direction == enPumpState::stop)
    {
        stopPump(pumpID);
        return;
    }
    PumpInfo *info = &_pumps[pumpID & 0x0F];
    if (info->state != direction)
    {
        info->state = direction;
    }
}

void ControllerBoard::stopPump(uint8_t pumpID)
{
    _pumps[pumpID & 0x0F].state = enPumpState::stop;
}

void ControllerBoard::startAllPumps(enPumpState direction)
{
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i].state = direction;
    }
}

void ControllerBoard::stopAllPumps(bool force = false)
{
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i].state = enPumpState::stop;
    }
    if (force)
    {
        updateRegister();
    }
}

void ControllerBoard::setMlPerMinute(float mlPerMinute, uint8_t pumpID)
{
    _pumps[pumpID & 0x0F].mlPerMinute = mlPerMinute;
}
void ControllerBoard::setBeverageID(int beverageID, uint8_t pumpID)
{
    _pumps[pumpID & 0x0F].beverageID = beverageID;
}
void ControllerBoard::setRemainingMl(float remainingMl, uint8_t pumpID)
{
    _pumps[pumpID & 0x0F].remainingMl = remainingMl;
}