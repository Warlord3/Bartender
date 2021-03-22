#include "Arduino.h"
#include "include/Pumps.h"
#include "include/Enum.h"
#include "include/Network.h"
#include "include/Storage.h"
#include "include/State.h"
#include "include/Communication.h"
#include "include/Debug.h"

void setup()
{
  DEBUG_BEGIN(112500);
  DEBUG_PRINTLN("Bartender gestartet");
}

void loop()
{
  switch (machineState)
  {
  case enMachineState::boot:
    DEBUG_PRINTLN(ESP.getCpuFreqMHz());
    initState();
    machineState = enMachineState::init;
    break;

  case enMachineState::init:
    initStorage();
    initNetwork();
    initPumps();
    initCommunication();
    machineState = enMachineState::idle;
    break;

  case enMachineState::idle:

    break;
  case enMachineState::running:

    break;

  case enMachineState::cleaning:

    break;

  case enMachineState::testing:

    break;

  default:
    break;
  }
  if (machineState > enMachineState::init)
  {
    runPumps();
    runState();
    runNetwork();
    runCommunication();
  }
}
