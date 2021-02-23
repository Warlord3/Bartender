
#include "Arduino.h"
#include "PumpController.h"
#include "Enum.h"
#include "Network.h"
#include "StorageController.h"
#include "StateController.h"
#include "CommunicationController.h"
#include "Debug.h"

Network networkController;
StateController stateController;
StorageController storageController;
PumpController pumpController;
CommunicationController communicationController;

void setup()
{
  Serial.begin(112500);
  Serial.println("tst");
  DEBUG_PRINTLN("Bartender gestartet");
  pumpController.setReferences(&communicationController, &stateController);
  communicationController.setReferences(&stateController, &pumpController);
  storageController.setReferences(&stateController);
  networkController.setReferences(&stateController, &storageController);
}

void loop()
{
  switch (stateController.machineState)
  {
  case enMachineState::boot:
    stateController.init();
    stateController.machineState = enMachineState::init;
    break;

  case enMachineState::init:
    storageController.init();
    networkController.init();
    communicationController.init();
    pumpController.init();
    stateController.machineState = enMachineState::idle;
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
  if (stateController.machineState > enMachineState::init)
  {
    communicationController.run();
    pumpController.run();
    networkController.run();
    stateController.run();
  }
}