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
    normalMode,
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
