#include "../include/Network.h"

Network::Network(StorageData *data) : server(80)
{
    storage = data;
}

void Network::init(void)
{

    DEBUG_PRINTLN("Init Network");
    resetWiFi();
    switch (storage->machineData.OperationMode)
    {
    case enOperationMode::configMode:
        startWebserver();

        break;
    case enOperationMode::homeMode:
        DEBUG_PRINTLN("HomeMode");
        DEBUG_PRINTLN("Setup mqttClient");
        DEBUG_PRINT("MqttBrokerIP: ");
        DEBUG_PRINTLN(storage->networkData.MqttBroker);
        DEBUG_PRINT("MqttBrokerPort: ");
        DEBUG_PRINTLN(storage->networkData.MqttPort);

        mqttClient.setClient(wifiMqtt);
        mqttClient.setServer(storage->networkData.MqttBroker.c_str(),
                             (uint16_t)storage->networkData.MqttPort);
        mqttClient.setCallback([this](char *topic, byte *payload, unsigned int length) { this->mqttCallback(topic, payload, length); });

        break;
    case enOperationMode::standaloneMode:

        break;
    default:
        break;
    }
}

void Network::resetWiFi(void)
{
    DEBUG_PRINTLN("Reset WiFi");
    WiFi.disconnect();
    WiFi.softAPdisconnect(true);
}

void Network::run(void)
{

    handleWiFi();
    handleMqtt();
    if (storage->machineData.OperationMode == enOperationMode::configMode)
        server.handleClient();
}

void Network::setWiFiMode(enOperationMode WiFiMode)
{
    resetWiFi();
    delay(10);
    storage->machineData.OperationMode = WiFiMode;
}

void Network::handleWiFi(void)
{
    switch (storage->machineData.OperationMode)
    {
    case enOperationMode::configMode:
        switch (ConfigState)
        {
        case enConfigState::startAP:
            DEBUG_PRINTLN("Start Access Point for Config Mode");

            WiFi.mode(WIFI_AP);
            delay(1);
            PrevMillis_WiFiTimeout = millis();

            DEBUG_PRINTLN("Start Access Point without Password");
            DEBUG_PRINT("WiFI SSID:");
            DEBUG_PRINTLN("MyBartender");

            while (!WiFi.softAP("MyBartender"))
            {
                //After 30 seconds restart in Config Mode
                if (millis() - PrevMillis_WiFiTimeout >= 30000)
                {
                    storage->machineData.OperationMode = enOperationMode::configMode;
                    storage->saveConfig();
                    delay(500);
                    ESP.restart();
                }
                DEBUG_PRINT(".");
                delay(500);
            }
            ConfigState = enConfigState::waitForData;
            break;
        case enConfigState::waitForData:
            break;
        case enConfigState::switchMode:
            break;
        default:
            break;
        }

        break;
    case enOperationMode::homeMode:
        switch (WiFiState)
        {
        case enWiFiState::startWiFi:
            DEBUG_PRINT("Start WiFi in ");

            DEBUG_PRINTLN("HomeMode");

            PrevMillis_WiFiTimeout = millis();
            //WiFi.disconnect();
            WiFi.mode(WIFI_STA);
            WiFi.begin(storage->networkData.STA_Name,
                       storage->networkData.STA_Password);
            delay(1); // Call delay(1) for the WiFi stack

            while (WiFi.status() != WL_CONNECTED)
            {
                delay(500);
                DEBUG_PRINT(".");
                if (millis() - PrevMillis_WiFiTimeout > 30000)
                {
                    WiFiState = enWiFiState::disconnectWiFi;
                    return;
                }
            }
            DEBUG_PRINTLN(F("\n-- Wifi Connected --"));
            DEBUG_PRINT(F("  IP Address  : "));
            ipAddress = WiFi.localIP().toString().c_str();
            DEBUG_PRINTLN(ipAddress);
            DEBUG_PRINT(F("  Subnetmask  : "));
            DEBUG_PRINTLN(WiFi.subnetMask());
            DEBUG_PRINT(F("  MAC Address : "));
            macAddress = WiFi.macAddress();
            DEBUG_PRINTLN(macAddress);
            DEBUG_PRINT(F("  Gateway     : "));
            DEBUG_PRINTLN(WiFi.gatewayIP());
            WiFiState = enWiFiState::monitorWiFi;
            WiFiConncted = true;

            break;

            break;
        case enWiFiState::monitorWiFi:
            if (WiFi.status() != WL_CONNECTED)
            {
                if (millis() - PrevMillis_WiFiTimeout > 5000)
                {
                    WiFiState = enWiFiState::disconnectWiFi;
                }
            }

            break;
        case enWiFiState::disconnectWiFi:
            if (WiFi.status() != WL_CONNECTED)
            {
                WiFiConncted = false;

                WiFi.disconnect();
                WiFiState = enWiFiState::startWiFi;
            }
            else
            {

                WiFiState = enWiFiState::monitorWiFi;
            }
            break;

        default:
            break;
        }
        break;
    case enOperationMode::standaloneMode:
        DEBUG_PRINTLN("Standalone Mode");

        PrevMillis_WiFiTimeout = millis();
        while (!WiFi.softAP(storage->networkData.AP_Name, storage->networkData.AP_Password))
        {
            DEBUG_PRINT(".");
            delay(500);
        }

        break;

    default:
        break;
    }
}

