-- Deterministic spread. Client and server call this with the same seed so the
-- tracers a shooter sees match the rays the server actually casts.
local Ballistics = {}

function Ballistics.directions(direction: Vector3, weapon, seed: number, ads: boolean): { Vector3 }
	local rng = Random.new(seed)
	local spread = math.rad(if ads then weapon.adsSpread else weapon.spread)
	local base = CFrame.lookAt(Vector3.zero, direction)
	local result = table.create(weapon.pellets)
	for i = 1, weapon.pellets do
		local roll = rng:NextNumber(0, math.pi * 2)
		local angle = spread * math.sqrt(rng:NextNumber())
		result[i] = (base * CFrame.Angles(0, 0, roll) * CFrame.Angles(angle, 0, 0)).LookVector
	end
	return result
end

return Ballistics
