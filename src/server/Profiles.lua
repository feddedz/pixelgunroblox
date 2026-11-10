-- Player progression: coins, owned weapons and the chosen weapon per slot.
-- Mirrored to the client through player attributes:
--   Coins, Owned_<weaponId>, Slot1..Slot5
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)
local WeaponData = require(Shared.WeaponData)

local Profiles = {}

local loaded = {} -- [player] = true once attributes are populated
local canSave = {} -- [player] = true only if the load succeeded (never overwrite on a failed load)

local store
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("BlockfireProfiles_v1")
	end)
	if ok then
		store = result
	else
		warn("[Profiles] DataStore unavailable, progress will not persist:", result)
	end
end

local function owns(player: Player, weapon): boolean
	return weapon.price == 0 or player:GetAttribute("Owned_" .. weapon.id) == true
end

function Profiles.owns(player: Player, weaponId: string): boolean
	local weapon = WeaponData.byId[weaponId]
	return weapon ~= nil and owns(player, weapon)
end

function Profiles.load(player: Player)
	local data
	local success = false
	if store then
		local ok, result = pcall(function()
			return store:GetAsync("u" .. player.UserId)
		end)
		if ok then
			success = true
			data = result
		else
			warn("[Profiles] load failed for", player.Name, result)
		end
	end
	if type(data) ~= "table" then
		data = {}
	end

	player:SetAttribute("Coins", if type(data.coins) == "number" then data.coins else Config.StartingCoins)

	if type(data.owned) == "table" then
		for _, id in data.owned do
			if type(id) == "string" and WeaponData.byId[id] then
				player:SetAttribute("Owned_" .. id, true)
			end
		end
	end

	for slot = 1, WeaponData.slotCount do
		local chosen = type(data.slots) == "table" and data.slots[slot]
		local weapon = type(chosen) == "string" and WeaponData.byId[chosen]
		if not weapon or weapon.slot ~= slot or not owns(player, weapon) then
			chosen = WeaponData.defaults[slot]
		end
		player:SetAttribute("Slot" .. slot, chosen)
	end

	loaded[player] = true
	canSave[player] = success
end

function Profiles.save(player: Player)
	if not store or not loaded[player] or not canSave[player] then
		return
	end
	local owned = {}
	local slots = {}
	for _, weapon in WeaponData.list do
		if player:GetAttribute("Owned_" .. weapon.id) then
			table.insert(owned, weapon.id)
		end
	end
	for slot = 1, WeaponData.slotCount do
		slots[slot] = player:GetAttribute("Slot" .. slot)
	end
	local payload = { coins = player:GetAttribute("Coins") or 0, owned = owned, slots = slots }
	local ok, err = pcall(function()
		store:SetAsync("u" .. player.UserId, payload)
	end)
	if not ok then
		warn("[Profiles] save failed for", player.Name, err)
	end
end

function Profiles.release(player: Player)
	Profiles.save(player)
	loaded[player] = nil
	canSave[player] = nil
end

function Profiles.addCoins(player: Player, amount: number)
	if loaded[player] then
		player:SetAttribute("Coins", (player:GetAttribute("Coins") or 0) + amount)
	end
end

-- Weapon ids the player takes into their next life, indexed by slot.
function Profiles.loadout(player: Player): { string }
	local slots = {}
	for slot = 1, WeaponData.slotCount do
		slots[slot] = player:GetAttribute("Slot" .. slot) or WeaponData.defaults[slot]
	end
	return slots
end

function Profiles.init()
	Remotes.Buy.OnServerEvent:Connect(function(player, weaponId)
		if not loaded[player] or type(weaponId) ~= "string" then
			return
		end
		local weapon = WeaponData.byId[weaponId]
		if not weapon or owns(player, weapon) then
			return
		end
		local coins = player:GetAttribute("Coins") or 0
		if coins < weapon.price then
			return
		end
		player:SetAttribute("Coins", coins - weapon.price)
		player:SetAttribute("Owned_" .. weapon.id, true)
		player:SetAttribute("Slot" .. weapon.slot, weapon.id)
	end)

	Remotes.SetLoadout.OnServerEvent:Connect(function(player, weaponId)
		if not loaded[player] or type(weaponId) ~= "string" then
			return
		end
		local weapon = WeaponData.byId[weaponId]
		if weapon and owns(player, weapon) then
			player:SetAttribute("Slot" .. weapon.slot, weapon.id)
		end
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			task.spawn(Profiles.save, player)
		end
		task.wait(2)
	end)
end

return Profiles
