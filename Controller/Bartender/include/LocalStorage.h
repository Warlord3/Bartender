
#pragma once
#include "Debug.h"
#include "Structs.h"
#include <LittleFS.h>
#include <ArduinoJson.h>
#define BACKUP_PATH "Backup/"
#define CONFIG_PATH "Config/"
#define DRINKS_JSON_FILENAME "Drink.json"
#define BEVERAGE_JSON_FILENAME "Beverage.json"
#define CONFIG_JSON_FILENAME "Config.json"
class StorageData
{
private:
    /* data */
    bool configExits(void);

    bool backupExits(void);

    void listFiles(const char *Dirname);

public:
    stMachineData machineData;
    stDrinkData drinkData;
    stNetworkData networkData;
    StorageData(/* args */);
    ~StorageData();

    File fsUploadFile;

    void init();

    bool loadConfig(void);
    bool saveConfig(void);

    bool loadBackup(void);
    bool saveBackup(void);
};
