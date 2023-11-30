TPZInv = exports.tpz_inventory:getInventoryAPI() -- Getting the inventory API Functions.

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

	TriggerClientEvent('tpz_goldpanning:startPanning', _source)

	TPZInv.removeItemDurability(_source, Config.GoldPanItem, Config.DurabilityRemove, data.itemId, false)
	--TPZInv.closeInventory(_source)  -- This is not required since we have already set it as closeInventory = true  from database `tpz_items` table.
end)

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_goldpanning:onRandomReward")
AddEventHandler("tpz_goldpanning:onRandomReward", function()
    local _source           = source 

    local randomRewardCount = math.random(Config.Reward.randomQuantity.min, Config.Reward.randomQuantity.max)
	local canCarryItem      = TPZInv.canCarryItem(_source, Config.Reward.item, randomRewardCount)

    Wait(500)

    if canCarryItem then

        TPZInv.addItem(_source, rewardData.item, randomRewardCount)

        SendNotification(_source, string.format(Locales['SUCCESSFULLY_FOUND'], randomRewardCount), "success")
        
    else
        SendNotification(_source, Locales['NOT_ENOUGH_INVENTORY_WEIGHT'], "error")
    end
end)
