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

--[[
List of ammo types:
	AR2 - Ammunition of the AR2/Pulse Rifle
	AlyxGun - (name in-game "5.7mm Ammo")
	Pistol - Ammunition of the 9MM Pistol 
	SMG1 - Ammunition of the SMG/MP7
	357 - Ammunition of the .357 Magnum
	XBowBolt - Ammunition of the Crossbow
	Buckshot - Ammunition of the Shotgun
	RPG_Round - Ammunition of the RPG/Rocket Launcher
	SMG1_Grenade - Ammunition for the SMG/MP7 grenade launcher (secondary fire)
	SniperRound
	SniperPenetratedRound - (name in-game ".45 Ammo")
	Grenade - Note you must be given the grenade weapon (weapon_frag) before you can throw grenades.
	Thumper - Ammunition cannot exceed 2 (name in-game "Explosive C4 Ammo")
	Gravity - (name in-game "4.6MM Ammo")
	Battery - (name in-game "9MM Ammo")
	GaussEnergy 
	CombineCannon - (name in-game ".50 Ammo")
	AirboatGun - (name in-game "5.56MM Ammo")
	StriderMinigun - (name in-game "7.62MM Ammo")
	HelicopterGun
	AR2AltFire - Ammunition of the AR2/Pulse Rifle 'combine ball' (secondary fire)
	slam - Like Grenade, but for the Selectable Lightweight Attack Munition (S.L.A.M)
]]--

local BASE = catherine.item.New( "AMMO", nil, true )
BASE.name = "Ammo Base"
BASE.desc = "A Ammo."
BASE.category = "^Item_Category_Ammo"
BASE.cost = 0
BASE.weight = 0
BASE.isAmmo = true
BASE.ammoType = "Pistol"
BASE.amount = 40
BASE.func = { }
BASE.func.use = {
	text = "^Item_FuncStr01_Ammo",
	icon = "icon16/tag_blue.png",
	canShowIsWorld = true,
	canShowIsMenu = true,
	func = function( pl, itemTable, ent )
		pl:GiveAmmo( itemTable.amount, itemTable.ammoType, true )
		pl:EmitSound( "items/ammo_pickup.wav" )
		
		if ( type( ent ) == "Entity" ) then
			ent:Remove( )
		else
			catherine.inventory.Work( pl, CAT_INV_ACTION_REMOVE, {
				uniqueID = itemTable.uniqueID
			} )
		end
	end
}

if ( CLIENT ) then
	function BASE:DoRightClick( pl, itemData )
		catherine.item.Work( self.uniqueID, "use", true )
	end
end

catherine.item.Register( BASE )