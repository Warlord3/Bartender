#pragma once
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include "Enum.h"
#include "Debug.h"
#include "LittleFS.h"
#include "Arduino.h"
#include "State.h"
#include "Storage.h"

#define SERVER_PORT 80
/* data */
extern bool initComplete;

//Timeout after Controller switches back to Configuration Mode
extern const unsigned long WiFiTimeout;
extern unsigned long PrevMillis_WiFiTimeout;

extern ESP8266WebServer server;


void handleWiFi(void);

void setMachineMode(enOperationMode newMode);

void resetWiFi(void);
void startWebserver(void);
bool handleFileRead(String path);

void handleFileUpload(void);
void handleConfig(void);

String formatBytes(size_t bytes);
String getContentType(String filename);

void initNetwork(void);
void runNetwork(void);
