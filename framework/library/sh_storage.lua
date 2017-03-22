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

catherine.storage = catherine.storage or { }
CAT_STORAGE_ACTION_ADD = 1
CAT_STORAGE_ACTION_REMOVE = 2
CAT_STORAGE_ACTION_SETPASSWORD = 3
CAT_STORAGE_ACTION_SAVECASH = 4
CAT_STORAGE_ACTION_GETCASH = 5

if ( SERVER ) then
	catherine.storage.lists = { }

	function catherine.storage.Register( name, desc, model, maxWeight, openSound, closeSound )
		catherine.storage.lists[ #catherine.storage.lists + 1 ] = {
			name = name,
			desc = desc,
			model = model,
			maxWeight = maxWeight,
			openSound = openSound,
			closeSound = closeSound
		}
	end

	catherine.storage.Register( "Wardrobe", "The Wardrobe to put clothes.", "models/props_c17/FurnitureDresser001a.mdl", 8, "physics/wood/wood_box_impact_soft2.wav", "physics/wood/wood_box_impact_soft3.wav" )
	catherine.storage.Register( "Desk", "A Desk to put books.", "models/props_interiors/Furniture_Desk01a.mdl", 7, "physics/wood/wood_box_impact_soft2.wav", "physics/wood/wood_box_impact_soft3.wav" )
	catherine.storage.Register( "Oil drum", "A Oil drum to put Oil.", "models/props_c17/oildrum001.mdl", 5 )
	catherine.storage.Register( "Lockers", "A Lockers to put clothes.", "models/props_c17/Lockers001a.mdl", 12, "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard8.wav" )
	catherine.storage.Register( "Fridge", "A Fridge to put foods.", "models/props_c17/FurnitureFridge001a.mdl", 7, "physics/plastic/plastic_box_impact_soft2.wav", "physics/plastic/plastic_box_impact_soft4.wav" )
	catherine.storage.Register( "Storage", "A Storage to put anythings.", "models/props_wasteland/controlroom_filecabinet002a.mdl", 7, "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard8.wav" )
	catherine.storage.Register( "Desk", "A Desk.", "models/props_c17/FurnitureDrawer002a.mdl", 4, "physics/plastic/plastic_box_impact_soft2.wav", "physics/plastic/plastic_box_impact_soft4.wav" )
	catherine.storage.Register( "Small storage", "A Small storage to put anythings.", "models/props_wasteland/controlroom_filecabinet001a.mdl", 3, "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard8.wav" )
	catherine.storage.Register( "Small storage", "A Small storage to put anythings.", "models/props_lab/filecabinet02.mdl", 3, "physics/metal/metal_sheet_impact_hard6.wav", "physics/metal/metal_sheet_impact_hard8.wav" )
	catherine.storage.Register( "Trash bin", "A Trash bin to put garbage.", "models/props_junk/TrashBin01a.mdl", 5, "physics/wood/wood_box_impact_soft2.wav", "physics/wood/wood_box_impact_soft3.wav" )
	catherine.storage.Register( "Desk", "A Desk to put books.", "models/props_interiors/Furniture_Vanity01a.mdl", 7, "physics/wood/wood_box_impact_soft2.wav", "physics/wood/wood_box_impact_soft3.wav" )
	
	function catherine.storage.GetAll( )
		return catherine.storage.lists
	end
	
	function catherine.storage.FindByModel( model )
		for k, v in pairs( catherine.storage.GetAll( ) ) do
			if ( v.model:lower( ) == model:lower( ) ) then
				return v
			end
		end
	end
	
	function catherine.storage.Work( pl, ent, workID, data )
		ent = type( ent ) == "number" and Entity( ent ) or ent
		
		if ( !IsValid( pl ) or !IsValid( ent ) or !workID or !data ) then return end
		
		if ( hook.Run( "PlayerShouldWorkStorage", pl, ent, workID, data ) == false ) then
			return
		end
		
		if ( workID == CAT_STORAGE_ACTION_ADD ) then
			local uniqueID = data.uniqueID
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
				if ( uniqueID == "wallet" ) then
					catherine.util.StringReceiver( pl, "Storage_WalletAmountQ", LANG( pl, "Item_StoreQ_Wallet", catherine.cash.GetOnlySingular( ) ), catherine.cash.Get( pl ), function( _, amount )
						amount = tonumber( amount )
						
						if ( amount ) then
							if ( catherine.cash.Has( pl, amount ) ) then
								catherine.storage.Work( pl, ent, CAT_STORAGE_ACTION_SAVECASH, amount )
							else
								catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
							end
						else
							catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
						end
					end )
					
					return
				end
				
				catherine.util.NotifyLang( pl, "Inventory_Notify_isPersistent" )
				return
			end
			
			local weight, maxWeight = catherine.storage.GetWeights( ent, itemTable.weight )
			
			if ( weight >= maxWeight ) then
				catherine.util.NotifyLang( pl, "Storage_Notify_HasNotSpace" )
				return
			end
			
			hook.Run( "PreItemStorageMove", pl, ent, itemTable, data )
			
			local inventory = catherine.storage.GetInv( ent )
			local invData = inventory[ uniqueID ]

			if ( invData ) then
				inventory[ uniqueID ] = {
					uniqueID = invData.uniqueID,
					itemCount = invData.itemCount + 1,
					itemData = data.itemData or invData.itemData or itemTable.itemData or { }
				}
			else
				inventory[ uniqueID ] = {
					uniqueID = uniqueID,
					itemCount = 1,
					itemData = data.itemData or itemTable.itemData or { }
				}
			end

			catherine.item.Take( pl, uniqueID )
			catherine.storage.SetInv( ent, inventory )
			
			hook.Run( "PostItemStorageMove", pl, ent, itemTable, data )
		elseif ( workID == CAT_STORAGE_ACTION_REMOVE ) then
			local itemTable = catherine.item.FindByID( data )
			
			if ( !itemTable ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
				return
			end
			
			local inventory = catherine.storage.GetInv( ent )

			if ( !inventory[ data ] ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
				return
			end
			
			if ( itemTable.isPersistent ) then
				if ( data == "wallet" ) then
					local haveCash = inventory[ data ].itemData.amount
					
					catherine.util.StringReceiver( pl, "Storage_WalletAmountQ", LANG( pl, "Item_GetQ_Wallet", catherine.cash.GetOnlySingular( ) ), haveCash or 0, function( _, amount )
						amount = tonumber( amount )
						
						if ( amount ) then
							catherine.storage.Work( pl, ent, CAT_STORAGE_ACTION_GETCASH, amount )
						else
							catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
						end
					end )
					
					return
				end
				
				catherine.util.NotifyLang( pl, "Inventory_Notify_isPersistent" )
				return
			end
			
			if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) ) then
				catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
				return
			end
			
			hook.Run( "PreItemStorageTake", pl, ent, itemTable, data )
			
			local invData = inventory[ data ]
			local itemDataBuffer = invData.itemData
			
			inventory[ data ] = {
				uniqueID = invData.uniqueID,
				itemCount = math.max( invData.itemCount - 1, 0 ),
				itemData = invData.itemData
			}
			
			if ( inventory[ data ].itemCount <= 0 ) then
				inventory[ data ] = nil
			end
			
			catherine.inventory.Work( pl, CAT_INV_ACTION_ADD, {
				uniqueID = data,
				itemData = ( itemTable.useDynamicItemData and itemDataBuffer ) or itemTable.itemData
			} )
			
			catherine.storage.SetInv( ent, inventory )
			
			hook.Run( "PostItemStorageTake", pl, ent, itemTable, data )
		elseif ( workID == CAT_STORAGE_ACTION_SETPASSWORD ) then
			ent.password = data != "" and data or nil
		elseif ( workID == CAT_STORAGE_ACTION_SAVECASH ) then
			if ( type( data ) == "number" ) then
				if ( catherine.cash.Has( pl, data ) ) then
					local resultAmount = catherine.storage.GetCash( ent ) + data
					
					catherine.cash.Take( pl, data )
					catherine.storage.SetCash( ent, resultAmount )
					
					local inventory = catherine.storage.GetInv( ent )
					
					inventory[ "wallet" ] = {
						uniqueID = "wallet",
						itemCount = 1,
						itemData = {
							amount = resultAmount
						}
					}
					
					catherine.storage.SetInv( ent, inventory )
				else
					catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
				end
			end
		elseif ( workID == CAT_STORAGE_ACTION_GETCASH ) then
			if ( type( data ) == "number" ) then
				local cash = catherine.storage.GetCash( ent )
				
				if ( cash >= data and data > 0 ) then
					local inventory = catherine.storage.GetInv( ent )
					local resultAmount = math.max( cash - data, 0 )
					
					if ( inventory[ "wallet" ] ) then
						inventory[ "wallet" ] = {
							uniqueID = "wallet",
							itemCount = 1,
							itemData = {
								amount = resultAmount
							}
						}
						
						catherine.storage.SetInv( ent, inventory )
					end
					
					catherine.cash.Give( pl, data )
					catherine.storage.SetCash( ent, resultAmount )
				else
					catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
				end
			end
		end
		
		netstream.Start( pl, "catherine.storage.RefreshPanel", ent:EntIndex( ) )
	end
	
	function catherine.storage.Make( ent, data )
		local originalData = catherine.storage.FindByModel( ent:GetModel( ) )
		
		if ( !data ) then
			data = catherine.storage.FindByModel( ent:GetModel( ) )
			
			if ( !data ) then return end
		end
		
		if ( !originalData ) then return end

		ent.name = data.name or originalData.name
		ent.desc = data.desc or originalData.desc
		ent.inv = data.inv or { }
		ent.isStorage = true
		ent.maxWeight = data.maxWeight or originalData.maxWeight
		ent.password = data.password
		ent.cash = data.cash or 0

		ent:SetNetVar( "name", ent.name )
		ent:SetNetVar( "desc", ent.desc )
		ent:SetNetVar( "inv", ent.inv )
		ent:SetNetVar( "cash", ent.cash )
		ent:SetNetVar( "maxWeight", ent.maxWeight )
		ent:SetNetVar( "isStorage", true )

		catherine.entity.RegisterUseMenu( ent, {
			{
				uniqueID = "ID_OPEN",
				text = "^Storage_OpenStr",
				icon = "icon16/eye.png",
				func = function( pl, ent )
					if ( !ent.CAT_storageOpenSound ) then
						local storageListData = catherine.storage.FindByModel( ent:GetModel( ) )
						
						if ( storageListData and storageListData.openSound ) then
							ent.CAT_storageOpenSound = storageListData.openSound
						else
							ent.CAT_storageOpenSound = ""
						end
					end

					if ( ent.CAT_storageOpenSound and ent.CAT_storageOpenSound != "" ) then
						ent:EmitSound( ent.CAT_storageOpenSound )
					end

					if ( ent.password ) then
						catherine.util.StringReceiver( pl, "Storage_Open_PWD", "^Storage_PWDQ", "", function( _, pwd )
							if ( ent.password == pwd ) then
								netstream.Start( pl, "catherine.storage.Use", ent:EntIndex( ) )
							else
								catherine.util.NotifyLang( pl, "Storage_Notify_PWDError" )
							end
						end )
					else
						netstream.Start( pl, "catherine.storage.Use", ent:EntIndex( ) )
					end
				end
			}
		} )
		
		return true
	end

	function catherine.storage.SetInv( ent, data )
		ent.inv = data
		ent:SetNetVar( "inv", data )
	end
	
	function catherine.storage.SetCash( ent, amount )
		ent.cash = amount
		ent:SetNetVar( "cash", amount )
	end
	
	function catherine.storage.GetInv( ent )
		return table.Copy( ent.inv or { } )
	end
	
	function catherine.storage.GetCash( ent )
		return ent.cash or 0
	end
	
	function catherine.storage.GetWeights( ent, customAdd )
		local inventory = catherine.storage.GetInv( ent )
		local weight = 0
		local maxWeight = ent.maxWeight or 0
		
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			
			weight = weight + ( itemTable.weight * v.itemCount )
		end
		
		return weight + ( customAdd or 0 ), maxWeight
	end
	
	function catherine.storage.GetItemInt( ent, uniqueID )
		local inventory = catherine.storage.GetInv( ent )
		
		return inventory[ uniqueID ] and inventory[ uniqueID ].itemCount or 0
	end

	function catherine.storage.GetDataByIndex( ent, data )
		for k, v in pairs( data ) do
			local pos = ent:GetPos( )
			local customEnt = nil
			
			if ( !ent:IsMapEntity( ) and v.pos ) then
				customEnt = ents.FindInSphere( v.pos, 16 )
				
				for k1, v1 in pairs( customEnt ) do
					if ( v1:GetClass( ) == "prop_physics" and v.model == v1:GetModel( ) and ent.CAT_staticIndex == v1.CAT_staticIndex ) then
						customEnt = v1
						break
					end
				end
			end

			if ( ( v.index and v.index == ent:EntIndex( ) ) or ( customEnt and IsValid( customEnt ) and !customEnt:IsMapEntity( ) ) ) then
				return v
			end
		end
	end
	
	function catherine.storage.DataSave( )
		local data = { }
		local i = 1
		
		for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
			if ( !v.isStorage ) then continue end

			data[ i ] = {
				inv = v.inv,
				password = v.password
			}
			
			if ( v:IsMapEntity( ) ) then
				data[ i ].index = v:EntIndex( )
			else
				data[ i ].pos = v:GetPos( )
				data[ i ].model = v:GetModel( )
				data[ i ].staticIndex = v.CAT_staticIndex
			end
			
			i = i + 1
		end
		
		catherine.data.Set( "storage", data )
	end

	function catherine.storage.DataLoad( )
		timer.Simple( 1, function( )
			local data = catherine.data.Get( "storage", { } )

			for k, v in pairs( ents.FindByClass( "prop_physics" ) ) do
				catherine.storage.Make( v, catherine.storage.GetDataByIndex( v, data ) )
			end
		end )
	end

	local plugin = catherine.plugin.Get( "permanententity" )
	
	function catherine.storage.PlayerSpawnedProp( pl, _, ent )
		timer.Simple( 1, function( )
			if ( IsValid( ent ) ) then
				local success = catherine.storage.Make( ent )

				if ( plugin and success ) then
					ent.CAT_isStorageCustom = true
					
					ent:SetNetVar( "isStatic", true )
				end
			end
		end )
	end

	hook.Add( "DataSave", "catherine.storage.DataSave", catherine.storage.DataSave )
	hook.Add( "PlayerSpawnedProp", "catherine.storage.PlayerSpawnedProp", catherine.storage.PlayerSpawnedProp )
	
	netstream.Hook( "catherine.storage.Work", function( pl, data )
		catherine.storage.Work( pl, data[ 1 ], data[ 2 ], data[ 3 ] )
	end )

	netstream.Hook( "catherine.storage.ClosePanel", function( pl, data )
		if ( IsValid( data ) ) then
			if ( !data.CAT_storageCloseSound ) then
				local storageListData = catherine.storage.FindByModel( data:GetModel( ) )
				
				if ( storageListData and storageListData.closeSound ) then
					data.CAT_storageCloseSound = storageListData.closeSound
				else
					data.CAT_storageCloseSound = ""
				end
			end

			if ( data.CAT_storageCloseSound and data.CAT_storageCloseSound != "" ) then
				data:EmitSound( data.CAT_storageCloseSound )
			end
		end
	end )
