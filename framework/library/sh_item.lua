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

catherine.item = catherine.item or { bases = { }, items = { } }
catherine.item.hooks = { }

function catherine.item.Register( itemTable )
	if ( !itemTable ) then return end
	
	if ( itemTable.isBase ) then
		catherine.item.bases[ itemTable.uniqueID ] = itemTable
		return
	end
	
	if ( itemTable.base ) then
		local base = catherine.item.bases[ itemTable.base ]
		
		if ( base ) then
			itemTable = table.Inherit( itemTable, base )
		else
			ErrorNoHalt( "\n[CAT ERROR] <" .. itemTable.uniqueID .. "> item has based of <" .. itemTable.base .. ">, but base is not valid! :< ...\n" )
		end
	end
	
	itemTable.name = itemTable.name or "A Name"
	itemTable.desc = itemTable.desc or "A Desc"
	itemTable.weight = itemTable.weight or 0
	itemTable.itemData = itemTable.itemData or { }
	itemTable.cost = itemTable.cost or 0
	itemTable.category = itemTable.category or "^Item_Category_Other"
	local funcBuffer = {
		take = {
			text = "^Item_FuncStr01_Basic",
			icon = "icon16/basket_put.png",
			canShowIsWorld = true,
			func = function( pl, itemTable, ent )
				if ( !IsValid( ent ) ) then
					catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
					return
				end
				
				if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
					catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
					return
				end
				
				hook.Run( "PreItemTake", pl, itemTable )

				if ( IsValid( ent ) and itemTable.useDynamicItemData ) then
					catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
						uniqueID = itemTable.uniqueID,
						itemData = table.Count( ent:GetItemData( ) ) == table.Count( itemTable.itemData ) and ent:GetItemData( ) or itemTable.itemData
					} )
				else
					catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
						uniqueID = itemTable.uniqueID
					} )
				end

				ent:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 70 )
				ent:Remove( )
				
				hook.Run( "PostItemTake", pl, itemTable )
			end
		},
		drop = {
			text = "^Item_FuncStr02_Basic",
			icon = "icon16/basket_remove.png",
			canShowIsMenu = true,
			func = function( pl, itemTable )
				hook.Run( "PreItemDrop", pl, itemTable )
				
				local uniqueID = itemTable.uniqueID
				local ent = catherine.item.Spawn( uniqueID, catherine.util.GetItemDropPos( pl ), nil, itemTable.useDynamicItemData and catherine.inventory.GetItemDatas( pl, itemTable.uniqueID ) or { } )
				
				catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
					uniqueID = uniqueID
				} )
				
				ent:EmitSound( "physics/body/body_medium_impact_soft" .. math.random( 1, 7 ) .. ".wav", 70 )
				
				hook.Run( "PostItemDrop", pl, itemTable )
			end,
			canLook = function( pl, itemTable )
				return catherine.inventory.HasItem( itemTable.uniqueID )
			end
		}
	}
	itemTable.func = table.Merge( funcBuffer, itemTable.func or { } )
	
	catherine.item.items[ itemTable.uniqueID ] = itemTable
	
	if ( itemTable.OnRegistered ) then
		itemTable:OnRegistered( )
	end
end

function catherine.item.New( uniqueID, base_uniqueID, isBase )
	return { uniqueID = uniqueID, base = base_uniqueID, isBase = isBase }
end

function catherine.item.GetAll( )
	return catherine.item.items
end

function catherine.item.GetAllHook( )
	return catherine.item.hooks
end

function catherine.item.FindByID( id )
	return catherine.item.items[ id ]
end

function catherine.item.FindBaseByID( id )
	return catherine.item.bases[ id ]
end

