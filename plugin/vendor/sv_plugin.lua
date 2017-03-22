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
local vars = {
	{
		id = "name",
		default = "Johnson"
	},
	{
		id = "desc",
		default = "No description."
	},
	{
		id = "factions",
		default = { }
	},
	{
		id = "classes",
		default = { }
	},
	{
		id = "inv",
		default = { }
	},
	{
		id = "cash",
		default = 0
	},
	{
		id = "setting",
		default = { }
	},
	{
		id = "status",
		default = false
	},
	{
		id = "model",
		default = "models/alyx.mdl"
	},
	{
		id = "items",
		default = { }
	}
}

function PLUGIN:SaveVendors( )
	local data = { }
	
	for k, v in pairs( ents.FindByClass( "cat_vendor" ) ) do
		if ( !v.vendorData ) then continue end
		local vendorData = v.vendorData
		local bodyGroupResult = { }
		
		for k1, v1 in pairs( v:GetBodyGroups( ) ) do
			bodyGroupResult[ #bodyGroupResult + 1 ] = v:GetBodygroup( v1.id )
		end
		
		data[ #data + 1 ] = {
			name = vendorData.name,
			desc = vendorData.desc,
			factions = vendorData.factions,
			classes = vendorData.classes,
			inv = vendorData.inv,
			cash = vendorData.cash,
			setting = vendorData.setting,
			status = vendorData.status,
			items = vendorData.items,
			model = vendorData.model,
			pos = v:GetPos( ),
			ang = v:GetAngles( ),
			mat = v:GetMaterial( ),
			col = v:GetColor( ),
			skin = v:GetSkin( ),
			bodyGroup = bodyGroupResult
		}
	end
	
	catherine.data.Set( "vendors", data )
end

function PLUGIN:LoadVendors( )
	local data = catherine.data.Get( "vendors", { } )
	
	for k, v in pairs( data ) do
		local ent = ents.Create( "cat_vendor" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:Spawn( )
		ent:Activate( )
		
		self:MakeVendor( ent, v )
		
		ent:SetModel( v.model )
		ent:SetSkin( v.skin or 0 )
		ent:SetColor( v.col or Color( 255, 255, 255, 255 ) )
		ent:SetMaterial( v.mat or "" )
		
		if ( v.bodyGroup and type( v.bodyGroup ) == "table" and #v.bodyGroup > 0 ) then
			ent:SetBodyGroups( table.concat( v.bodyGroup, "" ) )
		end
		
		ent:InitializeAnimation( )
	end
end

function PLUGIN:MakeVendor( ent, data )
	if ( !IsValid( ent ) or !data ) then return end
	
	ent.vendorData = { }
	
	for k, v in pairs( vars ) do
		local val = data[ v.id ] and data[ v.id ] or v.default
		
		ent:SetNetVar( v.id, val )
		ent.vendorData[ v.id ] = val
	end
	
	ent.isVendor = true
end

function PLUGIN:SetVendorData( ent, id, data, noSync )
	if ( !IsValid( ent ) or !id or !data ) then return end
	
	ent.vendorData[ id ] = data
	ent:SetNetVar( id, data )
	
	if ( id == "model" ) then
		ent:SetModel( data )
		ent:InitializeAnimation( )
	end
	
	if ( !noSync ) then
		local index = ent:EntIndex( )
		local target = self:GetVendorWorkingPlayers( index )
		
		if ( #target != 0 ) then
			netstream.Start( target, "catherine.plugin.vendor.RefreshRequest", index )
		end
	end
end

function PLUGIN:GetVendorData( ent, id, default )
	if ( !IsValid( ent ) or !id ) then return default end
	
	return ent.vendorData[ id ] or default
end

function PLUGIN:VendorWork( pl, ent, workID, data )
	if ( !IsValid( pl ) or !IsValid( ent ) or !workID or !data ) then return end
	
	if ( hook.Run( "PlayerShouldWorkVendor", pl, ent, workID, data ) == false ) then
		return
	end
	
	if ( workID == CAT_VENDOR_ACTION_BUY ) then
		local uniqueID = data.uniqueID
		local count = math.max( data.count or 1, 1 )
		local itemTable = catherine.item.FindByID( uniqueID )

		if ( !itemTable ) then
			catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			return
		end

		if ( !catherine.inventory.HasItem( pl, uniqueID ) ) then
			catherine.util.NotifyLang( pl, "Inventory_Notify_DontHave" )
			return
		end
		
		if ( itemTable.isPersistent ) then
			catherine.util.NotifyLang( pl, "Inventory_Notify_isPersistent" )
			return
		end
		
		--[[
		// Vendor 가 사야할 아이템 숫자가 플레이어의 인벤토리 아이템 수보다 많을때?
		if ( catherine.inventory.GetItemInt( pl, uniqueID ) < count ) then
			catherine.util.Notify( pl, "!!!!" )
			return
		end
		]]--
		
		local playerCash = catherine.cash.Get( pl )
		local vendorCash = self:GetVendorData( ent, "cash", 0 )
		local vendorInv = table.Copy( self:GetVendorData( ent, "inv", { } ) )
		
		if ( !vendorInv[ uniqueID ] ) then
			catherine.util.NotifyLang( pl, "Vendor_Notify_NoHasStock" )
			return
		end
		
		local itemCost = math.Round( ( vendorInv[ uniqueID ].cost * count ) / self.VENDOR_SOLD_DISCOUNTPER )
		
		if ( vendorCash < itemCost ) then
			catherine.util.NotifyLang( pl, "Vendor_Notify_VendorNoHasCash", catherine.cash.GetOnlySingular( ) )
			return
		end
		
		hook.Run( "PreItemVendorSell", pl, ent, itemTable, data )

		vendorInv[ uniqueID ] = {
			uniqueID = uniqueID,
			stock = vendorInv[ uniqueID ].stock + count,
			cost = vendorInv[ uniqueID ].cost,
			type = vendorInv[ uniqueID ].type
		}

		catherine.cash.Give( pl, itemCost )
		catherine.item.Take( pl, uniqueID, count )
		self:SetVendorData( ent, "inv", vendorInv )
		self:SetVendorData( ent, "cash", vendorCash - itemCost )
		
		hook.Run( "PostItemVendorSell", pl, ent, itemTable, data )
		catherine.util.NotifyLang( pl, "Vendor_Notify_Sell", catherine.util.StuffLanguage( pl, itemTable.name ), catherine.cash.GetCompleteName( itemCost ) )
	elseif ( workID == CAT_VENDOR_ACTION_SELL ) then
		local uniqueID = data.uniqueID
		local itemTable = catherine.item.FindByID( uniqueID )
		local count = math.max( data.count or 1, 1 )
		
		if ( !itemTable ) then
			catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			return
		end
		
		local playerCash = catherine.cash.Get( pl )
		local vendorCash = self:GetVendorData( ent, "cash", 0 )
		local vendorInv = table.Copy( self:GetVendorData( ent, "inv", { } ) )

		if ( !vendorInv[ uniqueID ] or vendorInv[ uniqueID ].stock <= 0 ) then
			catherine.util.NotifyLang( pl, "Vendor_Notify_NoHasStock" )
			return
		end
		
		if ( vendorInv[ uniqueID ].stock < count ) then
			count = vendorInv[ uniqueID ].stock
		end
		
		local itemCost = vendorInv[ uniqueID ].cost * count
		
		if ( itemCost > playerCash ) then
			catherine.util.NotifyLang( pl, "Cash_Notify_HasNot", catherine.cash.GetOnlySingular( ) )
			return 
		end
		
		local success = catherine.item.Give( pl, uniqueID, count )
		
		if ( !success ) then
			catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
			return
		end
		
		hook.Run( "PreItemVendorBuy", pl, ent, itemTable, data )

		vendorInv[ uniqueID ] = {
			uniqueID = uniqueID,
			stock = vendorInv[ uniqueID ].stock - count,
			cost = vendorInv[ uniqueID ].cost,
			type = vendorInv[ uniqueID ].type
		}
		
		if ( vendorInv[ uniqueID ].stock <= 0 ) then
			vendorInv[ uniqueID ].stock = 0
		end
		
		catherine.cash.Take( pl, itemCost )
		self:SetVendorData( ent, "inv", vendorInv )
		self:SetVendorData( ent, "cash", vendorCash + itemCost )
		
		hook.Run( "PostItemVendorBuy", pl, ent, itemTable, data )
		catherine.util.NotifyLang( pl, "Vendor_Notify_Buy", catherine.util.StuffLanguage( pl, itemTable.name ), catherine.cash.GetCompleteName( itemCost ) )
	elseif ( workID == CAT_VENDOR_ACTION_SETTING_CHANGE ) then
		if ( !pl:IsAdmin( ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
			return
		end
		
		PrintTable(data)
		
		for k, v in pairs( data ) do
			self:SetVendorData( ent, k, v )
		end
	elseif ( workID == CAT_VENDOR_ACTION_ITEM_CHANGE ) then
		if ( !pl:IsAdmin( ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
			return
		end
		
		local uniqueID = data.uniqueID
		local stock = math.Round( data.stock )
		local cost = math.Round( data.cost )
		local type = data.type
		local itemTable = catherine.item.FindByID( uniqueID )

		if ( !itemTable ) then
			catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			return
		end

		local vendorInv = table.Copy( self:GetVendorData( ent, "inv", { } ) )

		vendorInv[ uniqueID ] = {
			uniqueID = uniqueID,
			stock = stock,
			cost = cost,
			type = type
		}

		self:SetVendorData( ent, "inv", vendorInv )
		
		catherine.util.NotifyLang( pl, "Vendor_Notify_ItemDataUpdate" )
	elseif ( workID == CAT_VENDOR_ACTION_ITEM_UNCHANGE ) then
		local uniqueID = data
		local itemTable = catherine.item.FindByID( uniqueID )

		if ( !itemTable ) then
			catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			return
		end
		
		local vendorInv = table.Copy( self:GetVendorData( ent, "inv", { } ) )
		vendorInv[ uniqueID ] = nil
		self:SetVendorData( ent, "inv", vendorInv )
	end
end

function PLUGIN:CanUseVendor( pl, ent )
	if ( !IsValid( ent ) or !ent.isVendor ) then return false end
	
	if ( !ent.vendorData.status ) then
		//return false, "status" // 나중에 추가..
	end
	
	if ( hook.Run( "PlayerShouldUseVendor", pl, ent ) == false ) then
		return false
	end
	
	if ( pl:IsAdmin( ) ) then
		return true
	end
	
	local factionData = ent.vendorData.factions
	
	if ( #factionData != 0 and !table.HasValue( factionData, pl:Faction( ) ) ) then
		return false
	end
	
	local classData = ent.vendorData.classes
	local class = pl:Class( )
	
	if ( class ) then
		class = catherine.class.FindByIndex( class )
		
		if ( #classData != 0 and class and !table.HasValue( classData, class.uniqueID ) ) then
			if ( class and class.faction == pl:Team( ) ) then
				return false
			end
		end
	end
	
	return true
end

function PLUGIN:PreCleanupMap( )
	self:SaveVendors( )
end

function PLUGIN:PostCleanupMapDelayed( )
	self:LoadVendors( )
end

function PLUGIN:DataSave( )
	self:SaveVendors( )
end

function PLUGIN:DataLoad( )
	self:LoadVendors( )
end

netstream.Hook( "catherine.plugin.vendor.VendorWork", function( pl, data )
	PLUGIN:VendorWork( pl, data[ 1 ], data[ 2 ], data[ 3 ] )
end )

netstream.Hook( "catherine.plugin.vendor.VendorClose", function( pl )
	pl:SetNetVar( "vendorWorkingID", nil )
end )