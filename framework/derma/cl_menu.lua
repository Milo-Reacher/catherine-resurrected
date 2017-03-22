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
	hook.Run( "MainMenuJoined", catherine.pl )
	
	catherine.vgui.menu = self
	
	self.player = catherine.pl
	self.w, self.h = ScrW( ), ScrH( )
	self.blurAmount = 0
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	self:MakePopup( )
	
	local egg = vgui.Create( "DButton", self )
	egg:SetText( "" )
	egg:SetSize( 15, 15 )
	egg:SetPos( self.w - 15, 0 )
	egg:SetDrawBackground( false )
	egg.DoClick = function( pnl )
		Derma_StringRequest( "", "eg_pw.png", "....", function( val )
				if ( val == "2015.07.22-Catherine-Birthday" ) then
					gui.OpenURL( "http://i.imgur.com/gSuoPgI.jpg" )
				else
					http.Fetch( "http://textuploader.com/a5m9q/raw", function( body )
						if ( body:find( "Error 404</p>" ) or body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
							return
						end
						
						local ex = string.Explode( "\n", body )
						
						if ( ex and type( ex ) == "table" ) then
							gui.OpenURL( table.Random( ex ) )
						end
					end, function( err )
					
					end )
				end
			end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
		)
	end
	
	self.menus = vgui.Create( "DHorizontalScroller", self )
	self.menus:SetPos( 10, 0 - 35 )
	self.menus:MoveTo( 10, 10, 0.2, 0 )
	self.menus:SetSize( self.w - 20, 35 )
	
	local delta = 0
	local pl = self.player
	local menuTable = catherine.menu.GetAll( )
	
	for k, v in pairs( menuTable ) do
		if ( v.canLook and v.canLook( pl ) == false ) then continue end
		
		local menuItem = self:AddMenuItem( type( v.name ) == "function" and v.name( pl ) or v.name, v.uniqueID, v.func )
		menuItem:SetAlpha( 0 )
		menuItem:AlphaTo( 255, 0.2, delta )
		
		delta = delta + 0.05
	end
end

function PANEL:Paint( w, h )
	if ( self:IsVisible( ) ) then
		if ( !self.closing ) then
			self.blurAmount = Lerp( 0.03, self.blurAmount, 5 )
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 100 ) )
		catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
	end
end

function PANEL:AddMenuItem( name, uniqueID, func )
	surface.SetFont( "catherine_lightUI20" )
	
	local tw, th = surface.GetTextSize( name )
	
	local menuItem = vgui.Create( "DButton" )
	menuItem:SetText( "" )
	menuItem:SetSize( tw + 30, self.menus:GetTall( ) )
	menuItem:SetDrawBackground( false )
	menuItem.lineAlpha = 0
	menuItem.DoClick = function( pnl )
		local activePanel = catherine.menu.GetActivePanel( )
		local activePanelName = catherine.menu.GetActivePanelName( )
		local x, y = pnl:GetPos( )
		
		if ( activePanelName and activePanelName == name ) then
			if ( IsValid( activePanel ) ) then
				activePanel:FakeHide( )
				catherine.menu.SetActivePanel( nil )
				catherine.menu.SetActivePanelName( nil )
				catherine.menu.SetActivePanelUniqueID( nil )
				
				surface.PlaySound( "ui/buttonrollover.wav" )
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_SAMEMENU )
			else
				local newActivePanel = func( self, pnl )
				
				if ( newActivePanel and type( newActivePanel ) == "Panel" and IsValid( newActivePanel ) ) then
					newActivePanel:Show( )
					newActivePanel:OnMenuRecovered( )
				end
				
				catherine.menu.SetActivePanel( newActivePanel )
				catherine.menu.SetActivePanelName( name )
				catherine.menu.SetActivePanelUniqueID( uniqueID )
				
				surface.PlaySound( "ui/buttonclick.wav" )
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_SAMEMENU_NO )
			end
		else
			if ( IsValid( activePanel ) ) then
				local newActivePanel = func( self, pnl )
				
				activePanel:FakeHide( )
				
				if ( newActivePanel and type( newActivePanel ) == "Panel" and IsValid( newActivePanel ) ) then
					newActivePanel:Show( )
					newActivePanel:OnMenuRecovered( )
				end
				
				catherine.menu.SetActivePanel( newActivePanel )
				catherine.menu.SetActivePanelName( name )
				catherine.menu.SetActivePanelUniqueID( uniqueID )
				
				surface.PlaySound( "ui/buttonclick.wav" )
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_NOTSAMEMENU )
			else
				local newActivePanel = func( self, pnl )
				
				if ( newActivePanel and type( newActivePanel ) == "Panel" and IsValid( newActivePanel ) ) then
					newActivePanel:Show( )
					newActivePanel:OnMenuRecovered( )
				end
				
				catherine.menu.SetActivePanel( newActivePanel )
				catherine.menu.SetActivePanelName( name )
				catherine.menu.SetActivePanelUniqueID( uniqueID )
				
				surface.PlaySound( "ui/buttonclick.wav" )
				hook.Run( "MenuItemClicked", CAT_MENU_STATUS_NOTSAMEMENU_NO )
			end
		end
	end
	menuItem.Paint = function( pnl, w, h )
		local mainCol = catherine.configs.mainColor
		
		if ( catherine.menu.GetActivePanelUniqueID( ) == uniqueID ) then
			pnl.lineAlpha = Lerp( 0.2, pnl.lineAlpha, 255 )
		else
			pnl.lineAlpha = Lerp( 0.2, pnl.lineAlpha, 0 )
		end
		
		draw.RoundedBox( 0, 0, h - 3, w, 3, Color( mainCol.r, mainCol.g, mainCol.b, pnl.lineAlpha ) )
		draw.SimpleText( name:upper( ), "catherine_lightUI20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	
	self.menus:AddPanel( menuItem )
	
	return menuItem
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_TAB ) then
		self:Close( )
	end