function catherine.item.RegisterHook( hookID, itemTable, func )
	local hookUniqueID = "Catherine.hook.item." .. itemTable.uniqueID .. "." .. hookID
	
	hook.Add( hookID, hookUniqueID, function( ... )
		func( ... )
	end )
	catherine.item.hooks[ #catherine.item.hooks + 1 ] = { hookID, hookUniqueID }
end

function catherine.item.RemoveHook( hookID, itemTable )
	local hookUniqueID = "Catherine.hook.item." .. itemTable.uniqueID .. "." .. hookID
	
	hook.Remove( hookID, hookUniqueID )
	
	for k, v in pairs( catherine.item.hooks ) do
		if ( v[ 1 ] == hookID and v[ 2 ] == hookUniqueID ) then
			catherine.item.hooks[ k ] = nil
			return
		end
	end
end

function catherine.item.Include( dir )
	for k, v in pairs( file.Find( dir .. "/item/base/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/item/base/" .. v, "SHARED" )
	end
	
	local itemFiles, itemFolders = file.Find( dir .. "/item/*", "LUA" )
	
	table.RemoveByValue( itemFolders, "base" )
	
	for k, v in pairs( itemFolders ) do
		for k1, v1 in pairs( file.Find( dir .. "/item/" .. v .. "/*.lua", "LUA" ) ) do
			catherine.util.Include( dir .. "/item/" .. v .. "/" .. v1, "SHARED" )
		end
	end
	
	for k, v in pairs( itemFiles ) do
		catherine.util.Include( dir .. "/item/" .. v, "SHARED" )
	end
end

catherine.item.Include( catherine.FolderName .. "/framework" )

if ( SERVER ) then
	function catherine.item.Work( pl, uniqueID, funcID, ent_isMenu )
		local itemTable = catherine.item.FindByID( uniqueID )
		
		if ( !itemTable or !itemTable.func or !itemTable.func[ funcID ] ) then return end
		
		if ( hook.Run( "PlayerShouldWorkItem", pl, itemTable, funcID, ent_isMenu ) == false ) then
			return
		end
		
		itemTable.func[ funcID ].func( pl, itemTable, ent_isMenu )
	end
	
	function catherine.item.Give( pl, uniqueID, itemCount, force, itemData )
		if ( !force ) then
			local itemTable = catherine.item.FindByID( uniqueID )

			if ( itemTable and !catherine.inventory.HasSpace( pl, itemTable.weight * ( itemCount or 1 ) ) ) then
				return false, 1
			elseif ( !itemTable ) then
				return false, 2
			end
		end
		
		catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
			uniqueID = uniqueID,
			itemCount = itemCount,
			itemData = itemData
		} )

		return true
	end
	
	function catherine.item.Take( pl, uniqueID, itemCount )
		catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
			uniqueID = uniqueID,
			itemCount = itemCount
		} )
		
		return true
	end

	function catherine.item.Spawn( uniqueID, pos, ang, itemData )
		if ( !uniqueID or !pos ) then return end
		
		local itemTable = catherine.item.FindByID( uniqueID )
		
		if ( !itemTable ) then return end
		
		local ent = ents.Create( "cat_item" )
		ent:SetPos( Vector( pos.x, pos.y, pos.z + 10 ) )
		ent:SetAngles( ang or Angle( ) )
		ent:Spawn( )
		ent:SetModel( itemTable.GetDropModel and itemTable:GetDropModel( ) or itemTable.model )
		ent:SetSkin( itemTable.skin or 0 )
		
		if ( itemTable.color ) then
			ent:SetColor( itemTable.color )
		end
		
		if ( itemTable.material ) then
			ent:SetMaterial( itemTable.material )
		end
		
		ent:PhysicsInit( SOLID_VPHYSICS )
		ent:InitializeItem( uniqueID, itemData )
		
		local physObject = ent:GetPhysicsObject( )
		
		if ( !IsValid( physObject ) ) then
			local min, max = Vector( -8, -8, -8 ), Vector( 8, 8, 8 )
			
			ent:PhysicsInitBox( min, max )
			ent:SetCollisionBounds( min, max )
		end
		
		if ( IsValid( physObject ) ) then
			physObject:EnableMotion( true )
			physObject:Wake( )
		end
		
		return ent
	end

	netstream.Hook( "catherine.item.Work", function( pl, data )
		catherine.item.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ] )
	end )
	
	netstream.Hook( "catherine.item.Give", function( pl, data )
		catherine.item.Give( pl, data )
	end )
	
	netstream.Hook( "catherine.item.Take", function( pl, data )
		catherine.item.Take( pl, data )
	end )
else
	CAT_ITEM_OVERRIDE_DESC_TYPE_INVENTORY = 0
	CAT_ITEM_OVERRIDE_DESC_TYPE_BUSINESS = 1
	CAT_ITEM_OVERRIDE_DESC_TYPE_STORAGE = 2
	CAT_ITEM_OVERRIDE_DESC_TYPE_STORAGE_PLAYERINV = 3
	
	netstream.Hook( "catherine.item.EntityUseMenu", function( data )
		catherine.item.OpenEntityUseMenu( data )
	end )
	
	function catherine.item.Work( uniqueID, funcID, ent_isMenu )
		netstream.Start( "catherine.item.Work", {
			uniqueID,
			funcID,
			ent_isMenu
		} )
	end
	
	function catherine.item.OpenMenuUse( uniqueID )
		local pl = catherine.pl
		local itemTable = catherine.item.FindByID( uniqueID )
		
		if ( !itemTable ) then return end
		
		local menu = DermaMenu( )
		
		for k, v in pairs( itemTable.func or { } ) do
			if ( !v.canShowIsMenu or ( v.canLook and v.canLook( pl, itemTable ) == false ) ) then continue end
			
			menu:AddOption( v.preSetText and v.preSetText( pl, itemTable ) or catherine.util.StuffLanguage( v.text or "ERROR" ),
				function( )
					catherine.item.Work( uniqueID, k, true )
			end ):SetImage( v.icon or "icon16/information.png" )
		end
		
		menu:Open( )
	end
	
	function catherine.item.OpenEntityUseMenu( data )
		local pl = catherine.pl
		local ent = Entity( data[ 1 ] )
		local uniqueID = data[ 2 ]
		
		if ( !IsValid( ent ) or !IsValid( pl:GetEyeTrace( ).Entity ) or pl:GetActiveWeapon( ) == "weapon_physgun" ) then return end
		
		local itemTable = catherine.item.FindByID( uniqueID )
		
		if ( !itemTable ) then return end
		
		local isAv = false
		local menu = DermaMenu( )
		
		for k, v in pairs( itemTable.func or { } ) do
			if ( !v.canShowIsWorld or ( v.canLook and v.canLook( pl, itemTable ) == false ) ) then continue end
			
			menu:AddOption( v.preSetText and v.preSetText( pl, itemTable ) or catherine.util.StuffLanguage( v.text or "ERROR" ),
				function( )
					if ( IsValid( ent ) ) then
						catherine.item.Work( uniqueID, k, ent )
					end
				end ):SetImage( v.icon or "icon16/information.png" )
			
			isAv = true
		end
		
		menu:Open( )
		menu:Center( )
		
		if ( isAv ) then
			catherine.util.SetDermaMenuTitle( menu, LANG( "Basic_UI_ItemMenuOptionTitle" ) )
		end
	end
	
	function catherine.item.GetBasicDesc( itemTable )
		return catherine.util.StuffLanguage( itemTable.name ) .. "\n" .. catherine.util.StuffLanguage( itemTable.desc )
	end
end