
#include "Arduino.h"
#include "include/PumpController.h"
#include "include/Enum.h"
#include "include/Network.h"
#include "include/LocalStorage.h"
#include "include/Debug.h"
//Uncomment to enable Standalone Mode
#define STANDALONE

#define CTRL_BOARDS_NUM 2

int addresses[CTRL_BOARDS_NUM] = {0x20, 0x21};
String MQTT_BROKER_IP = "192.168.178.47";
int MQTT_BROKER_PORT = 1883;

StorageData storageData;

Network network(&storageData);
PumpController controller(CTRL_BOARDS_NUM, addresses);

enMachineState machineState = enMachineState::idleState;
void setup()
{
  Serial.begin(112500);
  Serial.println("tst");
  DEBUG_PRINTLN("Bartender gestartet");
}

void loop()
{
  switch (machineState)
  {
  case enMachineState::idleState:
    machineState = enMachineState::initState;
    break;

  case enMachineState::initState:
    storageData.init();
    controller.init();
    network.init();
    machineState = enMachineState::runningState;
    break;

  case enMachineState::runningState:
    controller.run();
    network.run();

    break;

  case enMachineState::cleaningState:

    break;

  case enMachineState::testingState:

    break;

  default:
    break;
  }
}
