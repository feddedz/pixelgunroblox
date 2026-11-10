-- Tunable game settings shared by server and client.
return {
	GameName = "Blockfire Arena",

	-- Match flow
	RoundLength = 300, -- seconds
	KillTarget = 25,
	Intermission = 12,
	RespawnDelay = 3,
	SpawnProtection = 2.5,

	-- Characters
	MaxHealth = 100,
	MaxArmor = 100,
	ArmorAbsorb = 0.5, -- share of incoming damage armor soaks up
	JumpPower = 52,
	Fov = 75,

	-- Economy
	StartingCoins = 150,
	Rewards = { Kill = 10, Headshot = 5, Win = 30, Participation = 5 },

	-- Pickups
	PickupRespawn = 20,
	PickupHealth = 50,
	PickupArmor = 50,

	-- Bots fill the server up to this many combatants (players + bots).
	MinCombatants = 5,
	BotDamageScale = 0.55,
	BotAimError = 4.5, -- degrees
	BotReaction = 0.45, -- seconds between seeing a target and shooting
	BotSightRange = 140,

	-- Sound asset ids (rbxassetid://...). Left empty on purpose: drop in ids
	-- you own and the effects module starts playing them.
	Sounds = {
		Shot = "",
		Melee = "",
		Reload = "",
		Hit = "",
		Kill = "",
		Explosion = "",
		Pickup = "",
	},
}
