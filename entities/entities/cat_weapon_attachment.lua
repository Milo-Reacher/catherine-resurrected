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
	This entity reference LauScript's Attachment Plugin.
	Thanks :)
	
	https://github.com/Chessnut/NutScript/tree/master/plugins/attachments
]]--

AddCSLuaFile( )

ENT.Type = "anim"
ENT.PrintName = "Catherine Weapon Attachment"
ENT.Author = "LauScript"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables( )
	self:NetworkVar( "Vector", 0, "AttachmentOffSet" )
	self:NetworkVar( "Angle", 0, "AttachmentAngles" )
	self:NetworkVar( "Entity", 0, "AttachmentParent" )
	self:NetworkVar( "Int", 0, "AttachmentBoneIndex" )
	self:NetworkVar( "String", 0, "AttachmentWeaponClass" )
end

if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( "models/props_junk/watermelon01.mdl" )
		self:SetSolid( SOLID_NONE )
		self:PhysicsInit( SOLID_NONE )
		self:SetMoveType( SOLID_NONE )
		self:DrawShadow( false )
		
		local physObject = self:GetPhysicsObject( )
		
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
	end
else
	function ENT:Think( )
		local pos, ang = self:GetAttachmentPos( )
		
		self:SetPos( pos )
		self:SetAngles( ang )
	end
	
	function ENT:Draw( )
		local lp = catherine.pl
		local pl = self:GetAttachmentParent( )
		local wep = pl:GetActiveWeapon( )

		if ( pl:IsNoclipping( ) or lp == pl and !lp:ShouldDrawLocalPlayer( ) ) then
			return
		end
		
		if ( IsValid( wep ) ) then
			if ( wep:GetClass( ) == self:GetAttachmentWeaponClass( ) or !pl:Alive( ) ) then
				return
			end
			
			self:DrawModel( )
		end
	end
end

function ENT:GetAttachmentPos( )
	local pos = self:GetAttachmentOffSet( )
	local ang = self:GetAttachmentAngles( )
	local parent = self:GetAttachmentParent( )
	local boneIndex = self:GetAttachmentBoneIndex( )
	
	if ( pos and ang and parent and boneIndex ) then
		local bonePos, boneAng = parent:GetBonePosition( boneIndex )
		
		if ( !bonePos or !boneAng ) then return pos, ang end
		
		local x, y, z = boneAng:Up( ) * pos.x, boneAng:Right( ) * pos.y, boneAng:Forward( ) * pos.z
		
		boneAng:RotateAroundAxis( boneAng:Forward( ), ang.p )
		boneAng:RotateAroundAxis( boneAng:Right( ), ang.y )
		boneAng:RotateAroundAxis( boneAng:Up( ), ang.r )
		
		return bonePos + x + y + z, boneAng
	end
end