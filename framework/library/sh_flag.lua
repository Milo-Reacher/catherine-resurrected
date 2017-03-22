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

catherine.flag = catherine.flag or { lists = { } }
local META = FindMetaTable( "Player" )

function catherine.flag.Register( uniqueID, desc, flagTable )
	flagTable = flagTable or { }
	
	table.Merge( flagTable, {
		uniqueID = uniqueID,
		desc = desc
	} )
	
	catherine.flag.lists[ uniqueID ] = flagTable
end

function catherine.flag.GetAll( )
	return catherine.flag.lists
end

function catherine.flag.FindByID( uniqueID )
	return catherine.flag.lists[ uniqueID ]
end

function catherine.flag.GetAllToString( )
	local flags = ""
	
	for k, v in pairs( catherine.flag.GetAll( ) ) do
		flags = flags .. k
	end
	
	return flags
end

catherine.flag.Register( "p", "^Flag_p_Desc", {
	onSpawn = function( pl )
		pl:Give( "weapon_physgun" )
	end,
	onGive = function( pl )
		pl:Give( "weapon_physgun" )
	end,
	onTake = function( pl )
		pl:StripWeapon( "weapon_physgun" )
	end
} )
catherine.flag.Register( "t", "^Flag_t_Desc", {
	onSpawn = function( pl )
		pl:Give( "gmod_tool" )
	end,
	onGive = function( pl )
		pl:Give( "gmod_tool" )
	end,
	onTake = function( pl )
		pl:StripWeapon( "gmod_tool" )
	end
} )
catherine.flag.Register( "e", "^Flag_e_Desc" )
catherine.flag.Register( "x", "^Flag_x_Desc" )
catherine.flag.Register( "V", "^Flag_V_Desc" )
catherine.flag.Register( "n", "^Flag_n_Desc" )
catherine.flag.Register( "R", "^Flag_R_Desc" )
catherine.flag.Register( "s", "^Flag_s_Desc" )
catherine.flag.Register( "i", "^Flag_i_Desc" )

