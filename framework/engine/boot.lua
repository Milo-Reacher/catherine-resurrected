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

local DeriveGamemode = DeriveGamemode
local AddCSLuaFile = AddCSLuaFile
local include = include

DeriveGamemode( "sandbox" )

GM.Name = "Catherine"
GM.Description = "A neat and beautiful role-play framework for Garry's Mod."
GM.Author = "L7D"
GM.Website = "https://github.com/L7D/Catherine"
GM.Email = "smhjyh2009@gmail.com"
GM.Version = "1.0"
GM.Build = "CAT"

catherine.FolderName = GM.FolderName
catherine.UpdateLog = [[
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
	<style>
		@import url(http://fonts.googleapis.com/css?family=Open+Sans);
		body {
			font-family: "Open Sans", "나눔고딕", "NanumGothic", "맑은 고딕", "Malgun Gothic", "serif", "sans-serif"; 
			-webkit-font-smoothing: antialiased;
			width: %spx;
			max-width: %spx;
			margin: 0 auto;
		}
	</style>
</head>
<body>
	<div class="page-header">
		<h2><center>Catherine Update Log</center><small>Version ]] .. GM.Version .. [[</small></h2>
	</div>
	
	<div class="panel panel-default">
		<div class="panel-body">
			<h3 class="panel-title">Released the CATHERINE 1.0.</h3>
		</div>
	</div>
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
	</body>
</html>
]]

CreateConVar( "_cat_isUpdateMode", "0", { FCVAR_LUA_SERVER, FCVAR_LUA_CLIENT, FCVAR_REPLICATED } )

function catherine.Boot( )
	if ( SERVER and catherine.isInitialized and catherine.update.running ) then
		return
	end
	
	if ( SERVER and catherine.isInitialized and catherine.update.running ) then
		return
	end
	
	local sysTime = SysTime( )
	
	if ( SERVER ) then
		catherine.isUpdateMode = file.Read( "catherine/updatemode.txt", "DATA" ) or "0"
		
		if ( catherine.isUpdateMode:sub( 1, 1 ) == "1" ) then
			catherine.isUpdateMode = "1"
			RunConsoleCommand( "_cat_isUpdateMode", "1" )
		end
	end
	
	if ( CLIENT ) then
		catherine.isUpdateMode = GetConVarString( "_cat_isUpdateMode" )
	end
	
	if ( catherine.isUpdateMode == "1" ) then
		AddCSLuaFile( "catherine/framework/engine/external/sh_netstream2.lua" )
		AddCSLuaFile( "catherine/framework/engine/external/sh_pon.lua" )
		AddCSLuaFile( "catherine/framework/engine/external/sh_utf8.lua" )
		
		AddCSLuaFile( "catherine/framework/config/framework_config.lua" )
		AddCSLuaFile( "catherine/framework/x/sh_update_only_lib.lua" )
		AddCSLuaFile( "catherine/framework/library/sh_update.lua" )
		
		include( "catherine/framework/engine/external/sh_netstream2.lua" )
		include( "catherine/framework/engine/external/sh_pon.lua" )
		include( "catherine/framework/engine/external/sh_utf8.lua" )
		
		include( "catherine/framework/config/framework_config.lua" )
		include( "catherine/framework/x/sh_update_only_lib.lua" )
		include( "catherine/framework/library/sh_update.lua" )
		
		if ( !catherine.isInitialized ) then
			MsgC( Color( 255, 255, 0 ), "[CAT] Catherine framework are loaded at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec), using UPDATE MODE.\n" )
			catherine.isInitialized = true
		else
			MsgC( Color( 255, 255, 0 ), "[CAT] Catherine framework are refreshed at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec), using UPDATE MODE.\n" )
		end
	else
		AddCSLuaFile( "catherine/framework/engine/utility.lua" )
		include( "catherine/framework/engine/utility.lua" )
		
		AddCSLuaFile( "catherine/framework/config/framework_config.lua" )
		include( "catherine/framework/config/framework_config.lua" )
		
		AddCSLuaFile( "catherine/framework/engine/character.lua" )
		include( "catherine/framework/engine/character.lua" )
		
		AddCSLuaFile( "catherine/framework/engine/plugin.lua" )
		include( "catherine/framework/engine/plugin.lua" )
		
		catherine.util.IncludeInDir( "library" )
		
		AddCSLuaFile( "catherine/framework/engine/hook.lua" )
		include( "catherine/framework/engine/hook.lua" )
		
		AddCSLuaFile( "catherine/framework/engine/schema.lua" )
		include( "catherine/framework/engine/schema.lua" )
		
		if ( SERVER ) then
			AddCSLuaFile( "catherine/framework/engine/client.lua" )
			AddCSLuaFile( "catherine/framework/engine/shared.lua" )
			AddCSLuaFile( "catherine/framework/engine/lime.lua" )
			AddCSLuaFile( "catherine/framework/engine/external_x.lua" )
			AddCSLuaFile( "catherine/framework/engine/database.lua" )
			AddCSLuaFile( "catherine/framework/engine/dev.lua" )
			
			include( "catherine/framework/engine/server.lua" )
			include( "catherine/framework/engine/shared.lua" )
			include( "catherine/framework/engine/crypto.lua" )
			include( "catherine/framework/engine/crypto_v2.lua" )
			include( "catherine/framework/engine/data.lua" )
			include( "catherine/framework/engine/database.lua" )
			include( "catherine/framework/engine/resource.lua" )
			include( "catherine/framework/engine/external_x.lua" )
			include( "catherine/framework/engine/patchx.lua" )
			include( "catherine/framework/engine/lime.lua" )
			include( "catherine/framework/engine/dev.lua" )
			include( "catherine/framework/engine/external/sv_catherine.lua" )
		else
			include( "catherine/framework/engine/client.lua" )
			include( "catherine/framework/engine/shared.lua" )
			include( "catherine/framework/engine/lime.lua" )
			include( "catherine/framework/engine/external_x.lua" )
			include( "catherine/framework/engine/database.lua" )
			include( "catherine/framework/engine/dev.lua" )
		end
		
		catherine.util.IncludeInDir( "derma" )
		
		AddCSLuaFile( "catherine/framework/command/commands.lua" )
		include( "catherine/framework/command/commands.lua" )
		
		if ( !catherine.isInitialized ) then
			MsgC( Color( 0, 255, 0 ), "[CAT] Catherine framework are loaded at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec).\n" )
			catherine.isInitialized = true
		else
			MsgC( Color( 0, 255, 255 ), "[CAT] Catherine framework are refreshed at " .. math.Round( SysTime( ) - sysTime, 3 ) .. "(sec).\n" )
		end
		
		if ( SERVER and !catherine.database.connected ) then
			catherine.database.Connect( )
		end
	end
end

if ( SERVER ) then
	function catherine.UpdateModeReboot( pl )
		file.Write( "catherine/updatemode.txt", "1\n" .. GetConVarString( "gamemode" ) )
		file.Write( "catherine/updatemode_data.txt", pl:SteamID( ) .. "\n" .. GetConVarString( "hostname" ) )
		RunConsoleCommand( "gamemode", "catherine" )
		RunConsoleCommand( "changelevel", game.GetMap( ) )
	end
end

local getFunctionsData = {
	{ "GetName", "Name" },
	{ "GetAuthor", "Author" },
	{ "GetDescription", "Description" },
	{ "GetVersion", "Version" },
	{ "GetBuild", "Build" },
	{ "GetWebsite", "Website" },
	{ "GetEmail", "Email" }
}

for i = 1, #getFunctionsData do
	catherine[ getFunctionsData[ i ][ 1 ] ] = function( )
		return GAMEMODE[ getFunctionsData[ i ][ 2 ] ]
	end
end

catherine.Boot( )