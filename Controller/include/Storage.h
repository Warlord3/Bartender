
#pragma once
#include "Debug.h"
#include "Structs.h"
#include <LittleFS.h>
#include <ArduinoJson.h>
#include "State.h"
#include "Pumps.h"
#define DRINKS_JSON_FILENAME "Drink.json"
#define BEVERAGE_JSON_FILENAME "Beverage.json"
#define CONFIG_JSON_FILENAME "Config.json"
#define PUMPCONFIG_JSON_FILENAME "PumpConfig.json"

extern File fsUploadFile;

bool configExits(void);
bool backupExits(void);
void listFiles(const char *Dirname);

void initStorage();

void loadConfig(void);
bool saveConfig();
bool loadPumpConfig();
bool savePumpConfig();

bool saveFile(String filename, String data);
String loadFile(String filename);
