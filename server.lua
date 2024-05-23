local Radars = {}

RegisterNetEvent("Detector:RadarOn", function(isOn)
    local src = source

    if isOn then
        Radars[src] = true
    else
        Radars[src] = nil
    end

    TriggerClientEvent("Detector:RadarOnSync", -1, Radars)
end)
