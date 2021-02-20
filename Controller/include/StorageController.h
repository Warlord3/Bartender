
#pragma once
#include "Debug.h"
#include "Structs.h"
#include <LittleFS.h>
#include <ArduinoJson.h>
#include "StateController.h"
#define DRINKS_JSON_FILENAME "Drink.json"
#define BEVERAGE_JSON_FILENAME "Beverage.json"
#define CONFIG_JSON_FILENAME "Config.json"
class StorageController
//asdf
{
private:
    bool configExits(void);
    bool backupExits(void);
    void listFiles(const char *Dirname);

    StateController *state;

public:
    StorageController(StateController *state);
    ~StorageController();

    File fsUploadFile;

    void init();

    void loadConfig(void);
    bool saveConfig(stConfig config);

    bool saveFile(String filename, String data);
    String loadFile(String filename);
};
