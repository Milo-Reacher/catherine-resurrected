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
	catherine.vgui.door = self

	self.door = nil
	self.mode = 0
	self.doorDesc = ""
	self.doorCurLen = 0
	self.player = catherine.pl
	self.w, self.h = ScrW( ) * 0.5, ScrH( ) * 0.6
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:MakePopup( )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
	self.playerLists = vgui.Create( "DPanelList", self )
	self.playerLists:SetPos( 10, 35 )
	self.playerLists:SetSize( self.w - 20, self.h - 100 )
	self.playerLists:SetSpacing( 0 )
	self.playerLists:EnableHorizontal( false )
	self.playerLists:EnableVerticalScrollbar( true )	
	self.playerLists.Paint = function( pnl, w, h )
		if ( self.mode != CAT_DOOR_FLAG_OWNER ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Door_Notify_NoOwner" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
	
	self.doorDescLabel = vgui.Create( "DLabel", self )
	self.doorDescLabel:SetPos( 10, self.h - 60 )
	self.doorDescLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.doorDescLabel:SetFont( "catherine_normal20" )
	self.doorDescLabel:SetText( LANG( "Door_UI_DoorDescStr" ) )
	self.doorDescLabel:SizeToContents( )

	self.doorDescEnt = vgui.Create( "DTextEntry", self )
	self.doorDescEnt:SetPos( 10, self.h - 35 )
	self.doorDescEnt:SetSize( self.w * 0.8, 25 )
	self.doorDescEnt:SetFont( "catherine_normal15" )
	self.doorDescEnt:SetText( "" )
	self.doorDescEnt:SetAllowNonAsciiCharacters( true )
	self.doorDescEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 110, 110, 110 ), Color( 255, 255, 255 ) )
	end
	self.doorDescEnt.OnTextChanged = function( pnl )
		self.doorDesc = pnl:GetText( )
		self.doorCurLen = pnl:GetText( ):utf8len( )
	end
	self.doorDescEnt.OnEnter = function( pnl )
		if ( self.mode == CAT_DOOR_FLAG_BASIC ) then
			catherine.notify.Add( LANG( "Door_Notify_NoOwner" ) )
			return
		end
		
		if ( catherine.configs.doorDescMaxLen <= self.doorCurLen ) then
			catherine.notify.Add( LANG( "Door_Notify_SetDescHitLimit" ) )
			return
		end

		if ( self.doorDesc == "" ) then
			pnl:SetText( catherine.door.GetDetailString( self.door ) )
		end
		
		netstream.Start( "catherine.door.Work", {
			self.door,
			CAT_DOOR_CHANGE_DESC,
			self.doorDesc
		} )
	end

	self.sellDoor = vgui.Create( "catherine.vgui.button", self )
	self.sellDoor:SetPos( self.w * 0.8 + 20, self.h - 55 )
	self.sellDoor:SetSize( self.w - self.w * 0.8 - 30, 45 )
	self.sellDoor:SetStr( LANG( "Door_UI_DoorSellStr" ) )
	self.sellDoor:SetStrFont( "catherine_normal20" )
	self.sellDoor:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.sellDoor:SetGradientColor( Color( 255, 0, 0, 255 ) )
	self.sellDoor.Click = function( )
		if ( self.mode != CAT_DOOR_FLAG_OWNER ) then
			catherine.notify.Add( LANG( "Door_Notify_NoOwner" ) )
			return
		end
		
		Derma_Query( LANG( "Door_Notify_SellQ" ), "", LANG( "Basic_UI_OK" ), function( )
				catherine.command.Run( "&uniqueID_doorSell" )
				self:Close( )
			end, LANG( "Basic_UI_NO" ), function( ) end
		)
	end
	self.sellDoor.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 0, 0, 150 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self.close = vgui.Create( "catherine.vgui.button", self )
	self.close:SetPos( self.w - 30, 0 )
	self.close:SetSize( 30, 23 )
	self.close:SetStr( "X" )
	self.close:SetStrFont( "catherine_normal30" )
	self.close:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.close.Click = function( )
		self:Close( )
	end
end

