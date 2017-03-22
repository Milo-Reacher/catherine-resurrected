--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

--[[
	This code has brought from NutScript.
	https://github.com/Chessnut/NutScript
]]--

Weapon_HoldType = { }
Weapon_HoldType[ "" ] = "normal"
Weapon_HoldType[ "physgun" ] = "smg"
Weapon_HoldType[ "ar2" ] = "smg"
Weapon_HoldType[ "crossbow" ] = "shotgun"
Weapon_HoldType[ "rpg" ] = "shotgun"
Weapon_HoldType[ "slam" ] = "normal"
Weapon_HoldType[ "grenade" ] = "normal"
Weapon_HoldType[ "fist" ] = "normal"
Weapon_HoldType[ "melee2" ] = "melee"
Weapon_HoldType[ "passive" ] = "normal"
Weapon_HoldType[ "knife" ] = "melee"
Weapon_HoldType[ "duel" ] = "pistol"
Weapon_HoldType[ "camera" ] = "smg"
Weapon_HoldType[ "magic" ] = "normal"
Weapon_HoldType[ "revolver" ] = "pistol"

PlayerHoldType = { }
PlayerHoldType[ "" ] = "normal"
PlayerHoldType[ "fist" ] = "normal"
PlayerHoldType[ "pistol" ] = "normal"
PlayerHoldType[ "grenade" ] = "normal"
PlayerHoldType[ "melee" ] = "normal"
PlayerHoldType[ "slam" ] = "normal"
PlayerHoldType[ "melee2" ] = "normal"
PlayerHoldType[ "passive" ] = "normal"
PlayerHoldType[ "knife" ] = "normal"
PlayerHoldType[ "duel" ] = "normal"
PlayerHoldType[ "bugbait" ] = "normal"

local twoD = FindMetaTable( "Vector" ).Length2D
local normalHoldTypes = {
	normal = true,
	fist = true,
	melee = true,
	revolver = true,
	pistol = true,
	slam = true,
	knife = true,
	grenade = true
}
WEAPON_LOWERED = 1
WEAPON_RAISED = 2

function GM:CalcMainActivity( pl, velo )
	local mdl = pl:GetModel( ):lower( )
	local class = catherine.animation.Get( mdl )
	local wep = pl:GetActiveWeapon( )
	local holdType = "normal"
	local status = WEAPON_LOWERED
	local act = "idle"
	
	if ( twoD( velo ) >= catherine.configs.playerDefaultRunSpeed - 10 ) then
		act = "run"
	elseif ( twoD( velo ) >= 5 ) then
		act = "walk"
	end
	
	if ( IsValid( wep ) ) then
		holdType = catherine.util.GetHoldType( wep )
		
		if ( wep.AlwaysRaised or catherine.configs.alwaysRaised[ wep:GetClass( ) ] ) then
			status = WEAPON_RAISED
		end
	end
	
	if ( pl:GetWeaponRaised( ) ) then
		status = WEAPON_RAISED
	end
	
	if ( mdl:find( "/player" ) or mdl:find( "/playermodel" ) or class == "player" ) then
		local calcIdle, calcOver = self.BaseClass:CalcMainActivity( pl, velo )
		
		if ( status == WEAPON_LOWERED ) then
			if ( pl:Crouching( ) ) then
				act = act.."_crouch"
			end
			
			if ( !pl:OnGround( ) ) then
				act = "jump"
			end
			
			if ( !normalHoldTypes[ holdType ] ) then
				calcIdle = _G[ "ACT_HL2MP_" .. act:upper( ) .. "_PASSIVE" ]
			else
				calcIdle = act == "jump" and ACT_HL2MP_JUMP_PASSIVE or _G[ "ACT_HL2MP_" .. act:upper( ) ]
			end
		end
		
		pl.CalcIdle = calcIdle
		pl.CalcOver = calcOver
		
		return pl.CalcIdle, pl.CalcOver
	end
	
	if ( pl:IsCharacterLoaded( ) and pl:Alive( ) ) then
		pl.CalcOver = -1
		
		if ( pl:Crouching( ) ) then
			act = act .. "_crouch"
		end
		
		local aniClass = catherine.animation[ class ]
		
		if ( !aniClass ) then
			class = "citizen_male"
		end
		
		if ( !aniClass[ holdType ] ) then
			holdType = "normal"
		end
		
		if ( !aniClass[ holdType ][ act ] ) then
			act = "idle"
		end
		
		local ani = aniClass[ holdType ][ act ]
		local val = ACT_IDLE
		
		if ( !pl:OnGround( ) ) then
			pl.CalcIdle = aniClass.glide or ACT_GLIDE
		elseif ( pl:InVehicle( ) ) then
			local vehicleTable = aniClass.vehicle
			local vehicle = pl:GetVehicle( )
			local class = vehicle:IsChair( ) and "chair" or vehicle:GetClass( )
			
			if ( vehicleTable and vehicleTable[ class ] ) then
				local act = vehicleTable[ class ][ 1 ]
				local posFix = vehicleTable[ class ][ 2 ]
				
				pl:ManipulateBonePosition( 0, posFix )
				
				if ( act ) then
					if ( type( act ) == "string" ) then
						pl.CalcOver = pl:LookupSequence( vehicleTable[ class ][ 1 ] )
					else
						pl.CalcIdle = act
					end
				end
			end
		elseif ( ani ) then
			pl:ManipulateBonePosition( 0, vector_origin )
			
			val = ani[ status ]
			
			if ( type( val ) == "string" ) then
				pl.CalcOver = pl:LookupSequence( val )
			else
				pl.CalcIdle = val
			end
		end
		
		local seqAni = pl:GetNetVar( "seqAni" )
		
		if ( seqAni ) then
			pl.CalcOver = pl:LookupSequence( seqAni )
		end
		
		if ( CLIENT ) then
			pl:SetIK( false )
		end
		
		pl:SetPoseParameter( "move_yaw", math.NormalizeAngle( velo:Angle( ).yaw - pl:EyeAngles( ).y ) )
		
		return pl.CalcIdle or ACT_IDLE, pl.CalcOver or -1
	end