else
	netstream.Hook( "catherine.storage.Use", function( data )
		if ( IsValid( catherine.vgui.storage ) ) then
			catherine.vgui.storage:Remove( )
			catherine.vgui.storage = nil
		end
		
		catherine.vgui.storage = vgui.Create( "catherine.vgui.storage" )
		catherine.vgui.storage:InitializeStorage( Entity( data ) )
	end )
	
	netstream.Hook( "catherine.storage.RefreshPanel", function( data )
		if ( IsValid( catherine.vgui.storage ) ) then
			catherine.vgui.storage:InitializeStorage( Entity( data ) )
		end
	end )
	
	function catherine.storage.GetInv( ent )
		return table.Copy( ent:GetNetVar( "inv", { } ) )
	end
	
	function catherine.storage.GetCash( ent )
		return ent:GetNetVar( "cash", 0 )
	end
	
	function catherine.storage.GetWeights( ent, customAdd )
		local inventory = catherine.storage.GetInv( ent )
		local weight = 0
		local maxWeight = ent:GetNetVar( "maxWeight" ) or 0
		
		for k, v in pairs( inventory ) do
			local itemTable = catherine.item.FindByID( k )
			if ( !itemTable ) then continue end
			
			weight = weight + ( itemTable.weight * v.itemCount )
		end
		
		return weight + ( customAdd or 0 ), maxWeight
	end

	function catherine.storage.GetItemInt( ent, uniqueID )
		local inventory = catherine.storage.GetInv( ent )
		
		return inventory[ uniqueID ] and inventory[ uniqueID ].itemCount or 0
	end
	
	local toscreen = FindMetaTable( "Vector" ).ToScreen
	
	function catherine.storage.DrawEntityTargetID( pl, ent, a )
		if ( !ent:GetNetVar( "isStorage", false ) ) then return end
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( ent:GetNetVar( "name", "" ), "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		draw.SimpleText( ent:GetNetVar( "desc", "" ), "catherine_outline20", x, y + 25, Color( 255, 255, 255, a ), 1, 1 )
	end
	
	hook.Add( "DrawEntityTargetID", "catherine.storage.DrawEntityTargetID", catherine.storage.DrawEntityTargetID )
end