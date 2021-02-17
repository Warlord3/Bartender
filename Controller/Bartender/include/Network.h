#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
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
    const char *WiFiName = WIFI_NAME;
    const char *WiFiPassword = WIFI_PASSWORD;
    const char *AccessPointName = AP_NAME;
    const char *AccessPointPassword = AP_PASSWORD;

    const char *MqttName = MQTT_NAME;
    const char *MqttPassword = MQTT_PASSWORD;
    String ipAddress = "";
    String macAddress = "";

    String MqttBroker;
    int MqttPort;
    WiFiClient wifiMqtt;
    unsigned long MqttTimeout;
    unsigned long WiFiTimout;

    ESP8266WebServer server;
    enOperationMode operationMode = enOperationMode::homeMode;

    enWiFiState WiFiState = enWiFiState::startWiFi;
    enMqttState MqttState = enMqttState::startMqtt;
    enConfigState ConfigState = enConfigState::startAP;

    StorageData *storage;

    void handleWiFi(void);
    void handleMqtt(void);

    void switchMode(void);

    void resetWiFi(void);
    void startWebserver(void);
    bool handleFileRead(String path);
    void handleFileUpload(void);
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
