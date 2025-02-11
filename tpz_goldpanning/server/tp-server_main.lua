local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI() -- Getting the inventory API Functions.

local ListedPlayers = {}

-----------------------------------------------------------
--[[ Local Functions  ]]--
-------------------------------------------------------------

local function GetPlayerData(source)
	local _source = source
    local xPlayer = TPZ.GetPlayer(_source)

	return {
        steamName      = GetPlayerName(_source),
        username       = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName(),
		identifier     = xPlayer.getIdentifier(),
        charIdentifier = xPlayer.getCharacterIdentifier(),
	}

end

local IsWaterSource = function(currentWaterId)

    for k,v in pairs(Config.WaterTypes) do
        if currentWaterId == Config.WaterTypes[k]["waterhash"] then
            return true
        end
    end

    return false

end

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

TPZInv.registerUsableItem(Config.GoldPanItem, "tpz_goldpanning", function(data)
	local _source = data.source

    ListedPlayers[_source] = nil

	if data.durability <= 0 and Config.Durability.Enabled then
	    SendNotification(_source, Locales['NO_DURABILITY'], "error")
	    return
	end

	TriggerClientEvent('tpz_goldpanning:client:startPanning', _source)
	
    if Config.Durability.Enabled then
        math.randomseed(os.time()) -- required to refresh the random.math for better results. 
        local randomValueRemove = math.random(Config.Durability.RemoveValue.min, Config.Durability.RemoveValue.max)
			
        TPZInv.removeItemDurability(_source, Config.GoldPanItem, randomValueRemove, data.itemId, false)
    end

end)
-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------
 
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
      
    ListedPlayers = nil -- clearing all data
end)

AddEventHandler('playerDropped', function (reason, resourceName, reason)
    ListedPlayers[source] = nil -- removing player source in case he is listed (crashed?)
end)

-------------------------------------------------------------
--[[ Events  ]]--
-------------------------------------------------------------

RegisterServerEvent("tpz_goldpanning:server:onRandomReward")
AddEventHandler("tpz_goldpanning:server:onRandomReward", function(waterHashId)
    local _source          = source 
    local PlayerData       = GetPlayerData(_source)
    local xPlayer          = TPZ.GetPlayer(_source)

    local foundWaterSource = IsWaterSource(waterHashId)

    if ListedPlayers[_source] or not foundWaterSource then

        if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then
            local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
            local description = 'The specified user attempted to use devtools / injection or netbug cheat on gold panning reward.'
            TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], _source, PlayerData.steamName, PlayerData.username, PlayerData.identifier, PlayerData.charIdentifier, description, _c)
        end

        ListedPlayers[_source] = nil
        xPlayer.disconnect(Locales['DEVTOOLS_INJECTION_DETECTED'])
        return
    end

    ListedPlayers[_source] = true

    math.randomseed(os.time()) -- required to refresh the random.math for better results. 

    local randomRewardCount = math.random(Config.Reward.ReceiveValue.min, Config.Reward.ReceiveValue.max)
    local canCarryItem      = xPlayer.canCarryItem(Config.Reward.Item, randomRewardCount)

    Wait(500)

    if canCarryItem then

        xPlayer.addItem(Config.Reward.Item, randomRewardCount)

        SendNotification(_source, string.format(Locales['SUCCESSFULLY_FOUND'], randomRewardCount), "success")
        
    else
        SendNotification(_source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], "error")
    end

    -- there is no chance winning the skillcheck within 5 seconds, 
    -- there are also animations at start, within those seconds, the player should
    -- do animations, its 100% devtools. 
    Wait(5000)  
    ListedPlayers[_source] = nil

end)
