#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WebSocketsServer.h>
#include "Enum.h"
#include "Debug.h"
#include "LittleFS.h"
#include "MyPassword.h"
#include "Arduino.h"
#include "LocalStorage.h"
class Network
{
private:
    /* data */
    bool initComplete = false;
    const char *WiFiName = WIFI_NAME;
    const char *WiFiPassword = WIFI_PASSWORD;
    const char *AccessPointName = AP_NAME;
    const char *AccessPointPassword = AP_PASSWORD;

    String ipAddress = "";
    String macAddress = "";

     unsigned long WiFiTimout;

    ESP8266WebServer server;
    WebSocketsServer webSocket;
    enOperationMode operationMode = enOperationMode::homeMode;

    enWiFiState WiFiState = enWiFiState::startWiFi;
    enMqttState MqttState = enMqttState::startMqtt;
    enConfigState ConfigState = enConfigState::startAP;

    StorageData *storage;

    void handleWiFi(void);

    void switchMode(void);

    void resetWiFi(void);
    void startWebserver(void);
    bool handleFileRead(String path);
    void handleFileUpload(void);
    String formatBytes(size_t bytes);
    String getContentType(String filename);

public:
    Network(StorageData *data);

    void setWiFiMode(enOperationMode WiFiMode);

    void init(void);
    void run(void);
};
