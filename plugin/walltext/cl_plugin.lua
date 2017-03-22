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

netstream.Hook( "catherine.plugin.walltext.SyncText", function( data )
	local index = data.index
	
	if ( !PLUGIN.textLists[ index ] or ( PLUGIN.textLists[ index ] and PLUGIN.textLists[ index ].text != data.text ) ) then
		PLUGIN:DrawText( data )
	end
end )

netstream.Hook( "catherine.plugin.walltext.RemoveText", function( data )
	if ( !PLUGIN.textLists[ data ] ) then return end
	
	PLUGIN.textLists[ data ] = nil
end )

function PLUGIN:DrawText( data )
	local col = data.col
	local object = nil
	
	if ( col and table.HasValue( self.colorMap, col ) ) then
		object = catherine.markup.Parse( "<font=catherine_walltext><color=" .. col .. ">" .. data.text .. "</font></color>" )
	else
		object = catherine.markup.Parse( "<font=catherine_walltext>" .. data.text .. "</font>" )
	end
	
	function object:DrawText( text, font, x, y, col, hA, vA, a )
		col.a = a
		
		draw.SimpleText( text, font, x, y, col, 0, 1, 2, Color( 0, 0, 0, a ) )
	end
	
	self.textLists[ data.index ] = {
		pos = data.pos,
		ang = data.ang,
		text = data.text,
		object = object,
		size = data.size,
		col = data.col
	}
end

function PLUGIN:PostDrawTranslucentRenderables( )
	local pos = catherine.pl:GetPos( )
	
	for k, v in pairs( self.textLists ) do
		local a = catherine.util.GetAlphaFromDistance( pos, v.pos, 1000 )
		
		if ( a > 0 ) then
			cam.Start3D2D( v.pos, v.ang, v.size or 0.25 )
				v.object:Draw( 0, 0, 1, 1, a )
			cam.End3D2D( )
		end
	end
end

catherine.font.Register( "catherine_walltext", {
	font = catherine.configs.Font,
	size = 150,
	weight = 1000,
	outline = true
} )