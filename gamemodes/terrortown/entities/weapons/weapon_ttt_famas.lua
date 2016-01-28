AddCSLuaFile()

if CLIENT then
   SWEP.PrintName = "Famas"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_famas"
end
-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "SMG1"
-- SWEP.Primary.Delay IS NOT USED! SEE BURST FIRE SHIT BELOW! --
SWEP.Primary.Delay =  0.08 -- Vanilla 0.08, previous 0.075
SWEP.Primary.Recoil = 1.1 --1.50 -- Vanilla 0.8
SWEP.Primary.Cone = 0.020 -- 0.028 Vanilla
SWEP.Primary.Damage = 17 -- Vanilla 17
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound("Weapon_FAMAS.Single")
-- All of the burst fire shit --
SWEP.Primary.BurstShots = 3 -- Number of bullets shot each burst.
SWEP.Primary.BurstInbetweenDelay = 0.08 -- The delay that's inbetween each shot of a burst.
SWEP.Primary.BurstDelay = 0.35 -- The delay between each burst.

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.IronSightsPos = Vector( -6.24, -2.757, 1.36 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = true

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { nil }

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	local att = dmginfo:GetAttacker()
	if not IsValid(att) then return 2 end

	local dist = victim:GetPos():Distance(att:GetPos())
	local d = math.max(0, dist - 150)

	-- decay from 3.2 to 1.7
	return 1.7 + math.max(0, (1.5 - 0.002 * (d ^ 1.25)))
end

local function ClearNetVars(self)
	self:SetIronsights(false)
	self:SetBurstFiring(false)
	self:SetReloadEndTime(0.0)
	self:SetBurstShotsFired(0)
	self:SetBurstShotEndTime(0.0)
end

function SWEP:OnDrop()
	ClearNetVars(self)
end

function SWEP:Deploy()
	ClearNetVars(self)
	return true
end

function SWEP:SetupDataTables()
	-- Put it in the last slot, least likely to interfere with derived weapon's
	-- own stuff.
	self:NetworkVar("Bool",  3, "Ironsights")

	-- Set to "0.0" if not reloading. Set to "Current time + (reload animation length)" when reloading.
	self:NetworkVar("Float", 4, "ReloadEndTime")
	-- Set to "true" if the "SWEP:Think()" function needs to do a burst fire.
	self:NetworkVar("Bool",  4, "BurstFiring")
	-- The number of shots already fired during the current burst. "0" no shots have been shot yet.
	self:NetworkVar("Int",   4, "BurstShotsFired")
	-- The time that the current shot being fired in the burst will be finished.
	self:NetworkVar("Float", 5, "BurstShotEndTime")
end

function SWEP:GetRandomViewpunchAngle()
	local recoil = self.Primary.Recoil
	local pitch  = math.Rand(-0.2, -0.1)
	local yaw    = math.Rand(-0.1,  0.1)
	local roll   = 0 --math.Rand(-0.3,  0.3) -- Roll is fun.

	return Angle(pitch * recoil, yaw * recoil, roll)
end

function SWEP:Reload()
	if self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then return end

	self:SetIronsights(false)
	self:DefaultReload(self.ReloadAnim)
	-- Set the time the reloading will end for the SWEP:Think() function.
	self:SetReloadEndTime(CurTime() + self:SequenceDuration(self.ReloadAnim))
	self:SetBurstShotsFired(0)
	self:SetBurstFiring(false)
	self:SetBurstShotEndTime(0.0)
end

function SWEP:Think()
	-- Deal with reloading shit.
	if self:GetReloadEndTime() ~= 0.0 then
		if self:GetReloadEndTime() <= CurTime() then
			self:SetReloadEndTime(0.0)
		else -- Still reloading, so let's return.
			return
		end
	end

	if not self:GetBurstFiring() then return end

	-- If not shot has been fired (BurstShotEndTime = 0.0) or our current
	-- shot's end-time has been passed.
	if self:GetBurstShotEndTime() <= CurTime() then
		local shotsFired = self:GetBurstShotsFired()
		if shotsFired >= self.Primary.BurstShots then
			-- Since we've fired all of our shots, we clean up.
			self:SetBurstShotsFired(0)
			self:SetBurstShotEndTime(0.0)
			self:SetBurstFiring(false)
			-- Delay until the next burst.
			self:SetNextSecondaryFire(CurTime() + self.Primary.BurstDelay)
			self:SetNextPrimaryFire(CurTime() + self.Primary.BurstDelay)
		elseif self:CanPrimaryAttack() then -- We still have shots to fire.
			self:FireShot()
			self:SetBurstShotsFired(shotsFired + 1)
			self:SetBurstShotEndTime(CurTime() + self.Primary.BurstInbetweenDelay)
		end
	end
end

function SWEP:PrimaryAttack(worldsnd)
	-- Let the "SWEP:Think()" function deal with the burst firing.
	if self:GetBurstFiring() then return end

	-- *click*
	if not self:CanPrimaryAttack() then
		self:SetNextSecondaryFire(CurTime() + self.Primary.BurstDelay)
		self:SetNextPrimaryFire(CurTime() + self.Primary.BurstDelay)
		return
	end

	self:SetBurstFiring(true)
end

-- This is basically the default TTT SWEP:PrimaryAttack() function.
function SWEP:FireShot(worldsnd)
	if not self:CanPrimaryAttack() then return end

	-- No idea where "worldsnd" is retrieved from...
	if not worldsnd then
		self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end

	self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
	self:TakePrimaryAmmo(1)

	local owner = self.Owner
	if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

	owner:ViewPunch(self:GetRandomViewpunchAngle())
end