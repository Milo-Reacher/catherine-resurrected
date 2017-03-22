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

if ( !catherine.item ) then
	catherine.util.Include( "sh_item.lua" )
end

catherine.inventory = catherine.inventory or { }
local META = FindMetaTable( "Player" )

// Function Optimize.
local getCharVar = catherine.character.GetCharVar
local setVar = catherine.character.SetVar
local getVar = catherine.character.GetVar
local itemFindByID = catherine.item.FindByID
local math_max = math.max
local table_copy = table.Copy
local baseInvMaxWeight = catherine.configs.baseInventoryWeight

if ( SERVER ) then
	CAT_INV_ACTION_ADD = 1
	CAT_INV_ACTION_REMOVE = 2
	CAT_INV_ACTION_UPDATE = 3

	function catherine.inventory.Work( pl, workID, data )
		if ( getCharVar( pl, "charBanned" ) ) then return end

		if ( workID == CAT_INV_ACTION_ADD ) then
			local inventory = catherine.inventory.Get( pl )
			local uniqueID = data.uniqueID
			local itemCount = math_max( data.itemCount or 1, 1 ) or 1
			local invData = inventory[ uniqueID ]
			
			if ( invData ) then
				inventory[ uniqueID ] = {
					uniqueID = uniqueID,
					itemCount = invData.itemCount + itemCount,
					itemData = data.itemData or invData.itemData
				}
			else
				local itemTable = itemFindByID( uniqueID )
				
				if ( !itemTable ) then return end
				
				inventory[ uniqueID ] = {
					uniqueID = uniqueID,
					itemCount = itemCount,
					itemData = data.itemData or itemTable.itemData or { }
				}
			end

			setVar( pl, "_inv", inventory )
		elseif ( workID == CAT_INV_ACTION_REMOVE ) then
			local inventory = catherine.inventory.Get( pl )
			local uniqueID = data.uniqueID
			local invData = inventory[ uniqueID ]
			
			if ( invData ) then
				local itemCount = invData.itemCount - ( data.count or 1 )

				if ( itemCount > 0 ) then
					inventory[ uniqueID ] = {
						uniqueID = uniqueID,
						itemCount = itemCount,
						itemData = invData.itemData
					}
				else
					inventory[ uniqueID ] = nil
				end
				
				setVar( pl, "_inv", inventory )
			end
		elseif ( workID == CAT_INV_ACTION_UPDATE ) then
			local inventory = catherine.inventory.Get( pl )
			local uniqueID = data.uniqueID
			local invData = inventory[ uniqueID ]
			
			if ( invData ) then
				inventory[ uniqueID ] = {
					uniqueID = uniqueID,
					itemCount = invData.itemCount,
					itemData = data.newData
				}
				
				setVar( pl, "_inv", inventory )
			end
		end
	end

	function catherine.inventory.Get( pl )
		return table_copy( getVar( pl, "_inv", { } ) )
	end

	function catherine.inventory.GetInvItem( pl, uniqueID )
		return catherine.inventory.Get( pl )[ uniqueID ]
	end

	function catherine.inventory.IsEquipped( pl, uniqueID )
		return catherine.inventory.GetItemData( pl, uniqueID, "equiped", false )
	end

	function catherine.inventory.HasItem( pl, uniqueID )
		return catherine.inventory.Get( pl )[ uniqueID ] or false
	end

	function catherine.inventory.GetItemInt( pl, uniqueID )
		local inventory = catherine.inventory.Get( pl )

		return inventory[ uniqueID ] and inventory[ uniqueID ].itemCount or 0
	end
	
	function catherine.inventory.GetWeights( pl, customAdd )
		local invWeight = 0
		local invMaxWeight = baseInvMaxWeight
		
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = itemFindByID( k )
			
			if ( !itemTable ) then continue end

			if ( itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( v.itemCount * ( itemTable.weightPlus or 0 ) )
			end
			
			invWeight = invWeight + ( v.itemCount * itemTable.weight )
		end
		
		return invWeight + ( customAdd or 0 ), invMaxWeight
	end
	
	function catherine.inventory.GetOnlyMaxWeight( pl )
		local invMaxWeight = baseInvMaxWeight
		
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = itemFindByID( k )

			if ( itemTable and itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( v.itemCount * ( itemTable.weightPlus or 0 ) )
			end
		end
		
		return invMaxWeight
	end
	
	function catherine.inventory.HasSpace( pl, customAdd )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( pl, customAdd )
		
		return invWeight < invMaxWeight
	end
	
	function catherine.inventory.GetItemData( pl, uniqueID, key, default )
		local inventory = catherine.inventory.Get( pl )

		return inventory[ uniqueID ] and inventory[ uniqueID ].itemData[ key ] or default
	end
	
	function catherine.inventory.GetItemDatas( pl, uniqueID )
		local inventory = catherine.inventory.Get( pl )
		
		return inventory[ uniqueID ] and inventory[ uniqueID ].itemData or { }
	end
	
	function catherine.inventory.SetItemData( pl, uniqueID, key, newData )
		local itemData = catherine.inventory.GetItemDatas( pl, uniqueID )
		
		itemData[ key ] = newData
		
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = uniqueID,
			newData = itemData
		} )
	end
	
	function catherine.inventory.SetItemDatas( pl, uniqueID, newData )
		catherine.inventory.Work( pl, CAT_INV_ACTION_UPDATE, {
			uniqueID = uniqueID,
			newData = newData
		} )
	end
	
	function META:HasInvSpace( )
		return catherine.inventory.HasSpace( self )
	end
	
	function META:HasItem( uniqueID )
		return catherine.inventory.HasItem( self, uniqueID )
	end
	
	function META:GetInvItemData( uniqueID, key, default )
		return catherine.inventory.GetItemData( self, uniqueID, key, default )
	end
	
	function META:GetInvItemDatas( uniqueID )
		return catherine.inventory.GetItemDatas( self, uniqueID )
	end
	
	function META:SetInvItemData( uniqueID, key, newData )
		catherine.inventory.SetItemData( self, uniqueID, key, newData )
	end
	
	function META:SetInvItemDatas( uniqueID, newData )
		catherine.inventory.SetItemDatas( self, uniqueID, newData )
	end
	
	function catherine.inventory.CreateNetworkRegistry( pl, charVars )
		local inventory = charVars._inv or { }
		local changed = false
		
		for k, v in pairs( inventory ) do
			if ( itemFindByID( k ) ) then continue end
			
			inventory[ k ] = nil
			changed = true
		end
		
		if ( changed ) then
			setVar( pl, "_inv", inventory )
		end
	end

	hook.Add( "CreateNetworkRegistry", "catherine.inventory.CreateNetworkRegistry", catherine.inventory.CreateNetworkRegistry )
