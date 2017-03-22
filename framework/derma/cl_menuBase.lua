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
	self.w = ScrW( ) * 0.5
	self.h = ScrH( ) * 0.5
	self.name = "MENU"
	self.player = catherine.pl
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.3, 0 )
	
	self:PanelCalled( )
end

function PANEL:OnMenuSizeChanged( w, h ) end
function PANEL:PanelCalled( ) end
function PANEL:OnMenuRecovered( ) end

function PANEL:SetMenuSize( w, h )
	self.w, self.h = w, h
	
	self:SetSize( w, h )
	self:Center( )
	self:MoveTo( ScrW( ) / 2 - self.w / 2, ( ScrH( ) + 45 ) / 2 - self.h / 2, 0.2, 0 )
	
	self:OnMenuSizeChanged( w, h )
end

function PANEL:SetMenuName( name )
	self.name = name
end

function PANEL:IsHiding( )
	return self.isHiding
end

function PANEL:FakeHide( )
	if ( self.isHiding ) then return end
	self.isHiding = true
	self:MoveTo( ScrW( ) / 2 - self.w / 2, ScrH( ), 0.2, 0, nil, function( )
		self:SetVisible( false )
	end )
end

function PANEL:Show( )
	//if ( !self.isHiding ) then return end -- Why? -_-
	local w, h = self:GetWide( ), self:GetTall( )
	
	self.isHiding = false
	self:SetVisible( true )
	self:MoveTo( ScrW( ) / 2 - self.w / 2, ( ScrH( ) + 45 ) / 2 - self.h / 2, 0.2, 0 )
end

function PANEL:MenuPaint( w, h ) end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, 0, w, 25, Color( 255, 255, 255, 255 ) )
	
	draw.SimpleText( self.name:upper( ), "catherine_lightUI20", 10, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
	
	self:MenuPaint( w, h )
end

function PANEL:Close( )
	self:MoveTo( ScrW( ) / 2 - self.w / 2, ScrH( ), 0.2, 0, nil, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.menuBase", PANEL, "DFrame" )