function PANEL:BuildPlayerList( )
	self.playerLists:Clear( )
	
	if ( self.mode != CAT_DOOR_FLAG_OWNER ) then return end
	local pl = self.player
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local know = pl == v and true or pl:IsKnow( v )
		local has, flag = catherine.door.IsHasDoorPermission( v, self.door )

		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.playerLists:GetWide( ), 60 )
		panel.Paint = function( pnl, w, h )
			if ( !know ) then
				draw.SimpleText( "?", "catherine_lightUI40", 5 + 50 / 2, 5 + 50 / 2, Color( 255, 255, 255, 255 ), 1, 1 )
					
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawOutlinedRect( 5, 5, 50, 50 )
			end
			
			draw.SimpleText( v:Name( ), "catherine_lightUI25", 70, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( v:FactionName( ), "catherine_lightUI15", 70, 45, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )

			if ( has ) then
				local text = LANG( "Door_UI_OwnerStr" )
				
				if ( flag == CAT_DOOR_FLAG_ALL ) then
					text = LANG( "Door_UI_AllStr" )
				elseif ( flag == CAT_DOOR_FLAG_BASIC ) then
					text = LANG( "Door_UI_BasicStr" )
				end
				
				draw.SimpleText( text, "catherine_lightUI15", w - 20, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
			end
		end
		
		local spawnIcon = vgui.Create( "SpawnIcon", panel )
		spawnIcon:SetPos( 5, 5 )
		spawnIcon:SetSize( 50, 50 )
		spawnIcon:SetModel( v:GetModel( ), v:GetSkin( ) or 0 )
		spawnIcon:SetToolTip( false )
		spawnIcon:SetDisabled( true )
		spawnIcon.PaintOver = function( pnl, w, h )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ), panel:GetTall( ) )
		button:SetDrawBackground( false )
		button:SetText( "" )
		button.DoClick = function( )
			if ( flag == CAT_DOOR_FLAG_OWNER ) then return end
			local menu = DermaMenu( )
			
			menu:AddOption( LANG( "Door_UI_AllPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.door,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v:SteamID( ),
						CAT_DOOR_FLAG_ALL
					}
				} )
			end )
			
			menu:AddOption( LANG( "Door_UI_BasicPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.door,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v:SteamID( ),
						CAT_DOOR_FLAG_BASIC
					}
				} )
			end )
			
			menu:AddOption( LANG( "Door_UI_RemPerStr" ), function( )
				netstream.Start( "catherine.door.Work", {
					self.door,
					CAT_DOOR_CHANGE_PERMISSION,
					{
						v:SteamID( ),
						0
					}
				} )
			end )
			
			menu:Open( )
		end
		
		if ( !know ) then
			spawnIcon:SetVisible( false )
		end
		
		self.playerLists:AddItem( panel )
	end
end

function PANEL:InitializeDoor( door, flag )
	self.door = door
	
	local doorDesc = door:GetNetVar( "customDesc", "" )
	
	if ( doorDesc == "" ) then
		doorDesc = catherine.door.GetDetailString( door )
	else
		self.doorCurLen = doorDesc:utf8len( )
	end

	self.doorDesc = doorDesc
	self.doorDescEnt:SetText( doorDesc )
	self.mode = flag

	if ( flag == CAT_DOOR_FLAG_ALL or flag == CAT_DOOR_FLAG_BASIC ) then
		self.sellDoor:SetVisible( false )
	end
	
	if ( flag == CAT_DOOR_FLAG_BASIC ) then
		self.doorDescEnt:SetVisible( false )
	end
	
	self:BuildPlayerList( )
end

function PANEL:Refresh( )
	local doorDesc = self.door:GetNetVar( "customDesc", "" )
	
	if ( doorDesc == "" ) then
		doorDesc = catherine.door.GetDetailString( door )
	else
		self.doorCurLen = doorDesc:utf8len( )
	end

	self.doorDesc = doorDesc
	self.doorDescEnt:SetText( doorDesc )
	
	self:BuildPlayerList( )
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, 0, w, 25, Color( 255, 255, 255, 255 ) )
	
	if ( IsValid( self.door ) ) then
		draw.SimpleText( self.door:GetNetVar( "title", LANG( "Door_UI_Default" ) ), "catherine_lightUI20", 10, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		local descLimit = catherine.configs.doorDescMaxLen
		local col = descLimit <= self.doorCurLen and Color( 255, 0, 0 ) or Color( 255, 255, 255 )

		draw.SimpleText( self.doorCurLen .. " / " .. descLimit, "catherine_normal20", w * 0.8 + 10, h - 50, col, TEXT_ALIGN_RIGHT, 1 )
	end
end

function PANEL:Think( )
	if ( ( self.nextPerCheck or 0 ) <= CurTime( ) and !self.closing ) then
		if ( IsValid( self.door ) ) then
			local has, flag = catherine.door.IsHasDoorPermission( self.player, self.door )
			
			if ( !has ) then
				self:Close( )
				
				return
			end
		else
			self:Close( )
			
			return
		end
		
		self.nextPerCheck = CurTime( ) + 0.3
	end
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:AlphaTo( 0, 0.2, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.door", PANEL, "DFrame" )