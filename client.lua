local Radars = {}
local DetectorOn = false

RegisterNetEvent("Detector:RadarOnSync", function(radars)
    Radars = radars
end)

RegisterCommand("rdetector", function(_, args, _)
    local arg1 = tostring(args[1])

    if arg1 == "on" then
        DetectorOn = true
    else
        DetectorOn = false
    end
end, false)

Citizen.CreateThread(function()
    while true do
        if DetectorOn then
            Wait(0)

            for _, veh in pairs(GetGamePool("CVehicle")) do
                if Entity(veh).state.radarPowered then
                    local radarCoords = GetEntityCoords(veh)
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(radarCoords - playerCoords)

                    if distance <= 50.0 then
                        local soundId = GetSoundId()

                        PlaySoundFromCoord(soundId, "Beep_Red", radarCoords[1], radarCoords[2], radarCoords[3],
                            "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 5.0, true)
                        ReleaseSoundId(soundId)
                        Wait(distance * 100)
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)
