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

if ( !catherine.cash ) then
	catherine.util.Include( "sh_cash.lua" )
end

catherine.language = catherine.language or { lists = { } }

function catherine.language.Register( languageTable )
	catherine.language.lists[ languageTable.uniqueID ] = languageTable
end

function catherine.language.New( uniqueID )
	return { name = "Unknown", data = { }, uniqueID = uniqueID }
end

function catherine.language.GetAll( )
	return catherine.language.lists
end

function catherine.language.FindByID( uniqueID )
	return catherine.language.lists[ uniqueID ]
end

function catherine.language.FindByGmodLangID( gmodLangID )
	for k, v in pairs( catherine.language.lists ) do
		if ( v.gmodLangID == gmodLangID ) then
			return v
		end
	end
end

function catherine.language.Include( dir, name )
	local files = file.Find( dir .. "/language/*.lua", "LUA" )
	
	if ( #files == 0 ) then
		MsgC( Color( 255, 255, 0 ), "[CAT WARNING] Can't find any language files on the " .. ( name or "framework" ) .. ", this is not good!\n" )
	else
		for k, v in pairs( files ) do
			catherine.util.Include( dir .. "/language/" .. v, "SHARED" )
		end
	end
end

function catherine.language.Merge( uniqueID, data )
	local languageTable = catherine.language.FindByID( uniqueID )
	
	if ( languageTable ) then
		languageTable.data = table.Merge( languageTable.data, data )
	end
end

catherine.language.Include( catherine.FolderName .. "/framework" )

local languageMasterTable = catherine.language.lists
local Format = Format

if ( SERVER ) then
	local getInfo = FindMetaTable( "Player" ).GetInfo
	
	function LANG( pl, key, ... )
		local languageTable = languageMasterTable[ getInfo( pl, "cat_convar_language" ) ] or languageMasterTable[ "english" ]
		
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
	
	function FORCE_LANG( pl, langID, key, ... )
		local languageTable = languageMasterTable[ langID ] or languageMasterTable[ "english" ]
		
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
else
	local getConvarString = GetConVarString
	local languageTable = catherine.language.FindByID( catherine.configs.defaultLanguage )
	
	CAT_CONVAR_LANGUAGE = CreateClientConVar( "cat_convar_language", ( languageTable and languageTable.uniqueID or "english" ), true, true )
	
	function LANG( key, ... )
		local languageTable = languageMasterTable[ getConvarString( "cat_convar_language" ) ] or languageMasterTable[ "english" ]
		
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
	
	function FORCE_LANG( langID, key, ... )
		local languageTable = languageMasterTable[ langID ] or languageMasterTable[ "english" ]
		
		if ( !languageTable or !languageTable.data or !languageTable.data[ key ] ) then return key .. "-Error" end
		
		return Format( languageTable.data[ key ], ... )
	end
end