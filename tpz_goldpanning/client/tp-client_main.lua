local IS_PLAYER_BUSY = false

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local IsWaterSource = function(currentWaterId)

    for k,v in pairs(Config.WaterTypes) do
        if currentWaterId == Config.WaterTypes[k]["waterhash"] then
            return true
        end
    end

    return false

end

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterNetEvent('tpz_goldpanning:client:startPanning')
AddEventHandler('tpz_goldpanning:client:startPanning', function()

    if not IS_PLAYER_BUSY then 

        local ped              = PlayerPedId()
        local coords           = GetEntityCoords(ped)

        local currentWaterId   = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x, coords.y, coords.z)

        local foundWaterSource = IsWaterSource(currentWaterId)
        local success          = false

        if foundWaterSource then

            IS_PLAYER_BUSY = true
            CrouchAnimAndAttach()

            Wait(6000)
            ClearPedTasks(ped)

            PlayGoldpanShakeAnimation()

            for index, difficulty in pairs (Config.Difficulties) do

                if exports["tp_skillcheck"]:skillCheck(difficulty.mode) then
    
                    if next(Config.Difficulties, index) == nil then
                        success = true
                     end
                 else
                     SendNotification(nil, Locales['NOT_FOUND'], "error")
                     break
                 end
             end

             Wait(1000)

             ClearPedTasks(ped)

             RemoveEntityProperly(GetPanObjectEntity(), joaat("P_CS_MININGPAN01X") )

             if success then
                 TriggerServerEvent("tpz_goldpanning:onRandomReward")
             end

        end
    else
        -- notify 
    end

    IS_PLAYER_BUSY = false

    if not foundWaterSource then
        SendNotification(nil, Locales['NOT_ALLOWED_AREA'], "error")
    end

end)
