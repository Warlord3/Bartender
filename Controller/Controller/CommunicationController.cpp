#include "CommunicationController.h"
CommunicationController::CommunicationController() : webSocket(81)
{
}
CommunicationController::~CommunicationController()
{
}
void CommunicationController::setReferences(StateController *state, PumpController *controller)
{

    this->_state = state;
    this->_controller = controller;
    this->clientConnected = false;
    this->cliendID = -1;
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
    {
        DEBUG_PRINTF("[%u] get Text: %s\n", num, payload);
        char *_payload = (char *)payload;
        char *rest;
        String command;
        char *data;
        command = strtok_r(_payload, "$", &rest);
        data = strtok_r(NULL, "$", &rest);
        String response_msg = "";
        if (command == "new_drink")
        {
            if (!this->_controller->isConfigurated())
            {
                webSocket.sendTXT(cliendID, "error$no_configuration");
            }
            else if (this->_controller->setDrink(data))
            {
                webSocket.broadcastTXT("new_drink_response$" + String(_state->currentDrink.ID) + "true");
            }
            else
            {
                webSocket.sendTXT(cliendID, "error$drink_not_possible");
                response_msg = this->_controller->getConfiguration();
                webSocket.sendTXT(cliendID, response_msg);
            }
        }
        else if (command == "pump_config")
        {
            this->_controller->setConfiguration(data);
            response_msg = _controller->getConfiguration();
            webSocket.broadcastTXT(response_msg);
        }
        else if (command == "pump_config_request")
        {
            response_msg = _controller->getConfiguration();
            webSocket.broadcastTXT(response_msg);
        }
        else if (command == "stop_pump")
        {
            _controller->stop(data);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "stop_pump_all")
        {
            _controller->stopAll();
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "start_pump")
        {
            _controller->stop(data);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "start_pump_all")
        {
            _controller->startAll();
            //webSocket.broadcastTXT(response_msg);
        }
        else
        {
            //TODO send Error msg
            //webSocket.sendTXT(cliendID, "");
        }
    }
    break;
    case WStype_ERROR:
        break;
    default:
        break;
    }
}
void CommunicationController::init(void)
{
    //webSocket.enableHeartbeat(15000, 3000, 2);
    webSocket.begin();
    //Use Lambda to call Class member function
    webSocket.onEvent([this](uint8_t num, WStype_t type, uint8_t *payload, size_t length) { webSocketEvent(num, type, payload, length); });
}
void CommunicationController::run(void)
{
    webSocket.loop();
}