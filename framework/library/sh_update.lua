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

catherine.update = catherine.update or { }

if ( SERVER ) then
	catherine.update.noFileIO = catherine.update.noFileIO or false
	
	local success, failMessage = pcall( require, "fileio" )
	
	if ( !success ) then
		MsgC( Color( 255, 0, 0 ), "[CAT UPDATE ERROR] File IO module failed to load. [" .. failMessage .. "]\n" )
		catherine.update.noFileIO = true
	else
		MsgC( Color( 0, 255, 0 ), "[CAT UPDATE] File IO module loaded.\n" )
		catherine.update.noFileIO = false
	end
	
	catherine.update.checked = catherine.update.checked or false
	
	function catherine.update.Check( pl, noCoolTime )
		if ( ( catherine.update.nextCheckable or 0 ) <= CurTime( ) ) then
			http.Fetch( catherine.crypto.Decode( "htotGApRdN:wATs/YQKJg/XtOgVftAXxLUwFeMMhRpleExWNbNiTrJstohuyKzdZeHujcGUyTMqBYqpSRXadbpeUSbmlubthnlZWPyugIodLsJqNkBaRXyLZajDcvhnniIvcAiHgdHSeooxCamnSLegPLeWcgdyWhIGLREnDZkmrRblOmgSizuCZIyyOeV.SDooHdMGkDsRGvRbOwbcBuUWqcSotDEQjqZdfEBAohSaFItJJowFCJrwDZFSJSmfrGNIhPwYcPFFWwmkXHyer/RyEQoDDCSiqzaHNjLILtqMRaepMupiAyJIfYeMrAOWOiZzhcgigzOgkpiEjPJcFynrjGryPCcN0mlKMGTEQpExZnVkvYOmBGgvXzy1nMjcFNiqaUzgMJMTlSFOgnFZgJCypuDfGIJPNJTysnZEPsZvmtSfPTVa/XcTwLdYZthgmRqEwvEVJSMXvuLOBwrCvOgupleZRXRAnEDxTRbXBZtmVtvPHaMhsTHECdzyjpLnExgUiCJrZldFTQfROwAaXFzWlnQOdRBbAWTwbeFbNlWIhzgIcY" ),
				function( body )
					if ( body:find( "Error 404</p>" ) ) then
						MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [404 ERROR]\n" )
						
						if ( IsValid( pl ) ) then
							netstream.Start( pl, "catherine.update.ResultCheck", "404 ERROR" )
						end
						
						return
					end
					
					if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
						MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [Unknown ERROR]\n" )
						
						if ( IsValid( pl ) ) then
							netstream.Start( pl, "catherine.update.ResultCheck", "Unknown Error" )
						end
						
						return
					end
					
					local data = CompileString( body, "catherine.update.Check" )( )
					
					if ( data.version != catherine.GetVersion( ) ) then
						MsgC( Color( 0, 255, 255 ), "[CAT Update] This server should update to the latest version of Catherine! [" .. catherine.GetVersion( ) .. " -> " .. data.version .. "]\n" )
					end
					
					catherine.net.SetNetGlobalVar( "cat_updateData", data )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.ResultCheck" )
					end
				end, function( err )
					MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [" .. err .. "]\n" )
					
					if ( IsValid( pl ) ) then
						netstream.Start( pl, "catherine.update.ResultCheck", err )
					end
				end
			)
			
			if ( !noCoolTime ) then
				catherine.update.nextCheckable = CurTime( ) + 500
			end
		else
			if ( IsValid( pl ) ) then
				netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_Notify_Update_NextTime" ) )
			end
		end
	end
	
	function catherine.update.StartUpdateMode( pl )
		catherine.UpdateModeReboot( pl )
	end
	
	function catherine.update.StartUpdate( pl )
		catherine.update.running = true
		local updatemode_data1 = string.Explode( "\n", file.Read( "catherine/updatemode_data.txt", "DATA" ) or "" )
		local updatemode_data2 = string.Explode( "\n", file.Read( "catherine/updatemode.txt", "DATA" ) or "" )
		
		catherine.update.SendUpdatePercent( pl, 1 )
		catherine.update.SendConsoleMessage( pl, "업데이트 정보를 가져오는 중 입니다 ..." )
		
		http.Fetch( "http://textuploader.com/5nmp8/raw",
			function( body )
				if ( body:find( "Error 404</p>" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [404 ERROR]\n" )
					return
				end
				
				if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
					MsgC( Color( 255, 0, 0 ), "[CAT Update ERROR] Failed to checking update! [Unknown ERROR]\n" )
					return
				end
				
				local updateData = util.JSONToTable( body )
				
				if ( updateData and istable( updateData ) ) then
					if ( updateData.newVer and updateData.newVer != catherine.GetVersion( ) ) then
						catherine.update.SendUpdatePercent( pl, 2 )
						catherine.update.SendConsoleMessage( pl, "업데이트 정보를 가져왔습니다, " .. updateData.newVer .. " 버전으로 업데이트를 시작합니다." )
						catherine.update.SendConsoleMessage( pl, "업데이트 해야 할 파일은 모두 " .. #updateData.updateNeed .. "개 입니다, 예상 소요 시간은 " .. string.NiceTime( #updateData.updateNeed * 5 ) .. " 입니다." )
						
						catherine.update.StartUpdate_Stage01( pl, updateData )
					else
						catherine.update.SendConsoleMessage( pl, "업데이트가 필요 없습니다, 잠시 후 업데이트 모드에서 나갑니다." )
						
						timer.Simple( 5, function( )
							catherine.update.ExitUpdateMode( )
						end )
					end
				else
				
				end
			end, function( err )
			
			end
		)
	end
	
	function catherine.update.SendUpdatePercent( pl, percent )
		percent = math.Clamp( percent, 0, 100 )
		
		catherine.update._percent = percent
		netstream.Start( pl, "catherine.update.SendUpdatePercent", percent )
	end
	
	function catherine.update.SendConsoleMessage( pl, message, color )
		netstream.Start( pl, "catherine.update.SendConsoleMessage", {
			message,
			color
		} )
	end
	
	local function FolderDirectoryTranslate( dir )
		if ( dir:sub( 1, 1 ) != "/" ) then
			dir = "/" .. dir
		end
		
		local ex = string.Explode( "/", dir )
		
		for k, v in pairs( ex ) do
			if ( v != "" ) then continue end
			
			table.remove( ex, k )
		end
		
		return ex
	end
	
	function catherine.update.StartUpdate_Stage01( pl, updateData )
		local updatemode_data1 = string.Explode( "\n", file.Read( "catherine/updatemode_data.txt", "DATA" ) or "" )
		local updatemode_data2 = string.Explode( "\n", file.Read( "catherine/updatemode.txt", "DATA" ) or "" )
		
		catherine.update.SendUpdatePercent( pl, 3 )
		catherine.update.SendConsoleMessage( pl, "현재 캐서린 프레임워크의 파일 상태를 백업 합니다 ..." )
		local time = os.date( "*t" )
		local today = time.year .. "-" .. time.month .. "-" .. time.day
		local baseDir = "data/catherine/update/backup/" .. today
		
		timer.Simple( 3, function( )
			fileio.MakeDirectory( "data/catherine/update" )
			fileio.MakeDirectory( "data/catherine/update/backup" )
			fileio.MakeDirectory( "data/catherine/update/backup/" .. today )
			
			catherine.update.SendConsoleMessage( pl, "백업 폴더가 생성되었습니다 경로는 'garrysmod/data/catherine/update/backup/" .. today .. "' 입니다." )
			catherine.update.SendConsoleMessage( pl, "백업할 파일을 검색합니다 ..." )
			
			local content = { }
			local files, folders = file.Find( "gamemodes/catherine/*", "GAME" )
			
			local function search( dir, dataTable )
				local files, folders = file.Find( "gamemodes/catherine/" .. dir .. "/*", "GAME" )
				
				for k, v in pairs( files ) do
					dataTable[ #dataTable + 1 ] = dir .. "/" .. v
				end
				
				for k, v in pairs( folders ) do
					dataTable[ v ] = dataTable[ v ] or { }
					search( dir .. "/" .. v, dataTable )
				end
			end
			
			for k, v in pairs( files ) do
				content[ #content + 1 ] = v
			end
			
			for k, v in pairs( folders ) do
				content[ v ] = content[ v ] or { }
				search( v, content )
			end
			
			content = table.concat( content, "\n" )
			content = string.Explode( "\n", content )
			
			catherine.update.SendConsoleMessage( pl, "백업할 파일 및 폴더, " .. table.Count( content ) .. "개를 찾았습니다." )
			
			for k, v in pairs( content ) do
				local toDir = FolderDirectoryTranslate( v )
				local b = baseDir .. "/" .. toDir[ 1 ]
				
				for k1, v1 in pairs( toDir ) do
					if ( k1 == 1 ) then continue end
					
					fileio.MakeDirectory( b )
					b = b .. "/" .. v1 .. "/"
				end
			end
			
			catherine.update.SendUpdatePercent( pl, 5 )
			catherine.update.SendConsoleMessage( pl, "백업을 준비하고 있습니다 ..." )
			
			timer.Simple( 3, function( )
				local delta = 0
				local per = 0
				local maxPer = table.Count( content )
				local onePer = math.min( 30, maxPer ) / math.max( 30, maxPer )
				
				catherine.update.SendConsoleMessage( pl, "백업을 진행하고 있습니다 ..." )
				
				for k, v in pairs( content ) do
					timer.Simple( delta, function( )
						local fileData = file.Read( "gamemodes/catherine/" .. v, "GAME" )
						
						fileData = fileData:gsub( "\r", "" )
						
						fileio.Write( baseDir .. "/" .. v, fileData )
						
						per = k / maxPer
						catherine.update.SendConsoleMessage( pl, "[성공] 백업을 진행합니다 ... " .. math.Round( per * 100 ) .. "% - " .. baseDir .. "/" .. v .. " ..." )
						catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
					end )
					
					delta = delta + 0.08
				end
				
				timer.Simple( delta, function( )
					catherine.update.SendUpdatePercent( pl, 35 )
					catherine.update.SendConsoleMessage( pl, "백업을 모두 완료했습니다 ..." )
					
					catherine.update.StartUpdate_Stage02( pl, updateData )
				end )
			end )
		end )
	end
	
	function catherine.update.StartUpdate_Stage02( pl, updateData )
		catherine.update.SendUpdatePercent( pl, 35 )
		catherine.update.SendConsoleMessage( pl, "새로운 파일을 다운로드 준비 중 입니다 ..." )
		local i = 1
		local fileDatas = { }
		local onePer = math.min( 30, #updateData.updateNeed ) / math.max( 30, #updateData.updateNeed )
		local blackListExx = {
			"dll"
		}
		
		local function download( i )
			if ( !updateData.updateNeed[ i ] ) then
				catherine.update.SendConsoleMessage( pl, "모든 파일을 다운로드 했습니다." )
				catherine.update.StartUpdate_Stage03( pl, updateData, fileDatas )
				catherine.update.SendUpdatePercent( pl, 65 )
				return
			end
			
			local url = updateData.urlMaster .. updateData.updateNeed[ i ]
			url = url:Replace( " ", "%20" )
			
			if ( table.HasValue( blackListExx, string.GetExtensionFromFilename( updateData.updateNeed[ i ] ) ) ) then
				catherine.update.SendConsoleMessage( pl, "[실패] 해당 파일은 다운받을 수 없습니다. - " .. updateData.updateNeed[ i ], Color( 255, 0, 0 ) )
				download( i + 1 )
				catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
			else
				http.Fetch( url,
					function( body )
						if ( body == "Not Found" ) then
							catherine.update.SendConsoleMessage( pl, "[실패] 파일을 다운받지 못했습니다 - " .. updateData.updateNeed[ i ], Color( 255, 0, 0 ) )
							download( i + 1 )
							catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
						else
							catherine.update.SendConsoleMessage( pl, "[성공] 파일을 다운로드 했습니다 - " .. updateData.updateNeed[ i ] )
							fileDatas[ updateData.updateNeed[ i ] ] = body
							download( i + 1 )
							catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
						end
							
					end, function( err )
					
					end
				)
			end
		end
		
		download( i )
	end
	
	function catherine.update.StartUpdate_Stage03( pl, updateData, fileDatas )
		catherine.update.SendConsoleMessage( pl, "설치 할 파일 " .. table.Count( updateData.updateNeed ) .. "개를 찾았습니다." )
		local time = os.date( "*t" )
		local today = time.year .. "-" .. time.month .. "-" .. time.day
		local baseDir = "data/catherine/update/buffer/" .. today
		local onePer = math.min( #updateData.updateNeed, 5 ) / math.max( #updateData.updateNeed, 5 )
		
		fileio.MakeDirectory( "data/catherine/update" )
		fileio.MakeDirectory( "data/catherine/update/buffer" )
		fileio.MakeDirectory( "data/catherine/update/buffer/" .. today )
		
		local delta = 0
		
		for k, v in pairs( updateData.updateNeed ) do
			timer.Simple( delta, function( )
				local toDir = FolderDirectoryTranslate( v )
				local b = baseDir .. "/" .. toDir[ 1 ]
				
				if ( #toDir == 1 ) then
					catherine.update.SendConsoleMessage( pl, "[성공] 파일을 임시 폴더에 옮겼습니다 - " .. toDir[ 1 ] )
					catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
					fileio.Write( b, fileDatas[ toDir[ 1 ] ] )
				else
					for k1, v1 in pairs( toDir ) do
						if ( k1 == 1 ) then continue end
						
						fileio.MakeDirectory( b )
						b = b .. "/" .. v1 .. "/"
					end
					
					fileio.Write( b, fileDatas[ table.concat( toDir, "/" ) ] )
					catherine.update.SendConsoleMessage( pl, "[성공] 파일을 임시 폴더에 옮겼습니다 - " .. table.concat( toDir, "/" ) )
					catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
				end
			end )
			
			delta = delta + 0.07
		end
		
		timer.Simple( delta + 3, function( )
			catherine.update.SendConsoleMessage( pl, "모든 파일을 임시 폴더에 옮겼습니다." )
			catherine.update.StartUpdate_Stage04( pl, updateData )
		end )
	end
	
	function catherine.update.StartUpdate_Stage04( pl, updateData )
		catherine.update.SendConsoleMessage( pl, "파일 정보를 불러옵니다 ..." )
		local time = os.date( "*t" )
		local today = time.year .. "-" .. time.month .. "-" .. time.day
		local baseDir = "data/catherine/update/buffer/" .. today
		local delta = 0
		local content = { }
		local onePer = math.min( #updateData.updateNeed, 5 ) / math.max( #updateData.updateNeed, 5 )
		
		for k, v in pairs( updateData.updateNeed ) do
			timer.Simple( delta, function( )
				local toDir = FolderDirectoryTranslate( v )
				local b = baseDir .. "/" .. toDir[ 1 ]
				
				if ( #toDir == 1 ) then
					catherine.update.SendConsoleMessage( pl, "[성공] 파일 정보를 불러왔습니다 - " .. toDir[ 1 ] )
					catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
					content[ toDir[ 1 ] ] = file.Read( b, "GAME" )
				else
					for k1, v1 in pairs( toDir ) do
						if ( k1 == 1 ) then continue end
						
						b = b .. "/" .. v1 .. "/"
					end
					
					content[ table.concat( toDir, "/" ) ] = file.Read( b, "GAME" )
					catherine.update.SendConsoleMessage( pl, "[성공] 파일 정보를 불러왔습니다 - " .. table.concat( toDir, "/" ) )
					catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
				end
			end )
			
			delta = delta + 0.07
		end
		
		timer.Simple( delta + 3, function( )
			catherine.update.SendConsoleMessage( pl, "모든 파일 정보를 불러왔습니다." )
			catherine.update.StartUpdate_Stage05( pl, updateData, content )
		end )
	end
	
	function catherine.update.StartUpdate_Stage05( pl, updateData, content )
		jit.off( )
		catherine.update.SendConsoleMessage( pl, "파일을 설치합니다 ..." )
		catherine.update.SendConsoleMessage( pl, "LuaJit 컴파일러를 일시적으로 비활성화 했습니다." )
		
		timer.Simple( 5, function( )
			local delta = 0
			local baseDir = "gamemodes/catherine"
			local oldVer = catherine.GetVersion( )
			local onePer = math.min( #content, 23 ) / math.max( #content, 23 )
			
			for k, v in pairs( content ) do
				timer.Simple( delta, function( )
					local toDir = FolderDirectoryTranslate( k )
					local b = baseDir .. "/" .. toDir[ 1 ]
					
					if ( #toDir == 1 ) then
						catherine.update.SendConsoleMessage( pl, "[성공] 업데이트 파일을 설치했습니다 - " .. toDir[ 1 ] )
						catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
						
						content[ toDir[ 1 ] ] = content[ toDir[ 1 ] ]:gsub( "\r", "" )
						fileio.Write( b, content[ toDir[ 1 ] ] )
					else
						local dirName = table.concat( toDir, "/" )
						
						for k1, v1 in pairs( toDir ) do
							if ( k1 == 1 ) then continue end
							
							fileio.MakeDirectory( b )
							b = b .. "/" .. v1 .. "/"
						end
						
						content[ dirName ] = content[ dirName ]:gsub( "\r", "" )
						fileio.Write( b, content[ dirName ] )
						catherine.update.SendConsoleMessage( pl, "[성공] 업데이트 파일을 설치했습니다 - " .. dirName )
						catherine.update.SendUpdatePercent( pl, catherine.update._percent + onePer )
					end
				end )
				
				delta = delta + 0.8
			end
			
			timer.Simple( delta + 5, function( )
				jit.on( )
				catherine.update.SendUpdatePercent( pl, 97 )
				catherine.update.SendConsoleMessage( pl, "모든 업데이트 파일을 설치했습니다." )
				catherine.update.SendConsoleMessage( pl, "LuaJit 컴파일러를 다시 활성화 했습니다." )
				
				catherine.update.SendConsoleMessage( pl, "버퍼 파일을 삭제합니다 ..." )
				
				local time = os.date( "*t" )
				local today = time.year .. "-" .. time.month .. "-" .. time.day
				
				fileio.Delete( "data/catherine/update/buffer/" .. today )
				
				catherine.update.SendUpdatePercent( pl, 100 )
				catherine.update.SendConsoleMessage( pl, "버퍼 파일을 삭제했습니다." )
				catherine.update.SendConsoleMessage( pl, "버전 정보 " .. oldVer .. " > " .. updateData.newVer )
				catherine.update.SendConsoleMessage( pl, "업데이트가 성공적으로 완료되었습니다, 축하드립니다." )
				catherine.update.SendConsoleMessage( pl, "잠시 후 서버를 재시작 합니다." )
				
				timer.Simple( 5, function( )
					catherine.update.ExitUpdateMode( )
				end )
			end )
		end )
	end
	
	function catherine.update.ExitUpdateMode( )
		if ( !catherine.update.running ) then return end
		local updatemode_data1 = string.Explode( "\n", file.Read( "catherine/updatemode_data.txt", "DATA" ) or "" )
		local updatemode_data2 = string.Explode( "\n", file.Read( "catherine/updatemode.txt", "DATA" ) or "" )
		
		hook.Remove( "Think", "catherine.Think" )
		hook.Remove( "CheckPassword", "catherine.CheckPassword" )
		hook.Remove( "GetGameDescription", "catherine.GetGameDescription" )
		concommand.Remove( "cat_forcestopupdate" )
		
		if ( updatemode_data2 and updatemode_data2[ 2 ] ) then
			RunConsoleCommand( "gamemode", updatemode_data2[ 2 ] )
		end
		
		if ( updatemode_data1 and updatemode_data1[ 2 ] ) then
			RunConsoleCommand( "hostname", updatemode_data1[ 2 ] )
		end
		
		file.Delete( "catherine/updatemode_data.txt" )
		file.Delete( "catherine/updatemode.txt" )
		
		RunConsoleCommand( "changelevel", game.GetMap( ) )
	end
	
	function catherine.update.PlayerLoadFinished( )
		if ( catherine.update.checked ) then return end
		
		catherine.update.Check( nil, true )
		catherine.update.checked = true
	end
	
	function catherine.update.PlayerSpawnedInCharacter( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		local data = catherine.net.GetNetGlobalVar( "cat_updateData", { version = catherine.GetVersion( ) } )
		
		if ( data.version != catherine.GetVersion( ) ) then
			catherine.popNotify.Send( pl, LANG( pl, "System_Notify_NewVersionUpdateNeed" ), 10, "CAT/notify03.wav" )
		end
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.update.PlayerLoadFinished", catherine.update.PlayerLoadFinished )
	hook.Add( "PlayerSpawnedInCharacter", "catherine.update.PlayerSpawnedInCharacter", catherine.update.PlayerSpawnedInCharacter )
	
	timer.Create( "catherine.update.NotifyAuto", 1500, 0, function( )
		local data = catherine.net.GetNetGlobalVar( "cat_updateData", { version = catherine.GetVersion( ) } )
		
		if ( data.version == catherine.GetVersion( ) ) then
			return
		end
		
		for k, v in pairs( catherine.util.GetAdmins( true ) ) do
			catherine.popNotify.Send( v, LANG( v, "System_Notify_NewVersionUpdateNeed" ), 10, "CAT/notify03.wav" )
		end
	end )
	
	netstream.Hook( "catherine.update.Check", function( pl )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.update.Check( pl )
		else
			netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
	
	netstream.Hook( "catherine.update.CURun", function( pl )
		if ( catherine.configs.OWNER and catherine.configs.OWNER != "" and pl:SteamID( ) == catherine.configs.OWNER ) then
			if ( catherine.update.noFileIO ) then
				netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_UI_Update_InGameUpdate_NoFileIO" ) )
			else
				catherine.update.StartUpdateMode( pl )
			end
		else
			netstream.Start( pl, "catherine.update.ResultCheck", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
else
	netstream.Hook( "catherine.update.ResultCheck", function( data )
		if ( IsValid( catherine.vgui.system ) ) then
			catherine.vgui.system.updatePanel.status = false
			catherine.vgui.system.updatePanel:RefreshHistory( )
			
			if ( data and type( data ) == "string" ) then
				Derma_Message( LANG( "System_Notify_UpdateError", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
end