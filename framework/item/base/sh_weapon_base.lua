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

local BASE = catherine.item.New( "WEAPON", nil, true )
BASE.name = "Weapon Base"
BASE.desc = "A Weapon."
BASE.category = "^Item_Category_Weapon"
BASE.cost = 0
BASE.weight = 0
BASE.isWeapon = true
BASE.weaponClass = "weapon_smg1"
BASE.itemData = {
	equiped = false,
	clip1 = 0,
	clip2 = 0
}
BASE.useDynamicItemData = true
BASE.weaponType = "primary"
BASE.attachmentLimit = {
	primary = 1,
	secondary = 1,
	melee = 1
}
BASE.func = { }
BASE.func.equip = {
	text = "^Item_FuncStr01_Weapon",
	icon = "icon16/ruby_get.png",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( !catherine.inventory.HasSpace( pl, itemTable.weight ) and type( ent ) == "Entity" ) then
			catherine.util.NotifyLang( pl, "Inventory_Notify_HasNotSpace" )
			return
		end
		
		local playerWeaponType = catherine.character.GetCharVar( pl, "equippingWeaponTypes", { } )
		local itemWeaponType = itemTable.weaponType
		
		if (
			playerWeaponType[ itemWeaponType ] and
			( !itemTable.attachmentLimit[ itemWeaponType ] or
			playerWeaponType[ itemWeaponType ] >= itemTable.attachmentLimit[ itemWeaponType ] )
		) then
			catherine.util.NotifyLang( pl, "Item_Notify01_Weapon" )
			return
		end
		
		if ( type( ent ) == "Entity" ) then
			local itemData = ent:GetItemData( )
			
			itemData.equiped = nil
			
			catherine.item.Give( pl, itemTable.uniqueID, nil, nil, itemData )
			ent:Remove( )
		end
		
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			pl:StripWeapon( itemTable.weaponClass )
		end
		
		local wep = pl:Give( itemTable.weaponClass, true )
		
		if ( IsValid( wep ) ) then
			pl:SelectWeapon( itemTable.weaponClass )
			
			wep:SetClip1( catherine.inventory.GetItemData( pl, itemTable.uniqueID, "clip1", 0 ) )
			wep:SetClip2( catherine.inventory.GetItemData( pl, itemTable.uniqueID, "clip2", 0 ) )
			
			if ( playerWeaponType[ itemWeaponType ] ) then
				playerWeaponType[ itemWeaponType ] = playerWeaponType[ itemWeaponType ] + 1
			else
				playerWeaponType[ itemWeaponType ] = 1
			end
			
			catherine.attachment.Refresh( pl )
			
			pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
			pl:SetupHands( )
			catherine.character.SetCharVar( pl, "equippingWeaponTypes", playerWeaponType )
			catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", true )
		else
			ErrorNoHalt( "\n[CAT ERROR] On the Item <" .. itemTable.uniqueID .. "> called the weapon <" .. itemTable.weaponClass .. "> does not exist :< ...\n" )
		end
	end,
	canLook = function( pl, itemTable )
		return !catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}
BASE.func.unequip = {
	text = "^Item_FuncStr02_Weapon",
	icon = "icon16/ruby_put.png",
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( pl:HasWeapon( itemTable.weaponClass ) ) then
			local wep = pl:GetWeapon( itemTable.weaponClass )
			
			if ( IsValid( wep ) ) then
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "clip1", wep:Clip1( ) )
				catherine.inventory.SetItemData( pl, itemTable.uniqueID, "clip2", wep:Clip2( ) )
				pl:StripWeapon( itemTable.weaponClass )
			end
		end
		
		local playerWeaponType = catherine.character.GetCharVar( pl, "equippingWeaponTypes", { } )
		local itemWeaponType = itemTable.weaponType
		
		if ( playerWeaponType[ itemWeaponType ] ) then
			playerWeaponType[ itemWeaponType ] = playerWeaponType[ itemWeaponType ] - 1
			
			if ( playerWeaponType[ itemWeaponType ] <= 0 ) then
				playerWeaponType[ itemWeaponType ] = nil
			end
		end
		
		catherine.attachment.Refresh( pl )
		
		pl:EmitSound( "npc/combine_soldier/gear" .. math.random( 1, 6 ) .. ".wav", 40 )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", playerWeaponType )
		catherine.inventory.SetItemData( pl, itemTable.uniqueID, "equiped", false )
	end,
	canLook = function( pl, itemTable )
		return catherine.inventory.IsEquipped( itemTable.uniqueID )
	end
}

