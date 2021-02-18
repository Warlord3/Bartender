#include "Network.h"

Network::Network(StorageData *data) : server(80), webSocket(81)
{
    storage = data;
}

void Network::init(void)
{
    DEBUG_PRINTLN("Init Network");
    switch (storage->machineData.OperationMode)
    {
    case enOperationMode::homeMode:

        break;
    case enOperationMode::standaloneMode:

        break;
    default:
        break;
    }
    startWebserver();
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
            resetWiFi();

            WiFi.mode(WIFI_AP);
            delay(1);
            WiFiTimout = millis();

            DEBUG_PRINTLN("Start Access Point without Password");
            DEBUG_PRINT("WiFI SSID:");
            DEBUG_PRINTLN("MyBartender");

            while (!WiFi.softAP("MyBartender"))
            {
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

            //WiFi.disconnect();
            WiFi.mode(WIFI_STA);
            WiFi.begin(storage->networkData.STA_Name,
                       storage->networkData.STA_Password);
            delay(1); // Call delay(1) for the WiFi stack

            while (WiFi.status() != WL_CONNECTED)
            {
                delay(500);
                DEBUG_PRINT(".");
                if (millis() - WiFiTimout > 30000)
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
            break;

            break;
        case enWiFiState::monitorWiFi:
            if (WiFi.status() != WL_CONNECTED)
            {
                if (millis() - WiFiTimout > 5000)
                {
                    WiFiState = enWiFiState::disconnectWiFi;
                }
            }

            break;
        case enWiFiState::disconnectWiFi:
            if (WiFi.status() != WL_CONNECTED)
            {
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

        WiFiTimout = millis();
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

void Network::switchMode(void)
{
    DEBUG_PRINTLN("Switch WiFi Mode");
    if (storage->machineData.OperationMode == enOperationMode::standaloneMode)
    {
        DEBUG_PRINTLN("Switched to HomeMode");
        storage->machineData.OperationMode = enOperationMode::homeMode;
    }
    else
    {
        DEBUG_PRINTLN("Switched to Standalone");
        storage->machineData.OperationMode = enOperationMode::standaloneMode;
    }
}

void Network::startWebserver(void)
{
    server.onNotFound([this]() {
        if (!handleFileRead(server.uri()))                    // send it if it exists
            server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    server.on(
        "/upload", HTTP_POST, // if the client posts to the upload page
        [this]() {
            server.send(200);
        }, // Send status 200 (OK) to tell the client we are ready to receive
        [this]() { this->handleFileUpload(); });
    server.on("/upload", HTTP_GET, [&]() {                    // if the client requests the upload page
        if (!handleFileRead("/upload.html"))                  // send it if it exists
            server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    server.begin(); // start the HTTP server
    DEBUG_PRINTLN("HTTP server started.");
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
