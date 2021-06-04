#include "Storage.h"

File fsUploadFile;

bool configExits(void)
{
    return false;
}

bool backupExits(void)
{
    return false;
}

void initStorage()
{
    LittleFS.begin();
    listFiles("/");
    loadConfig();
}

void listFiles(const char *Dirname)
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

void loadConfig(void)
{
    operationMode = enOperationMode::configMode;
    wifiState = enWiFiState::startAccessPoint;
    if (!LittleFS.exists(CONFIG_JSON_FILENAME))
    {
        DEBUG_PRINTLN(F("No Config File"));
        return;
    }
    File f = LittleFS.open(CONFIG_JSON_FILENAME, "r");
    if (!f)
    {
        DEBUG_PRINTLN(F("Failed to read file, using default configuration"));
        f.close();
        return;
    }
    StaticJsonDocument<1024> doc;
    DeserializationError err = deserializeJson(doc, f);
    if (err)
    {
        DEBUG_PRINTLN(F("Couldn't deserialize Json"));
        DEBUG_PRINTLN(err.c_str());
        f.close();
        return;
    }
    // Copy values from the JsonDocument to the Config
    operationMode = (enOperationMode)doc["OperationMode"].as<int>();

    if (operationMode == enOperationMode::normalMode)
    {
        wifiState = enWiFiState::startWiFi;
    }
    else
    {
        DEBUG_PRINTLN("Start Accespoint");
        wifiState = enWiFiState::startAccessPoint;
    }

    wifiSSID = (const char *)doc["WiFiSSID"];
    wifiPassword = (const char *)doc["WiFiPassword"];
    DEBUG_PRINTLN("Loaded Config:");
    DEBUG_PRINTF("\t OperationMode: %i\n", (int)operationMode);
    DEBUG_PRINTF("\t WiFi SSID: %s\n", wifiSSID.c_str());
    DEBUG_PRINTF("\t WiFi Password: %s\n", wifiPassword.c_str());

    f.close();
}

bool saveConfig()
{
    File file = LittleFS.open(CONFIG_JSON_FILENAME, "w");
    if (!file)
    {
        Serial.println(F("Failed to create file"));
        return false;
    }
    StaticJsonDocument<512> doc;
    doc["OperationMode"] = static_cast<int>(operationMode);
    doc["WiFiSSID"] = wifiSSID;
    doc["WiFiPassword"] = wifiPassword;
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

bool loadPumpConfig()
{
    if (!LittleFS.exists(PUMPCONFIG_JSON_FILENAME))
    {
        DEBUG_PRINTLN(F("No Pumpconfiguration File"));
        return false;
    }
    File f = LittleFS.open(PUMPCONFIG_JSON_FILENAME, "r");
    if (!f)
    {
        DEBUG_PRINTLN(F("Failed to read file, using default configuration"));
        f.close();
        return false;
    }
    //Dont Use StaticJsonDocument if size is greater than 1k
    DynamicJsonDocument doc(2000);
    DeserializationError err = deserializeJson(doc, f);
    if (err)
    {
        DEBUG_PRINTLN(F("Couldn't deserialize Json Pumpconfiguration"));
        DEBUG_PRINTLN(err.c_str());
        f.close();
        return false;
    }
    JsonArray array = doc.as<JsonArray>();

    for (int i = 0; i < 16; i++)
    {
        JsonObject value = array.getElement(i).as<JsonObject>();
        pumps[i].beverageID = value["beverageID"].as<int>();
        pumps[i].mlPerMinute = value["MlPerMinute"].as<int>();
    }
    DEBUG_PRINTLN(F("Load Pumpconfiguration"));
    f.close();
    return true;
}
bool savePumpConfig()
{

    File file = LittleFS.open(PUMPCONFIG_JSON_FILENAME, "w");
    if (!file)
    {
        DEBUG_PRINTLN(F("Failed to create file"));
        return false;
    }

    DEBUG_PRINTLN("File opened");
    //Dont Use StaticJsonDocument if size is greater than 1k
    DynamicJsonDocument doc(2000);
    JsonArray newArray = doc.to<JsonArray>();
    DEBUG_PRINTLN("Create Array");

    for (int i = 0; i < 16; i++)
    {
        delay(10);

        JsonObject nested = newArray.createNestedObject();
        nested["beverageID"] = pumps[i].beverageID;
        nested["MlPerMinute"] = pumps[i].mlPerMinute;
    }
    DEBUG_PRINTLN("Filled Json");

    if (serializeJson(doc, file) == 0)
    {
        DEBUG_PRINTLN(F("Failed to save Pumpconfiguration to file"));
        return false;
    }
    DEBUG_PRINTLN(F("Saved Pumpconfiguration on Flash"));

    file.close();
    return true;
}
bool saveFile(String filename, String data)
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
String loadFile(String filename)
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