if ( SERVER ) then
	function catherine.flag.Give( pl, flagID )
		if ( flagID == "" ) then
			return false, "Flag_Notify_NotValid", { flagID }
		end
		
		local ex = string.Explode( "", flagID )
		local flags = catherine.character.GetCharVar( pl, "flags", "" )
		local hasTable = { }
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			
			if ( catherine.flag.Has( pl, v ) ) then
				hasTable[ #hasTable + 1 ] = v
				ex[ k ] = nil
				continue
			end
			
			flags = flags .. v
			
			if ( flagTable.onGive ) then
				flagTable.onGive( pl )
			end
		end
		
		if ( table.Count( ex ) > 0 ) then
			local i = 1
			local buffer = { }
			
			for k, v in pairs( ex ) do
				buffer[ i ] = v
				i = i + 1
			end
			
			hook.Run( "PlayerFlagGived", pl, buffer )
			catherine.character.SetCharVar( pl, "flags", flags )
			netstream.Start( pl, "catherine.flag.BuildHelp" )
			
			return true, nil, { buffer }
		else
			return false, "Flag_Notify_AlreadyHas", { pl:Name( ), table.concat( hasTable, ", " ) }
		end
	end
	
	function catherine.flag.Take( pl, flagID )
		if ( flagID == "" ) then
			return false, "Flag_Notify_NotValid", { flagID }
		end
		
		local ex = string.Explode( "", flagID )
		local flags = catherine.character.GetCharVar( pl, "flags", "" )
		local hasntTable = { }
		
		for k, v in pairs( ex ) do
			local flagTable = catherine.flag.FindByID( v )
			
			if ( !flagTable ) then
				return false, "Flag_Notify_NotValid", { v }
			end
			
			if ( !catherine.flag.Has( pl, v ) ) then
				hasntTable[ #hasntTable + 1 ] = v
				ex[ k ] = nil
				continue
			end
			
			flags = flags:gsub( v, "" )
			
			if ( flagTable.onTake ) then
				flagTable.onTake( pl )
			end
		end
		
		if ( table.Count( ex ) > 0 ) then
			local i = 1
			local buffer = { }
			
			for k, v in pairs( ex ) do
				buffer[ i ] = v
				i = i + 1
			end
			
			hook.Run( "PlayerFlagTaked", pl, buffer )
			catherine.character.SetCharVar( pl, "flags", flags )
			netstream.Start( pl, "catherine.flag.BuildHelp" )
			
			return true, nil, { buffer }
		else
			return false, "Flag_Notify_HasNot", { pl:Name( ), table.concat( hasntTable, ", " ) }
		end
	end
	
	function catherine.flag.Has( pl, uniqueID )
		return tobool( catherine.character.GetCharVar( pl, "flags", "" ):find( uniqueID ) )
	end
	
	function META:HasFlag( uniqueID )
		return catherine.flag.Has( self, uniqueID )
	end
	
	function catherine.flag.PlayerSpawnedInCharacter( pl )
		for k, v in pairs( catherine.flag.GetAll( ) ) do
			if ( catherine.player.IsIgnoreGiveFlagWeapon( pl ) or !catherine.flag.Has( pl, k ) or !v.onSpawn ) then continue end
			
			v.onSpawn( pl )
		end
		
		if ( !pl.CAT_flag_buildHelp or pl.CAT_flag_buildHelp != pl:GetCharacterID( ) ) then
			netstream.Start( pl, "catherine.flag.BuildHelp" )
			pl.CAT_flag_buildHelp = pl:GetCharacterID( )
		end
	end
	
	function catherine.flag.PlayerFlagGived( pl, flag )
		netstream.Start( pl, "catherine.flag.BuildHelp" )
	end
	
	function catherine.flag.PlayerFlagTaked( pl, flag )
		netstream.Start( pl, "catherine.flag.BuildHelp" )
	end
	
	hook.Add( "PlayerSpawnedInCharacter", "catherine.flag.PlayerSpawnedInCharacter", catherine.flag.PlayerSpawnedInCharacter )
	hook.Add( "PlayerFlagGived", "catherine.flag.PlayerFlagGived", catherine.flag.PlayerFlagGived )
	hook.Add( "PlayerFlagTaked", "catherine.flag.PlayerFlagTaked", catherine.flag.PlayerFlagTaked )
	
	netstream.Hook( "catherine.flag.Scoreboard_PlayerOption06", function( pl, data )
		if ( !IsValid( data ) ) then return end
		
		netstream.Start( pl, "catherine.flag.Scoreboard_PlayerOption06_Receive", {
			data,
			catherine.character.GetCharVar( data, "flags", "" )
		} )
	end )
else
	local flag_htmlValue = [[
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
			}
		</style>
	</head>
	<body>
		<div class="container" style="margin-top:15px;">
		<div class="page-header">
			<h1>%s&nbsp&nbsp<small>%s</small></h1>
		</div>
		
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
	]]
	
	local function rebuildFlag( )
		local title_flag = LANG( "Help_Category_Flag" )
		local html = Format( flag_htmlValue, title_flag, LANG( "Help_Desc_Flag" ) )
		
		for k, v in SortedPairs( catherine.flag.GetAll( ) ) do
			html = html .. [[
				<div class="]] .. ( catherine.flag.Has( k ) and "panel panel-primary" or "panel panel-default" ) .. [[">
					<div class="panel-heading">
						<h3 class="panel-title">]] .. k .. [[</h3>
					</div>
						<div class="panel-body">]] .. catherine.util.StuffLanguage( v.desc ) .. [[</div>
				</div>
			]]
		end
		
		html = html .. [[</body></html>]]
		
		catherine.help.Register( CAT_HELP_HTML, title_flag, html, true )
	end
	
	netstream.Hook( "catherine.flag.BuildHelp", function( data )
		rebuildFlag( )
	end )
	
	netstream.Hook( "catherine.flag.Scoreboard_PlayerOption06_Receive", function( data )
		Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption06_Q" ), data[ 2 ] or "", function( val )
				if ( !IsValid( data[ 1 ] ) ) then return end
				
				catherine.command.Run( "&uniqueID_flagTake", data[ 1 ]:Name( ), val )
			end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
		)
	end )
	
	function catherine.flag.Has( uniqueID )
		return tobool( catherine.character.GetCharVar( catherine.pl, "flags", "" ):find( uniqueID ) )
	end
	
	function META:HasFlag( uniqueID )
		return catherine.flag.Has( uniqueID )
	end
	
	function catherine.flag.LanguageChanged( )
		rebuildFlag( )
	end
	
	function catherine.flag.InitPostEntity( )
		if ( IsValid( catherine.pl ) ) then
			rebuildFlag( )
		end
	end
	
	hook.Add( "LanguageChanged", "catherine.flag.LanguageChanged", catherine.flag.LanguageChanged )
	hook.Add( "InitPostEntity", "catherine.flag.InitPostEntity", catherine.flag.InitPostEntity )
	
	if ( IsValid( catherine.pl ) ) then
		rebuildFlag( )
	end
end