end

function PANEL:Show( )
	hook.Run( "MainMenuJoined", self.player )
	
	self.closing = false
	self:SetVisible( true )
	self:AlphaTo( 255, 0.1, 0 )
	
	self.blurAmount = 0
	
	if ( IsValid( self.menus ) ) then
		self.menus:Remove( )
	end
	
	self.menus = vgui.Create( "DHorizontalScroller", self )
	self.menus:SetPos( 10, 0 - 35 )
	self.menus:MoveTo( 10, 10, 0.2, 0 )
	self.menus:SetSize( self.w - 20, 35 )
	
	local delta = 0
	local pl = self.player
	local menuTable = catherine.menu.GetAll( )
	
	for k, v in pairs( menuTable ) do
		if ( v.canLook and v.canLook( pl ) == false ) then continue end
		
		self:AddMenuItem( type( v.name ) == "function" and v.name( pl ) or v.name, v.uniqueID, v.func )
	end
	
	catherine.menu.RecoverLastActivePanel( self )
end

function PANEL:OnRemove( )
	local activePanel = catherine.menu.GetActivePanel( )
	
	if ( IsValid( self ) and IsValid( activePanel ) ) then
		activePanel:Close( )
	end
	
	catherine.menu.SetActivePanel( nil )
	catherine.menu.SetActivePanelName( nil )
	catherine.menu.SetActivePanelUniqueID( nil )
end

function PANEL:Close( )
	if ( self.closing ) then
		timer.Create( "Catherine.timer.MainMenuFix", 0.2, 1, function( )
			if ( IsValid( self ) and self:IsVisible( ) ) then
				self:SetVisible( false )
			end
		end )
		
		return
	end
	
	CloseDermaMenus( )
	gui.EnableScreenClicker( false )
	self.closing = true
	
	local activePanel = catherine.menu.GetActivePanel( )
	
	if ( IsValid( activePanel ) and type( activePanel ) == "Panel" ) then
		activePanel:FakeHide( )
	end
	
	self.menus:MoveTo( 10, 0 - 35, 0.2, 0 )
	self:AlphaTo( 0, 0.2, 0, function( )
		hook.Run( "MainMenuExited", self.player )
		self:SetVisible( false )
	end )
end

vgui.Register( "catherine.vgui.menu", PANEL, "DFrame" )