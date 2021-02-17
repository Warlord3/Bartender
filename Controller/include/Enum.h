#pragma once

enum class enPumpState
{
    stop,
    forward,
    backward
};

enum class enMachineState
{
    idleState,
    initState,
    runningState,
    cleaningState,
    testingState
};

enum class enOperationMode
{
    configMode,
    homeMode,
    standaloneMode //TODO implement
};
enum class enConfigState
{
    startAP,
    waitForData,
    switchMode
};
enum class enWiFiState
{
    startWiFi,
    monitorWiFi,
    disconnectWiFi
};

enum class enMqttState
{
    startMqtt,
    monitorMqtt,
    disconnectMqtt
};