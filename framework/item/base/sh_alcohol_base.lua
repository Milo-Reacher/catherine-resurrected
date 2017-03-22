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

local BASE = catherine.item.New( "ALCOHOL", nil, true )
BASE.name = "Alcohol Base"
BASE.desc = "A Alcohol."
BASE.category = "^Item_Category_Alcohol"
BASE.cost = 0
BASE.weight = 1
BASE.isAlcohol = true
BASE.useDynamicItemData = false
BASE.attributeAdd = { }
BASE.attributeRemove = { }
BASE.headDamageAmount = 10
BASE.headDamageStartAmount = 2
BASE.staminaAdd = 10
BASE.hungerRemove = 0
BASE.thirstyRemove = 35
BASE.func = { }
BASE.func.drink = {
	text = "^Item_FuncStr01_Alcohol",
	icon = "icon16/rainbow.png",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		if ( type( ent ) == "Entity" ) then
			ent:Remove( )
		else
			catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
				uniqueID = itemTable.uniqueID
			} )
		end
		
		for k, v in pairs( itemTable.attributeAdd ) do
			catherine.attribute.AddTemporaryIncreaseProgress( pl, v.uniqueID, v.amount, v.removeTime or 300 )
		end
		
		for k, v in pairs( itemTable.attributeRemove ) do
			catherine.attribute.AddTemporaryDecreaseProgress( pl, v.uniqueID, v.amount, v.removeTime or 300 )
		end
		
		pl:EmitSound( table.Random( {
			"npc/barnacle/barnacle_gulp1.wav",
			"npc/barnacle/barnacle_gulp2.wav"
		} ), 100 )
		
		if ( itemTable.staminaAdd != 0 ) then
			catherine.character.SetCharVar( pl, "stamina", math.Clamp( catherine.character.GetCharVar( pl, "stamina", 0 ) + itemTable.staminaAdd, 0, 100 ) )
		end
		
		if ( itemTable.hungerRemove != 0 ) then
			catherine.character.SetCharVar( pl, "hunger", math.Clamp( catherine.character.GetCharVar( pl, "hunger", 0 ) - itemTable.hungerRemove, 0, 100 ) )
		end
		
		if ( itemTable.thirstyRemove != 0 ) then
			catherine.character.SetCharVar( pl, "thirsty", math.Clamp( catherine.character.GetCharVar( pl, "thirsty", 0 ) - itemTable.thirstyRemove, 0, 100 ) )
		end
		
		local stackTable = catherine.character.GetCharVar( pl, "alcohol_stack", { } )
		local stack = stackTable[ itemTable.uniqueID ] or 0
		
		if ( stack >= itemTable.headDamageStartAmount ) then
			catherine.limb.TakeDamage( pl, HITGROUP_HEAD, itemTable.headDamageAmount )
		else
			stack = stack + 1
			stackTable[ itemTable.uniqueID ] = stack
		end
		
		catherine.character.SetCharVar( pl, "alcohol_stack", stackTable )
	end
}

if ( SERVER ) then
	catherine.item.RegisterHook( "PlayerLimbDamageHealed", BASE, function( pl, hitGroup, limbData )
		if ( hitGroup == HITGROUP_HEAD and limbData == 0 and table.Count( catherine.character.GetCharVar( pl, "alcohol_stack", { } ) ) != 0 ) then
			catherine.character.SetCharVar( pl, "alcohol_stack", { } )
		end
	end )
else
	function BASE:DoRightClick( pl, itemData )
		catherine.item.Work( self.uniqueID, "drink", true )
	end
end

catherine.item.Register( BASE )