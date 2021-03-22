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

    if (drinkFinished)
    {
        drinkFinished = false;
        webSocket.broadcastTXT("drink_finished");
    }
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

        DynamicJsonDocument doc(1000);
        DeserializationError error = deserializeJson(doc, payload);
        if (error)
        {
            DEBUG_PRINTLN("Error deserialize Message");
            return;
        }

        const char* command = doc["command"].as<char*>();
        DEBUG_PRINTF("Command: %s\n",command);

        String response_msg = "";
        if (strcmp(command, "new_drink")==0)
        {
            if (!isConfigurated())
            {
                webSocket.sendTXT(cliendID, "error$no_configuration");
            }
            else if (setDrink(doc))
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
        else if(strcmp(command, "pump_config")==0)
        {
            setConfiguration(doc);
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
            DEBUG_PRINTLN((int)wifiState);
        }
        else if (strcmp(command, "pump_config_request")==0)
        {
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
        }
        else if (strcmp(command, "stop_pump")==0)
        {
            stop(doc);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (strcmp(command, "stop_pump_all")==0)
        {
            stopAllPumps(true);
            //webSocket.broadcastTXT(response_msg);
        }
        else if (strcmp(command, "start_pump")==0)
        {
            stop(doc);
            //webSocket.broadcastTXT(response_msg);
        }
        else if(strcmp(command, "start_pump_all")==0) 
        {
            startAllPumps((enPumpDirection)doc["direction"].as<int>());
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