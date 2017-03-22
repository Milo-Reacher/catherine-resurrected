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

catherine.font = catherine.font or { }

function catherine.font.Register( uniqueID, fontTable )
	surface.CreateFont( uniqueID, fontTable )
end

hook.Add( "SchemaInitialized", "catherine.font.SchemaInitialized", function( )
	local font = catherine.configs.Font

	for i = 1, 8 do
		local size = 10 + ( 5 * i )
		
		catherine.font.Register( "catherine_normal" .. size, {
			font = font,
			size = size,
			weight = 1000
		} )
		
		catherine.font.Register( "catherine_outline" .. size, {
			font = font,
			size = size,
			weight = 1000,
			outline = true
		} )
		
		catherine.font.Register( "catherine_italic" .. size, {
			font = font,
			size = size,
			weight = 1000,
			italic = true
		} )
		
		catherine.font.Register( "catherine_slight" .. size, {
			font = "Segoe UI",
			size = size,
			weight = 1000
		} )
		
		catherine.font.Register( "catherine_lightUI" .. size, {
			font = font,
			size = size,
			weight = 1000
		} )
		
		catherine.font.Register( "catherine_lightUIoutline" .. size, {
			font = font,
			size = size,
			weight = 1000,
			outline = true
		} )
	end

	catherine.font.Register( "catherine_chat", {
		font = "Segoe UI",
		size = 17,
		weight = 1000
	} )

	catherine.font.Register( "catherine_chat_italic", {
		font = "Segoe UI",
		size = 17,
		weight = 1000,
		italic = true
	} )
end )