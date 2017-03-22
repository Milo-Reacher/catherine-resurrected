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

local PLUGIN = PLUGIN

AddCSLuaFile( )

ENT.Type = "anim"
ENT.PrintName = "Catherine Vendor"
ENT.Author = "L7D"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if ( SERVER ) then
	function ENT:Initialize( )
		self:SetModel( "models/alyx.mdl" )
		self:SetSolid( SOLID_BBOX )
		self:PhysicsInit( SOLID_BBOX )
		self:DrawShadow( true )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( SIMPLE_USE )
		
		local physObject = self:GetPhysicsObject( )
		
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( false )
			physObject:Sleep( )
		end
		
		self:InitializeAnimation( )
	end
	
	function ENT:InitializeAnimation( )
		for k, v in pairs( self:GetSequenceList( ) ) do
			if ( !v:lower( ):find( "idle" ) or v == "idlenoise" ) then continue end
			
			self:ResetSequence( k )
			return
		end
		
		self:ResetSequence( 4 )
	end

	function ENT:Use( pl )
		local status, reason = PLUGIN:CanUseVendor( pl, self )
		
		if ( !status ) then
			if ( reason ) then
				catherine.util.NotifyLang( pl, reason )
			else
				catherine.util.NotifyLang( pl, "Vendor_Message_CantUse" )
			end
			
			return
		end
		
		local index = self:EntIndex( )
		
		pl:SetNetVar( "vendorWorkingID", index )
		netstream.Start( pl, "catherine.plugin.vendor.VendorUse", index )
	end
	
	function ENT:OnRemove( )
		if ( catherine.shuttingDown ) then return end
		
		catherine.cash.Spawn( self:GetPos( ), self:GetAngles( ), PLUGIN:GetVendorData( self, "cash", 0 ) )
	end
else
	local toscreen = FindMetaTable( "Vector" ).ToScreen
	
	function ENT:Think( )
		self:SetEyeTarget( catherine.pl:GetPos( ) )
	end
	
	function ENT:DrawEntityTargetID( pl, ent, a )
		local pos = toscreen( self:LocalToWorld( self:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( self:GetNetVar( "name", "" ), "catherine_outline20", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( self:GetNetVar( "desc", "" ), "catherine_outline15", x, y + 25, Color( 255, 255, 255, a ), 1, 1 )
	end
end