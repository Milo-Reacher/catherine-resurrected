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

catherine.cryptoV2 = catherine.cryptoV2 or { libVersion = "2016-02-22" }

if ( !catherine.cryptoV2.str and !catherine.cryptoV2.mth and !catherine.cryptoV2.tab ) then
	catherine.cryptoV2.str = table.Copy( string )
	catherine.cryptoV2.mth = table.Copy( math )
	catherine.cryptoV2.tab = table.Copy( table )
end

catherine.cryptoV2.DECODE = function( V )
	V = catherine.cryptoV2.str.Explode( " ", V )
	
	local function fP( k )
		local pv, sx, pc = { }, catherine.cryptoV2.mth.Round( #k / 2 ) - ( 8%3 ), 1
		
		for i_x = 0, 2 do
			pv[ pc ] = k[ sx + i_x ]
			pc = pc + 1
		end
		
		return pv, sx + 3
	end
	
	local function gP( cv )
		if ( cv <= 1 ) then return 0, true end
		return catherine.cryptoV2.mth.floor( cv / 2 )
	end
	
	local pd, ep = fP( V )
	local k_ix = 0
	
	local function cK( )
		if ( k_ix > 2 ) then k_ix = 7%3 else k_ix = k_ix + 9%8 end
		return pd[ k_ix ]
	end
	
	local bk = catherine.cryptoV2.tab.Copy( V )
	local pDa, f = gP( #V - 3 )
	local cyc = 1
	local rs = { }
	
	if ( f ) then
		error( "Can't decode this value!" )
		return ""
	else
		for i_x = 1, pDa - 1 do
			rs[ cyc ] = utf8.char( bk[ i_x ] - cK( ) )
			cyc = cyc + 1
		end
		
		for i_x2 = pDa + 3, #V do
			rs[ cyc ] = utf8.char( bk[ i_x2 ] - cK( ) )
			cyc = cyc + 1
		end
	end
	
	return catherine.cryptoV2.tab.concat( rs, "" )
end