#include "StorageController.h"

bool StorageController::configExits(void)
{
    return false;
}

bool StorageController::backupExits(void)
{
    return false;
}

StorageController::StorageController(StateController *state)
{
    this->state = state;
}

StorageController::~StorageController()
{
}

void StorageController::init()
{
    LittleFS.begin();
    listFiles("/");
    loadConfig();
}

void StorageController::listFiles(const char *Dirname)
{
    DEBUG_PRINTLN(F("Found files in root dir:"));

    Dir root = LittleFS.openDir("/");

    while (root.next())
    {
        File file = root.openFile("r");
        DEBUG_PRINT(F("  FILE: "));
        DEBUG_PRINT(root.fileName());
        DEBUG_PRINT(F("  SIZE: "));
        DEBUG_PRINTLN(file.size());
        file.close();
    }
}

void StorageController::loadConfig(void)
{

    bool configLoaded = false;
    if (LittleFS.exists(CONFIG_JSON_FILENAME))
    {
        File f = LittleFS.open(CONFIG_JSON_FILENAME, "r");
        if (f)
        {
            StaticJsonDocument<512> doc;

            // Deserialize the JSON document
            DeserializationError error = deserializeJson(doc, f);
            if (!error)
            {

                // Copy values from the JsonDocument to the Config
                state->operationMode = (enOperationMode)doc["OperationMode"].as<int>();

                state->wifiSSID = (const char *)doc["WiFiSSID"];
                state->wifiPassword = (const char *)doc["WiFiPassword"];

                configLoaded = true;
                DEBUG_PRINTLN(F("Read Configuration from Config.json"));
            }
        }
        f.close();
    }
    if (!configLoaded)
    {
        DEBUG_PRINTLN(F("Failed to read file, using default configuration"));
        state->operationMode = enOperationMode::configMode;
        state->wifiState = enWiFiState::startAccessPoint;
    }
}

bool StorageController::saveConfig(stConfig config)
{
    File file = LittleFS.open(CONFIG_JSON_FILENAME, "w");
    if (!file)
    {
        Serial.println(F("Failed to create file"));
        return false;
    }
    StaticJsonDocument<512> doc;
    doc["OperationMode"] = static_cast<int>(config.operationMode);
    doc["WiFiSSID"] = config.wifiSSID;
    doc["WiFiPassword"] = config.wifiPassword;
    if (serializeJson(doc, file) == 0)
    {
        DEBUG_PRINTLN(F("Failed to write to file"));
        file.close();
        return false;
    }
    file.close();
    DEBUG_PRINTLN(F("Saved Config on Flash"));

    return true;
}

bool StorageController::saveFile(String filename, String data)
{
    File f = LittleFS.open(CONFIG_JSON_FILENAME, "w");
    if (f)
    {
        return f.write(data.c_str());
    }
    else
    {
        DEBUG_PRINTF("Failed to open File %s", filename.c_str())
    }
    return false;
}
String StorageController::loadFile(String filename)
{
    File f = LittleFS.open(CONFIG_JSON_FILENAME, "r");
    if (f)
    {
        return f.readString();
    }
    else
    {
        DEBUG_PRINTF("Failed to open File %s", filename.c_str())
    }
    return "";
}