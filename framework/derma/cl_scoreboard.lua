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
	catherine.vgui.scoreboard = self
	
	self.playerCount = 0
	self.shouldOpen = hook.Run( "ShouldOpenScoreboard", self.player )
	
	self:SetMenuSize( ScrW( ) * 0.8, ScrH( ) * 0.85 )
	self:SetMenuName( LANG( "Scoreboard_UI_Title" ) )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		if ( self.shouldOpen == false ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Scoreboard_UI_CanNotLook_Str" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
	
	self:Refresh( )
end

function PANEL:OnMenuRecovered( )
	self.shouldOpen = hook.Run( "ShouldOpenScoreboard", self.player )
	self:Refresh( )
end

function PANEL:MenuPaint( w, h )
	draw.SimpleText( GetHostName( ) .. "      " .. #player.GetAll( ) .. " / " .. game.MaxPlayers( ), "catherine_lightUI20", w - 10, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

function PANEL:Refresh( )
	self.playerCount = #player.GetAllByLoaded( )
	
	self:SortPlayerLists( )
end

function PANEL:IsPlayerDataChanged( pl, name, desc, model )
	if ( pl:Name( ) != name or pl:Desc( ) != desc or pl:GetModel( ) != model ) then
		return true
	end
	
	return false
end

function PANEL:SortPlayerLists( )
	local players = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		local factionTable = catherine.faction.FindByIndex( v:Team( ) )
		
		if ( !factionTable ) then continue end
		
		local class = v:Class( )
		
		if ( class ) then
			local classTable = catherine.class.FindByIndex( class )
			
			if ( classTable and classTable.name and classTable.showInUI ) then
				local name = classTable.name or "CLASS"
				
				players[ name ] = players[ name ] or { }
				players[ name ][ #players[ name ] + 1 ] = v
			else
				local name = factionTable and factionTable.name or "LOADING"
				
				players[ name ] = players[ name ] or { }
				players[ name ][ #players[ name ] + 1 ] = v
			end
		else
			local name = factionTable and factionTable.name or "LOADING"
			
			players[ name ] = players[ name ] or { }
			players[ name ][ #players[ name ] + 1 ] = v
		end
	end
	
	self.playerLists = players
	
	self:RefreshPlayerLists( )
end

function PANEL:RefreshPlayerLists( )
	if ( self.shouldOpen == false ) then return end
	local pl = self.player
	local scrollBar = self.Lists.VBar
	local scroll = scrollBar.Scroll
	
	self.Lists:Clear( )
	
	for k, v in SortedPairs( self.playerLists or { } ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form.Paint = function( pnl, w, h ) end
		form.Header:SetFont( "catherine_lightUI25" )
		form.Header:SetTall( 25 )
		form.Header:SetTextColor( Color( 255, 255, 255, 255 ) )
		
		for k1, v1 in SortedPairs( v ) do
			local know = pl == v1 and true or pl:IsKnow( v1 )
			local nextRefresh = CurTime( ) + k1
			local name = v1:Name( )
			local descOriginal = v1:Desc( )
			local desc = catherine.util.GetWrapTextData( ( know and descOriginal or LANG( "Scoreboard_UI_UnknownDesc" ) ), form:GetWide( ) - 400, "catherine_normal15" )
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( form:GetWide( ), 30 + ( #desc * 20 ) )
			panel.Paint = function( pnl, w, h )
				if ( !IsValid( v1 ) ) then
					self:Refresh( )
					return
				end
				
				if ( nextRefresh <= CurTime( ) ) then
					if ( self:IsPlayerDataChanged( v1, name, descOriginal, v1:GetModel( ) ) ) then
						self:Refresh( )
						return
					end
					
					nextRefresh = CurTime( ) + k1
				end
				
				hook.Run( "ScoreboardPlayerListPanelPaint", pl, v1, w, h )
				
				if ( !know ) then
					draw.SimpleText( "?", "catherine_lightUI40", 50 + 40 / 2, 5 + 40 / 2, Color( 255, 255, 255, 255 ), 1, 1 )
					
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawOutlinedRect( 50, 5, 40, 40 )
				end
				
				draw.SimpleText( name, "catherine_lightUI20", 100, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				
				if ( #desc == 1 ) then
					draw.SimpleText( desc[ 1 ], "catherine_normal15", 100, 30, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				else
					local textY = 30
					
					for k, v in pairs( desc ) do
						draw.SimpleText( v, "catherine_normal15", 100, textY, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
						
						textY = textY + 20
					end
				end
			end
			
			local avatar = vgui.Create( "AvatarImage", panel )
			avatar:SetPos( 5, 5 )
			avatar:SetSize( 40, 40 )
			avatar:SetPlayer( v1, 64 )
			avatar.PaintOver = function( pnl, w, h )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			
			local avatarButton = vgui.Create( "DButton", panel )
			avatarButton:SetPos( 5, 5 )
			avatarButton:SetSize( 40, 40 )
			avatarButton:SetText( "" )
			avatarButton:SetDrawBackground( false )
			avatarButton:SetToolTip( LANG( "Scoreboard_UI_PlayerDetailStr", v1:SteamName( ), v1:SteamID( ), v1:Ping( ) ) )
			avatarButton.DoClick = function( )
				hook.Run( "ScoreboardPlayerOption", self.player, v1 )
			end
			
			local spawnIcon = vgui.Create( "SpawnIcon", panel )
			spawnIcon:SetPos( 50, 5 )
			spawnIcon:SetSize( 40, 40 )
			spawnIcon:SetModel( v1:GetModel( ), v1:GetSkin( ) or 0 )
			spawnIcon:SetToolTip( false )
			spawnIcon:SetDisabled( true )
			spawnIcon.PaintOver = function( pnl, w, h )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			
			if ( !know ) then
				spawnIcon:SetVisible( false )
			end
			
			form:AddItem( panel )
		end
		
		self.Lists:AddItem( form )
	end
	
	scrollBar:AnimateTo( scroll, 0.3, 0, 0.1 )
end

vgui.Register( "catherine.vgui.scoreboard", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Scoreboard_UI_Title" )
end, "scoreboard", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.scoreboard ) and catherine.vgui.scoreboard or vgui.Create( "catherine.vgui.scoreboard", menuPnl )
end, function( pl )
	if ( hook.Run( "ShouldOpenScoreboard", pl ) == false ) then
		return false
	else
		return true
	end
end )