void Network::handleMqtt(void)
{
    mqttClient.loop();

    switch (MqttState)
    {
    case enMqttState::startMqtt:
        if (WiFiConncted)
        {
            DEBUG_PRINTLN("Connect MqttClient");
            DEBUG_PRINT("Username: ");
            DEBUG_PRINTLN(storage->networkData.MqttBroker);
            DEBUG_PRINT("Password: ");
            DEBUG_PRINTLN(storage->networkData.MqttPassword);
            if (mqttClient.connect("asdre", storage->networkData.MqttBroker.c_str(), storage->networkData.MqttPassword.c_str()))
            {
                DEBUG_PRINTLN("MqttClient started");
                //TODO set Topcis
                mqttClient.publish("/home/data", "Started");

                mqttClient.subscribe("Home/Devices/Bartender/Settings");

                MqttState = enMqttState::monitorMqtt; // Check if dc occurred
                MqttConnected = true;
            }
        }
        break;
    case enMqttState::monitorMqtt:
        if (!mqttClient.connected() || !WiFiConncted)
        {
            unsigned long CurMillis_MQTTTimeout = millis();
            if (CurMillis_MQTTTimeout - PrevMillis_WiFiTimeout >= MqttTimeout)
            {
                MqttState = enMqttState::disconnectMqtt;        // Check if dc occurred
                PrevMillis_WiFiTimeout = CurMillis_MQTTTimeout; // Set time for WiFi timeout check
            }
        }
        break;
    case enMqttState::disconnectMqtt:
        if (!mqttClient.connected())
        {
            // Wait for timeout. After timeout restart WiFi
            MqttConnected = false;
            mqttClient.disconnect(); // Disconnect MQTT and start new connection
            MqttState = enMqttState::startMqtt;
        }
        else
        {
            MqttState = enMqttState::startMqtt;
        }
        break;

    default:
        break;
    }
}

void Network::mqttCallback(char *topic, byte *payload, unsigned int length)
{
}

void Network::setMachineMode(enOperationMode newMode)
{
    if (storage->machineData.OperationMode == newMode)
    {
        return;
    }
    DEBUG_PRINT("Switch WiFi Mode to ");
    switch (newMode)
    {
    case enOperationMode::configMode:
        DEBUG_PRINT("ConfigMode");
        break;
    case enOperationMode::homeMode:
        DEBUG_PRINT("HomeMode");
        break;
    case enOperationMode::standaloneMode:
        DEBUG_PRINT("StandaloneMode");
        break;

    default:
        DEBUG_PRINT("Error Mode not found");
        break;
    }
}

