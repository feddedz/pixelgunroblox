-- Builds a blocky weapon model from the part list in WeaponData.
-- The invisible "Handle" sits at the grip; the barrel points down -Z.
local GunModel = {}

function GunModel.build(weapon, anchored: boolean): Model
	local model = Instance.new("Model")
	model.Name = weapon.id

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 0.2, 0.2)
	handle.Transparency = 1
	handle.Parent = model
	model.PrimaryPart = handle

	local parts = { handle }
	for index, spec in weapon.model do
		local part = Instance.new("Part")
		part.Name = "Block" .. index
		part.Size = spec.size
		part.CFrame = CFrame.new(spec.pos)
		part.Color = spec.color
		part.Material = spec.material or Enum.Material.SmoothPlastic
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		table.insert(parts, part)
	end

	for _, part in parts do
		part.Anchored = anchored
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
		part.CastShadow = false
		if not anchored and part ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = part
			weld.Parent = part
		end
	end

	return model
end

return GunModel
