#include "ControllerBoard.h"
ControllerBoard::ControllerBoard(uint8_t address)
{
    _address = address;
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i] = stPumpInfo();
        _pumps[i].ID = i;
        _pumps[i].beverageID = -1;
        _pumps[i].remainingMl = 0.0;
        _pumps[i].mlPerMinute = 0;
        _pumps[i].state = enPumpState::stop;
    }
}

ControllerBoard::~ControllerBoard()
{
}

bool ControllerBoard::isConfigurated(void)
{
    for (int i = 0; i < PUMP_NUM; i++)
    {
        if (this->_pumps[i].beverageID < 0)
        {
            return false;
        }
    }
    return true;
}

stPumpInfo ControllerBoard::pumpInfo(uint8_t pumpID)
{
    return _pumps[pumpID & 0x07];
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
    if (pumpStatus.numberPumpsRunning == 0)
    {
        return;
    }
    for (int i = 0; i < PUMP_NUM; i++)
    {
        if (_pumps[i].remainingMl <= 0 || _pumps[i].mlPerMinute <= 0)
        {
            stopPump(i);
            pumpStatus.numberPumpsRunning -= 1;
            continue;
        }
        _pumps[i].remainingMl -= _pumps[i].mlPerMinute * 100 / (60 * 1000);
        if (_pumps[i].remainingMl <= 0)
        {
            _pumps[i].remainingMl = 0;
            pumpStatus.numberPumpsRunning -= 1;

            stopPump(i);
        }
    }
}

int ControllerBoard::getPumpID(uint beverageID)
{
    for (int i = 0; i < PUMP_NUM; i++)
    {
        if (_pumps[i].beverageID == beverageID)
        {
            return i;
        }
    }
    return -1;
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
    DEBUG_PRINT("Send Data Register: ");
    for (int b = 15; b >= 0; b--)
    {
        DEBUG_PRINT(bitRead(_dataRegister, b));
    }
    DEBUG_PRINTLN("");
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
    pumpStatus.numberPumpsRunning += 1;
    DEBUG_PRINTF("Start Pump %i \n", pumpID);

    stPumpInfo *info = &_pumps[pumpID & 0x0F];
    if (info->state != direction)
    {
        info->state = direction;
    }
}

void ControllerBoard::stopPump(uint8_t pumpID)
{
    pumpStatus.numberPumpsRunning -= 1;
    DEBUG_PRINTF("Stop Pump %i \n", pumpID);
    _pumps[pumpID & 0x0F].state = enPumpState::stop;
}

void ControllerBoard::startAllPumps(enPumpState direction)
{
    pumpStatus.numberPumpsRunning = PUMP_NUM;
    DEBUG_PRINTLN("Start All Pumps");

    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i].state = direction;
    }
}

void ControllerBoard::stopAllPumps(bool force = false)
{
    pumpStatus.numberPumpsRunning = 0;
    DEBUG_PRINTLN("Stop All Pumps");
    for (int i = 0; i < PUMP_NUM; i++)
    {
        _pumps[i].state = enPumpState::stop;
    }
    if (force)
    {
        updateRegister();
    }
}

void ControllerBoard::setMlPerMinute(int mlPerMinute, uint8_t pumpID)
{
    DEBUG_PRINTF("Set ml/min: %i for Pump: %i\n", mlPerMinute, pumpID);
    _pumps[pumpID & 0x07].mlPerMinute = mlPerMinute;
}
void ControllerBoard::setBeverageID(int beverageID, uint8_t pumpID)
{
    DEBUG_PRINTF("Set BeverageID: %i for Pump: %i\n", beverageID, pumpID);
    _pumps[pumpID & 0x07].beverageID = beverageID;
}
void ControllerBoard::setRemainingMl(float remainingMl, uint8_t pumpID)
{
    DEBUG_PRINTF("Set Remaining ml: %f for Pump: %i\n", remainingMl, pumpID);

    _pumps[pumpID & 0x07].remainingMl = remainingMl;
}