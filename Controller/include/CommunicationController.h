#pragma once
#include "Arduino.h"
#include "WebSocketsServer.h"
#include "Debug.h"
#define WEBSOCKET_PORT 81

class CommunicationController
{
private:
    WebSocketsServer webSocket;
    uint8_t cliendID;

public:
    CommunicationController(/* args */);
    ~CommunicationController();

    bool clientConnected = false;

    //Websocket Event callback function to receive Data
    void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length);
    /*
    Send data to Connected Client
    Return True if Data send
    */
    bool sendData(String data);

    void init(void);
    void run(void);
};
