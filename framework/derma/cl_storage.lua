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
	catherine.vgui.storage = self
	
	self.ent = nil
	self.player = catherine.pl
	self.w, self.h = ScrW( ) * 0.7, ScrH( ) * 0.8
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2

	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:MakePopup( )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
	self.storageLists = vgui.Create( "DPanelList", self )
	self.storageLists:SetPos( 10, 55 )
	self.storageLists:SetSize( self.w / 2 - 20, self.h - 115 )
	self.storageLists:SetSpacing( 5 )
	self.storageLists:EnableHorizontal( false )
	self.storageLists:EnableVerticalScrollbar( true )	
	self.storageLists.Paint = function( pnl, w, h )
		if ( self.storageInventory and table.Count( self.storageInventory ) == 0 ) then
			draw.SimpleText( LANG( "Storage_UI_StorageNoHaveItem" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
	
	self.playerLists = vgui.Create( "DPanelList", self )
	self.playerLists:SetPos( self.w / 2, 55 )
	self.playerLists:SetSize( self.w / 2 - 10, self.h - 115 )
	self.playerLists:SetSpacing( 5 )
	self.playerLists:EnableHorizontal( false )
	self.playerLists:EnableVerticalScrollbar( true )	
	self.playerLists.Paint = function( pnl, w, h )
		if ( self.playerInventory and table.Count( self.playerInventory ) == 0 ) then
			draw.SimpleText( LANG( "Storage_UI_PlayerNoHaveItem" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end

	self.playerWeight = vgui.Create( "catherine.vgui.weight", self )
	self.playerWeight:SetPos( self.w - 50, self.h - 50 )
	self.playerWeight:SetSize( 40, 40 )
	self.playerWeight:SetShowText( true )
	
	self.storageWeight = vgui.Create( "catherine.vgui.weight", self )
	self.storageWeight:SetPos( 10, self.h - 50 )
	self.storageWeight:SetSize( 40, 40 )
	self.storageWeight:SetShowText( true )
	
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

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, 0, w, 25, Color( 255, 255, 255, 255 ) )
	
	if ( IsValid( self.ent ) ) then
		local name = self.ent:GetNetVar( "name" )
		
		if ( name ) then
			draw.SimpleText( name:upper( ), "catherine_lightUI20", 10, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( LANG( "Storage_UI_StorageCash", catherine.cash.GetCompleteName( catherine.storage.GetCash( self.ent ) ) ), "catherine_lightUI15", 10, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
		end
		
		draw.SimpleText( LANG( "Storage_UI_YourInv" ):upper( ), "catherine_lightUI20", w / 2, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
		draw.SimpleText( LANG( "Storage_UI_PlayerCash", catherine.cash.GetCompleteName( catherine.cash.Get( self.player ) ) ), "catherine_lightUI15", w / 2, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	end
end

function PANEL:InitializeStorage( ent )
	self.ent = ent
	
	local storageInventory = { }
	local playerInventory = { }
	
	for k, v in pairs( catherine.storage.GetInv( ent ) ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		
		storageInventory[ category ] = storageInventory[ category ] or { }
		storageInventory[ category ][ k ] = v
	end

	for k, v in pairs( catherine.inventory.Get( ) ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		
		playerInventory[ category ] = playerInventory[ category ] or { }
		playerInventory[ category ][ k ] = v
	end
	
	self.playerInventory = playerInventory
	self.storageInventory = storageInventory
	
	self.storageWeight:SetWeight( catherine.storage.GetWeights( ent ) )
	self.playerWeight:SetWeight( catherine.inventory.GetWeights( ) )

	self:BuildStorage( )
end

function PANEL:Think( )
	if ( ( self.entCheck or 0 ) <= CurTime( ) ) then
		if ( !IsValid( self.ent ) and !self.closing ) then
			self:Close( )
			
			return
		end
		
		self.entCheck = CurTime( ) + 0.3
	end
end

function PANEL:BuildStorage( )
	if ( !self.storageInventory or !self.playerInventory ) then return end
	local pl = self.player
	
	local storageLists_scrollBar = self.storageLists.VBar
	local storageLists_scroll = storageLists_scrollBar.Scroll
	
	local playerLists_scrollBar = self.playerLists.VBar
	local playerLists_scroll = playerLists_scrollBar.Scroll
	
	self.storageLists:Clear( )
	self.playerLists:Clear( )

	for k, v in SortedPairs( self.storageInventory ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.storageLists:GetWide( ), 54 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form.Paint = function( pnl, w, h ) end
		form.Header:SetFont( "catherine_lightUI25" )
		form.Header:SetTall( 25 )
		form.Header:SetTextColor( Color( 255, 255, 255, 255 ) )

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )
		
		form:AddItem( lists )

		for k1, v1 in SortedPairsByMemberValue( v, "uniqueID" ) do
			local w, h = 54, 54
			local itemTable = catherine.item.FindByID( k1 )
			local itemData = v1.itemData
			local overrideItemDesc = itemTable.GetOverrideItemDesc and itemTable:GetOverrideItemDesc( pl, itemData, CAT_ITEM_OVERRIDE_DESC_TYPE_STORAGE ) or nil
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( pl, itemData, false ) or nil
			local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
			local noDrawItemCount = hook.Run( "NoDrawItemCount", pl, itemTable )
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, itemTable.skin or 0 )
			
			if ( overrideItemDesc ) then
				spawnIcon:SetToolTip( overrideItemDesc )
			else
				spawnIcon:SetToolTip( catherine.item.GetBasicDesc( itemTable ) .. ( itemDesc and "\n" .. itemDesc or "" ) )
			end
			
			spawnIcon.DoClick = function( )
				netstream.Start( "catherine.storage.Work", {
					self.ent:EntIndex( ),
					CAT_STORAGE_ACTION_REMOVE,
					k1
				} )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( pl, w, h, itemData )
				end
				
				if ( !noDrawItemCount and v1.itemCount > 1 ) then
					local count = v1.itemCount
					
					surface.SetFont( "catherine_normal20" )
					local tw, th = surface.GetTextSize( count )
					
					draw.RoundedBox( 0, 5 - tw / 2, h - 20, tw * 2, 20, Color( 255, 255, 255, 200 ) )
					draw.SimpleText( count, "catherine_normal20", 5, h - 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.storageLists:AddItem( form )
	end

	for k, v in SortedPairs( self.playerInventory ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.playerLists:GetWide( ), 54 )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form.Paint = function( pnl, w, h ) end
		form.Header:SetFont( "catherine_lightUI25" )
		form.Header:SetTall( 25 )
		form.Header:SetTextColor( Color( 255, 255, 255, 255 ) )

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )
		
		form:AddItem( lists )

		for k1, v1 in SortedPairsByMemberValue( v, "uniqueID" ) do
			local w, h = 54, 54
			local itemTable = catherine.item.FindByID( k1 )
			local itemData = pl:GetInvItemDatas( k1 )
			local overrideItemDesc = itemTable.GetOverrideItemDesc and itemTable:GetOverrideItemDesc( pl, itemData, CAT_ITEM_OVERRIDE_DESC_TYPE_STORAGE_PLAYERINV ) or nil
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( pl, itemData, true ) or nil
			local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
			local noDrawItemCount = hook.Run( "NoDrawItemCount", pl, itemTable )
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, itemTable.skin or 0 )
			
			if ( overrideItemDesc ) then
				spawnIcon:SetToolTip( overrideItemDesc )
			else
				spawnIcon:SetToolTip( catherine.item.GetBasicDesc( itemTable ) .. ( itemDesc and "\n" .. itemDesc or "" ) )
			end
			
			spawnIcon.DoClick = function( )
				netstream.Start( "catherine.storage.Work", {
					self.ent:EntIndex( ),
					CAT_STORAGE_ACTION_ADD,
					{
						uniqueID = k1,
						itemData = itemData
					}
				} )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( catherine.inventory.IsEquipped( k1 ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( pl, w, h, itemData )
				end
				
				if ( !noDrawItemCount and v1.itemCount > 1 ) then
					local count = v1.itemCount
					
					surface.SetFont( "catherine_normal20" )
					local tw, th = surface.GetTextSize( count )
					
					draw.RoundedBox( 0, 5 - tw / 2, h - 20, tw * 2, 20, Color( 255, 255, 255, 200 ) )
					draw.SimpleText( count, "catherine_normal20", 5, h - 20, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.playerLists:AddItem( form )
	end
	
	storageLists_scrollBar:AnimateTo( storageLists_scroll, 0.3, 0, 0.1 )
	playerLists_scrollBar:AnimateTo( playerLists_scroll, 0.3, 0, 0.1 )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:AlphaTo( 0, 0.2, 0, function( )
		if ( IsValid( self.ent ) ) then
			netstream.Start( "catherine.storage.ClosePanel", self.ent )
		end
		
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.storage", PANEL, "DFrame" )