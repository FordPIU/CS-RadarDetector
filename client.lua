local Radars = {}
local DetectorOn = false

RegisterNetEvent("Detector:RadarOnSync", function(radars)
    Radars = radars
end)

RegisterCommand("rdetector", function(_, args, _)
    local arg1 = tostring(args[1]):lower()

    if arg1 == "on" then
        DetectorOn = true
    else
        DetectorOn = false
    end

    print(DetectorOn)
end, false)

local function getClosestRadarCar(refPoint)
    local closestVeh, closestDist = nil, 500.0

    for _, veh in pairs(GetGamePool("CVehicle")) do
        if Entity(veh).state.radarPowered then
            local dist = #(GetEntityCoords(veh) - refPoint)

            if dist < closestDist then
                closestVeh, closestDist = veh, dist
            end
        end
    end

    return closestVeh, closestDist
end

Citizen.CreateThread(function()
    while true do
        if DetectorOn then
            Wait(0)

            local playerPoint = GetEntityCoords(PlayerPedId())
            local radarVeh, radarDist = getClosestRadarCar(playerPoint)

            print(radarDist, radarDist * 2.5)

            if radarVeh then
                local soundId = GetSoundId()

                PlaySoundFromCoord(soundId, "Beep_Red", playerPoint[1], playerPoint[2], playerPoint[3],
                    "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 5.0, true)
                ReleaseSoundId(soundId)
                Wait(radarDist * 2.5)
            else
                Wait(100)
            end
        else
            Wait(500)
        end
    end
end)
