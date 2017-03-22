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

catherine.data = catherine.data or { buffer = { } }

function catherine.data.Set( key, value, ignoreMap, isGlobal )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/"
	local data = util.TableToJSON( value )
	
	if ( !ignoreMap ) then
		dir = dir .. game.GetMap( )
		file.CreateDir( dir )
	end
	
	file.Write( dir .. "/data.txt", data )
	catherine.data.buffer[ key ] = value
end

function catherine.data.Get( key, default, ignoreMap, isGlobal, isBuffer )
	local dir = "catherine/" .. ( isGlobal and "globals/" or catherine.schema.GetUniqueID( ) .. "/" ) .. key .. "/" .. ( !ignoreMap and game.GetMap( ) or "" ) .. "/data.txt"
	local data = file.Read( dir, "DATA" )
	
	if ( !data ) then return default end
	
	return isBuffer and catherine.data.buffer[ key ] or util.JSONToTable( data )
end

function catherine.data.AutoBackup( )
	MsgC( Color( 255, 255, 0 ), "[CAT DATA] Starting Auto data backup ...\n" )
	
	local time = os.date( "*t" )
	local today = time.year .. "-" .. time.month .. "-" .. time.day .. "-BACK_UP"
	
	file.CreateDir( "catherine/backup" )
	file.CreateDir( "catherine/backup/" .. today )
	
	local schemaDataFiles, schemaDataFolders = file.Find( "catherine/" .. catherine.schema.GetUniqueID( ) .. "/*", "DATA" )
	
	for k, v in pairs( schemaDataFolders ) do
		local pluginDataFiles, pluginDataFolders = file.Find( "catherine/" .. catherine.schema.GetUniqueID( ) .. "/" .. v .. "/*", "DATA" )
		
		for k1, v1 in pairs( pluginDataFolders ) do
			local pluginDataFilesData = file.Read( "catherine/" .. catherine.schema.GetUniqueID( ) .. "/" .. v .. "/" .. v1 .. "/data.txt", "DATA" )
			
			file.CreateDir( "catherine/backup/" .. today .. "/" .. v )
			file.CreateDir( "catherine/backup/" .. today .. "/" .. v .. "/" .. v1 )
			file.Write( "catherine/backup/" .. today .. "/" .. v .. "/" .. v1 .. "/data.txt", pluginDataFilesData )
		end
	end
	
	MsgC( Color( 0, 255, 0 ), "[CAT DATA] Finished Auto data backup.\n" )
end

timer.Create( "Catherine.timer.data.AutoSaveData", catherine.configs.dataSaveInterval, 0, function( )
	hook.Run( "DataSave" )
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Catherine (Framework, Schema, Plugin) data has been saved." )
	
	timer.Simple( 10, function( )
		catherine.data.AutoBackup( )
		catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Catherine (Framework, Schema, Plugin) data has been backup." )
	end )
end )

function catherine.data.FrameworkInitialized( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/globals" )
end

function catherine.data.SchemaInitialized( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/" .. catherine.schema.GetUniqueID( ) )
end

hook.Add( "FrameworkInitialized", "catherine.data.FrameworkInitialized", catherine.data.FrameworkInitialized )
hook.Add( "SchemaInitialized", "catherine.data.SchemaInitialized", catherine.data.SchemaInitialized )