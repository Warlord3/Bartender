#include "Network.h"

Network::Network() : _server(81)
{
}
Network::~Network()
{
}
void Network::setReferences(StateController *state, StorageController *storage)
{
    this->state = state;
    DEBUG_PRINTLN("Create Network");

    this->storage = storage;
}

void Network::init(void)
{
    wifi_set_sleep_type(NONE_SLEEP_T);
    DEBUG_PRINTLN("Init Network");
    resetWiFi();
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
    switch (state->operationMode)
    {
    case enOperationMode::configMode:
        _server.handleClient();
        break;
    case enOperationMode::normalMode:

        break;
    case enOperationMode::standaloneMode:
        break;

    default:
        break;
    }
}

void Network::handleWiFi(void)
{
    switch (state->wifiState)
    {
    case enWiFiState::startWiFi:
        DEBUG_PRINT("Start WiFi in ");

        DEBUG_PRINTLN("Normal Mode");

        PrevMillis_WiFiTimeout = millis();
        WiFi.mode(WIFI_STA);
        WiFi.begin(state->wifiSSID, state->wifiPassword);
        delay(1); // Call delay(1) for the WiFi stack

        while (WiFi.status() != WL_CONNECTED)
        {
            delay(500);
            DEBUG_PRINT(".");
            if (millis() - PrevMillis_WiFiTimeout > WiFiTimeout)
            {
                state->wifiState = enWiFiState::startAccessPoint;
                state->operationMode = enOperationMode::configMode;
                return;
            }
        }
        DEBUG_PRINTLN(F("\n-- Wifi Connected --"));
        DEBUG_PRINT(F("  IP Address  : "));
        state->ipAddress = WiFi.localIP().toString().c_str();
        DEBUG_PRINTLN(state->ipAddress);
        DEBUG_PRINT(F("  Subnetmask  : "));
        DEBUG_PRINTLN(WiFi.subnetMask());
        DEBUG_PRINT(F("  MAC Address : "));
        state->macAddress = WiFi.macAddress();
        DEBUG_PRINTLN(state->macAddress);
        DEBUG_PRINT(F("  Gateway     : "));
        DEBUG_PRINTLN(WiFi.gatewayIP());
        state->wifiState = enWiFiState::monitorWiFi;
        state->WiFiConncted = true;
        break;
    case enWiFiState::monitorWiFi:
        if (WiFi.status() != WL_CONNECTED)
        {
            if (millis() - PrevMillis_WiFiTimeout > 5000)
            {
                state->wifiState = enWiFiState::disconnectWiFi;
            }
        }
        break;
    case enWiFiState::disconnectWiFi:
        if (WiFi.status() != WL_CONNECTED)
        {
            state->WiFiConncted = false;
            WiFi.disconnect();
            state->wifiState = enWiFiState::startWiFi;
        }
        else
        {

            state->wifiState = enWiFiState::monitorWiFi;
        }
        break;
    case enWiFiState::startAccessPoint:
        if (state->operationMode == enOperationMode::configMode)
        {

            DEBUG_PRINTLN("Start Access Point for Config Mode");

            WiFi.mode(WIFI_AP);
            delay(1);

            DEBUG_PRINTLN("Start Access Point without Password");
            DEBUG_PRINT("WiFI SSID:");
            DEBUG_PRINTLN("MyBartender");

            PrevMillis_WiFiTimeout = millis();
            while (!WiFi.softAP("MyBartender"))
            {
                //After 30 seconds restart in Config Mode
                if (millis() - PrevMillis_WiFiTimeout >= 30000)
                {
                    delay(500);
                    ESP.restart();
                }
                DEBUG_PRINT(".");
                delay(500);
            }
            startWebserver();
        }
        state->wifiState = enWiFiState::monitorAccessPoint;
        break;
    case enWiFiState::monitorAccessPoint:
        break;
    case enWiFiState::disconnectAccessPoint:
        _server.close();
        _server.stop();
        resetWiFi();
        if (state->operationMode == enOperationMode::normalMode)
        {
            state->wifiState = enWiFiState::startWiFi;
        }
        else
        {
            state->wifiState = enWiFiState::startAccessPoint;
        }

        break;

    default:
        break;
    }
}

void Network::setMachineMode(enOperationMode newMode)
{
}

void Network::startWebserver(void)
{
    _server.onNotFound([this]() {
        if (!handleFileRead(_server.uri()))                    // send it if it exists
            _server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    _server.on("/", HTTP_GET, [this]() { 
                _server.sendHeader("Location", "/config.html", true);
                _server.send(302,"text/plane",""); });
    _server.on(
        "/upload", HTTP_POST, // if the client posts to the upload page
        [this]() {
            _server.send(200);
        }, // Send status 200 (OK) to tell the client we are ready to receive
        [this]() { this->handleFileUpload(); });
    _server.on("/success", HTTP_POST, [this]() { DEBUG_PRINTLN("TEst"); handleConfig(); });
    _server.begin(); // start the HTTP server
    DEBUG_PRINTLN("HTTP server started.");
}

void Network::handleConfig(void)
{
    handleFileRead("/success.html");
    delay(100);
    stConfig newConfig = stConfig();
    if (_server.hasArg("wifiSSID"))
    {
        newConfig.wifiSSID = _server.arg("wifiSSID");
    }
    if (_server.hasArg("wifiPassword"))
    {
        newConfig.wifiPassword = _server.arg("wifiPassword");
    }
    if (_server.hasArg("operationMode"))
    {
        newConfig.operationMode = (enOperationMode)strtol(_server.arg("operationMode").c_str(), NULL, 0);
    }
    storage->saveConfig(newConfig);
    state->wifiState = enWiFiState::disconnectAccessPoint;
    state->operationMode = newConfig.operationMode;
    state->wifiSSID = newConfig.wifiSSID;
    state->wifiPassword = newConfig.wifiPassword;
}

void Network::handleFileUpload(void)
{
    HTTPUpload &upload = _server.upload();
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
            _server.sendHeader("Location", "/success.html"); // Redirect the client to the success page
            _server.send(303);
        }
        else
        {
            _server.send(500, "text/plain", "500: couldn't create file");
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
    {                                                        // If the file exists, either as a compressed archive, or normal
        if (LittleFS.exists(pathWithGz))                     // If there's a compressed version available
            path += ".gz";                                   // Use the compressed version
        File file = LittleFS.open(path, "r");                // Open the file
        size_t sent = _server.streamFile(file, contentType); // Send it to the client
        file.close();                                        // Close the file again
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
