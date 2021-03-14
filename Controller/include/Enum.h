#pragma once

enum class enPumpDirection
{
    stop,
    forward,
    backward
};

enum class enMachineState
{
    boot,
    init,
    idle,
    running,
    cleaning,
    testing
};

enum class enOperationMode
{
    configMode,
    normalMode,
    standaloneMode //TODO implement
};

enum class enWiFiState
{
    startWiFi,
    monitorWiFi,
    disconnectWiFi,
    startAccessPoint,
    monitorAccessPoint,
    disconnectAccessPoint
};
