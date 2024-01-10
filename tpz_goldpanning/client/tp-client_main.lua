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


-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

function CrouchAnimAndAttach()
    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")
    local modelHash = joaat("P_CS_MININGPAN01X")
    LoadModel(modelHash)
    goldPanObject = CreateObject(modelHash, coords.x+0.3, coords.y,coords.z, true, false, false)
    SetEntityVisible(goldPanObject, true)
    SetEntityAlpha(goldPanObject, 255, false)
    Citizen.InvokeNative(0x283978A15512B2FE, goldPanObject, true)
    SetModelAsNoLongerNeeded(modelHash)
    AttachEntityToEntity(goldPanObject,ped, boneIndex, 0.2, 0.0, -0.2, -100.0, -50.0, 0.0, false, false, false, true, 2, true)

    TaskPlayAnim(ped, dict, "inspectfloor_player", 1.0, 8.0, -1, 1, 0, false, false, false)
end

function GoldShake()
    local dict = "script_re@gold_panner@gold_success"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end
    TaskPlayAnim(PlayerPedId(), dict, "SEARCH02", 1.0, 8.0, -1, 1, 0, false, false, false)
end

function LoadModel(model)
    local attempts = 0
    while attempts < 100 and not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(10)
        attempts = attempts + 1
    end
    return IsModelValid(model)
end
