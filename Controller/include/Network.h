#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include "Enum.h"
#include "Debug.h"
#include "LittleFS.h"
#include "PubSubClient.h"
#include "MyPassword.h"
#include "Arduino.h"
#include "LocalStorage.h"
class Network
{
private:
    /* data */
    bool initComplete = false;

    String ipAddress = "";
    String macAddress = "";

    bool MqttConnected = false;
    bool WiFiConncted = false;
    WiFiClient wifiMqtt;
    const unsigned long WiFiTimeout = 5000;
    const unsigned long MqttTimeout = 5000;
    unsigned long PrevMillis_WiFiTimeout;
    unsigned long PrevMillis_MqttTimeout;

    ESP8266WebServer server;
    enOperationMode operationMode = enOperationMode::homeMode;

    enWiFiState WiFiState = enWiFiState::startWiFi;
    enMqttState MqttState = enMqttState::startMqtt;
    enConfigState ConfigState = enConfigState::startAP;

    StorageData *storage;

    void handleWiFi(void);
    void handleMqtt(void);

    void setMachineMode(enOperationMode newMode);

    void resetWiFi(void);
    void startWebserver(void);
    bool handleFileRead(String path);

    void handleFileUpload(void);
    void handleConfig(void);

    void sendFileUploadPage(void);
    void sendConfigPage(void);

    void mqttCallback(char *topic, byte *payload, unsigned int length);
    String formatBytes(size_t bytes);
    String getContentType(String filename);

public:
    Network(StorageData *data);

    PubSubClient mqttClient;
    void setWiFiMode(enOperationMode WiFiMode);

    void init(void);
    void run(void);
};
