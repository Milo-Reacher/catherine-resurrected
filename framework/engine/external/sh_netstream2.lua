--[[
	NetStream - 2.0.0

	Alexander Grist-Hucker
	http://www.revotech.org
	
	Credits to:
		thelastpenguin for pON.
		https://github.com/thelastpenguin/gLUA-Library/tree/master/pON
--]]

if ( !pon ) then
	AddCSLuaFile( "sh_pon.lua" )
	include( "sh_pon.lua" )
end

AddCSLuaFile( )

netstream = netstream or { stored = { } }

local type, error, pcall, pairs, player, table_concat, pon_encode, pon_decode, net_Start, net_Send, net_SendToServer, net_Receive, net_WriteString, net_ReadString, net_WriteUInt, net_ReadUInt, net_WriteData, net_ReadData = type, error, pcall, pairs, player, table.concat, pon.encode, pon.decode, net.Start, net.Send, net.SendToServer, net.Receive, net.WriteString, net.ReadString, net.WriteUInt, net.ReadUInt, net.WriteData, net.ReadData

function netstream.Split( data )
	local index, result, buffer = 1, { }, { }
	
	for i = 0, data:len( ) do
		buffer[ #buffer + 1 ] = data:sub( i, i )
		
		if ( #buffer == 32768 ) then
			result[ #result + 1 ] = table_concat( buffer )
			index = index + 1
			buffer = { }
		end
	end
	
	result[ #result + 1 ] = table_concat( buffer )
	
	return result
end

function netstream.Hook( name, func )
	netstream.stored[ name ] = func
end

if ( SERVER ) then
	util.AddNetworkString( "NetStream.DataStream" )
	
	function netstream.Start( pl, name, ... )
		local receiver, shouldSend = { }, false
		
		if ( type( pl ) != "table" ) then
			pl = pl and { pl } or player.GetAll( )
		end
		
		for k, v in pairs( pl ) do
			if ( type( v ) == "Player" ) then
				receiver[ #receiver + 1 ] = v
				
				shouldSend = true
			elseif ( type( k ) == "Player" ) then
				receiver[ #receiver + 1 ] = k
				
				shouldSend = true
			end
		end
		
		if ( shouldSend ) then
			local encodedData = pon_encode( { ... } )
			
			if ( encodedData and #encodedData > 0 ) then
				net_Start( "NetStream.DataStream" )
				net_WriteString( name )
				net_WriteUInt( #encodedData, 32 )
				net_WriteData( encodedData, #encodedData )
				net_Send( receiver )
			end
		end
	end
	
	net_Receive( "NetStream.DataStream", function( len, pl )
		local NET_NAME, NET_LEN = net_ReadString( ), net_ReadUInt( 32 )
		local NET_DATA = net_ReadData( NET_LEN )
		
		if ( NET_NAME and NET_DATA and NET_LEN ) then
			if ( netstream.stored[ NET_NAME ] ) then
				local success, value = pcall( pon_decode, NET_DATA )
				
				if ( success ) then
					netstream.stored[ NET_NAME ]( pl, unpack( value ) )
				else
					ErrorNoHalt( "\n[CAT NetStream ERROR] An error of run working on Netstream '" .. NET_NAME .. "' hook!\n\n" .. value .. "\n" )
				end
			end
		end
		
		NET_NAME, NET_DATA, NET_LEN = nil, nil, nil
	end )
else
	function netstream.Start( name, ... )
		local encodedData = pon_encode( { ... } )
		
		if ( encodedData and #encodedData > 0 ) then
			net_Start( "NetStream.DataStream" )
			net_WriteString( name )
			net_WriteUInt( #encodedData, 32 )
			net_WriteData( encodedData, #encodedData )
			net_SendToServer( )
		end
	end
	
	net_Receive( "NetStream.DataStream", function( len )
		local NET_NAME, NET_LEN = net_ReadString( ), net_ReadUInt( 32 )
		local NET_DATA = net_ReadData( NET_LEN )
		
		if ( NET_NAME and NET_DATA and NET_LEN ) then
			if ( netstream.stored[ NET_NAME ] ) then
				local success, value = pcall( pon_decode, NET_DATA )
			
				if ( success ) then
					netstream.stored[ NET_NAME ]( unpack( value ) )
				else
					ErrorNoHalt( "\n[CAT NetStream ERROR] An error of run working on Netstream '" .. NET_NAME .. "' hook!\n\n" .. value .. "\n" )
				end
			end
		end
		
		NET_NAME, NET_DATA, NET_LEN = nil, nil, nil
	end )
end