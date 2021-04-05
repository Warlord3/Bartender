#pragma once
#include "Arduino.h"
#include "WebSocketsServer.h"
#include "Debug.h"
#include "State.h"
#include "ArduinoJson.h"
#include "Pumps.h"
#define WEBSOCKET_PORT 81

extern WebSocketsServer webSocket;
extern bool clientConnected;
extern String response;
extern uint8_t cliendID;

//Websocket Event callback function to receive Data
void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length);

bool sendData(String data);

bool pumpsStarted(void);
bool pumpsStopped(void);

void initCommunication(void);
void runCommunication(void);