if ( SERVER ) then
	catherine.item.RegisterHook( "OnSpawnedInCharacter", BASE, function( pl )
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", { } )
		
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = catherine.item.FindByID( k )
			
			if ( !itemTable.isWeapon or !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			catherine.item.Work( pl, k, "equip" )
		end
		
		timer.Simple( 0, function( )
			if ( pl:HasWeapon( "cat_fist" ) ) then
				pl:SelectWeapon( "cat_fist" )
			end
		end )
	end )
	
	catherine.item.RegisterHook( "CharacterLoadingStart", BASE, function( pl )
		if ( !pl:IsCharacterLoaded( ) ) then return end
		
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = catherine.item.FindByID( k )
			
			if ( !itemTable.isWeapon or !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			local wep = pl:GetWeapon( itemTable.weaponClass )
			
			if ( IsValid( wep ) ) then
				catherine.inventory.SetItemData( pl, k, "clip1", wep:Clip1( ) )
				catherine.inventory.SetItemData( pl, k, "clip2", wep:Clip2( ) )
			end
		end
		
		catherine.character.SetCharVar( pl, "equippingWeaponTypes", { } )
	end )
	
	catherine.item.RegisterHook( "PlayerDeath", BASE, function( pl )
		for k, v in pairs( catherine.inventory.Get( pl ) ) do
			local itemTable = catherine.item.FindByID( k )
			
			if ( !itemTable.isWeapon or !catherine.inventory.IsEquipped( pl, k ) ) then continue end
			
			catherine.item.Work( pl, k, "unequip" )
			catherine.inventory.SetItemData( pl, k, "clip1", 0 )
			catherine.inventory.SetItemData( pl, k, "clip2", 0 )
			catherine.item.Spawn( k, pl:GetPos( ) )
			catherine.item.Take( pl, k )
		end
	end )
	
	catherine.item.RegisterHook( "PreItemDrop", BASE, function( pl, itemTable )
		if ( itemTable.isWeapon ) then
			catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
		end
	end )
	
	catherine.item.RegisterHook( "PreItemStorageMove", BASE, function( pl, ent, itemTable, data )
		if ( itemTable.isWeapon ) then
			catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
		end
	end )
	
	catherine.item.RegisterHook( "PreItemVendorSell", BASE, function( pl, ent, itemTable, data )
		if ( itemTable.isWeapon ) then
			catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
		end
	end )
	
	catherine.item.RegisterHook( "PreItemForceTake", BASE, function( pl, target, itemTable )
		if ( itemTable.isWeapon ) then
			catherine.item.Work( pl, itemTable.uniqueID, "unequip" )
		end
	end )
	
	catherine.item.RegisterHook( "DataSave", BASE, function( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			for k1, v1 in pairs( catherine.inventory.Get( v ) ) do
				local itemTable = catherine.item.FindByID( k1 )
				
				if ( !itemTable.isWeapon or !catherine.inventory.IsEquipped( v, k1 ) ) then continue end
				
				local wep = v:GetWeapon( itemTable.weaponClass )
				
				if ( IsValid( wep ) ) then
					catherine.inventory.SetItemData( v, k1, "clip1", wep:Clip1( ) )
					catherine.inventory.SetItemData( v, k1, "clip2", wep:Clip2( ) )
				end
			end
		end
	end )
else
	function BASE:DoRightClick( pl, itemData )
		if ( itemData.equiped ) then
			catherine.item.Work( self.uniqueID, "unequip", true )
		else
			catherine.item.Work( self.uniqueID, "equip", true )
		end
	end
end

catherine.item.Register( BASE )