else
	function catherine.inventory.Get( )
		return table_copy( getVar( catherine.pl, "_inv", { } ) )
	end
	
	function catherine.inventory.GetInvItem( uniqueID )
		return catherine.inventory.Get( )[ uniqueID ]
	end

	function catherine.inventory.GetItemInt( uniqueID )
		local inventory = catherine.inventory.Get( )

		return inventory[ uniqueID ] and inventory[ uniqueID ].itemCount or 0
	end
	
	function catherine.inventory.HasItem( uniqueID )
		return catherine.inventory.Get( )[ uniqueID ]
	end
	
	function catherine.inventory.IsEquipped( uniqueID )
		return catherine.inventory.GetItemData( uniqueID, "equiped", false )
	end

	function catherine.inventory.GetWeights( customAdd )
		local invWeight = 0
		local invMaxWeight = baseInvMaxWeight
		
		for k, v in pairs( catherine.inventory.Get( ) ) do
			local itemTable = itemFindByID( k )
			
			if ( !itemTable ) then continue end
			
			if ( itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( v.itemCount * ( itemTable.weightPlus or 0 ) )
			end
			
			invWeight = invWeight + ( v.itemCount * itemTable.weight )
		end
		
		return invWeight + ( customAdd or 0 ), invMaxWeight
	end
	
	function catherine.inventory.GetOnlyMaxWeight( )
		local invMaxWeight = baseInvMaxWeight
		
		for k, v in pairs( catherine.inventory.Get( ) ) do
			local itemTable = itemFindByID( k )

			if ( itemTable and itemTable.isBag ) then
				invMaxWeight = invMaxWeight + ( v.itemCount * ( itemTable.weightPlus or 0 ) )
			end
		end
		
		return invMaxWeight
	end

	function catherine.inventory.GetItemData( uniqueID, key, default )
		local inventory = catherine.inventory.Get( )

		return inventory[ uniqueID ] and inventory[ uniqueID ].itemData[ key ] or default
	end
	
	function catherine.inventory.GetItemDatas( uniqueID )
		local inventory = catherine.inventory.Get( )

		return inventory[ uniqueID ] and inventory[ uniqueID ].itemData or { }
	end

	function catherine.inventory.HasSpace( customAdd )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( customAdd )
		
		return invWeight < invMaxWeight
	end
	
	function META:HasInvSpace( )
		return catherine.inventory.HasSpace( )
	end
	
	function META:HasItem( uniqueID )
		return catherine.inventory.HasItem( uniqueID )
	end
	
	function META:GetInvItemData( uniqueID, key, default )
		return catherine.inventory.GetItemData( uniqueID, key, default )
	end
	
	function META:GetInvItemDatas( uniqueID )
		return catherine.inventory.GetItemDatas( uniqueID )
	end
	
	function catherine.inventory.CharacterVarChanged( pl, key, value )
		if ( key == "_inv" ) then
			if ( IsValid( catherine.vgui.inventory ) and !catherine.vgui.inventory:IsHiding( ) ) then
				catherine.vgui.inventory:BuildInventory( )
			end
			
			if ( IsValid( catherine.vgui.storage ) ) then
				catherine.vgui.storage:InitializeStorage( catherine.vgui.storage.ent )
			end
		end
	end
	
	hook.Add( "CharacterVarChanged", "catherine.inventory.CharacterVarChanged", catherine.inventory.CharacterVarChanged )
end