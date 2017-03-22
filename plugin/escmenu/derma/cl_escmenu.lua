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
local PANEL = { }

function PANEL:Init( )
	catherine.vgui.escmenu = self
	
	self.player = catherine.pl
	self.w, self.h = ScrW( ), ScrH( )
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	self.blurAmount = 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	self:SetDraggable( false )
	
	self.leftPanel = vgui.Create( "DPanel", self )
	self.leftPanel:SetSize( self.w * 0.3, self.h )
	self.leftPanel:SetPos( 0 - self.leftPanel:GetWide( ), 0 )
	self.leftPanel:MoveTo( 0, 0, 0.2, 0 )
	self.leftPanel.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		draw.SimpleText( GetHostName( ), "catherine_normal20", w / 2, 20, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	self.leftPanel.PerformLayout = function( )
		self.close:SetPos( 10, self.h - 50 )
		self.disconnect:SetPos( 10, self.h - 100 )
		self.classicMenu:SetPos( 10, self.h - 150 )
	end
	
	self.classicMenu = vgui.Create( "catherine.vgui.button", self.leftPanel )
	self.classicMenu:SetPos( 10, self.h - 150 )
	self.classicMenu:SetSize( self.leftPanel:GetWide( ) - 20, 40 )
	self.classicMenu:SetStr( LANG( "ESCMenu_UI_ClassicMenu" ) )
	self.classicMenu:SetStrFont( "catherine_normal20" )
	self.classicMenu:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.classicMenu:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.classicMenu.Click = function( )
		if ( self.closing ) then return end
		
		self:Close( )
		gui.ActivateGameUI( )
	end
	
	self.disconnect = vgui.Create( "catherine.vgui.button", self.leftPanel )
	self.disconnect:SetPos( 10, self.h - 100 )
	self.disconnect:SetSize( self.leftPanel:GetWide( ) - 20, 40 )
	self.disconnect:SetStr( LANG( "ESCMenu_UI_Disconnect" ) )
	self.disconnect:SetStrFont( "catherine_normal20" )
	self.disconnect:SetStrColor( Color( 255, 150, 150, 255 ) )
	self.disconnect:SetGradientColor( Color( 255, 150, 150, 255 ) )
	self.disconnect.Click = function( )
		RunConsoleCommand( "disconnect" )
	end
	
	self.close = vgui.Create( "catherine.vgui.button", self.leftPanel )
	self.close:SetPos( 10, self.h - 50 )
	self.close:SetSize( self.leftPanel:GetWide( ) - 20, 40 )
	self.close:SetStr( LANG( "ESCMenu_UI_Close" ) )
	self.close:SetStrFont( "catherine_normal20" )
	self.close:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.close:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.close.Click = function( )
		if ( self.closing ) then return end
		
		self:Close( )
	end
end

function PANEL:Paint( w, h )
	self.blurAmount = Lerp( 0.05, self.blurAmount, self.closing and 0 or 3 )
	
	catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	
	local versionText = catherine.GetVersion( ) .. " " .. catherine.GetBuild( )
	
	surface.SetFont( "catherine_normal20" )
	
	local tw, th = surface.GetTextSize( versionText )
	
	draw.RoundedBox( 0, w - tw - 20, h - th - 10, tw + 10, th, Color( 50, 50, 50, 255 ) )
	draw.SimpleText( versionText, "catherine_normal20", w - 15, h - 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self.leftPanel:MoveTo( 0 - self.leftPanel:GetWide( ), 0, 0.2, 0 )
	self:AlphaTo( 0, 0.2, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.escmenu", PANEL, "DFrame" )