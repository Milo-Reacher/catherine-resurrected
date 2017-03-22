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

catherine.block = catherine.block or { }
CAT_BLOCK_TYPE_ALL_CHAT = 0
CAT_BLOCK_TYPE_PM_CHAT = 1

if ( SERVER ) then
	catherine.block.lists = catherine.block.lists or { }
	
	function catherine.block.Register( pl, target, blockType )
		if ( !IsValid( target ) or !target:IsPlayer( ) ) then
			netstream.Start( pl, "catherine.block.RegisterResult", LANG( pl, "Entity_Notify_NotPlayer" ) )
			return
		end
		
		local data = catherine.block.lists[ pl:SteamID( ) ]
		
		for k, v in pairs( data ) do
			if ( v.steamID == target:SteamID( ) ) then
				netstream.Start( pl, "catherine.block.RegisterResult", LANG( pl, "Block_Notify_IsAlreadyBlocked" ) )
				return
			end
		end
		
		data[ #data + 1 ] = {
			steamID = target:SteamID( ),
			name = target:Name( ),
			blockType = blockType,
			time = catherine.util.GetRealTime( )
		}
		
		catherine.catData.SetVar( pl, "block", data, false, true )
		netstream.Start( pl, "catherine.block.RegisterResult", true )
	end
	
	function catherine.block.RegisterBySteamID( pl, targetSteamID, blockType )
		if ( !targetSteamID:match( "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
			netstream.Start( pl, "catherine.block.RegisterResult", LANG( pl, "Player_Message_IsNotSteamID" ) )
			return
		end
		
		local data = catherine.block.lists[ pl:SteamID( ) ]
		
		for k, v in pairs( data ) do
			if ( v.steamID == targetSteamID ) then
				netstream.Start( pl, "catherine.block.RegisterResult", LANG( pl, "Block_Notify_IsAlreadyBlocked" ) )
				return
			end
		end
		
		data[ #data + 1 ] = {
			steamID = targetSteamID,
			name = targetSteamID,
			blockType = blockType,
			time = catherine.util.GetRealTime( )
		}
		
		catherine.catData.SetVar( pl, "block", data, false, true )
		netstream.Start( pl, "catherine.block.RegisterResult", true )
	end
	
	function catherine.block.Remove( pl, target )
		local data = catherine.block.lists[ pl:SteamID( ) ] or { }
		
		for k, v in pairs( data ) do
			if ( v.steamID == target:SteamID( ) ) then
				table.remove( data, k )
				catherine.catData.SetVar( pl, "block", data, false, true )
				netstream.Start( pl, "catherine.block.RemoveResult", true )
				
				return
			end
		end
		
		netstream.Start( pl, "catherine.block.RemoveResult", "ERROR" )
	end
	
	function catherine.block.RemoveBySteamID( pl, targetSteamID )
		local data = catherine.block.lists[ pl:SteamID( ) ] or { }
		
		for k, v in pairs( data ) do
			if ( v.steamID == targetSteamID ) then
				table.remove( data, k )
				catherine.catData.SetVar( pl, "block", data, false, true )
				netstream.Start( pl, "catherine.block.RemoveResult", true )
				
				return
			end
		end
		
		netstream.Start( pl, "catherine.block.RemoveResult", "ERROR" )
	end
	
	function catherine.block.ChangeType( pl, targetSteamID, newType )
		local data = catherine.block.lists[ pl:SteamID( ) ] or { }
		
		for k, v in pairs( data ) do
			if ( v.steamID == targetSteamID ) then
				data[ k ].blockType = newType
				catherine.catData.SetVar( pl, "block", data, false, true )
				netstream.Start( pl, "catherine.block.ChangeTypeResult", true )
				
				return
			end
		end
		
		netstream.Start( pl, "catherine.block.ChangeTypeResult", "ERROR" )
	end
	
	function catherine.block.IsBlocked( pl, target, blockType )
		if ( !IsValid( pl ) or !IsValid( target ) ) then return false end
		
		local data = catherine.block.lists[ pl:SteamID( ) ] or { }
		
		for k, v in pairs( data ) do
			if ( v.steamID == target:SteamID( ) and ( blockType and table.HasValue( v.blockType, blockType ) ) ) then
				return true
			end
		end
		
		return false
	end
	
	function catherine.block.PlayerLoadFinished( pl )
		catherine.block.lists[ pl:SteamID( ) ] = catherine.catData.GetVar( pl, "block", { } )
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.block.PlayerLoadFinished", catherine.block.PlayerLoadFinished )
	
	netstream.Hook( "catherine.block.Register", function( pl, data )
		catherine.block.Register( pl, data[ 1 ], data[ 2 ] )
	end )
	
	netstream.Hook( "catherine.block.RegisterBySteamID", function( pl, data )
		catherine.block.RegisterBySteamID( pl, data[ 1 ], data[ 2 ] )
	end )
	
	netstream.Hook( "catherine.block.Remove", function( pl, data )
		catherine.block.Remove( pl, data )
	end )
	
	netstream.Hook( "catherine.block.RemoveBySteamID", function( pl, data )
		catherine.block.RemoveBySteamID( pl, data )
	end )
	
	netstream.Hook( "catherine.block.ChangeType", function( pl, data )
		catherine.block.ChangeType( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.block.RegisterResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.block ) ) then
				catherine.vgui.block:BuildBlock( )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.block.RemoveResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.block ) ) then
				catherine.vgui.block:BuildBlock( )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.block.ChangeTypeResult", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.block ) ) then
				catherine.vgui.block:BuildBlock( )
			end
		else
			Derma_Message( data, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	function catherine.block.GetList( )
		return catherine.catData.GetVar( "block", { } )
	end
	
	function catherine.block.IsBlocked( target, blockType )
		local data = catherine.block.GetList( )
		
		for k, v in pairs( data ) do
			if ( v.steamID == target:SteamID( ) and ( blockType and table.HasValue( v.blockType, blockType ) ) ) then
				return true
			end
		end
		
		return false
	end
end