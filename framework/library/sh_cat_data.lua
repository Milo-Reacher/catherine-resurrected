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

catherine.catData = catherine.catData or { networkRegistry = { } }

if ( SERVER ) then
	local META = FindMetaTable( "Player" )
	local getSteamID = META.SteamID
	local isPlayer = META.IsPlayer
	
	function catherine.catData.SetVar( pl, key, value, noSync, save )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		catherine.catData.networkRegistry[ steamID ] = catherine.catData.networkRegistry[ steamID ] or { }
		catherine.catData.networkRegistry[ steamID ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( pl, "catherine.catData.SetVar", {
				key,
				value
			} )
		end
		
		if ( save ) then
			catherine.catData.Save( pl )
		end
	end
	
	function catherine.catData.GetVar( pl, key, default )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		return catherine.catData.networkRegistry[ steamID ] and catherine.catData.networkRegistry[ steamID ][ key ] or default
	end
	
	function catherine.catData.Save( pl, removeData )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		if ( hook.Run( "PlayerShouldSaveCatData", pl ) == false ) then return end
		local steamID = getSteamID( pl )
		
		if ( !catherine.catData.networkRegistry[ steamID ] ) then return end
		
		catherine.database.UpdateDatas( "catherine_players", "_steamID = '" .. steamID .. "'", {
			_catData = util.TableToJSON( catherine.catData.networkRegistry[ steamID ] ) or "[]"
		} )
		
		if ( removeData ) then
			catherine.catData.networkRegistry[ steamID ] = nil
		end
	end
	
	function catherine.catData.SendAllNetworkRegistries( pl )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		catherine.database.GetDatas( "catherine_players", "_steamID = '" .. steamID .. "'", function( data )
			if ( !data or !data[ 1 ] ) then return end
			
			catherine.catData.networkRegistry[ steamID ] = util.JSONToTable( data[ 1 ][ "_catData" ] ) or { }
			netstream.Start( pl, "catherine.catData.SendAllNetworkRegistries", catherine.catData.networkRegistry[ steamID ] )
		
			if ( !catherine.catData.GetVar( pl, "language" ) ) then
				catherine.player.UpdateLanguageSetting( pl )
			end
		end )
	end
	
	function catherine.catData.PlayerDisconnected( pl )
		catherine.catData.Save( pl, true )
	end
	
	hook.Add( "PlayerDisconnected", "catherine.catData.PlayerDisconnected", catherine.catData.PlayerDisconnected )
	
	netstream.Hook( "catherine.catData.SetVar", function( pl, data )
		catherine.catData.SetVar( pl, data[ 1 ], data[ 2 ], data[ 3 ], data[ 4 ] )
	end )
else
	netstream.Hook( "catherine.catData.SetVar", function( data )
		catherine.catData.networkRegistry[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.catData.Clear", function( data )
		catherine.catData.networkRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.catData.SendAllNetworkRegistries", function( data )
		catherine.catData.networkRegistry = data
	end )
	
	function catherine.catData.SetVar( key, value, noSync, save )
		netstream.Start( "catherine.catData.SetVar", {
			key,
			value,
			noSync,
			save
		} )
	end
	
	function catherine.catData.GetVar( key, default )
		return catherine.catData.networkRegistry[ key ] or default
	end
end