#include "../include/LocalStorage.h"

bool StorageData::configExits(void)
{
    return false;
}

bool StorageData::backupExits(void)
{
    return false;
}

StorageData::StorageData(/* args */)
{
}

StorageData::~StorageData()
{
}

void StorageData::init()
{
    LittleFS.begin();
    listFiles("/");
    if (!loadConfig())
    {
        machineData = stMachineData();
        machineData.setPumpcount(0);
    }
}

void StorageData::listFiles(const char *Dirname)
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

bool StorageData::loadConfig(void)
{
    if (!LittleFS.exists(CONFIG_PATH))
    {
        DEBUG_PRINTLN(F("Create Config Folder"));
        LittleFS.mkdir(CONFIG_PATH);
    }
    bool configLoaded = false;
    if (LittleFS.exists(String(CONFIG_PATH) + CONFIG_JSON_FILENAME))
    {
        File f = LittleFS.open(String(CONFIG_PATH) + CONFIG_JSON_FILENAME, "r");
        if (f)
        {
            StaticJsonDocument<512> doc;

            // Deserialize the JSON document
            DeserializationError error = deserializeJson(doc, f);
            if (!error)
            {
                // Copy values from the JsonDocument to the Config
                machineData.OperationMode = (enOperationMode)doc["OperationMode"].as<int>();
                machineData.Pumpcount = doc["Pumpcount"];
                machineData.setPumpcount(machineData.Pumpcount);

                networkData.WiFiConnected = false;
                networkData.MqttConnected = false;
                networkData.AP_Name = (const char *)doc["AP_Name"];
                networkData.AP_Password = (const char *)doc["AP_Password"];

                networkData.STA_Name = (const char *)doc["STA_Name"];
                networkData.STA_Password = (const char *)doc["STA_Password"];

                networkData.MqttBroker = (const char *)doc["MqttBroker"];
                networkData.MqttPort = doc["MqttPort"];
                networkData.MqttUser = (const char *)doc["MqttUser"];
                networkData.MqttPassword = (const char *)doc["MqttPassword"];

                drinkData.setPumpcount(machineData.Pumpcount);
                drinkData.DrinkName = "";
                drinkData.DrinkID = 0;
                drinkData.DrinkAmount = 0.0;
                configLoaded = true;
                DEBUG_PRINTLN(F("Read Configuration from Config.json"));
            }
        }
        f.close();
    }
    if (!configLoaded)
    {
        DEBUG_PRINTLN(F("Failed to read file, using default configuration"));
        machineData.OperationMode = enOperationMode::configMode;
        machineData.Pumpcount = 0;
        machineData.setPumpcount(machineData.Pumpcount);

        networkData.WiFiConnected = false;
        networkData.MqttConnected = false;
        networkData.AP_Name = "";
        networkData.AP_Password = "";

        networkData.STA_Name = "";
        networkData.STA_Password = "";

        networkData.MqttBroker = "";
        networkData.MqttPort = 1883;
        networkData.MqttUser = "";
        networkData.MqttPassword = "";
        saveConfig();
        return false;
    }
    return true;
}

bool StorageData::saveConfig(void)
{
    File file = LittleFS.open(String(CONFIG_PATH) + CONFIG_JSON_FILENAME, "w");
    if (!file)
    {
        Serial.println(F("Failed to create file"));
        return false;
    }
    StaticJsonDocument<512> doc;
    doc["OperationMode"] = static_cast<int>(machineData.OperationMode);
    doc["Pumpcount"] = machineData.Pumpcount;

    doc["AP_Name"] = networkData.AP_Name;
    doc["AP_Password"] = networkData.AP_Password;

    doc["STA_Name"] = networkData.STA_Name;
    doc["STA_Password"] = networkData.STA_Password;

    doc["MqttBroker"] = networkData.MqttBroker;
    doc["MqttPort"] = networkData.MqttPort;
    doc["MqttUser"] = networkData.MqttUser;
    doc["MqttPassword"] = networkData.MqttPassword;
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

bool StorageData::loadBackup(void)
{
    if (!LittleFS.exists(BACKUP_PATH))
    {
        LittleFS.mkdir(BACKUP_PATH);
    }
    if (LittleFS.exists(BACKUP_PATH))
    {
        File f = LittleFS.open(String(BACKUP_PATH) + CONFIG_JSON_FILENAME, "r");
        if (f)
        {

            return true;
        }
    }

    return false;
}

bool StorageData::saveBackup(void)
{
    return false;
}