void Network::startWebserver(void)
{
    server.onNotFound([this]() {
        if (!handleFileRead(server.uri()))                    // send it if it exists
            server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    server.on("/", HTTP_GET, [this]() { 
                server.sendHeader("Location", "/config.html", true);
                server.send(302,"text/plane",""); });
    server.on(
        "/upload", HTTP_POST, // if the client posts to the upload page
        [this]() {
            server.send(200);
        }, // Send status 200 (OK) to tell the client we are ready to receive
        [this]() { this->handleFileUpload(); });
    server.on("/success", HTTP_POST, [this]() { DEBUG_PRINTLN("TEst"); handleConfig(); });
    server.begin(); // start the HTTP server
    DEBUG_PRINTLN("HTTP server started.");
}

void Network::sendFileUploadPage(void)
{
    server.send(200, "text/html", "<!DOCTYPE html><html><body> <div id='Header'></div> <div id='Home'> <form method='post' enctype='multipart/form-data'> <input type='file' name='name'> <input class='button' type='submit' value='Upload'> </form> </div></body></html>");
}

void Network::sendConfigPage(void)
{
    server.send(200, "text/html", "<!DOCTYPE html><html><body> <div id='Header'></div> <div id='Home'> <form method='post' enctype='multipart/form-data'> <input type='file' name='name'> <input class='button' type='submit' value='Upload'> </form> </div></body></html>");
}

void Network::handleConfig(void)
{
    handleFileRead("/success.html");
    delay(100);
    if (server.hasArg("wifiSSID"))
    {
        storage->networkData.STA_Name = server.arg("wifiSSID");
    }
    if (server.hasArg("wifiPassword"))
    {
        storage->networkData.STA_Password = server.arg("wifiPassword");
    }
    if (server.hasArg("apSSID"))
    {
        storage->networkData.AP_Name = server.arg("apSSID");
    }
    if (server.hasArg("apPassword"))
    {
        storage->networkData.AP_Password = server.arg("apPassword");
    }
    if (server.hasArg("mqttBrokerIpAddress"))
    {
        storage->networkData.MqttBroker = server.arg("mqttBrokerIpAddress");
    }
    if (server.hasArg("mqttBrokerUsername"))
    {
        storage->networkData.MqttUser = server.arg("mqttBrokerUsername");
    }
    if (server.hasArg("mqttBrokerPassword"))
    {
        storage->networkData.MqttPassword = server.arg("mqttBrokerPassword");
    }
    if (server.hasArg("mqttBrokerPort"))
    {
        storage->networkData.MqttPort = strtol(server.arg("mqttBrokerPort").c_str(), NULL, 0);
    }
    if (server.hasArg("operationMode"))
    {
        storage->machineData.OperationMode = (enOperationMode)strtol(server.arg("operationMode").c_str(), NULL, 0);
    }
    storage->saveConfig();
    ESP.restart();
}

void Network::handleFileUpload(void)
{
    HTTPUpload &upload = server.upload();
    if (upload.status == UPLOAD_FILE_START)
    {
        String filename = upload.filename;
        if (!filename.startsWith("/"))
            filename = "/" + filename;
        DEBUG_PRINT("handleFileUpload Name: ");
        DEBUG_PRINTLN(filename);
        storage->fsUploadFile = LittleFS.open(filename, "w+"); // Open the file for writing in LittleFS (create if it doesn't exist)
        filename = String();
    }
    else if (upload.status == UPLOAD_FILE_WRITE)
    {
        if (storage->fsUploadFile)
            storage->fsUploadFile.write(upload.buf, upload.currentSize); // Write the received bytes to the file
    }
    else if (upload.status == UPLOAD_FILE_END)
    {
        if (storage->fsUploadFile)
        {                                  // If the file was successfully created
            storage->fsUploadFile.close(); // Close the file again
            DEBUG_PRINT("handleFileUpload Size: ");
            DEBUG_PRINTLN(upload.totalSize);
            server.sendHeader("Location", "/success.html"); // Redirect the client to the success page
            server.send(303);
        }
        else
        {
            server.send(500, "text/plain", "500: couldn't create file");
        }
    }
}

bool Network::handleFileRead(String path)
{
    DEBUG_PRINTLN("handleFileRead: " + path);
    if (path.endsWith("/"))
        path += "index.html";                  // If a folder is requested, send the index file
    String contentType = getContentType(path); // Get the MIME type
    String pathWithGz = path + ".gz";
    if (LittleFS.exists(pathWithGz) || LittleFS.exists(path))
    {                                                       // If the file exists, either as a compressed archive, or normal
        if (LittleFS.exists(pathWithGz))                    // If there's a compressed version available
            path += ".gz";                                  // Use the compressed version
        File file = LittleFS.open(path, "r");               // Open the file
        size_t sent = server.streamFile(file, contentType); // Send it to the client
        file.close();                                       // Close the file again
        DEBUG_PRINTLN(String("\tSent file: ") + path);
        return true;
    }
    DEBUG_PRINTLN(String("\tFile Not Found: ") + path);
    return false; // If the file doesn't exist, return false
}

String Network::formatBytes(size_t bytes)
{
    if (bytes < 1024)
    {
        return String(bytes) + "B";
    }
    else if (bytes < (1024 * 1024))
    {
        return String(bytes / 1024.0) + "KB";
    }
    else if (bytes < (1024 * 1024 * 1024))
    {
        return String(bytes / (1024.0 * 1024.0)) + "MB";
    }
    else
    {
        return String("Error");
    }
}

String Network::getContentType(String filename)
{
    if (filename.endsWith(".htm"))
        return "text/html";
    else if (filename.endsWith(".html"))
        return "text/html";
    else if (filename.endsWith(".css"))
        return "text/css";
    else if (filename.endsWith(".js"))
        return "application/javascript";
    else if (filename.endsWith(".png"))
        return "image/png";
    else if (filename.endsWith(".gif"))
        return "image/gif";
    else if (filename.endsWith(".jpg"))
        return "image/jpeg";
    else if (filename.endsWith(".ico"))
        return "image/x-icon";
    else if (filename.endsWith(".xml"))
        return "text/xml";
    else if (filename.endsWith(".pdf"))
        return "application/x-pdf";
    else if (filename.endsWith(".zip"))
        return "application/x-zip";
    else if (filename.endsWith(".gz"))
        return "application/x-gzip";
    return "text/plain";
}
