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

local PANEL = { }

function PANEL:Init( )
	hook.Run( "RPInformationMenuJoined", catherine.pl, self )
	
	catherine.vgui.information = self
	
	self.player = catherine.pl
	self.w, self.h = ScrW( ), ScrH( )
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	self.blurAmount = 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:MakePopup( )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.3, 0 )
	
	self.limbBaseMaterial = Material( "CAT/limb/body.png", "smooth" )
	
	local limbBaseMaterial_w, limbBaseMaterial_h = 150, 341
	
	if ( self.limbBaseMaterial and !self.limbBaseMaterial:IsError( ) ) then
		limbBaseMaterial_w, limbBaseMaterial_h = self.limbBaseMaterial:Width( ) / 1.7, self.limbBaseMaterial:Height( ) / 1.5 // 150, 341
	end
	
	surface.SetFont( "catherine_lightUI50" )
	local pl = catherine.pl
	local tw, th = surface.GetTextSize( pl:Name( ) )
	
	self.name = vgui.Create( "DLabel", self )
	self.name.fixed = false
	self.name:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.name:SetTextColor( Color( 255, 255, 255 ) )
	self.name:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 - 10 )
	self.name:SetFont( "catherine_lightUI50" )
	self.name:SetText( pl:Name( ) )
	self.name.PerformLayout = function( pnl )
		if ( tw > pnl:GetWide( ) ) then
			for i = 1, 7 do
				local newFontSize = math.Clamp( 50 - ( 5 * i ), 15, 50 )
				
				surface.SetFont( "catherine_lightUI" .. newFontSize )
				tw, th = surface.GetTextSize( pl:Name( ) )
				
				if ( tw <= pnl:GetWide( ) ) then
					self.name:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, newFontSize )
					self.name:SetFont( "catherine_lightUI" .. newFontSize )
					self.name:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 - newFontSize / 2 )
					self.name:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 - newFontSize / 2, 0.3, 0 )
					pnl.fixed = true
					break
				end
			end
		else
			if ( !pnl.fixed ) then
				self.name:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 - 10, 0.3, 0 )
			end
		end
	end
	
	self.desc = vgui.Create( "DLabel", self )
	self.desc:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.desc:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) )
	self.desc:SetTextColor( Color( 255, 255, 255 ) )
	self.desc:SetFont( "catherine_normal15" )
	self.desc:SetText( pl:Desc( ) )
	self.desc.PerformLayout = function( pnl )
		pnl:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ), 0.3, 0.1 )
	end
	
	self.descEnt = vgui.Create( "DTextEntry", self )
	self.descEnt:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 20 )
	self.descEnt:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + 29 / 2 )
	self.descEnt:SetFont( "catherine_normal15" )
	self.descEnt:SetText( pl:Desc( ) )
	self.descEnt:SetAlpha( 0 )
	self.descEnt:SetAllowNonAsciiCharacters( true )
	self.descEnt.Paint = function( pnl, w, h )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 45, 45, 45 ), Color( 255, 255, 255 ) )
	end
	self.descEnt.PerformLayout = function( pnl )
		pnl:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + 29 / 2, 0.3, 0.1 )
	end
	self.descEnt.OnEnter = function( pnl )
		local newDesc = pnl:GetText( )
		
		pnl:SetAlpha( 0 )
		self.desc:SetVisible( true )
		
		if ( pl:Desc( ) != newDesc ) then
			catherine.command.Run( "&uniqueID_charPhysDesc", newDesc )
			
			if ( !newDesc:find( "#" ) ) then
				if ( newDesc:utf8len( ) >= catherine.configs.characterDescMinLen and newDesc:utf8len( ) < catherine.configs.characterDescMaxLen ) then
					self.desc:SetText( newDesc )
					pnl:SetText( newDesc )
				else
					pnl:SetText( pl:Desc( ) )
				end
			else
				pnl:SetText( pl:Desc( ) )
			end
		end
	end
	self.descEnt.OnMousePressed = function( pnl )
		if ( pnl:GetAlpha( ) == 0 ) then
			self.desc:SetVisible( false )
			pnl:SetAlpha( 255 )
		end
	end
	
	self.factionName = vgui.Create( "DLabel", self )
	self.factionName:SetSize( self.w / 2 - limbBaseMaterial_w / 2 - 20, 50 )
	self.factionName:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) )
	self.factionName:SetTextColor( Color( 255, 255, 255 ) )
	self.factionName:SetFont( "catherine_normal20" )
	self.factionName:SetText( pl:FactionName( ) )
	self.factionName.PerformLayout = function( pnl )
		pnl:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ), 0.3, 0.2 )
	end
	
	local classTable = catherine.class.FindByIndex( pl:Class( ) )
	
	if ( classTable and classTable.name and classTable.showInUI ) then
		self.factionName:SetText( pl:FactionName( ) .. " : " .. catherine.util.StuffLanguage( classTable.name ) )
	end
	
	local defAng = Angle( 0, 45, 0 )
	
	self.playerModel = vgui.Create( "DModelPanel", self )
	self.playerModel:SetSize( 150, 150 )
	self.playerModel:SetPos( 0 - self.playerModel:GetWide( ), self.h / 2 - limbBaseMaterial_h / 2 )
	self.playerModel:MoveTo( self.w / 2 - limbBaseMaterial_w / 2 - 40 - self.playerModel:GetWide( ), self.h / 2 - limbBaseMaterial_h / 2, 0.3, 0 )
	self.playerModel:MoveToBack( )
	self.playerModel:SetModel( pl:GetModel( ) )
	self.playerModel:SetDrawBackground( false )
	self.playerModel:SetDisabled( true )
	self.playerModel:SetFOV( 15 )
	self.playerModel:SetLookAt( Vector( 0, 0, 65 ) )
	self.playerModel.LayoutEntity = function( pnl, ent )
		draw.RoundedBox( 0, 0, 0, pnl:GetWide( ), pnl:GetTall( ), Color( 255, 255, 255, 255 ) )
		
		local boneIndex = ent:LookupBone( "ValveBiped.Bip01_Head1" )
		local entMin, entMax = ent:GetRenderBounds( )
		local convertBodyGroup = { }
		
		for k, v in pairs( pl:GetBodyGroups( ) ) do
			convertBodyGroup[ #convertBodyGroup + 1 ] = pl:GetBodygroup( v.id )
		end
		
		if ( boneIndex ) then
			local pos, ang = ent:GetBonePosition( boneIndex )
			
			if ( pos ) then
				pnl:SetLookAt( pos )
			end
		else
			pnl:SetLookAt( ( entMax + entMin ) / 2 )
		end
		
		--[[
			Based from
			https://github.com/Chessnut/NutScript/blob/master/gamemode/derma/cl_charmenu.lua
		]]--
		ent:SetPoseParameter( "head_pitch", gui.MouseY( ) / ScrH( ) * 80 - 40 )
		ent:SetPoseParameter( "head_yaw", ( gui.MouseX( ) / ScrW( ) - 0.75 ) * 70 + 23 )
		ent:SetAngles( defAng )
		
		ent:SetIK( false )
		ent:SetSkin( pl:GetSkin( ) or 0 )
		
		if ( #convertBodyGroup > 0 ) then
			ent:SetBodyGroups( table.concat( convertBodyGroup, "" ) )
		end
		
		pnl:RunAnimation( )
	end
	
	if ( IsValid( self.playerModel.Entity ) ) then
		for k, v in pairs( pl:GetMaterials( ) ) do
			self.playerModel.Entity:SetSubMaterial( k - 1, pl:GetSubMaterial( k - 1 ) )
		end
		
		for k, v in pairs( self.playerModel.Entity:GetSequenceList( ) ) do
			if ( v:find( "idle" ) ) then
				local seq = self.playerModel.Entity:LookupSequence( v )
				self.playerModel.Entity:SetSequence( seq )
				
				break
			end
		end
	end
	
	self.rpInformations = vgui.Create( "DPanelList", self )
	self.rpInformations.init = false
	self.rpInformations:SetSpacing( 5 )
	self.rpInformations:SetPos( self.w, self.h / 2 - limbBaseMaterial_h / 2 + 20 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) + ( self.factionName:GetTall( ) / 2 ) )
	self.rpInformations:SetSize( self.w - ( self.w / 2 + limbBaseMaterial_w / 2 + 20 ) - 20, limbBaseMaterial_h - 90 )
	self.rpInformations:EnableHorizontal( false )
	self.rpInformations:EnableVerticalScrollbar( true )
	self.rpInformations:MoveTo( self.w / 2 + limbBaseMaterial_w / 2 + 20, self.h / 2 - limbBaseMaterial_h / 2 + 20 + ( self.name:GetTall( ) / 2 ) + ( self.desc:GetTall( ) / 2 ) + ( self.factionName:GetTall( ) / 2 ), 0.3, 0.3, nil, function( )
		local data = { }
		local delta = 0
		local rpInformation = hook.Run( "AddRPInformation", self, data, pl )
		
		for k, v in pairs( data ) do
			self:AddRPInformation( v, delta )
			
			delta = delta + 0.03
		end
	end )
end

function PANEL:AddRPInformation( text, delta )
	local panel = vgui.Create( "DPanel" )
	panel:SetSize( self.rpInformations:GetWide( ), 15 )
	panel:SetAlpha( 0 )
	panel:AlphaTo( 255, 0.2, delta )
	panel.Paint = function( pnl, w, h )
		draw.SimpleText( text, "catherine_normal15", 0, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	end
	
	self.rpInformations:AddItem( panel )
end

function PANEL:Paint( w, h )
	hook.Run( "PreRPInformationPaint", self, w, h )
	
	if ( !self.closing ) then
		self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
	end
	
	draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 100 ) )
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
	local limbBaseMaterial_w, limbBaseMaterial_h = 150, 341
	
	if ( self.limbBaseMaterial and !self.limbBaseMaterial:IsError( ) ) then
		limbBaseMaterial_w, limbBaseMaterial_h = self.limbBaseMaterial:Width( ) / 1.7, self.limbBaseMaterial:Height( ) / 1.5
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.limbBaseMaterial )
		surface.DrawTexturedRect( w / 2 - limbBaseMaterial_w / 2, h / 2 - limbBaseMaterial_h / 2, limbBaseMaterial_w, limbBaseMaterial_h )
		
		for k, v in pairs( catherine.limb.GetTable( ) ) do
			local mat = catherine.limb.materials[ k ]
			
			if ( mat ) then
				surface.SetDrawColor( catherine.limb.GetColor( v ) )
				surface.SetMaterial( mat )
				surface.DrawTexturedRect( w / 2 - limbBaseMaterial_w / 2, h / 2 - limbBaseMaterial_h / 2, limbBaseMaterial_w, limbBaseMaterial_h )
			end
		end
	end
	
	if ( catherine.configs.enable_rpTime ) then
		draw.SimpleText( catherine.environment.GetDateString( ), "catherine_lightUI50", w / 2, h / 2 - limbBaseMaterial_h / 2 - 60, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( catherine.environment.GetTimeString( ), "catherine_lightUI30", w / 2, h / 2 - limbBaseMaterial_h / 2 - 30, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	
	hook.Run( "PostRPInformationPaint", self, w, h )
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_F1 and !self.closing ) then
		self:Close( )
	end
end

function PANEL:Close( )
	if ( self.closing ) then
		timer.Remove( "Catherine.timer.F1MenuFix" )
		timer.Create( "Catherine.timer.F1MenuFix", 0.2, 1, function( )
			if ( IsValid( self ) ) then
				self:Remove( )
				self = nil
			end
		end )
		
		return
	end
	
	self.closing = true
	
	self:AlphaTo( 0, 0.3, 0, function( )
		hook.Run( "RPInformationMenuExited", self.player )
		
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.information", PANEL, "DFrame" )