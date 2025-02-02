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
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if IS_PLAYER_BUSY then

        ClearPedTasks(PlayerPedId())

        RemoveAnimDict("script_rc@cldn@ig@rsc2_ig1_questionshopkeeper") -- must remove the dict of animation
        RemoveAnimDict("script_re@gold_panner@gold_success") -- must remove the dict of animation
        RemoveEntityProperly(GetPanObjectEntity(), joaat("P_CS_MININGPAN01X") ) -- must remove the entity and the model hash to unload properly. 

    end

end)

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
            PlayCrouchAnimationAndAttachPanObject()

            Wait(6000)

            ClearPedTasks(ped)
            RemoveAnimDict("script_rc@cldn@ig@rsc2_ig1_questionshopkeeper") -- must remove the dict of animation

            PlayGoldpanShakeAnimation()

            for index, difficulty in pairs (Config.Difficulties) do

                if exports["tpz_skillcheck"]:skillCheck(difficulty.mode) then
    
                    if next(Config.Difficulties, index) == nil then
                        success = true
                    end
                else
                    SendNotification(nil, Locales['NOT_FOUND'], "error")
                    break
                end

            end

            Wait(1000)

            ClearPedTasks(ped) -- clearing all tasks

            RemoveAnimDict("script_re@gold_panner@gold_success") -- must remove the dict of animation
            RemoveEntityProperly(GetPanObjectEntity(), joaat("P_CS_MININGPAN01X") ) -- must remove the entity and the model hash to unload properly. 

            if success then
                TriggerServerEvent("tpz_goldpanning:onRandomReward", currentWaterId)
            end

            IS_PLAYER_BUSY = false
            
        else
            SendNotification(nil, Locales['NOT_ALLOWED_AREA'], "error")
        end

    else
        SendNotification(nil, Locales['ALREADY_IN_PROGRESS'], "error")
    end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

-- The specified task is required to prevent players opening the inventory while being busy.
Citizen.CreateThread(function() 

    while true do

        Wait(0)

        if IS_PLAYER_BUSY then
            TriggerEvent('tpz_inventory:closePlayerInventory')
        else
            Wait(1000)
        end

    end

end)
