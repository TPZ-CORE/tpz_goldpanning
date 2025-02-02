
local CURRENT_OBJECT_ENTITY = nil -- we use it as local and we get it through a getter.

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

GetPanObjectEntity = function() -- getter 
    return CURRENT_OBJECT_ENTITY
end

PlayCrouchAnimationAndAttachPanObject = function()

    local dict = "script_rc@cldn@ig@rsc2_ig1_questionshopkeeper"
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    local ped       = PlayerPedId()
    local coords    = GetEntityCoords(ped)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_HAND")

    LoadModel("P_CS_MININGPAN01X")

    CURRENT_OBJECT_ENTITY = CreateObject(joaat("P_CS_MININGPAN01X"), coords.x+0.3, coords.y,coords.z, true, false, false)
    
    SetEntityVisible(CURRENT_OBJECT_ENTITY, true)
    SetEntityAlpha(CURRENT_OBJECT_ENTITY, 255, false)
    Citizen.InvokeNative(0x283978A15512B2FE, CURRENT_OBJECT_ENTITY, true)

    AttachEntityToEntity(CURRENT_OBJECT_ENTITY,ped,boneIndex, 0.2, 0.0, -0.2, -100.0, -50.0, 0.0, false, false, false, true, 2, true)
    TaskPlayAnim(ped, dict, "inspectfloor_player", 1.0, 8.0, -1, 1, 0, false, false, false)
end

PlayGoldpanShakeAnimation = function()
    local dict = "script_re@gold_panner@gold_success"
    RequestAnimDict(dict)
    
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), dict, "SEARCH02", 1.0, 8.0, -1, 1, 0, false, false, false)
end

LoadModel = function(inputModel)
    local model = joaat(inputModel)
 
    RequestModel(model)
 
    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(10)
    end
 end

RemoveEntityProperly = function(entity, objectHash)
    DeleteEntity(entity)
    DeletePed(entity)
    SetEntityAsNoLongerNeeded( entity )

    if objectHash then
        SetModelAsNoLongerNeeded(objectHash)
    end
end