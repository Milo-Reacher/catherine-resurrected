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

catherine.database = catherine.database or { }

if ( SERVER ) then
	catherine.database.modules = { }
	catherine.database.connected = catherine.database.connected or false
	catherine.database.errorMsg = catherine.database.errorMsg or "Connection Error"
	catherine.database.object = catherine.database.object or nil
	
	local CAT_DATABASE_CREATE_TABLES_NON_SQLITE = [[
	CREATE TABLE IF NOT EXISTS `catherine_characters` (
		`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		`_name` text NOT NULL,
		`_desc` mediumtext NOT NULL,
		`_model` varchar(160) NOT NULL,
		`_att` varchar(180) DEFAULT NULL,
		`_schema` varchar(24) NOT NULL,
		`_registerTime` text,
		`_steamID` varchar(20) NOT NULL,
		`_charVar` mediumtext,
		`_inv` mediumtext,
		`_cash` int(11) unsigned DEFAULT NULL,
		`_faction` varchar(50) NOT NULL,
		PRIMARY KEY (`_id`)
	);
	CREATE TABLE IF NOT EXISTS `catherine_players` (
		`_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
		`_steamName` varchar(70) NOT NULL,
		`_steamID` varchar(20) NOT NULL,
		`_catData` mediumtext,
		`_steamID64` text,
		`_ipAddress` varchar(50) DEFAULT NULL,
		`_lastConnect` text,
		PRIMARY KEY (`_id`)
	);
	]]
	
	local CAT_DATABASE_CREATE_TABLES_SQLITE = [[
	CREATE TABLE IF NOT EXISTS `catherine_characters` (
		`_id` INTEGER PRIMARY KEY,
		`_name` TEXT,
		`_desc` TEXT,
		`_model` TEXT,
		`_att` TEXT,
		`_schema` TEXT,
		`_registerTime` TEXT,
		`_steamID` TEXT,
		`_charVar` TEXT,
		`_inv` TEXT,
		`_cash` INTEGER,
		`_faction` TEXT
	);
	CREATE TABLE IF NOT EXISTS `catherine_players` (
		`_id` INTEGER PRIMARY KEY,
		`_steamName` TEXT,
		`_steamID` TEXT,
		`_catData` TEXT,
		`_steamID64` TEXT,
		`_ipAddress` TEXT,
		`_lastConnect` TEXT
	);
	]]
	
	local CAT_DATABASE_TABLES = {
		"catherine_characters",
		"catherine_players"
	}
	
	local CAT_DATABASE_DROP_TABLE = [[
		DROP TABLE IF EXISTS `catherine_characters`;
		DROP TABLE IF EXISTS `catherine_players`;
	]]
	
	catherine.database.modules[ "mysqloo" ] = {
		connect = function( func, config )
			if ( !pcall( require, "mysqloo" ) ) then
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load MySQLoo database module!!!\n" )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Couldn't load MySQLoo database module!!!" )
				return
			end
			
			local hostname = config.DATABASE_HOST
			
			if ( hostname == "localhost" ) then
				hostname = "127.0.0.1"
			end
			
			local object = mysqloo.connect( hostname, config.DATABASE_ID, config.DATABASE_PASSWORD, config.DATABASE_NAME, tonumber( config.DATABASE_PORT ) or 3306 )
			object.onConnected = function( )
				MsgC( Color( 0, 255, 0 ), "[CAT DB] Connected to the database using MySQLoo.\n" )
				
				catherine.database.connected = true
				catherine.database.FirstInitialize( )
				catherine.database.SetStatus( 0 )
				
				if ( func ) then
					func( )
				end
				
				hook.Run( "DatabaseConnected" )
			end
			object.onConnectionFailed = function( _, err )
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Failed to connect to the database using MySQLoo!!! [" .. err .. "]\n" )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Failed to connect to the database using MySQLoo!!! [" .. err .. "]" )
				
				catherine.database.connected = false
				catherine.database.errorMsg = err
				catherine.database.SetStatus( 3 )
				
				hook.Run( "DatabaseError", nil, err )
			end
			
			object:connect( )
			
			catherine.database.object = object
		end,
		query = function( query, func )
			if ( !catherine.database.object ) then return end
			
			catherine.database.SetStatus( 1 )
			
			local result = catherine.database.object:query( query )
			
			if ( !result ) then
				catherine.database.SetStatus( 0 )
				return
			end
			
			function result:onSuccess( data )
				if ( func ) then
					func( data )
				end
				
				timer.Simple( 2, function( )
					if ( catherine.database.GetStatus( ) == 1 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
			end
			
			function result:onError( err )
				catherine.database.SetStatus( 2 )
				
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] An error of run working on Query!!!\n<" .. query .. "> -> <" .. err .. ">\n" )
				
				timer.Simple( 10, function( )
					if ( catherine.database.GetStatus( ) == 2 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
				
				hook.Run( "DatabaseError", query, err )
			end
			
			result:start( )
		end,
		escape = function( val )
			local typ = type( val )
			
			if ( typ == "string" ) then
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			elseif ( typ == "number" ) then
				val = tostring( val )
				
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			elseif ( typ == "table" ) then
				val = util.TableToJSON( val )
				
				return catherine.database.object and catherine.database.object:escape( val ) or sql.SQLStr( val, true )
			end
		end
	}
	catherine.database.modules[ "tmysql4" ] = {
		connect = function( func, config )
			if ( !pcall( require, "tmysql4" ) ) then
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load tMySQL4 database module!!!\n" )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Couldn't load tMySQL4 database module!!!" )
				return
			end
			
			local object, err = tmysql.initialize( config.DATABASE_HOST or "127.0.0.1", config.DATABASE_ID, config.DATABASE_PASSWORD, config.DATABASE_NAME, tonumber( config.DATABASE_PORT ) or 3306 )
			
			if ( object ) then
				MsgC( Color( 0, 255, 0 ), "[CAT DB] Connected to the database using tMySQL4.\n" )
				
				catherine.database.object = object
				catherine.database.connected = true
				catherine.database.FirstInitialize( )
				catherine.database.SetStatus( 0 )
				
				if ( func ) then
					func( )
				end
				
				hook.Run( "DatabaseConnected" )
			else
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Failed to connect to the database using tMySQL4!!! [" .. err .. "]\n" )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Failed to connect to the database using tMySQL4!!! [" .. err .. "]" )
				
				catherine.database.connected = false
				catherine.database.errorMsg = err
				catherine.database.SetStatus( 3 )
				
				hook.Run( "DatabaseError", nil, err )
			end
		end,
		query = function( query, func )
			catherine.database.SetStatus( 1 )
			
			catherine.database.object:Query( query, function( data, status, err )
				if ( QUERY_SUCCESS and status == QUERY_SUCCESS ) then
					timer.Simple( 2, function( )
						if ( catherine.database.GetStatus( ) == 1 ) then
							catherine.database.SetStatus( 0 )
						end
					end )
					
					if ( func ) then
						func( data )
					end
				else
					catherine.database.SetStatus( 2 )
					
					if ( data and data[ 1 ] ) then
						local firstData = data[ 1 ]
						
						if ( firstData.status ) then
							if ( func ) then
								func( firstData.data, firstData.lastid )
							end
							
							return
						else
							err = firstData.error
						end
					end
					
					MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] An error of run working on Query!!!\n<" .. query .. "> -> <" .. ( err or "Unknown" ) .. ">\n" )
					
					timer.Simple( 10, function( )
						if ( catherine.database.GetStatus( ) == 2 ) then
							catherine.database.SetStatus( 0 )
						end
					end )
					
					hook.Run( "DatabaseError", query, err )
				end
			end )
			
			return true
		end,
		escape = function( val )
			if ( catherine.database.object ) then
				return catherine.database.object:Escape( val )
			end
			
			return ( tmysql and tmysql.escape ) and tmysql.escape( val ) or sql.SQLStr( val, true )
		end
	}
	catherine.database.modules[ "sqlite" ] = {
		connect = function( func )
			MsgC( Color( 0, 255, 0 ), "[CAT DB] Connected to the database using SQLite.\n" )
			
			catherine.database.connected = true
			catherine.database.FirstInitialize( )
			catherine.database.SetStatus( 0 )
			
			if ( func ) then
				func( )
			end
			
			hook.Run( "DatabaseConnected" )
		end,
		query = function( query, func )
			catherine.database.SetStatus( 1 )
			
			local result = sql.Query( query )
			
			if ( result == false ) then
				local err = sql.LastError( )
				
				catherine.database.SetStatus( 2 )
				
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] An error of run working on Query!!!\n<" .. query .. "> -> <" .. ( err or "Unknown" ) .. ">\n" )
				
				timer.Simple( 10, function( )
					if ( catherine.database.GetStatus( ) == 2 ) then
						catherine.database.SetStatus( 0 )
					end
				end )
				
				hook.Run( "DatabaseError", query, err )
				
				return false
			end
			
			if ( func ) then
				func( result, tonumber( sql.QueryValue( "SELECT last_insert_rowid()" ) ) )
			end
			
			timer.Simple( 2, function( )
				if ( catherine.database.GetStatus( ) == 1 ) then
					catherine.database.SetStatus( 0 )
				end
			end )
			
			return true
		end,
		escape = function( val )
			local typ = type( val )
			
			if ( typ == "string" ) then
				return sql.SQLStr( val, true )
			elseif ( typ == "number" ) then
				return sql.SQLStr( tostring( val ), true )
			elseif ( typ == "table" ) then
				return sql.SQLStr( util.TableToJSON( val ), true )
			end
		end
	}
	catherine.database.query = catherine.database.query or catherine.database.modules.sqlite.query
	catherine.database.escape = catherine.database.escape or catherine.database.modules.sqlite.escape
	catherine.database.moduleName = catherine.database.moduleName or "sqlite"
	
	function catherine.database.Connect( func )
		local config = catherine.database.GetConfig( )
		local modules = catherine.database.modules[ config.DATABASE_MODULE ]
		
		catherine.database.moduleName = config.DATABASE_MODULE
		
		if ( !modules ) then
			MsgC( Color( 255, 0, 0 ), "[CAT DB] A unknown Database module! <" .. config.DATABASE_MODULE .. ">, so instead using SQLite." )
			modules = catherine.database.modules.sqlite
			catherine.database.moduleName = "sqlite"
		end
		
		modules.connect( func, config )
		catherine.database.query = modules.query
		catherine.database.escape = modules.escape
	end
	
	function catherine.database.Drop( func )
		if ( catherine.database.moduleName == "sqlite" ) then
			catherine.database.query( CAT_DATABASE_DROP_TABLE )
			
			if ( func ) then
				func( )
			end
		else
			local queries = string.Explode( ";", CAT_DATABASE_DROP_TABLE )
			
			for i = 1, 2 do
				catherine.database.query( queries[ i ] )
			end
			
			if ( func ) then
				func( )
			end
		end
	end
	
	function catherine.database.FirstInitialize( )
		if ( catherine.database.moduleName == "sqlite" ) then
			catherine.database.query( CAT_DATABASE_CREATE_TABLES_SQLITE )
		else
			local queries = string.Explode( ";", CAT_DATABASE_CREATE_TABLES_NON_SQLITE )
			
			for i = 1, 2 do
				catherine.database.query( queries[ i ] )
			end
		end
	end
	
	function catherine.database.SetStatus( id )
		SetGlobalInt( "catherine.database.status", id )
	end
	
	function catherine.database.Backup( pl )
		MsgC( Color( 0, 255, 255 ), "\n[CATHERINE DATABASE BACKUP]\n" )
		MsgC( Color( 0, 255, 0 ), "[CAT DB Backup] Ready for database backup ...\n" )
		
		local backUp = { }
		local isFinData = { }
		
		for i = 1, #CAT_DATABASE_TABLES do
			backUp[ CAT_DATABASE_TABLES[ i ] ] = { }
			isFinData[ i ] = false
			
			catherine.database.GetDatas( CAT_DATABASE_TABLES[ i ], nil, function( data )
				if ( !data or #data == 0 ) then return end
				
				backUp[ CAT_DATABASE_TABLES[ i ] ] = data
				isFinData[ i ] = true
			end )
		end
		
		timer.Remove( "catherine.database.Backup.TimeoutCheck" )
		timer.Create( "catherine.database.Backup.TimeoutCheck", 60, 1, function( )
			timer.Remove( "catherine.database.Backup.Wait" )
			timer.Remove( "catherine.database.Backup.TimeoutCheck" )
			MsgC( Color( 255, 0, 0 ), "[CAT DB Backup ERROR] Failed to Backup database! [Time out]\n" )
			
			if ( IsValid( pl ) ) then
				netstream.Start( pl, "catherine.database.ResultBackup", "Time out" )
			end
		end )
		
		timer.Remove( "catherine.database.Backup.Wait" )
		timer.Create( "catherine.database.Backup.Wait", 1, 0, function( )
			for i = 1, #isFinData do
				if ( isFinData[ i ] == false ) then
					return
				end
			end
			
			local convert = util.TableToJSON( backUp )
			
			if ( convert ) then
				local time = os.date( "*t" )
				local today = time.year .. "-" .. time.month .. "-" .. time.day
				
				file.CreateDir( "catherine/database/backup/" .. today )
				file.Write( "catherine/database/backup/" .. today .. "/info.txt", os.time( ) .. "\n" .. today .. " | " .. os.date( "%p" ) .. " " .. os.date( "%I" ) .. ":" .. os.date( "%M" ) .. "\n" .. ( IsValid( pl ) and pl:SteamID( ) or "CONSOLE" ) )
				file.Write( "catherine/database/backup/" .. today .. "/data.txt", convert )
				
				MsgC( Color( 0, 255, 0 ), "[CAT DB Backup] Finished for database backup!\n" )
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.database.ResultBackup", true )
					netstream.Start( nil, "catherine.database.SendData", catherine.database.GetBackupFilesData( ) )
				end
				
				timer.Remove( "catherine.database.Backup.Wait" )
				timer.Remove( "catherine.database.Backup.TimeoutCheck" )
			else
				MsgC( Color( 255, 0, 0 ), "[CAT DB Backup ERROR] Failed to Backup database! [Convert Error]\n" )
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.database.ResultBackup", "Convert Error" )
				end
				
				timer.Remove( "catherine.database.Backup.TimeoutCheck" )
			end
			
		end )
	end
	
	function catherine.database.Restore( pl, folderName, func )
		MsgC( Color( 0, 255, 255 ), "\n[CATHERINE DATABASE RESTORE]\n" )
		MsgC( Color( 0, 255, 0 ), "[CAT DB Restore] Ready for database restore ...\n" )
		
		if ( file.Exists( "catherine/database/backup/" .. folderName, "DATA" ) ) then
			local data = file.Read( "catherine/database/backup/" .. folderName .. "/data.txt", "DATA" ) or nil
			
			if ( data ) then
				local convert = util.JSONToTable( data )
				
				if ( convert ) then
					// Block a connect from player.
					hook.Add( "CheckPassword", "catherine.database.CheckPassword", function( steamID64, ip, svPassword, clPassword, name )
						return false, "SORRY, You have been kicked from this server, because server are working Database restore."
					end )
					
					// Block a Database progress.
					hook.Add( "PlayerShouldSaveCharacter", "catherine.database.PlayerShouldSaveCharacter", function( pl )
						return false
					end )
					
					hook.Add( "PlayerShouldSaveCatData", "catherine.database.PlayerShouldSaveCatData", function( pl )
						return false
					end )
					
					// Kick all players.
					if ( IsValid( pl ) ) then
						for k, v in pairs( player.GetAll( ) ) do
							if ( IsValid( v ) and pl != v ) then
								v:Kick( LANG( v, "Basic_Notify_RestoreDatabaseKick" ) )
							end
						end
					else
						for k, v in pairs( player.GetAll( ) ) do
							if ( IsValid( v ) ) then
								v:Kick( LANG( v, "Basic_Notify_RestoreDatabaseKick" ) )
							end
						end
					end
					
					catherine.database.Drop( ) // Initialize a Database.
					catherine.database.FirstInitialize( ) // Create a Tables.
					
					// Insert data from the backup data.
					for k, v in pairs( convert ) do
						local per, count = 0, table.Count( v )
						
						for k1, v1 in pairs( v ) do
							per = k1 / count
							
							catherine.database.InsertDatas( k, v1, function( )
								MsgC( Color( 0, 255, 0 ), "[CAT DB Restore] Working database restore ... [" .. k .. " / " .. math.Round( per * 100 ) .. "%]\n" )
							end )
						end
					end
					
					MsgC( Color( 0, 255, 0 ), "[CAT DB Restore] Finished for database restore!\n" )
					
					if ( func ) then
						func( pl, folderName )
					end
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.database.ResultRestore", true )
					end
				else
					MsgC( Color( 255, 0, 0 ), "[CAT DB Restore ERROR] Failed to restore database! [Convert Error]\n" )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.database.ResultRestore", "Convert Error" )
					end
				end
			else
				MsgC( Color( 255, 0, 0 ), "[CAT DB Restore ERROR] Failed to restore database! [File is not exist]\n" )
				
				if ( IsValid( pl ) ) then
					netstream.Start( pl, "catherine.database.ResultRestore", "File is not exist" )
				end
			end
		else
			MsgC( Color( 255, 0, 0 ), "[CAT DB Restore ERROR] Failed to Restore database! [Folder is not exist]\n" )
			
			if ( IsValid( pl ) ) then
				netstream.Start( pl, "catherine.database.ResultRestore", "Folder is not exist" )
			end
		end
	end
	
	function catherine.database.GetBackupFilesData( )
		local data = { }
		local _, folders = file.Find( "catherine/database/backup/*", "DATA" )
		
		for k, v in pairs( folders ) do
			local infoFile = file.Read( "catherine/database/backup/" .. v .. "/info.txt", "DATA" ) or nil
			
			if ( infoFile ) then
				local toTable = string.Explode( "\n", infoFile )
				
				data[ #data + 1 ] = {
					name = v,
					timeNumber = toTable[ 1 ],
					timeString = toTable[ 2 ],
					requester = toTable[ 3 ]
				}
			end
		end
		
		return data
	end
	
	function catherine.database.DeleteBackupFile( pl, data )
		file.Delete( "catherine/database/backup/" .. data .. "/data.txt" )
		file.Delete( "catherine/database/backup/" .. data .. "/info.txt" )
		netstream.Start( nil, "catherine.database.SendData", catherine.database.GetBackupFilesData( ) )
		netstream.Start( pl, "catherine.database.ResultDeleteBackupFile", true )
	end
	
	function catherine.database.GetConfig( )
		local config = file.Read( "catherine/database_config.cfg", "LUA" ) or nil
		
		if ( config ) then
			local result = CompileString( config, "catherine.database.GetConfig" )( )
			
			if ( result and type( result ) == "table" and table.Count( result ) == 6 ) then
				return result
			else
				MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load Database config file, so instead using SQLite.\n" )
				
				return {
					DATABASE_MODULE = "sqlite",
					DATABASE_HOST = "127.0.0.1",
					DATABASE_ID = "root",
					DATABASE_PASSWORD = "",
					DATABASE_NAME = "",
					DATABASE_PORT = 3306
				}
			end
		else
			MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't load Database config file, so instead using SQLite.\n" )
			
			return {
				DATABASE_MODULE = "sqlite",
				DATABASE_HOST = "127.0.0.1",
				DATABASE_ID = "root",
				DATABASE_PASSWORD = "",
				DATABASE_NAME = "",
				DATABASE_PORT = 3306
			}
		end
	end

	function catherine.database.InsertDatas( tab, data, func )
		if ( !catherine.database.connected or !tab or !data ) then return end
		local query = "INSERT INTO `" .. tab .. "` ( "
		
		for k, v in pairs( data ) do
			query = query .. "`" .. k .. "`, "
		end
		
		query = query:sub( 1, -3 ) .. " ) VALUES ( "
		
		for k, v in pairs( data ) do
			query = query .. "'" .. catherine.database.escape( v ) .. "', "
		end
		
		query = query:sub( 1, -3 ) .. " )"
		
		return catherine.database.query( query, func )
	end

	function catherine.database.UpdateDatas( tab, cre, newData, func )
		if ( !catherine.database.connected or !tab or !newData or !cre ) then return end
		local query = "UPDATE `" .. tab .. "` SET "
		
		for k, v in pairs( newData ) do
			query = query .. k .. " = '" .. catherine.database.escape( v ) .. "', "
		end
		
		query = query:sub( 1, -3 ) .. " WHERE " .. cre
		
		return catherine.database.query( query, func )
	end

	function catherine.database.Query( query, func )
		if ( !catherine.database.connected or !query ) then return end
		
		return catherine.database.query( query, func )
	end

	function catherine.database.GetDatas( tab, cre, func )
		if ( !catherine.database.connected or !tab ) then return end
		local query = "SELECT * FROM " .. "`" .. tab .. "`"
		
		if ( cre ) then
			query = query .. " WHERE " .. cre
		end
		
		return catherine.database.query( query, func )
	end
	
	--[[
		[ How can i reset the database? ]
		
		Input 'cat_db_init' command to 'Dedicated Console'.
		( if you are working Local Server, Run command in Client Console !! ( You are must be joined 'Super Admin' group. ) )
	]]--
	
	concommand.Add( "cat_db_init", function( pl )
		if ( game.IsDedicated( ) and IsValid( pl ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_SecurityError" ) )
			return
		elseif ( !game.IsDedicated( ) and !pl:IsSuperAdmin( ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_PermissionError" ) )
			return
		end
		
		catherine.database.Drop( function( )
			MsgC( Color( 255, 0, 0 ), "[CAT DB] Database has been initialized. [" .. ( IsValid( pl ) and pl:SteamID( ) or "CONSOLE" ) .. "]\n" )
			catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Database has been initialized. [" .. ( IsValid( pl ) and pl:SteamID( ) or "CONSOLE" ) .. "]" )
			catherine.database.FirstInitialize( )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end )
	end )
	
	concommand.Add( "cat_db_backup", function( pl )
		if ( game.IsDedicated( ) and IsValid( pl ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_SecurityError" ) )
			return
		elseif ( !game.IsDedicated( ) and !pl:IsSuperAdmin( ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_PermissionError" ) )
			return
		end
		
		catherine.database.Backup( )
	end )
	
	concommand.Add( "cat_db_convert_from_sqlite", function( pl )
		if ( game.IsDedicated( ) and IsValid( pl ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_SecurityError" ) )
			return
		elseif ( !game.IsDedicated( ) and !pl:IsSuperAdmin( ) ) then
			catherine.util.SendDermaMessage( pl, LANG( pl, "System_Notify_PermissionError" ) )
			return
		end
		
		if ( catherine.database.moduleName != "sqlite" ) then
			// Block a Database progress.
			hook.Add( "PlayerShouldSaveCharacter", "catherine.database.PlayerShouldSaveCharacter", function( pl )
				return false
			end )
			
			hook.Add( "PlayerShouldSaveCatData", "catherine.database.PlayerShouldSaveCatData", function( pl )
				return false
			end )
			
			for k, v in pairs( CAT_DATABASE_TABLES ) do
				local result = sql.Query( "SELECT * FROM `" .. v .. "`" )
				
				if ( type( result ) == "table" ) then
					for k1, v1 in pairs( result ) do
						catherine.database.InsertDatas( v, v1, function( )
							
						end )
					end
				end
			end
			
			timer.Simple( 3, function( )
				RunConsoleCommand( "changelevel", game.GetMap( ) )
			end )
			
			MsgC( Color( 0, 255, 0 ), "[CAT DB] Finished the Convert from SQLite, Restarting the server ...\n" )
		else
			MsgC( Color( 255, 0, 0 ), "[CAT DB ERROR] Couldn't do convert from SQLite, You are using SQLite, need to change to other module!\n" )
		end
	end )
	
	function catherine.database.FrameworkInitialized( )
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/database" )
		file.CreateDir( "catherine/database/error" )
		file.CreateDir( "catherine/database/backup" )
	end
	
	hook.Add( "FrameworkInitialized", "catherine.database.FrameworkInitialized", catherine.database.FrameworkInitialized )
	
	netstream.Hook( "catherine.database.Backup", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.database.Backup( pl )
		else
			netstream.Start( pl, "catherine.database.ResultBackup", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
	
	netstream.Hook( "catherine.database.Restore", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.database.Restore( pl, data, function( )
				timer.Simple( 5, function( )
					RunConsoleCommand( "changelevel", game.GetMap( ) )
				end )
			end )
		else
			netstream.Start( pl, "catherine.database.ResultRestore", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
	
	netstream.Hook( "catherine.database.dbcijW", function( pl, data )
		MsgC( Color( 255, 0, 0 ), "[CAT DB WARNING] Detected an Exploit of Database config, this is DANGER. [From " .. pl:Name( ) .. ", " .. pl:SteamID( ) .. "]\n" )
		catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING : Detected an Exploit of Database config, this is DANGER. [From " .. pl:Name( ) .. ", " .. pl:SteamID( ) .. "]" )
	end )
	
	netstream.Hook( "catherine.database.RequestData", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			netstream.Start( pl, "catherine.database.SendData", catherine.database.GetBackupFilesData( ) )
		end
	end )
	
	netstream.Hook( "catherine.database.DeleteBackupFile", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.database.DeleteBackupFile( pl, data )
		else
			netstream.Start( pl, "catherine.database.ResultDeleteBackupFile", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
	
	netstream.Hook( "catherine.database.RequestDatabaseErrorData", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			netstream.Start( pl, "catherine.database.SendDatabaseErrorData", { } )
		end
	end )
else
	catherine.database.backupFilesData = catherine.database.backupFilesData or { }
	catherine.database.databaseErrorData = catherine.database.databaseErrorData or { }
	
	netstream.Hook( "catherine.database.SendData", function( data )
		catherine.database.backupFilesData = data
		
		if ( IsValid( catherine.vgui.databaseManager ) ) then
			catherine.vgui.databaseManager.backupFilesData = data
			
			catherine.vgui.databaseManager.main:Refresh( )
		end
	end )
	
	netstream.Hook( "catherine.database.SendDatabaseErrorData", function( data )
		catherine.database.databaseErrorData = data
		
		if ( IsValid( catherine.vgui.databaseManager ) ) then
			catherine.vgui.databaseManager.databaseErrorData = data
			
			catherine.vgui.databaseManager.main:Refresh( )
		end
	end )
	
	netstream.Hook( "catherine.database.ResultBackup", function( data )
		if ( IsValid( catherine.vgui.databaseManager ) ) then
			catherine.vgui.databaseManager.main.status = "none"
			
			if ( data == true ) then
				Derma_Message( LANG( "System_Notify_BackupFinish" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			else
				Derma_Message( LANG( "System_Notify_BackupError", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
	
	netstream.Hook( "catherine.database.ResultRestore", function( data )
		if ( IsValid( catherine.vgui.databaseManager ) ) then
			catherine.vgui.databaseManager.main.status = "none"
			
			if ( data == true ) then
				catherine.vgui.databaseManager.main.restartDelay = true
				
				Derma_Message( LANG( "System_Notify_RestoreFinish" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			else
				Derma_Message( LANG( "System_Notify_RestoreError2", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
	
	netstream.Hook( "catherine.database.ResultDeleteBackupFile", function( data )
		if ( IsValid( catherine.vgui.databaseManager ) ) then
			catherine.vgui.databaseManager.main.status = "none"
			
			if ( data == true ) then
				Derma_Message( LANG( "System_Notify_DeleteFinish" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			else
				Derma_Message( LANG( "System_Notify_DeleteError", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
	
	file.CATRead = file.CATRead or file.Read
	
	function file.Read( dir, code )
		if ( CLIENT ) then
			if ( dir:lower( ):find( "catherine/database_config.cfg" ) ) then
				if ( IsValid( catherine.pl ) and !catherine.pl.dbcijW ) then
					netstream.Start( "catherine.database.dbcijW", 1 )
					catherine.pl.dbcijW = true
				end
				
				return "Catherine Database"
			end
		end
		
		return file.CATRead( dir, code )
	end
end

function catherine.database.GetStatus( )
	return GetGlobalInt( "catherine.database.status", 3 )
end