end

function GM:PlayerCanNoClip( pl, status )
	if ( pl:IsRagdolled( ) ) then
		return false
	end
end

function GM:PlayerNoClip( pl, status )
	local force = hook.Run( "PlayerCanNoClip", pl, status )
	local isAdmin = pl:IsAdmin( )
	
	if ( !isAdmin or force == false ) then
		if ( force == false ) then
			return false
		else
			return isAdmin
		end
	end
	
	if ( pl:GetMoveType( ) == MOVETYPE_WALK ) then
		pl:SetNotSolid( true )
		pl:SetNoDraw( true )
		pl:DrawShadow( false )
		pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		
		if ( SERVER ) then
			pl:SetNoTarget( true )
			pl:DrawWorldModel( false )
			pl:SetNetVar( "nocliping", true )
			
			if ( pl:HasGodMode( ) ) then
				pl.CAT_godmodeAlready = true
			else
				pl:GodEnable( )
			end
		end
		
		hook.Run( "PlayerNoclipJoined", pl )
	else
		pl:SetNotSolid( false )
		pl:SetNoDraw( false )
		pl:DrawShadow( true )
		pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		
		if ( SERVER ) then
			pl:SetNoTarget( false )
			pl:DrawWorldModel( true )
			pl:SetNetVar( "nocliping", false )
			
			if ( !pl.CAT_godmodeAlready ) then
				pl:GodDisable( )
				pl.CAT_godmodeAlready = nil
			end
		end
		
		hook.Run( "PlayerNoclipExited", pl )
	end
	
	return true
end

function GM:DoAnimationEvent( pl, eve, data )
	local mdl = pl:GetModel( ):lower( )
	local class = catherine.animation.Get( mdl )
	
	if ( mdl:find( "/player/" ) or mdl:find( "/playermodel" ) or class == "player" ) then
		return self.BaseClass:DoAnimationEvent( pl, eve, data )
	end
	
	local wep = pl:GetActiveWeapon( )
	local holdType = "normal"
	
	if ( !catherine.animation[ class ] ) then
		class = "citizen_male"
	end
	
	if ( IsValid( wep ) ) then
		holdType = catherine.util.GetHoldType( wep )
	end	
	
	if ( !catherine.animation[ class ][ holdType ] ) then
		holdType = "normal"
	end
	
	local ani = catherine.animation[ class ][ holdType ]
	
	if ( eve == PLAYERANIMEVENT_ATTACK_PRIMARY ) then
		pl:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ani.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true )
		
		return ACT_VM_PRIMARYATTACK
	elseif ( eve == PLAYERANIMEVENT_ATTACK_SECONDARY ) then
		pl:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ani.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true )
		
		return ACT_VM_SECONDARYATTACK
	elseif ( eve == PLAYERANIMEVENT_RELOAD ) then
		pl:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ani.reload or ACT_GESTURE_RELOAD_SMG1, true )
		
		return ACT_INVALID
	elseif ( eve == PLAYERANIMEVENT_CANCEL_RELOAD ) then
		pl:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		
		return ACT_INVALID
	end
	
	return nil
end

local KEY_BLACKLIST = IN_ATTACK + IN_ATTACK2

function GM:StartCommand( pl, cmd )
	if ( !pl:GetWeaponRaised( ) or pl:IsTied( ) ) then
		local wep = pl:GetActiveWeapon( )
		
		if ( IsValid( wep ) and wep.CanFireLowered ) then
			return
		end
		
		cmd:RemoveKey( KEY_BLACKLIST )
	end
end

function GM:PlayerShouldThrowPunch( pl )
	if ( pl:GetWeaponRaised( ) ) then
		return true
	else
		return false
	end
end

function GM:GetPlayerInformation( pl, target, isFull )
	if ( pl == target ) then
		return pl:Name( ), pl:Desc( )
	end
	
	if ( pl:IsKnow( target ) ) then
		return target:Name( ), target:Desc( )
	end
	
	return hook.Run( "GetUnknownTargetName", pl, target ),
	isFull and target:Desc( ) or ( target:Desc( ):utf8sub( 1, 37 ) .. "..." )
end