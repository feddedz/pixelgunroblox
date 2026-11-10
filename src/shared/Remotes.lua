-- Creates the RemoteEvents on the server and waits for them on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NAMES = {
	-- client -> server
	"Fire", -- weaponId, origin, direction, seed, ads
	"Reload", -- weaponId
	"Equip", -- weaponId
	"Buy", -- weaponId
	"SetLoadout", -- weaponId
	-- server -> client
	"Loadout", -- { slots = {id...}, ammo = {[id] = {mag, reserve}} }
	"AmmoSync", -- {[id] = {mag, reserve}}
	"ShotFx", -- shooterKey, weaponId, origin, endpoints
	"ProjectileFx", -- projectileKey, shooterKey, weaponId, origin, direction
	"Explosion", -- projectileKey, position, radius
	"HitConfirm", -- damage, headshot, killed
	"Damaged", -- sourcePosition
	"KillFeed", -- killerName?, victimName, weaponName?, headshot
}

local Remotes = {}

if RunService:IsServer() then
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in NAMES do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		Remotes[name] = remote
	end
	folder.Parent = ReplicatedStorage
else
	local folder = ReplicatedStorage:WaitForChild("Remotes")
	for _, name in NAMES do
		Remotes[name] = folder:WaitForChild(name)
	end
end

return Remotes
