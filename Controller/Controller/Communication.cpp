#include "include\Communication.h"

WebSocketsServer webSocket(WEBSOCKET_PORT);
bool clientConnected = false;
uint8_t cliendID;


void initCommunication(void)
{
    clientConnected = false;
    cliendID = -1;
    //webSocket.enableHeartbeat(15000, 3000, 2);
    webSocket.begin();
    DEBUG_PRINTLN("Strat Websocket server");
    //Use Lambda to call Class member function
    webSocket.onEvent(webSocketEvent);
}
void runCommunication(void)
{
    webSocket.loop();
}



void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
    switch (type)
    {
    case WStype_DISCONNECTED:
        DEBUG_PRINTF("[%u] Disconnected!\n", num);
        clientConnected = false;
        cliendID = -1;
        break;
    case WStype_CONNECTED:
    {
        String response_msg = "";
        cliendID = num;
        clientConnected = true;
        IPAddress ip = webSocket.remoteIP(num);
        DEBUG_PRINTF("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

        // send message to client
        webSocket.sendTXT(num, "Connected");
        response_msg = getConfiguration();
        webSocket.sendTXT(num, response_msg);
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
            if (!isConfigurated())
            {
                webSocket.sendTXT(cliendID, "error$no_configuration");
            }
            else if (setDrink(data))
            {
                webSocket.broadcastTXT("new_drink_response$" + String(currentDrink.ID) + "true");
            }
            else
            {
                webSocket.sendTXT(cliendID, "error$drink_not_possible");
                response_msg = getConfiguration();
                webSocket.sendTXT(cliendID, response_msg);
            }
        }
        else if (command == "pump_config")
        {
            setConfiguration(data);
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
            DEBUG_PRINTLN((int)wifiState);
        }
        else if (command == "pump_config_request")
        {
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
        }
        else if (command == "stop_pump")
        {
            stop(data);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "stop_pump_all")
        {
            stopAllPumps(true);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "start_pump")
        {
            stop(data);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (command == "start_pump_all")
        {
            startAllPumps((enPumpDirection)strtol(data ,NULL, 10));
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

bool sendData(String data)
{
    if (clientConnected)
    {
        webSocket.sendTXT(cliendID, data);
        return true;
    }
    return false;
}