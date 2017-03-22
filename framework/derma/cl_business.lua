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
	catherine.vgui.business = self
	
	self.business = nil
	self.shoppingcartInfo = nil
	self.shoppingcart = { }
	
	self:SetMenuSize( ScrW( ) * 0.95, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Business_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - self.w * 0.4, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h )
		if ( self.business and table.Count( self.business ) == 0 ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Business_UI_NoBuyable" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
	
	self.Cart = vgui.Create( "DPanelList", self )
	self.Cart:SetPos( self.w - self.w * 0.4 + 20, 60 )
	self.Cart:SetSize( self.w * 0.4 - 30, self.h - 110 )
	self.Cart:SetSpacing( 5 )
	self.Cart:EnableHorizontal( false )
	self.Cart:EnableVerticalScrollbar( true )
	self.Cart.Paint = function( pnl, w, h ) end
	
	self.buyItems = vgui.Create( "catherine.vgui.button", self )
	self.buyItems:SetPos( self.w * 0.6 + 20, self.h - 40 )
	self.buyItems:SetSize( self.w * 0.4 - 30, 30 )
	self.buyItems:SetStr( LANG( "Business_UI_BuyButtonStr", 0 ) )
	self.buyItems:SetStrFont( "catherine_normal20" )
	self.buyItems:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.buyItems:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.buyItems.Click = function( )
		if ( self:GetShipmentCount( ) > 0 ) then
			if ( catherine.cash.Get( self.player ) >= self.shoppingcartInfo ) then
				Derma_Query( LANG( "Business_Notify_BuyQ" ), "", LANG( "Basic_UI_YES" ), function( )
					netstream.Start( "catherine.business.BuyItems", self.shoppingcart )
				end, LANG( "Basic_UI_NO" ), function( ) end )
			else
				catherine.notify.Add( LANG( "Cash_Notify_HasNot", catherine.cash.GetOnlySingular( ) ), 5 )
			end
		else
			catherine.notify.Add( LANG( "Business_Notify_NeedCartAdd" ), 5 )
		end
	end
	
	self:InitializeBusiness( )
end

function PANEL:OnMenuRecovered( )
	self:InitializeBusiness( )
end

function PANEL:RefreshShoppingCartInfo( )
	local costs = 0

	for k, v in pairs( self.shoppingcart ) do
		local itemTable = catherine.item.FindByID( k )

		costs = costs + itemTable.cost * v
	end
	
	self.shoppingcartInfo = costs
end

function PANEL:MenuPaint( w, h )
	draw.SimpleText( LANG( "Business_UI_ShoppingCartStr" ), "catherine_normal20", w * 0.6 + 20, 45, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	
	if ( self.shoppingcartInfo ) then
		draw.SimpleText( LANG( "Business_UI_TotalStr", catherine.cash.GetCompleteName( self.shoppingcartInfo ) ), "catherine_normal20", w - 10, 45, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
end

function PANEL:InitializeBusiness( )
	local pl = self.player
	local team = pl:Team( )
	local class = pl:Class( )
	local items = { }
	
	for k, v in pairs( catherine.item.GetAll( ) ) do
		if ( v.ShowOnBusiness and v:ShowOnBusiness( pl ) == false ) then continue end
		if ( ( !v.ShowOnBusiness or v:ShowOnBusiness( pl ) == false ) and !table.HasValue( v.onBusinessFactions or { }, team ) ) then continue end
		if ( class and ( ( !v.ShowOnBusiness or v:ShowOnBusiness( pl ) == false ) and !table.HasValue( v.onBusinessClasses or { }, class ) ) ) then continue end
		local category = v.category
		
		items[ category ] = items[ category ] or { }
		items[ category ][ k ] = v
	end
	
	self.business = items
	
	self:BuildBusiness( )
end

function PANEL:GetShipmentCount( )
	local count = 0
	
	for k, v in pairs( self.shoppingcart ) do
		count = count + v
	end
	
	return count
end

function PANEL:BuildShoppingCart( )
	local scrollBar = self.Cart.VBar
	local scroll = scrollBar.Scroll
	
	self.Cart:Clear( )
	
	for k, v in SortedPairs( self.shoppingcart ) do
		local itemTable = catherine.item.FindByID( k )
		local costs = itemTable.cost * v
		local name = catherine.util.StuffLanguage( itemTable.name )
		local count = LANG( "Basic_UI_Count", v )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Cart:GetWide( ), 40 )
		panel.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 50, 50, 50, 90 ) )
			
			draw.SimpleText( name, "catherine_normal15", 10, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( count .. " / " .. catherine.cash.GetCompleteName( costs ), "catherine_normal15", w - 40, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
		end
		
		local removeItem = vgui.Create( "catherine.vgui.button", panel )
		removeItem:SetPos( panel:GetWide( ) - 30, 10 )
		removeItem:SetSize( 20, 20 )
		removeItem:SetStr( "X" )
		removeItem:SetStrFont( "catherine_normal15" )
		removeItem:SetStrColor( Color( 255, 255, 255, 255 ) )
		removeItem:SetGradientColor( Color( 255, 0, 0, 255 ) )
		removeItem.Click = function( )
			self.shoppingcart[ k ] = self.shoppingcart[ k ] - 1
			
			if ( self.shoppingcart[ k ] <= 0 ) then
				self.shoppingcart[ k ] = nil
				self.Cart:RemoveItem( panel )
			end
			
			self:RefreshShoppingCartInfo( )
			self:BuildShoppingCart( )
			
			costs = itemTable.cost * v
		end
		
		self.Cart:AddItem( panel )
	end
	
	scrollBar:SetScroll( scroll, 0, 0, 0 )
end

function PANEL:BuildBusiness( )
	if ( !self.business ) then return end
	local pl = self.player
	local scrollBar = self.Lists.VBar
	local scroll = scrollBar.Scroll
	
	self.Lists:Clear( )

	for k, v in SortedPairs( self.business ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
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
			local w, h = 64, 64
			local model = v1.GetDropModel and v1:GetDropModel( ) or v1.model
			local overrideItemDesc = v1.GetOverrideItemDesc and v1:GetOverrideItemDesc( pl, nil, CAT_ITEM_OVERRIDE_DESC_TYPE_BUSINESS ) or nil
			
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( model, v1.skin or 0 )
			
			if ( overrideItemDesc ) then
				spawnIcon:SetToolTip( overrideItemDesc )
			else
				spawnIcon:SetToolTip( catherine.item.GetBasicDesc( v1 ) .. "\n" .. ( v1.cost == 0 and LANG( "Item_Free" ) or catherine.cash.GetCompleteName( v1.cost ) ) )
			end
			
			spawnIcon.DoClick = function( )
				local shoppingCart = self.shoppingcart
				
				if ( shoppingCart[ k1 ] ) then
					shoppingCart[ k1 ] = shoppingCart[ k1 ] + 1
				else
					shoppingCart[ k1 ] = 1
				end
				
				self:RefreshShoppingCartInfo( )
				self:BuildShoppingCart( )
				
				self.buyItems:SetStr( LANG( "Business_UI_BuyButtonStr", self:GetShipmentCount( ) ) )
			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( v1.DrawInformation ) then
					v1:DrawInformation( pl, w, h, pl:GetInvItemDatas( k1 ) )
				end
			end
			
			lists:AddItem( spawnIcon )
		end
		
		self.Lists:AddItem( form )
	end
	
	scrollBar:SetScroll( scroll, 0, 0, 0 )
end

vgui.Register( "catherine.vgui.business", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	catherine.vgui.shipment = self

	self.entCheck = CurTime( ) + 1
	self.w, self.h = ScrW( ) * 0.4, ScrH( ) * 0.6
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:MakePopup( )
	self:ShowCloseButton( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.2, 0 )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h ) end
	
	self.close = vgui.Create( "catherine.vgui.button", self )
	self.close:SetPos( self.w - 30, 0 )
	self.close:SetSize( 30, 23 )
	self.close:SetStr( "X" )
	self.close:SetStrFont( "catherine_normal30" )
	self.close:SetStrColor( Color( 0, 0, 0, 255 ) )
	self.close.Click = function( )
		if ( self.closing ) then return end
		
		self:Close( )
	end
end

function PANEL:BuildShipment( )
	if ( !self.shipments ) then return end
	self.Lists:Clear( )
	
	for k, v in SortedPairs( self.shipments ) do
		local itemTable = catherine.item.FindByID( k )
		local name = catherine.util.StuffLanguage( itemTable.name )
		local count = LANG( "Basic_UI_Count", v )
		local model = itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Lists:GetWide( ), 40 )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( name, "catherine_normal15", 50, h / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( count, "catherine_normal15", w - 80, h / 2, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
		end

		local spawnIcon = vgui.Create( "SpawnIcon", panel )
		spawnIcon:SetPos( 5, 5 )
		spawnIcon:SetSize( 30, 30 )
		spawnIcon:SetModel( model, itemTable.skin or 0 )
		spawnIcon:SetToolTip( false )
		spawnIcon:SetDisabled( true )
		spawnIcon.PaintOver = function( ) end
		
		local takeItem = vgui.Create( "catherine.vgui.button", panel )
		takeItem:SetPos( panel:GetWide( ) - 70, 10 )
		takeItem:SetSize( 60, 20 )
		takeItem:SetStr( LANG( "Business_UI_Take" ) )
		takeItem:SetStrFont( "catherine_normal15" )
		takeItem:SetStrColor( Color( 255, 255, 255 ) )
		takeItem:SetGradientColor( Color( 255, 255, 255 ) )
		takeItem.Click = function( )
			local itemTable = catherine.item.FindByID( k )
			
			if ( !itemTable ) then
				self.Lists:RemoveItem( panel )
				return
			end
			
			if ( !catherine.inventory.HasSpace( itemTable.weight ) ) then
				catherine.notify.Add( LANG( "Inventory_Notify_HasNotSpace" ), 5 )
				return
			end
			
			self.shipments[ k ] = self.shipments[ k ] - 1
			
			if ( self.shipments[ k ] <= 0 ) then
				self.shipments[ k ] = nil
				self.Lists:RemoveItem( panel )
			end
			
			netstream.Start( "catherine.item.Give", k )
			
			count = LANG( "Basic_UI_Count", self.shipments[ k ] )
			
			if ( table.Count( self.shipments ) == 0 and IsValid( self.ent ) ) then
				netstream.Start( "catherine.business.RemoveShipment", self.ent:EntIndex( ) )
			end
		end
		
		self.Lists:AddItem( panel )
	end
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, 0, w, 25, Color( 255, 255, 255, 255 ) )
	
	draw.SimpleText( LANG( "Business_UI_Shipment_Title" ):upper( ), "catherine_lightUI20", 10, 13, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT, 1 )
end

function PANEL:InitializeShipment( ent, shipments )
	self.ent = ent
	self.shipments = shipments
	
	self:BuildShipment( )
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

function PANEL:Close( )
	self.closing = true
	
	self:AlphaTo( 0, 0.2, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.shipment", PANEL, "DFrame" )

catherine.menu.Register( function( )
	return LANG( "Business_UI_Title" )
end, "business", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.business ) and catherine.vgui.business or vgui.Create( "catherine.vgui.business", menuPnl )
end )