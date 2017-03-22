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
	catherine.vgui.resource = self
	
	self.w, self.h = 300, 200
	self.x, self.y = ScrW( ) - self.w - 20, 20
	self.showing = true
	
	self:SetSize( self.w, self.h )
	self:SetPos( ScrW( ), self.y )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self:SetDrawOnTop( true )
	self:MoveTo( ScrW( ) - self.w - 20, self.y, 0.2, 0 )
	
	self.subscribe = vgui.Create( "catherine.vgui.button", self )
	self.subscribe:SetPos( self.w / 2 - ( self.w - 20 ) / 2, self.h - 50 )
	self.subscribe:SetSize( self.w - 20, 40 )
	self.subscribe:SetStr( LANG( "Resource_UI_Subscribe" ) )
	self.subscribe:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.subscribe:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.subscribe:SetStrFont( "catherine_lightUI20" )
	self.subscribe.Click = function( )
		steamworks.ViewFile( "491904294" )
		Derma_Message( LANG( "Resource_UI_SubscribeNotify" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		self:Close( )
	end
	self.subscribe.PaintOverAll = function( pnl, w, h )
		pnl:SetStr( LANG( "Resource_UI_Subscribe" ) )
		
		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
end

function PANEL:Think( )
	self:MoveToFront( )
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, 0, w, 25, Color( 255, 255, 255, 255 ) )
	
	draw.SimpleText( LANG( "Resource_UI_Title" ), "catherine_lightUI20", w / 2, 13, Color( 0, 0, 0, 255 ), 1, 1 )
	
	local wrapTexts = catherine.util.GetWrapTextData( LANG( "Resource_UI_Value" ), w - 60, "catherine_normal15" )
	
	if ( #wrapTexts == 1 ) then
		draw.SimpleText( wrapTexts[ 1 ], "catherine_normal15", w / 2, 55, Color( 255, 255, 255, 255 ), 1, 1 )
	else
		local textY = 55 - ( #wrapTexts * 20 ) / 2
		
		for k, v in pairs( wrapTexts ) do
			draw.SimpleText( v, "catherine_normal15", w / 2, textY + k * 20, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
end

function PANEL:Show( )
	if ( self.showing ) then return end
	
	self.showing = true
	
	self:SetVisible( true )
	self:MoveTo( ScrW( ) - self.w - 20, self.y, 0.2, 0 )
end

function PANEL:Hide( )
	if ( !self.showing ) then return end
	
	self.showing = false
	
	self:MoveTo( ScrW( ), self.y, 0.2, 0, nil, function( )
		self:SetVisible( false )
	end )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:MoveTo( ScrW( ), self.y, 0.2, 0, nil, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.resource", PANEL, "DFrame" )