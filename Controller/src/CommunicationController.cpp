#include "CommunicationController.h"
CommunicationController::CommunicationController(/* args */) : webSocket(WEBSOCKET_PORT)
{
    this->clientConnected = false;
    this->cliendID = -1;
}
CommunicationController::~CommunicationController()
{
}

bool CommunicationController::sendData(String data)
{
    if (clientConnected)
    {
        webSocket.sendTXT(cliendID, data);
        return true;
    }
    return false;
}

void CommunicationController::webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
    switch (type)
    {
    case WStype_DISCONNECTED:
        DEBUG_PRINTF("[%u] Disconnected!\n", num);
        this->clientConnected = false;
        this->cliendID = -1;
        break;
    case WStype_CONNECTED:
    {
        this->cliendID = num;
        this->clientConnected = true;
        IPAddress ip = webSocket.remoteIP(num);
        DEBUG_PRINTF("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

        // send message to client
        webSocket.sendTXT(num, "Connected");
    }
    break;
    case WStype_TEXT:
        DEBUG_PRINTF("[%u] get Text: %s\n", num, payload);

        break;
    case WStype_ERROR:
        break;
    default:
        break;
    }
}
void CommunicationController::init(void)
{
    webSocket.begin();
    //Use Lambda to call Class member function
    webSocket.onEvent([this](uint8_t num, WStype_t type, uint8_t *payload, size_t length) { webSocketEvent(num, type, payload, length); });
}
void CommunicationController::run(void)
{
    webSocket.loop();
}