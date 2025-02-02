local TPZInv = exports.tpz_inventory:getInventoryAPI() -- Getting the inventory API Functions.

local ListedPlayers = {}

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

-- @param source     - returns the player source.
-- @param item       - returns the item name.
-- @param itemId     - returns the itemId (itemId exists only for non-stackable items) otherwise it will return as "0"
-- @param id         - returns the item id which is located in the tpz_items table.
-- @param label      - returns the item label name.
-- @param weight     - returns the item weight.
-- @param durability - returns the durability (exists only for non-stackable items).
-- @param metadata   - returns the metadata that you have created on the given item.

TPZInv.registerUsableItem(Config.GoldPanItem, "tpz_goldpanning", function(data)
	local _source = data.source

 if ListedPlayers[_source] then
     SendNotification(_source, Locales['GOLDPAN_IN_PROGRESS'], "error")
     return
 end

	if data.durability <= 0 and Config.Durability.Enabled then
	    SendNotification(_source, Locales['NO_DURABILITY'], "error")
	    return
	end

 ListedPlayers[_source] = true
		
	TriggerClientEvent('tpz_goldpanning:client:startPanning', _source)
	
 if Config.Durability.Enabled then
     TPZInv.removeItemDurability(_source, Config.GoldPanItem, Config.Durability.RemoveValue, data.itemId, false)
 end

	--TPZInv.closeInventory(_source)  -- This is not required since we have already set it as closeInventory = true  from database `tpz_items` table.
end)
 
-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_goldpanning:server:onRandomReward")
AddEventHandler("tpz_goldpanning:server:onRandomReward", function()
    local _source = source 

    if ListedPlayers[_source] then
        -- devtools
        return
    end

    math.randomseed(os.time()) -- required to refresh the random.math for better results. 

    local randomRewardCount = math.random(Config.Reward.ReceiveValue.min, Config.Reward.ReceiveValue.max)
    local canCarryItem       = TPZInv.canCarryItem(_source, Config.Reward.Item, randomRewardCount)

    Wait(500)

    if canCarryItem then

        TPZInv.addItem(_source, Config.Reward.Item, randomRewardCount)

        SendNotification(_source, string.format(Locales['SUCCESSFULLY_FOUND'], randomRewardCount), "success")
        
    else
        SendNotification(_source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], "error")
    end

    ListedPlayers[_source] = nil

end)
