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
PLUGIN.name = "^Legs_Plugin_Name"
PLUGIN.author = "blackops7799, Valkyrie, robinkooli"
PLUGIN.desc = "^Legs_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Legs_Plugin_Name" ] = "Legs",
	[ "Legs_Plugin_Desc" ] = "Adding legs of first person view.",
	[ "Option_Str_LEG_Name" ] = "Show Legs",
	[ "Option_Str_LEG_Desc" ] = "Show legs on your body."
} )

catherine.language.Merge( "korean", {
	[ "Legs_Plugin_Name" ] = "다리",
	[ "Legs_Plugin_Desc" ] = "캐릭터 밑에 다리를 표시합니다.",
	[ "Option_Str_LEG_Name" ] = "캐릭터 다리 표시",
	[ "Option_Str_LEG_Desc" ] = "캐릭터 밑에 다리를 표시합니다."
} )

catherine.util.Include( "cl_plugin.lua" )