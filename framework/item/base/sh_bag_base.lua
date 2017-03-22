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

local BASE = catherine.item.New( "BAG", nil, true )
BASE.name = "Bag Base"
BASE.desc = "A Bag."
BASE.category = "^Item_Category_Storage"
BASE.cost = 0
BASE.weight = 0
BASE.weightPlus = 10
BASE.isBag = true
BASE.func = { }
BASE.func.drop = {
	text = "^Item_FuncStr02_Basic",
	canShowIsMenu = true,
	canLook = function( pl, itemTable )
		local invWeight, invMaxWeight = catherine.inventory.GetWeights( )
		
		return invWeight < ( invMaxWeight - itemTable.weightPlus )
	end
}

catherine.item.Register( BASE )