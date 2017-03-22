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
PLUGIN.name = "^ToolUtil_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^ToolUtil_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "ToolUtil_Plugin_Name" ] = "Tool Utility",
	[ "ToolUtil_Plugin_Desc" ] = "Can be useful works using the tool gun."
} )

catherine.language.Merge( "korean", {
	[ "ToolUtil_Plugin_Name" ] = "툴 유틸리티",
	[ "ToolUtil_Plugin_Desc" ] = "유용한 작업을 툴건으로 가능합니다."
} )