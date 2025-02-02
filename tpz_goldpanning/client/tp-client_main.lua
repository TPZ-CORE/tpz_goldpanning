local goldPanObject   = nil

local isPlayerPanning = false

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent('tpz_goldpanning:startPanning')
AddEventHandler('tpz_goldpanning:startPanning', function()

    if not isPlayerPanning then 

        isPlayerPanning = true

        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local Water  = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x, coords.y, coords.z)

        local foundWaterSource              = false
        local hasSuccessfullyPassedMinigame = false

        for k,v in pairs(Config.WaterTypes) do
            if Water == Config.WaterTypes[k]["waterhash"]  then

                foundWaterSource = true
                CrouchAnimAndAttach()

                Wait(6000)

                ClearPedTasks(ped)

                GoldShake()

                for index, difficulty in pairs (Config.Difficulties) do

                    if exports["tp_skillcheck"]:skillCheck(difficulty.mode) then
    
                        if next(Config.Difficulties, index) == nil then
                            hasSuccessfullyPassedMinigame = true
                        end
                    else
                        SendNotification(nil, Locales['NOT_FOUND'], "error")
                        break
                    end
                end

                Wait(1000)

                ClearPedTasks(ped)

                DeleteObject(goldPanObject)
                DeleteEntity(goldPanObject)

                if hasSuccessfullyPassedMinigame then
                    TriggerServerEvent("tpz_goldpanning:onRandomReward")
                end

                break
            end
        end

        isPlayerPanning = false

        if not foundWaterSource then
            SendNotification(nil, Locales['NOT_ALLOWED_AREA'], "error")
        end

    end
end)
