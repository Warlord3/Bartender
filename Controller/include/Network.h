#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include "Enum.h"
#include "Debug.h"
#include "LittleFS.h"
#include "MyPassword.h"
#include "Arduino.h"
#include "StateController.h"
#include "StorageController.h"

class Network
{
private:
    /* data */
    bool initComplete = false;

    //Timeout after Controller switches back to Configuration Mode
    const unsigned long WiFiTimeout = 30000;
    unsigned long PrevMillis_WiFiTimeout;

    ESP8266WebServer _server;

    StateController *state;
    StorageController *storage;

    void handleWiFi(void);

    void setMachineMode(enOperationMode newMode);

    void resetWiFi(void);
    void startWebserver(void);
    bool handleFileRead(String path);

    void handleFileUpload(void);
    void handleConfig(void);

    String formatBytes(size_t bytes);
    String getContentType(String filename);

public:
    Network();
    ~Network();

    void setReferences(StateController *state, StorageController *storage);

    void init(void);
    void run(void);
};
