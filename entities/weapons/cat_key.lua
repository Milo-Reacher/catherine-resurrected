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

AddCSLuaFile( )

SWEP.HoldType = "normal"
SWEP.PrintName = "^Weapon_Key_Name"
SWEP.Instructions = "^Weapon_Key_Instructions"
SWEP.Purpose = "^Weapon_Key_Purpose"
SWEP.Author = "L7D"
SWEP.ViewModel = Model( "models/weapons/c_arms_cstrike.mdl" )
SWEP.WorldModel = ""
SWEP.IsAlwaysLowered = true
SWEP.CanFireLowered = true
SWEP.DrawHUD = false

function SWEP:Deploy( )
	if ( CLIENT or !IsValid( self.Owner ) ) then return true end
	local pl = self.Owner
	
	pl:DrawWorldModel( false )
	pl:DrawViewModel( false )
	
	return true
end

function SWEP:Initialize( )
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( )
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	
	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 40
	data.filter = pl
	local ent = util.TraceLine( data ).Entity

	if ( !IsValid( ent ) or !ent:IsDoor( ) or ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	
	if ( !has or flag == 0 ) then return end
	
	pl.CAT_keyCallerID = pl:GetCharacterID( )
	pl:Freeze( true )

	catherine.util.ProgressBar( pl, "^Door_Message_Locking", hook.Run( "GetLockTime", pl ) or 2, function( )
		if ( !IsValid( pl ) or !pl:Alive( ) or pl:IsRagdolled( ) or pl:IsTied( ) or pl.CAT_keyCallerID != pl:GetCharacterID( ) ) then
			pl.CAT_keyCallerID = nil
			pl:Freeze( false )
			return
		end
		
		if ( IsValid( ent ) ) then
			ent.CAT_doorLocked = true
			ent:Fire( "Lock" )
			ent:EmitSound( "doors/door_latch3.wav" )
		end
		
		pl.CAT_keyCallerID = nil
		pl:Freeze( false )
		
		hook.Run( "DoorLocked", pl, ent )
	end )

	self:SetNextPrimaryFire( CurTime( ) + 4 )
end

function SWEP:SecondaryAttack( )
	if ( !IsFirstTimePredicted( ) or CLIENT ) then return end
	local pl = self.Owner
	
	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 40
	data.filter = pl
	local ent = util.TraceLine( data ).Entity
	
	if ( !IsValid( ent ) or !ent:IsDoor( ) or !ent.CAT_doorLocked ) then return end
	local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
	
	if ( !has or flag == 0 ) then return end
	
	pl.CAT_keyCallerID = pl:GetCharacterID( )
	pl:Freeze( true )
	
	catherine.util.ProgressBar( pl, "^Door_Message_UnLocking", hook.Run( "GetUnlockTime", pl ) or 2, function( )
		if ( !IsValid( pl ) or !pl:Alive( ) or pl:IsRagdolled( ) or pl:IsTied( ) or pl.CAT_keyCallerID != pl:GetCharacterID( ) ) then
			pl.CAT_keyCallerID = nil
			pl:Freeze( false )
			return
		end
		
		if ( IsValid( ent ) ) then
			ent.CAT_doorLocked = false
			ent:Fire( "UnLock" )
			ent:EmitSound( "doors/door_latch3.wav" )
		end
		
		pl.CAT_keyCallerID = nil
		pl:Freeze( false )
		
		hook.Run( "DoorUnLocked", pl, ent )
	end )
	
	self:SetNextSecondaryFire( CurTime( ) + 4 )
end

if ( CLIENT ) then
	function SWEP:PreDrawViewModel( viewMdl, wep, pl )
		if ( IsValid( viewMdl ) and !viewMdl:GetNoDraw( ) ) then
			viewMdl:SetNoDraw( true )
		end
	end
end