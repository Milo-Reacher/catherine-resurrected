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

catherine.plugin = catherine.plugin or { lists = { } }
catherine.plugin.extras = { }

CAT_HOOK_PLUGIN_CACHES = { }
CAT_LUA_REFRESHING = CAT_LUA_REFRESHING or false

local plugin_htmlValue = [[
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

local function rebuildPlugin( )
	local title_plugin = LANG( "Help_Category_Plugin" )
	local html = Format( plugin_htmlValue, title_plugin, LANG( "Help_Desc_Plugin" ) )
	
	for k, v in SortedPairs( catherine.plugin.GetAll( ) ) do
		if ( v.isDisabled ) then continue end
		
		html = html .. [[
			<div class="panel panel-default">
				<div class="panel-heading">
					<h3 class="panel-title">]] .. catherine.util.StuffLanguage( v.name ) .. [[</h3>
				</div>
					<div class="panel-body">]] .. catherine.util.StuffLanguage( v.desc ) .. [[<br>]] .. LANG( "Plugin_Value_Author", v.author ) .. [[
					</div>
			</div>
		]]
	end
	
	html = html .. [[</body></html>]]
	
	catherine.help.Register( CAT_HELP_HTML, title_plugin, html, true )
end

function catherine.plugin.Include( dir )
	local _, folders = file.Find( dir .. "/plugin/*", "LUA" )
	
	for k, v in pairs( folders ) do
		if ( !catherine.plugin.GetActive( v ) ) then
			if ( SERVER ) then
				catherine.plugin.deactivePlugins[ v ] = {
					uniqueID = v,
					FolderName = dir .. "/plugin/" .. v,
					isSchema = dir:lower( ) == "catherine" and "a" or "b",
					isDisabled = true,
					isLoaded = false
				}
			end
			
			local pluginTable = catherine.plugin.Get( v )
			
			if ( pluginTable ) then
				pluginTable.isDisabled = true
				pluginTable.isLoaded = false
			end
			
			continue
		end
		
		PLUGIN = catherine.plugin.Get( v ) or {
			uniqueID = v,
			FolderName = dir .. "/plugin/" .. v,
			isSchema = dir:lower( ) == "catherine" and "a" or "b",
			isDisabled = false,
			isLoaded = true
		}
		
		local pluginDir = PLUGIN.FolderName
		
		if ( file.Exists( pluginDir .. "/sh_plugin.lua", "LUA" ) ) then
			catherine.util.Include( pluginDir .. "/sh_plugin.lua" )
			
			catherine.item.Include( pluginDir )
			catherine.faction.Include( pluginDir )
			catherine.class.Include( pluginDir )
			catherine.attribute.Include( pluginDir )
			
			catherine.plugin.IncludeEntities( pluginDir )
			catherine.plugin.IncludeWeapons( pluginDir )
			catherine.plugin.IncludeEffects( pluginDir )
			catherine.plugin.IncludeTools( pluginDir )
			
			for k1, v1 in pairs( catherine.plugin.GetAllExtras( ) ) do
				for k2, v2 in pairs( file.Find( pluginDir .. "/" .. v1.folderName .. "/*.lua", "LUA" ) ) do
					catherine.util.Include( pluginDir .. "/" .. v1.folderName .. "/" .. v2, v1.typ )
				end
			end
			
			for k1, v1 in pairs( PLUGIN ) do
				if ( type( v1 ) == "function" ) then
					CAT_HOOK_PLUGIN_CACHES[ k1 ] = CAT_HOOK_PLUGIN_CACHES[ k1 ] or { }
					CAT_HOOK_PLUGIN_CACHES[ k1 ][ PLUGIN ] = v1
				end
			end
			
			catherine.plugin.lists[ v ] = PLUGIN
		else
			MsgC( Color( 255, 0, 0 ), "[CAT ERROR] SORRY, The plugin <" .. v .. "> are do not have files named sh_plugin.lua, failed to loading it ...\n" )
		end
		
		PLUGIN = nil
	end
	
	if ( CLIENT ) then
		rebuildPlugin( )
	end
end

--[[
	catherine.plugin.Refresh( )
	
	This function is too Danger!
		Do not run this. :<
]]--
function catherine.plugin.Refresh( )
	if ( CAT_LUA_REFRESHING ) then return end
	
	CAT_LUA_REFRESHING = true
	CAT_HOOK_PLUGIN_CACHES = { }
	
	if ( SERVER ) then
		catherine.plugin.deactivePlugins = { }
	end
	
	if ( Schema ) then
		catherine.plugin.Include( Schema.Name )
	end
	
	catherine.plugin.Include( catherine.FolderName )
	
	DeriveGamemode( "catherine" )
	catherine.schema.Initialization( )
	
	CAT_LUA_REFRESHING = false
end

function catherine.plugin.RegisterExtras( folderName, typ )
	catherine.plugin.extras[ #catherine.plugin.extras + 1 ] = {
		folderName = folderName,
		typ = typ
	}
end

catherine.plugin.RegisterExtras( "derma" )
catherine.plugin.RegisterExtras( "library" )

function catherine.plugin.GetAll( )
	return catherine.plugin.lists
end

function catherine.plugin.GetAllExtras( )
	return catherine.plugin.extras
end

function catherine.plugin.Get( id )
	return catherine.plugin.lists[ id ]
end

function catherine.plugin.IncludeEntities( dir )
	local files, folders = file.Find( dir .. "/entities/entities/*", "LUA" )
	
	for k, v in pairs( files ) do
		ENT = { Type = "anim", Base = "base_gmodentity", ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/entities/" .. v, "SHARED" )
		scripted_ents.Register( ENT, ENT.ClassName )
		
		ENT = nil
	end
	
	for k, v in pairs( folders ) do
		ENT = { Type = "anim", Base = "base_gmodentity", ClassName = v }
		
		if ( SERVER ) then
			if ( file.Exists( dir .. "/entities/entities/" .. v .. "/init.lua", "LUA" ) ) then
				include( dir .. "/entities/entities/" .. v .. "/init.lua" )
			elseif ( file.Exists( dir .. "/entities/entities/" .. v .. "/shared.lua", "LUA" ) ) then
				include( dir .. "/entities/entities/" .. v .. "/shared.lua" )
			end
			
			if ( file.Exists( dir .. "/entities/entities/" .. v .. "/cl_init.lua", "LUA" ) ) then
				AddCSLuaFile( dir .. "/entities/entities/" .. v .. "/cl_init.lua" )
			end
		elseif ( file.Exists( dir .. "/entities/entities/" .. v .. "/cl_init.lua", "LUA" ) ) then
			include( dir .. "/entities/entities/" .. v .. "/cl_init.lua" )
		elseif ( file.Exists( dir .. "/entities/entities/" .. v .. "/shared.lua", "LUA" ) ) then
			include( dir .. "/entities/entities/" .. v .. "/shared.lua" )
		end
		
		scripted_ents.Register( ENT, ENT.ClassName )
		
		ENT = nil
	end
end

function catherine.plugin.IncludeWeapons( dir )	
	local files, folders = file.Find( dir .. "/entities/weapons/*", "LUA" )
	
	for k, v in pairs( files ) do
		SWEP = { Base = "weapon_base", Primary = { }, Secondary = { }, ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/weapons/" .. v, "SHARED" )
		weapons.Register( SWEP, SWEP.ClassName )
		
		SWEP = nil
	end
	
	for k, v in pairs( folders ) do
		SWEP = { Base = "weapon_base", Primary = { }, Secondary = { }, ClassName = v }
		
		if ( SERVER ) then
			if ( file.Exists( dir .. "/entities/weapons/" .. v .. "/init.lua", "LUA" ) ) then
				include( dir .. "/entities/weapons/" .. v .. "/init.lua" )
			elseif ( file.Exists( dir .. "/entities/weapons/" .. v .. "/shared.lua", "LUA" ) ) then
				include( dir .. "/entities/weapons/" .. v .. "/shared.lua" )
			end
			
			if ( file.Exists( dir .. "/entities/weapons/" .. v .. "/cl_init.lua", "LUA" ) ) then
				AddCSLuaFile( dir .. "/entities/weapons/" .. v .. "/cl_init.lua" )
			end
		elseif ( file.Exists( dir .. "/entities/weapons/" .. v .. "/cl_init.lua", "LUA" ) ) then
			include( dir .. "/entities/weapons/" .. v .. "/cl_init.lua" )
		elseif ( file.Exists( dir .. "/entities/weapons/" .. v .. "/shared.lua", "LUA" ) ) then
			include( dir .. "/entities/weapons/" .. v .. "/shared.lua" )
		end
		
		weapons.Register( SWEP, SWEP.ClassName )
		
		SWEP = nil
	end
end

function catherine.plugin.IncludeEffects( dir )
	local files, folders = file.Find( dir .. "/entities/effects/*", "LUA" )
	
	for k, v in pairs( files ) do
		EFFECT = { ClassName = v:sub( 1, #v - 4 ) }
		
		catherine.util.Include( dir .. "/entities/effects/" .. v, "SHARED" )
		
		if ( CLIENT ) then
			effects.Register( EFFECT, EFFECT.ClassName )
		end
		
		EFFECT = nil
	end
	
	for k, v in pairs( folders ) do
		if ( SERVER ) then
			if ( file.Exists( dir .. "/entities/effects/" .. v .. "/cl_init.lua", "LUA" ) ) then
				AddCSLuaFile( dir .. "/entities/effects/" .. v .. "/cl_init.lua" )
			elseif ( file.Exists( dir .. "/entities/effects/" .. v .. "/init.lua", "LUA" ) ) then
				AddCSLuaFile( dir .. "/entities/effects/" .. v .. "/init.lua" )
			end
		elseif ( file.Exists( dir .. "/entities/effects/" .. v .. "/cl_init.lua", "LUA" ) ) then
			EFFECT = { ClassName = v }
			
			include( dir .. "/entities/effects/" .. v .. "/cl_init.lua" )
			effects.Register( EFFECT, EFFECT.ClassName )
			
			EFFECT = nil
		elseif ( file.Exists( dir .. "/entities/effects/" .. v .. "/init.lua", "LUA" ) ) then
			EFFECT = { ClassName = v }
			
			include( dir .. "/entities/effects/" .. v .. "/init.lua" )
			effects.Register( EFFECT, EFFECT.ClassName )
			
			EFFECT = nil
		end
	end
end

function catherine.plugin.IncludeTools( dir )
	for k, v in pairs( file.Find( dir .. "/tools/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/tools/" .. v, "SHARED" )
	end
end

function catherine.plugin.FrameworkInitialized( )
	local toolGun = weapons.GetStored( "gmod_tool" )
	
	for k, v in pairs( catherine.tool.GetAll( ) ) do
		toolGun.Tool[ v.Mode ] = v
	end
end

hook.Add( "FrameworkInitialized", "catherine.plugin.FrameworkInitialized", catherine.plugin.FrameworkInitialized )

if ( SERVER ) then
	catherine.plugin.deactivePlugins = { }
	catherine.plugin.deactiveList = catherine.plugin.deactiveList or { }
	
	function catherine.plugin.ToggleActive( uniqueID, doRefresh )
		local globalVar = catherine.net.GetNetGlobalVar( "plugin_deactiveList", { } )
		
		if ( catherine.plugin.GetActive( uniqueID ) ) then
			catherine.plugin.deactiveList[ uniqueID ] = uniqueID
			globalVar[ uniqueID ] = uniqueID
		else
			catherine.plugin.deactiveList[ uniqueID ] = nil
			globalVar[ uniqueID ] = nil
		end
		
		catherine.net.SetNetGlobalVar( "plugin_deactiveList", globalVar )
		catherine.plugin.SaveActiveList( )
		
		if ( doRefresh ) then
			catherine.plugin.Refresh( )
		end
	end
	
	function catherine.plugin.SetActive( uniqueID, active )
		local globalVar = catherine.net.GetNetGlobalVar( "plugin_deactiveList", { } )
		
		if ( active ) then
			catherine.plugin.deactiveList[ uniqueID ] = nil
			globalVar[ uniqueID ] = nil
		else
			catherine.plugin.deactiveList[ uniqueID ] = uniqueID
			globalVar[ uniqueID ] = uniqueID
		end
		
		catherine.net.SetNetGlobalVar( "plugin_deactiveList", globalVar )
		catherine.plugin.SaveActiveList( )
	end
	
	function catherine.plugin.SaveActiveList( )
		catherine.data.Set( "plugin_deactive_list", catherine.net.GetNetGlobalVar( "plugin_deactiveList", { } ) )
	end
	
	function catherine.plugin.LoadActiveList( )
		local data = catherine.data.Get( "plugin_deactive_list", { } )
		
		catherine.plugin.deactiveList = data
		catherine.net.SetNetGlobalVar( "plugin_deactiveList", data )
	end
	
	function catherine.plugin.GetActive( uniqueID )
		return !catherine.plugin.deactiveList[ uniqueID ]
	end
	
	function catherine.plugin.SendDeactivePlugins( pl )
		if ( table.Count( catherine.plugin.deactivePlugins ) > 0 ) then
			netstream.Start( pl, "catherine.plugin.SendDeactivePlugins", catherine.plugin.deactivePlugins )
		end
	end
	
	netstream.Hook( "catherine.plugin.ToggleActive", function( pl, data )
		catherine.plugin.ToggleActive( data[ 1 ], data[ 2 ] )
	end )
	
	netstream.Hook( "catherine.plugin.Refresh", function( pl )
		catherine.plugin.Refresh( )
	end )
else
	netstream.Hook( "catherine.plugin.SendDeactivePlugins", function( data )
		if ( table.Count( data ) > 0 ) then
			catherine.plugin.lists = table.Merge( data, catherine.plugin.lists )
		end
	end )
	
	function catherine.plugin.LanguageChanged( )
		rebuildPlugin( )
	end
	
	function catherine.plugin.InitPostEntity( )
		if ( IsValid( catherine.pl ) ) then
			rebuildPlugin( )
		end
	end
	
	hook.Add( "LanguageChanged", "catherine.plugin.LanguageChanged", catherine.plugin.LanguageChanged )
	hook.Add( "InitPostEntity", "catherine.plugin.InitPostEntity", catherine.plugin.InitPostEntity )
	
	function catherine.plugin.GetActive( uniqueID )
		return catherine.net.GetNetGlobalVar( "plugin_deactiveList", { } )[ uniqueID ] == nil
	end
end