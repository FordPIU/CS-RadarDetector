-- Register the radar detector command
RegisterCommand("rdetector", function(_, args, _)
    local arg1 = tostring(args[1]):lower()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    if not DoesEntityExist(veh) then
        print("You are not in a vehicle.")
        return
    end

    if arg1 == "on" then
        SetState(veh, "radarDetector", true)
        print("Radar detector activated.")
    else
        SetState(veh, "radarDetector", nil)
        print("Radar detector deactivated.")
    end
end, false)

-- Function to set the state of an entity
function SetState(entity, key, value)
    TriggerServerEvent("CSV:SETSTATE", NetworkGetNetworkIdFromEntity(entity), key, value)
end

-- Function to get the state of an entity
function GetState(entity, key)
    return Entity(entity).state[key]
end

-- Function to play a sound
local function playSound(soundName)
    local soundId = GetSoundId()

    PlaySoundFrontend(soundId, soundName, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
    ReleaseSoundId(soundId)
end

local function noObstructingTerrain(coord1, coord2, coord1_xBump)
    coord1_xBump = coord1_xBump or 0
    local rayId = StartExpensiveSynchronousShapeTestLosProbe(coord1[1], coord1[2], coord1[3] + coord1_xBump, coord2[1],
        coord2[2],
        coord2[3], 1, 0, 4)
    local _, hit, _, _, _ = GetShapeTestResult(rayId)

    if hit == 1 then
        return false
    else
        return true
    end
end

-- Function to find the closest vehicle with radar
local function getClosestRadarCar(refPoint)
    local closestVeh, closestDist = nil, 1000.0

    for _, veh in pairs(GetGamePool("CVehicle")) do
        if GetState(veh, "radarPowered") and noObstructingTerrain(refPoint, GetEntityCoords(veh), 1.5) then
            local dist = #(GetEntityCoords(veh) - refPoint)

            if dist < closestDist then
                closestVeh, closestDist = veh, dist
            end
        end
    end

    return closestVeh, closestDist
end

-- Main thread to handle radar detector functionality
Citizen.CreateThread(function()
    local wasActive = false
    local lastBeepTime = 0

    while true do
        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)

        if GetState(playerVeh, "radarDetector") then
            Wait(0)

            if not wasActive then
                playSound("Start")
                wasActive = true
                Wait(1000)
            end

            local playerPos = GetEntityCoords(PlayerPedId())
            local radarVeh, radarDist = getClosestRadarCar(playerPos)

            if radarVeh then
                if GetGameTimer() >= (lastBeepTime + (radarDist * 1.75)) then
                    playSound("Beep_Red")
                    lastBeepTime = GetGameTimer()
                end

                Wait(radarDist)
                print(radarDist)
            else
                Wait(100)
            end
        else
            if wasActive then
                playSound("Power_Down")
                wasActive = false
            end

            Wait(1000)
        end
    end
end)