-- Replicated match state. Clients read the attributes on this folder and the
-- per-combatant score folders under Match.Scores.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local folder = Instance.new("Folder")
folder.Name = "Match"
folder:SetAttribute("State", "Loading") -- Loading | Playing | Intermission
folder:SetAttribute("EndsAt", 0) -- workspace:GetServerTimeNow() timestamp
folder:SetAttribute("MapName", "")
folder:SetAttribute("Winner", "")
folder:SetAttribute("KillTarget", Config.KillTarget)

local scores = Instance.new("Folder")
scores.Name = "Scores"
scores.Parent = folder

folder.Parent = ReplicatedStorage

return { folder = folder, scores = scores }
