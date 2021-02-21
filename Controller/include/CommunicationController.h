#pragma once
#include "Arduino.h"
#include "WebSocketsServer.h"
#include "Debug.h"
#include "StateController.h"
#include "ArduinoJson.h"
#include "PumpController.h"
#define WEBSOCKET_PORT 81

class PumpController;

class CommunicationController
{
private:
    WebSocketsServer webSocket;
    uint8_t cliendID;
    StateController *_state;
    PumpController *_controller;

public:
    CommunicationController();
    ~CommunicationController();

    void setReferences(StateController *state, PumpController *controller);
    bool clientConnected = false;

    //Websocket Event callback function to receive Data
    void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length);

    bool sendData(String data);

    bool startCleaning(void);
    bool stopCleaning(void);

    bool pumpsStarted(void);
    bool pumpsStopped(void);

    void init(void);
    void run(void);
};
