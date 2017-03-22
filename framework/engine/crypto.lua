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

catherine.crypto = catherine.crypto or { libVersion = "2015-10-26" }

if ( !catherine.crypto.str and !catherine.crypto.mth and !catherine.crypto.tab ) then
	catherine.crypto.str = table.Copy( string )
	catherine.crypto.mth = table.Copy( math )
	catherine.crypto.tab = table.Copy( table )
end

if ( !catherine.crypto.Encode ) then
	catherine.crypto.Encode = function( str )
		local e, k = catherine.crypto.str.Explode( "", str ), 0
		
		for i = 1, #e do
			local rs = ""
			
			if ( k != 0 ) then
				for i2 = 1, k do
					local cr = catherine.crypto.str.char( catherine.crypto.mth.random( 65, 90 ) )
					
					rs = rs .. ( catherine.crypto.mth.random( 0, 1 ) == 1 and cr:lower( ) or cr )
				end
			end
			
			k = k + 1
			e[ i ] = e[ i ] .. rs
		end
		
		return catherine.crypto.tab.concat( e, "" )
	end
end

if ( !catherine.crypto.Decode ) then
	catherine.crypto.Decode = function( str )
		local r, s, e, p = { }, 1, 1, 1
		
		for i = 1, #str do
			local f = str:sub( s, e )
			
			if ( f == "" ) then break end
			
			p = p + 1
			s = s + ( p - 1 )
			e = e + p
			
			r[ #r + 1 ] = f:sub( 1, 1 )
		end
		
		return catherine.crypto.tab.concat( r, "" )
	end
end