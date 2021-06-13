#include "include\Communication.h"

WebSocketsServer webSocket(WEBSOCKET_PORT);
bool clientConnected = false;
String response = "";
uint8_t cliendID;

void initCommunication(void)
{
    clientConnected = false;
    cliendID = -1;
    //webSocket.enableHeartbeat(15000, 3000, 2);
    webSocket.begin();
    DEBUG_PRINTLN("Start Websocket server");
    //Use Lambda to call Class member function
    webSocket.onEvent(webSocketEvent);
}
void runCommunication(void)
{
    webSocket.loop();

    if (drinkFinished)
    {
        drinkFinished = false;
        String output;
        StaticJsonDocument<48> doc;
        doc["commnad"] = "drink_finished";
        serializeJson(doc, output);
        webSocket.broadcastTXT(output);
    }
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length)
{
    response = "";
    switch (type)
    {
    case WStype_DISCONNECTED:
        DEBUG_PRINTF("[%u] Disconnected!\n", num);
        clientConnected = false;
        cliendID = -1;
        if (testingMode)
        {
            stopAllPumps(true);
        }
        break;
    case WStype_CONNECTED:
    {
        IPAddress ip = webSocket.remoteIP(num);
        DEBUG_PRINTF("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);

        StaticJsonDocument<48> doc;
        doc["command"] = "connected";
        serializeJson(doc, response);
        // send message to client
        webSocket.sendTXT(num, response);
        response = getProgress();
        webSocket.sendTXT(num, response);
    }
    break;
    case WStype_TEXT:
    {
        DEBUG_PRINTF("[%u] get Text: %s\n", num, payload);
        if (String((char *)payload) == "connected")
        {
            cliendID = num;
            clientConnected = true;
        }

        DynamicJsonDocument doc(1000);
        DeserializationError error = deserializeJson(doc, payload);
        if (error)
        {
            DEBUG_PRINTLN("Error deserialize Message");
            return;
        }

        const char *command = doc["command"].as<char *>();
        DEBUG_PRINTF("Command: %s\n", command);

        String response_msg = "";
        if (strcmp(command, "new_drink") == 0)
        {
            if (!isConfigurated())
            {
                webSocket.sendTXT(cliendID, "error$no_configuration");
            }
            else if (setDrink(doc))
            {
                doc.clear();
                doc["command"] = "new_drink_response";
                doc["accepted"] = true;
                serializeJson(doc, response);
                webSocket.broadcastTXT(response);
            }
            else
            {
                doc.clear();
                doc["command"] = "error";
                doc["message"] = "drink_not_possible";
                serializeJson(doc, response);
                webSocket.sendTXT(num, response);
            }
        }
        else if (strcmp(command, "pump_config") == 0)
        {
            setConfiguration(doc);
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
            DEBUG_PRINTLN((int)wifiState);
        }
        else if (strcmp(command, "pump_config_request") == 0)
        {
            response_msg = getConfiguration();
            webSocket.broadcastTXT(response_msg);
        }
        else if (strcmp(command, "stop_pump") == 0)
        {
            int id = doc["ID"].as<int>();
            if (testingMode)
            {
                pumps[id].testingMode = false;
            }
            stopPump(id);
        }
        else if (strcmp(command, "stop_pump_all") == 0)
        {
            stopAllPumps(true);
        }
        else if (strcmp(command, "start_pump") == 0)
        {
            int id = doc["ID"].as<int>();
            if (testingMode)
            {
                pumps[id].testingMode = true;
            }
            startPump((enPumpRunningDirection)doc["direction"].as<int>(), id);
        }
        else if (strcmp(command, "start_pump_all") == 0)
        {

            startAllPumps((enPumpRunningDirection)doc["direction"].as<int>());
            //webSocket.broadcastTXT(response_msg);
        }
        else if (strcmp(command, "pause_drink") == 0)
        {
            interuptActive = false;
            drinkPaused = true;
            stopAllPumps(true);
            doc.clear();
            doc["command"] = "pause_drink_response";
            doc["paused"] = true;
            serializeJson(doc, response);
            webSocket.sendTXT(num, response);
        }
        else if (strcmp(command, "continue_drink") == 0)
        {
            if (!drinkPaused)
                return;
            interuptActive = true;
            drinkPaused = false;
            startPumpsWithCurrentDrink();
            doc.clear();
            doc["command"] = "continue_drink_response";
            doc["continued"] = true;
            serializeJson(doc, response);
            webSocket.sendTXT(num, response);
        }
        else if (strcmp(command, "stop_drink") == 0)
        {
            drinkPaused = false;
            interuptActive = true;
            stopDrink();
            doc.clear();
            doc["command"] = "stop_drink_response";
            doc["stopped"] = true;
            serializeJson(doc, response);
            webSocket.sendTXT(num, response);
        }
        else if (strcmp(command, "pump_milliliter") == 0)
        {
            int pumpID = doc["ID"].as<int>();
            int ml = doc["ml"].as<int>();
            setRemainingMl(ml, pumpID);
            startPump(enPumpRunningDirection::forward, pumpID);
        }
        else if (strcmp(command, "testing_mode") == 0)
        {
            if (doc["enable"].as<bool>())
            {
                testingMode = true;
                machineState = enMachineState::testing;
            }
            else
            {
                testingMode = false;
                for (int i = 0; i < NUM_CONTROLLERS * NUM_PUMPS_PER_CONTROLLER; i++)
                {
                    pumps[i].testingMode = false;
                }
                stopAllPumps(true);
                machineState = enMachineState::running;
            }
        }
        else if (strcmp(command, "reset") == 0)
        {
            startAllPumps((enPumpRunningDirection)doc["direction"].as<int>());
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