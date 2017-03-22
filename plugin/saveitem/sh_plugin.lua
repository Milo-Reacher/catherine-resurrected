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
PLUGIN.name = "^SI_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SI_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "SI_Plugin_Name" ] = "Save Item",
	[ "SI_Plugin_Desc" ] = "Saving the items on the map."
} )

catherine.language.Merge( "korean", {
	[ "SI_Plugin_Name" ] = "아이템 저장",
	[ "SI_Plugin_Desc" ] = "맵에 떨어져 있는 아이템을 저장합니다."
} )

if ( CLIENT ) then return end

function PLUGIN:DataSave( )
	local data = { }
	
	for k, v in pairs( ents.FindByClass( "cat_item" ) ) do
		data[ #data + 1 ] = {
			uniqueID = v:GetItemUniqueID( ),
			itemData = v:GetItemData( ),
			pos = v:GetPos( ),
			ang = v:GetAngles( )
		}
	end
	
	catherine.data.Set( "items", data )
end

function PLUGIN:DataLoad( )
	for k, v in pairs( catherine.data.Get( "items", { } ) ) do
		catherine.item.Spawn( v.uniqueID, v.pos, v.ang, v.itemData )
	end
end