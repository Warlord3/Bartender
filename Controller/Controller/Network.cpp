#include "Network.h"

bool initComplete = false;
const unsigned long WiFiTimeout = 30000;
unsigned long PrevMillis_WiFiTimeout;
ESP8266WebServer server(SERVER_PORT);

void initNetwork(void)
{
    wifi_set_sleep_type(NONE_SLEEP_T);
    DEBUG_PRINTLN("Init Network");
    resetWiFi();
}

void resetWiFi(void)
{
    DEBUG_PRINTLN("Reset WiFi");
    WiFi.disconnect();
    WiFi.softAPdisconnect(true);
}

void runNetwork(void)
{
    handleWiFi();
    server.handleClient();

    switch (operationMode)
    {
    case enOperationMode::configMode:
        break;
    case enOperationMode::normalMode:

        break;
    case enOperationMode::standaloneMode:
        break;

    default:
        break;
    }
}

void handleWiFi(void)
{
    switch (wifiState)
    {
    case enWiFiState::startWiFi:
        DEBUG_PRINT("Start WiFi in ");

        DEBUG_PRINTLN("Normal Mode");

        PrevMillis_WiFiTimeout = millis();
        WiFi.mode(WIFI_STA);
        WiFi.begin(wifiSSID, wifiPassword);
        delay(1); // Call delay(1) for the WiFi stack

        while (WiFi.status() != WL_CONNECTED)
        {
            delay(500);
            DEBUG_PRINT(".");
            if (millis() - PrevMillis_WiFiTimeout > WiFiTimeout)
            {
                DEBUG_PRINTLN("WiFi timeout");
                wifiState = enWiFiState::startAccessPoint;
                operationMode = enOperationMode::configMode;
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

        startWebserver();

        wifiState = enWiFiState::monitorWiFi;
        WiFiConncted = true;
        break;
    case enWiFiState::monitorWiFi:
        if (WiFi.status() != WL_CONNECTED)
        {
            if (millis() - PrevMillis_WiFiTimeout > 5000)
            {
                wifiState = enWiFiState::disconnectWiFi;
            }
        }
        break;
    case enWiFiState::disconnectWiFi:
        if (WiFi.status() != WL_CONNECTED)
        {
            DEBUG_PRINTLN("Disconnect WiFI");
            WiFiConncted = false;
            WiFi.disconnect();
            wifiState = enWiFiState::startWiFi;
        }
        else
        {

            wifiState = enWiFiState::monitorWiFi;
        }
        break;
    case enWiFiState::startAccessPoint:
        if (operationMode == enOperationMode::configMode)
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
        wifiState = enWiFiState::monitorAccessPoint;
        break;
    case enWiFiState::monitorAccessPoint:
        break;
    case enWiFiState::disconnectAccessPoint:
        DEBUG_PRINTLN("Stop AccessPoint");
        server.close();
        server.stop();
        resetWiFi();
        if (operationMode == enOperationMode::normalMode)
        {
            wifiState = enWiFiState::startWiFi;
        }
        else
        {
            wifiState = enWiFiState::startAccessPoint;
        }

        break;

    default:
        break;
    }
}

void setMachineMode(enOperationMode newMode)
{
}

void startWebserver(void)
{
    server.onNotFound([]() {
        if (!handleFileRead(server.uri()))                    // send it if it exists
            server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    server.onFileUpload([] {
        DEBUG_PRINTLN("File Upload");
        if (server.uri() != "/upload")
            return;
        handleFileUpload();
    });
    server.on("/", HTTP_GET, []() { 
                server.sendHeader("Location", "/config.html", true);
                server.send(302,"text/plane",""); });
    server.on("/upload", HTTP_GET, []() {                     // if the client requests the upload page
        if (!handleFileRead("/upload.html"))                  // send it if it exists
            server.send(404, "text/plain", "404: Not Found"); // otherwise, respond with a 404 (Not Found) error
    });
    server.on(
        "/upload", HTTP_POST, // if the client posts to the upload page
        []() {
            server.send(200);
            DEBUG_PRINTLN("Upload Post");
        }, // Send status 200 (OK) to tell the client we are ready to receive
        handleFileUpload);
    server.on("/success", HTTP_POST, handleConfig);
    server.begin(); // start the HTTP server
    DEBUG_PRINTLN("HTTP server started.");
}

void handleConfig(void)
{
    handleFileRead("/success.html");
    delay(100);
    if (server.hasArg("wifiSSID"))
    {
        wifiSSID = server.arg("wifiSSID");
    }
    if (server.hasArg("wifiPassword"))
    {
        wifiPassword = server.arg("wifiPassword");
    }
    if (server.hasArg("operationMode"))
    {
        operationMode = (enOperationMode)strtol(server.arg("operationMode").c_str(), NULL, 0);
    }
    saveConfig();
    wifiState = enWiFiState::disconnectAccessPoint;
}

void handleFileUpload(void)
{
    DEBUG_PRINTLN("Handle File Upload");
    HTTPUpload &upload = server.upload();
    if (upload.status == UPLOAD_FILE_START)
    {
        String filename = upload.filename;
        if (!filename.startsWith("/"))
            filename = "/" + filename;
        DEBUG_PRINT("handleFileUpload Name: ");
        DEBUG_PRINTLN(filename);
        fsUploadFile = LittleFS.open(filename, "w+"); // Open the file for writing in LittleFS (create if it doesn't exist)
        filename = String();
    }
    else if (upload.status == UPLOAD_FILE_WRITE)
    {
        if (fsUploadFile)
            fsUploadFile.write(upload.buf, upload.currentSize); // Write the received bytes to the file
    }
    else if (upload.status == UPLOAD_FILE_END)
    {
        if (fsUploadFile)
        {                         // If the file was successfully created
            fsUploadFile.close(); // Close the file again
            DEBUG_PRINT("handleFileUpload Size: ");
            DEBUG_PRINTLN(upload.totalSize);
            server.send(200);
        }
        else
        {
            server.send(500, "text/plain", "500: couldn't create file");
        }
    }
}

bool handleFileRead(String path)
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

String formatBytes(size_t bytes)
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

String getContentType(String filename)
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
