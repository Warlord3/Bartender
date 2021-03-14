#pragma once
#include "Enum.h"
#include "Arduino.h"
#include "Debug.h"
#include "Network.h"
#include "Communication.h"
#include "State.h"
#include "Wire.h"

#define NUM_PUMPS_PER_CONTROLLER 8
#define NUM_CONTROLLERS 2

#define BOARD_ADR_BOT 0x20
#define BOARD_ADR_TOP 0x21

extern stPumpInfo pumps[NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER];
extern uint8_t addresses[NUM_CONTROLLERS];
extern uint16_t pumpDataRegister[NUM_CONTROLLERS];
extern unsigned long lastUpdatedMillis;
extern int numberPumpsRunning;
extern float remainingPumpTime;
extern bool interuptStarted;

extern uint8_t getBoardID(uint8_t pumpID);

int getPumpID(uint beverageID);
void startInterupt(void);

void initPumps();
void runPumps();

//Cofiguration of Pumps
bool isConfigurated(void);
void setConfiguration(char *newConfig);
String getConfiguration(void);
void setMlPerMinute(int mlPerMinute, uint8_t pumpID);
void setBeverageID(int beverageID, uint8_t pumpID);
void setRemainingMl(float remainingMl, uint8_t pumpID);

//Status
bool pumpsAreRunning(void);
bool pumpIsRunning(uint8_t pumpID);
void status(void);
uint8_t _getDirection(enPumpDirection direction);

void startCleaning(void);
void stopCleaning(void);

void startPump(enPumpDirection direction, uint8_t pumpID);
void stopPump(uint8_t pumpID);
void startAllPumps(enPumpDirection direction);
void stopAllPumps(bool force);
void forward(uint8_t pumpID);
void backward(uint8_t pumpID);
//Update
void ICACHE_RAM_ATTR updatePumps(void);
void updateRegister(void);

//Commands
void start(char *data);
void stop(char *data);
int8_t setDrink(char *newDrink);
