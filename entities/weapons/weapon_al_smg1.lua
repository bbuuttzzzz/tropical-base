AddCSLuaFile()
DEFINE_BASECLASS("weapon_base_tropical")

SWEP.Primary.Sound = Sound("Weapon_SMG1.Single")
SWEP.DryFireSound = Sound("Weapon_SMG1.Empty")
SWEP.ReloadSound = Sound("Weapon_SMG1.Reload")

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"

SWEP.MaxSpareAmmo = 120
SWEP.Primary.ClipSize = 30

SWEP.Primary.Damage = 5
SWEP.Primary.KnockbackScale = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.07
SWEP.Primary.Automatic = true

SWEP.ConeMax = 4.5
SWEP.ConeMin = 2.5
