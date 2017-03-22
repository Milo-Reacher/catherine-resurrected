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

--[[ Catherine External X 3.0 : Last Update 2015-10-02 ]]--

catherine.externalX = catherine.externalX or { libVersion = "2015-10-02" }

if ( SERVER ) then
	catherine.externalX.isInitialized = catherine.externalX.isInitialized or false
	catherine.externalX.applied = catherine.externalX.applied or false
	catherine.externalX.patchVersion = catherine.externalX.patchVersion or nil
	catherine.externalX.newPatchVersion = catherine.externalX.newPatchVersion or nil
	catherine.externalX.foundNewPatch = catherine.externalX.foundNewPatch or false
	
	local function isErrorData( data )
		if ( data:find( "Error 404</p>" ) ) then
			return 1
		end
		
		if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
			return 2
		end
		
		return 0
	end
	
	function catherine.externalX.CheckNewPatch( pl, isManual, runFunc, noCoolTime )
		if ( isManual and IsValid( pl ) ) then
			if ( ( catherine.externalX.nextCheckable or 0 ) >= CurTime( ) ) then
				netstream.Start( pl, "catherine.externalX.ResultCheckNewPatch", LANG( pl, "System_Notify_ExternalX_NextTime" ) )
				return
			end
		end
		
		http.Fetch( catherine.crypto.Decode( "htDtgtpzMl:YbCb/qpehh/FqoQeNtnYXIDruelRVQLCJExSAvHwIqWStqQBFGQanDuuCpgGbgoekIBpKbMivrjFMbeOloLqFSPDUoysAyoTygVRLIQIzZyceapFeopiZpYaUncIXdNHsWUtHuLqheLFFQeoBgSCUAppkQNmKNuartzJoFLIHtQlWpbkeGN.HMNCsRWkSEgIZZZqtEmcDKjBMshaDuzrBvztufYfotBKoxmArgttkpTZHdMsDVmBQksVJzErdSRnsHnTWhzTq/LtNmhxBtoeZVebrRJgVbcKZapUOtwOWGtiOMbAuJJwCqqemz2uIFXrdJWhodcaHMJiVEtzRHgsnzTisaeozTvyrGStfdqItnDTtFJ0xwEaREyRVdSXEPxDRfXnrPZMRwCtlTOajRgtqttIbAGeOIzYtHXFpTfE/ELATjQiWCUXccTzUxaiZWVRixzqRYrdQchaxIOhFcfVcjvQXprLbvLMtpyvearNDsEVefEwsCUsHXfQMKUTZKOscKeFtwdVIldJKVawUXPUYIoaLRWEyukxncXlbN" ),
			function( data )
				local isErrorData = isErrorData( data )
				
				if ( isErrorData == 1 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to check for new patch! [404 ERROR]\n" )
					timer.Remove( "Catherine.timer.externalX.CheckNewPatch.Retry" )
					
					if ( isManual and IsValid( pl ) ) then
						netstream.Start( pl, "catherine.externalX.ResultCheckNewPatch", "404 ERROR" )
					end
					return
				elseif ( isErrorData == 2 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to check for new patch!, recheck ... [Unknown Error]\n" )
					
					timer.Remove( "Catherine.timer.externalX.CheckNewPatch.Retry" )
					timer.Create( "Catherine.timer.externalX.CheckNewPatch.Retry", 15, 0, function( )
						MsgC( Color( 255, 255, 0 ), "[CAT ExX] Rechecking new patch ...\n" )
						catherine.externalX.CheckNewPatch( pl, isManual, runFunc, noCoolTime )
					end )
					return
				end
				
				if ( catherine.externalX.patchVersion == data ) then
					if ( runFunc ) then
						catherine.externalX.StartApplyServerPatch( )
					end
					
					if ( IsValid( pl ) ) then
						netstream.Start( nil, "catherine.externalX.SendData", {
							catherine.externalX.foundNewPatch,
							catherine.externalX.patchVersion,
							catherine.externalX.newPatchVersion
						} )
						
						if ( runFunc ) then
							catherine.externalX.StartInitApplyRequestClientPatch( pl )
						end
					end
				else
					catherine.externalX.NotifyPatch( data )
				end
				
				catherine.externalX.isInitialized = true
				timer.Remove( "Catherine.timer.externalX.CheckNewPatch.Retry" )
				
				if ( isManual and IsValid( pl ) ) then
					netstream.Start( pl, "catherine.externalX.ResultCheckNewPatch" )
				end
				
				if ( !noCoolTime ) then
					catherine.externalX.nextCheckable = CurTime( ) + 150
				end
			end, function( err )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to check for new patch! [" .. err .. "]\n" )
				
				if ( isManual and IsValid( pl ) ) then
					netstream.Start( pl, "catherine.externalX.ResultCheckNewPatch", err )
				end
			end
		)
	end
	
	function catherine.externalX.DownloadPatch( pl )
		http.Fetch( catherine.crypto.Decode( "htqtKCpzra:EHmD/RHtGI/VPXcOAtpxsPnzKeYNDyJbGCxXiAXYoXyGtAHltFzAaWOunkNVJOnljCPpyYhgySEWvTexlckSqoesZvIzVnodxXfPGEBZxUHosafluLesVdgdpqYKpdRisuyqBgwoPBcRXKeOfHGsWQyjVmjHnprcretrJkSdpsLKjrQCBqr.nodmyNJRhYeSeWjhJcVcIGrMcQIuhSyPHfNRDfdiolEEOnKFwIBWtwVVfVeDqfmYwviLCCFxPqYKTXSEcIFSQ/kXszerVAtnvWGdrQIZYvZAoaiODsELZcyOQhQfpcYmgBpiEn2BzEvTElmswnMdgrVqqIqMyowvyeiqaCyWwXmgShQNRcnZIRfwVOTltxQbVgPtGaOxSSKwPdAXNWeVHGWezmxQEIBWdmwsJgiuwwKmcyohGRWX/WleGwFPEZtFWedRzULHgVpwafwkkVrhpXxHckUuxFoxnNnZqYJxfUGWtSJmkalgMaEWilUVYqAAvFCodvKefToXhbShxwytXCQbVuNCLSKuBDxItMNxrpipzEaksD" ),
			function( data )
				local isErrorData = isErrorData( data )
				
				if ( isErrorData == 1 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to download for new patch! [404 ERROR]\n" )
					timer.Remove( "Catherine.timer.externalX.DownloadPatch.Retry" )
					return
				elseif ( isErrorData == 2 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to download for new patch, redownload ... [Unknown Error]\n" )
					
					timer.Remove( "Catherine.timer.externalX.DownloadPatch.Retry" )
					timer.Create( "Catherine.timer.externalX.DownloadPatch.Retry", 15, 0, function( )
						MsgC( Color( 255, 255, 0 ), "[CAT ExX] Downloading new patch ...\n" )
						catherine.externalX.DownloadPatch( pl )
					end )
					return
				end
				
				timer.Simple( 1, function( )
					local success, err = catherine.externalX.InstallPatchFile( data )
					
					if ( success ) then
						netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
							true
						} )
						
						netstream.Start( nil, "catherine.externalX.SendData", {
							catherine.externalX.foundNewPatch,
							catherine.externalX.patchVersion,
							catherine.externalX.newPatchVersion
						} )
						
						timer.Simple( 5, function( )
							RunConsoleCommand( "changelevel", game.GetMap( ) )
						end )
					else
						netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
							false,
							err
						} )
					end
				end )
				
				timer.Remove( "Catherine.timer.externalX.DownloadPatch.Retry" )
			end, function( err )
				MsgC( Color( 255, 0, 0 ), "[CAT ExX ERROR] Failed to download for new patch! [" .. err .. "]\n" )
				
				netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
					false,
					err
				} )
			end
		)
	end
	
	function catherine.externalX.NotifyPatch( newPatchVer )
		catherine.externalX.newPatchVersion = newPatchVer
		catherine.externalX.foundNewPatch = true
		
		netstream.Start( nil, "catherine.externalX.SendData", {
			catherine.externalX.foundNewPatch,
			catherine.externalX.patchVersion,
			newPatchVer
		} )
	end
	
	function catherine.externalX.InstallPatchFile( patchCodes )
		local convert = util.JSONToTable( patchCodes )
		local patchVer = tostring( convert.patchVer )
		local serverPatchCodes, clientPatchCodes = convert.server, convert.client
		
		file.Write( "catherine/exx3/patch_ver.txt", patchVer or "INIT" )
		file.Write( "catherine/exx3/patch_server.txt", serverPatchCodes )
		file.Write( "catherine/exx3/patch_client.txt", clientPatchCodes )
		
		catherine.externalX.foundNewPatch = false
		catherine.externalX.patchVersion = patchVer or "INIT"
		catherine.externalX.newPatchVersion = patchVer
		
		return true
	end
	
	function catherine.externalX.StartApplyServerPatch( )
		local serverPatchCodes = file.Read( "catherine/exx3/patch_server.txt", "DATA" ) or ""
		
		if ( !serverPatchCodes or serverPatchCodes == "nil" or serverPatchCodes == "" or serverPatchCodes == "INIT" ) then return end
		
		local success, result = pcall( RunString, serverPatchCodes )
		
		if ( success ) then
			catherine.externalX.applied = true
		else
			ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.externalX.applied = false
		end
	end
	
	function catherine.externalX.StartInitApplyRequestClientPatch( pl )
		local clientPatchCodes = file.Read( "catherine/exx3/patch_client.txt", "DATA" ) or ""
		
		if ( !clientPatchCodes or clientPatchCodes == "nil" or clientPatchCodes == "" or clientPatchCodes == "INIT" ) then return end
		
		local codeDivide = catherine.util.GetDivideTextData( clientPatchCodes, 1000 )
				
		netstream.Start( pl, "catherine.externalX.StartProtocol" )
		
		for k, v in pairs( codeDivide ) do
			netstream.Start( pl, "catherine.externalX.SendExCodes", {
				k,
				v
			} )
		end
		
		netstream.Start( pl, "catherine.externalX.CloseProtocol", true )
	end
	
	function catherine.externalX.StartApplyRequestClientPatch( pl )
		netstream.Start( pl, "catherine.externalX.StartApplyClientPatch" )
	end
	
	function catherine.externalX.Initialize( )
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/exx3" )
		catherine.externalX.patchVersion = file.Read( "catherine/exx3/patch_ver.txt", "DATA" ) or "INIT"
	end
	
	function catherine.externalX.PlayerLoadFinished( pl )
		if ( !catherine.externalX.isInitialized ) then
			catherine.externalX.CheckNewPatch( pl, false, true, true )
		else
			netstream.Start( pl, "catherine.externalX.SendData", {
				catherine.externalX.foundNewPatch,
				catherine.externalX.patchVersion,
				catherine.externalX.newPatchVersion
			} )
			
			catherine.externalX.StartInitApplyRequestClientPatch( pl )
		end
	end
	
	function catherine.externalX.PlayerSpawnedInCharacter( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		
		if ( catherine.externalX.foundNewPatch ) then
			catherine.popNotify.Send( pl, LANG( pl, "System_Notify_ExternalXUpdateNeed" ), 10, "CAT/notify03.wav" )
		end
	end
	
	hook.Add( "PlayerLoadFinished", "catherine.externalX.PlayerLoadFinished", catherine.externalX.PlayerLoadFinished )
	hook.Add( "PlayerSpawnedInCharacter", "catherine.externalX.PlayerSpawnedInCharacter", catherine.externalX.PlayerSpawnedInCharacter )
	
	timer.Create( "catherine.externalX.NotifyAuto", 900, 0, function( )
		if ( !catherine.externalX.foundNewPatch ) then return end
		
		for k, v in pairs( catherine.util.GetAdmins( true ) ) do
			catherine.popNotify.Send( v, LANG( v, "System_Notify_ExternalXUpdateNeed" ), 10, "CAT/notify03.wav" )
		end
	end )
	
	catherine.externalX.Initialize( )
	
	netstream.Hook( "catherine.externalX.DownloadPatch", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.externalX.DownloadPatch( pl )
		else
			netstream.Start( pl, "catherine.externalX.ResultInstallPatch", {
				false,
				LANG( pl, "System_Notify_PermissionError" )
			} )
		end
	end )
	
	netstream.Hook( "catherine.externalX.CheckNewPatch", function( pl, data )
		if ( pl:IsSuperAdmin( ) ) then
			catherine.externalX.CheckNewPatch( pl, true, false )
		else
			netstream.Start( pl, "catherine.externalX.ResultCheckNewPatch", LANG( pl, "System_Notify_PermissionError" ) )
		end
	end )
else
	catherine.externalX.applied = catherine.externalX.applied or false
	catherine.externalX.foundNewPatch = catherine.externalX.foundNewPatch or false
	catherine.externalX.patchVersion = catherine.externalX.patchVersion or nil
	catherine.externalX.newPatchVersion = catherine.externalX.newPatchVersion or nil
	catherine.externalX.clientPatchCodes = catherine.externalX.clientPatchCodes or nil
	catherine.externalX.clientPatchCodesBuffer = catherine.externalX.clientPatchCodesBuffer or nil
	
	netstream.Hook( "catherine.externalX.StartProtocol", function( data )
		catherine.externalX.clientPatchCodesBuffer = { }
	end )
	
	netstream.Hook( "catherine.externalX.CloseProtocol", function( data )
		if ( !catherine.externalX.clientPatchCodesBuffer ) then return end
		catherine.externalX.clientPatchCodes = table.concat( catherine.externalX.clientPatchCodesBuffer, "" )
		catherine.externalX.clientPatchCodesBuffer = nil
		
		if ( data == true ) then
			catherine.externalX.StartApplyClientPatch( )
		end
	end )
	
	netstream.Hook( "catherine.externalX.StartApplyClientPatch", function( data )
		catherine.externalX.StartApplyClientPatch( )
	end )
	
	netstream.Hook( "catherine.externalX.SendExCodes", function( data )
		if ( !catherine.externalX.clientPatchCodesBuffer ) then return end
		
		catherine.externalX.clientPatchCodesBuffer[ data[ 1 ] ] = data[ 2 ]
	end )
	
	netstream.Hook( "catherine.externalX.SendData", function( data )
		catherine.externalX.foundNewPatch = data[ 1 ]
		catherine.externalX.patchVersion = data[ 2 ]
		catherine.externalX.newPatchVersion = data[ 3 ]
	end )
	
	netstream.Hook( "catherine.externalX.ResultCheckNewPatch", function( data )
		if ( IsValid( catherine.vgui.system ) ) then
			catherine.vgui.system.externalXPanel.status = false
			
			if ( data and type( data ) == "string" ) then
				Derma_Message( LANG( "System_Notify_ExternalXError", data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
	
	netstream.Hook( "catherine.externalX.ResultInstallPatch", function( data )
		if ( IsValid( catherine.vgui.system ) ) then
			if ( data[ 1 ] ) then
				catherine.vgui.system.externalXPanel.restartDelay = true
				catherine.externalX.foundNewPatch = false
			end
			
			catherine.vgui.system.externalXPanel.status = false
			catherine.vgui.system.externalXPanel.hideAll = false
			
			if ( data[ 2 ] and type( data[ 2 ] ) == "string" ) then
				Derma_Message( LANG( "System_Notify_ExternalXError2", data[ 2 ] ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end
		end
	end )
	
	function catherine.externalX.StartApplyClientPatch( )
		if ( catherine.externalX.applied ) then return end
		local clientPatchCodes = catherine.externalX.clientPatchCodes or ""
		
		if ( !clientPatchCodes or clientPatchCodes == "nil" or clientPatchCodes == "" or clientPatchCodes == "INIT" ) then return end
		
		local success, result = pcall( RunString, clientPatchCodes )
		
		if ( success ) then
			catherine.externalX.applied = true
		else
			ErrorNoHalt( "\n[CAT ExX ERROR] SORRY, On the External X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.externalX.applied = false
		end
	end
end