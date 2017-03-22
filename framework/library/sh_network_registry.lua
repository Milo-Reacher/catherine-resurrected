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

catherine.net = catherine.net or { globalRegistry = { }, entityRegistry = { } }
local META = FindMetaTable( "Entity" )
local META2 = FindMetaTable( "Player" )

if ( SERVER ) then
	function catherine.net.SetNetVar( ent, key, value, noSync )
		local id = ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( )
		
		catherine.net.entityRegistry[ id ] = catherine.net.entityRegistry[ id ] or { }
		catherine.net.entityRegistry[ id ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				id,
				key,
				value
			} )
		end
	end
	
	function catherine.net.SetNetGlobalVar( key, value, noSync )
		catherine.net.globalRegistry[ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetGlobalVar", {
				key,
				value
			} )
		end
	end
	
	function META:SetNetVar( key, value, noSync )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		catherine.net.entityRegistry[ id ] = catherine.net.entityRegistry[ id ] or { }
		catherine.net.entityRegistry[ id ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				id,
				key,
				value
			} )
		end
	end
	
	function META2:SetNetVar( key, value, noSync )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		catherine.net.entityRegistry[ id ] = catherine.net.entityRegistry[ id ] or { }
		catherine.net.entityRegistry[ id ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( nil, "catherine.net.SetNetVar", {
				id,
				key,
				value
			} )
		end
	end
	
	function catherine.net.GetNetVar( ent, key, default )
		local id = ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function catherine.net.GetNetGlobalVar( key, default )
		return catherine.net.globalRegistry[ key ] or default
	end
	
	function META:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function META2:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function catherine.net.SendAllNetworkRegistries( pl )
		netstream.Start( pl, "catherine.net.SendAllNetworkRegistries", {
			catherine.net.entityRegistry,
			catherine.net.globalRegistry
		} )
	end
	
	function catherine.net.EntityRemoved( ent )
		local id = ent:EntIndex( )
		
		catherine.net.entityRegistry[ id ] = nil
		netstream.Start( nil, "catherine.net.ClearNetVar", id )
	end
	
	function catherine.net.PlayerDisconnected( pl )
		-- 네트워크 레지스트리가 바로 삭제되면 일부 데이터저장에서 문제가 발생합니다.
		local id = pl:SteamID( )
		
		timer.Simple( 2, function( )
			catherine.net.entityRegistry[ id ] = nil
			netstream.Start( nil, "catherine.net.ClearNetVar", id )
		end )
	end
	
	hook.Add( "EntityRemoved", "catherine.net.EntityRemoved", catherine.net.EntityRemoved )
	hook.Add( "PlayerDisconnected", "catherine.net.PlayerDisconnected", catherine.net.PlayerDisconnected )
else
	netstream.Hook( "catherine.net.SetNetVar", function( data )
		local steamID = data[ 1 ]
		
		catherine.net.entityRegistry[ steamID ] = catherine.net.entityRegistry[ steamID ] or { }
		catherine.net.entityRegistry[ steamID ][ data[ 2 ] ] = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.net.SetNetGlobalVar", function( data )
		catherine.net.globalRegistry[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.net.ClearNetVar", function( data )
		catherine.net.entityRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.net.ClearNetGlobalVar", function( data )
		catherine.net.globalRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.net.SendAllNetworkRegistries", function( data )
		catherine.net.entityRegistry = data[ 1 ]
		catherine.net.globalRegistry = data[ 2 ]
	end )
	
	function catherine.net.GetNetVar( ent, key, default )
		local id = ent:IsPlayer( ) and ent:SteamID( ) or ent:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function catherine.net.GetNetGlobalVar( key, default )
		return catherine.net.globalRegistry[ key ] or default
	end
	
	function META:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
	
	function META2:GetNetVar( key, default )
		local id = self:IsPlayer( ) and self:SteamID( ) or self:EntIndex( )
		
		return catherine.net.entityRegistry[ id ] and catherine.net.entityRegistry[ id ][ key ] or default
	end
end