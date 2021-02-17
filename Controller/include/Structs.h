#pragma once
#include "Arduino.h"
#include "Debug.h"
#include "vector"
#include "Enum.h"
struct stNetworkData
{
    bool WiFiConnected = false;
    bool MqttConnected = false;
    String AP_Name = "";
    String AP_Password = "";
    String STA_Name = "";
    String STA_Password = "";

    String MqttBroker = "";
    int MqttPort = 1883;
    String MqttUser = "";
    String MqttPassword = "";
};

struct stMachineData
{
    enOperationMode OperationMode = enOperationMode::configMode;
    int Pumpcount = 0;
    std ::vector<float> PumpsMlPerMinute; // Speed of the Pumps
    void setPumpcount(int newPumpcount)
    {
        this->Pumpcount = newPumpcount;
        PumpsMlPerMinute.resize(newPumpcount);
    }
    ~stMachineData()
    {
        PumpsMlPerMinute.resize(0);
        PumpsMlPerMinute.shrink_to_fit();
    }
};

struct stDrinkData
{
    String DrinkName = "";
    int DrinkID = 0;
    float DrinkAmount = 0.0;
    std::vector<float> AmountIngredients; //Amount of Ingredients for each Pump
    void setPumpcount(int newPumpcount)
    {
        AmountIngredients.resize(newPumpcount);
    }

        bool setValue(int Position, float Value)
    {
        if (Position < AmountIngredients.size())
        {
            AmountIngredients[Position] = Value;
            return true;
        }
        else
        {
            DEBUG_PRINTLN("ERROR: Trying to access invalid Array Index for set Ingredients Amount");
            return false;
        }
    }
    ~stDrinkData()
    {
        AmountIngredients.resize(0);
        AmountIngredients.shrink_to_fit();
    }
};
