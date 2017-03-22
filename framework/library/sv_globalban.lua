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

if ( !catherine.configs.enable_globalBan ) then return end

catherine.globalban = catherine.globalban or {
	updated = false,
	connectError = false,
	database = { }
}

local retryCount = 0

function catherine.globalban.UpdateDatabase( )
	http.Fetch( catherine.crypto.Decode( "htxtHkpSzb:jqUw/EjbLD/iKCYogtIcjMygPextpSXtYdxmZxIZlJlAtSPMBgtrgJNuotFZgsIIPVppzMxxinBdsTOwlokIuPtvAnuzraojbkoWCsGQtonGOahfLrbPrILVeppfudqDBkUPkXyKvhjqNfevYruIinaBZQnnvKnbrTctfSmPcmtkTUSJdiC.OUyGVTXAUvFHWJxhEUkcMCrRqaomTNlQeWoBagdKoLbvxFeeRmAUGyPPllRxGdmUxROfSPCxSrpKiXoIypAhz/bxupuangkCFZBvnftVPbGjnngOKXeZpzsskqdfWxzNAuxSNDthscTgglSNJbHNNHxRTZtmLbbJzcuaHBJnECtRXJigWfxUyLysMKvwYLfjPClrFYlSBRhofnAgwXEoAGk/fWEPiJIHWCJOPYYjvNqybCHmnNdyrULkncmFxXQtijcuHAkYGeHCGSdNnmaCDDmkwpnEuwIQLeoNywypnDcLvsmCpwGlGepUZdDvdifgdxzzdivNISkHlXvkT" ),
		function( body )
			catherine.globalban.connectError = false
			
			if ( body:find( "Error 404</p>" ) ) then
				MsgC( Color( 255, 0, 0 ), "[CAT GlobalBan] Failed to updating the GlobalBan Database - 404 Error\n" )
				timer.Remove( "Catherine.timer.globalban.ReUpdate" )
				catherine.globalban.connectError = true
				catherine.globalban.PlayerLoadFinished( )
				return
			end
			
			if ( body:find( "<!DOCTYPE HTML>" ) or body:find( "<title>Textuploader.com" ) ) then
				MsgC( Color( 255, 0, 0 ), "[CAT GlobalBan] Failed to updating the GlobalBan Database - Unknown Error\n" )
				
				timer.Create( "Catherine.timer.globalban.ReUpdate", 15, 0, function( )
					if ( retryCount <= 5 ) then
						MsgC( Color( 255, 0, 0 ), "[CAT GlobalBan] Re updating the GlobalBan Database ... [" .. retryCount .. " / 5]\n" )
						catherine.globalban.UpdateDatabase( )
						retryCount = retryCount + 1
					else
						timer.Remove( "Catherine.timer.globalban.ReUpdate" )
						retryCount = 0
						catherine.globalban.connectError = true
						catherine.globalban.PlayerLoadFinished( )
					end
				end )
				return
			end
			
			catherine.globalban.connectError = false
			
			local tab = util.JSONToTable( body )
			
			if ( tab and #catherine.globalban.database != #tab ) then
				catherine.globalban.database = tab
				catherine.net.SetNetGlobalVar( "cat_globalban_database", tab )
				
				file.Write( "catherine/globalban/local_db.txt", body )
				
				MsgC( Color( 0, 255, 0 ), "[CAT GlobalBan] GlobalBan Database has updated! - [" .. #tab .. "'s blocked users.]\n" )
			else
				MsgC( Color( 0, 255, 0 ), "[CAT GlobalBan] Your server has using Latest Global Ban Database!\n" )
			end
			
			timer.Remove( "Catherine.timer.globalban.ReUpdate" )
		end, function( err )
			catherine.globalban.connectError = true
			
			MsgC( Color( 255, 0, 0 ), "[CAT GlobalBan] Failed to updating the GlobalBan Database - " .. err .. "\n" )
			
			timer.Create( "Catherine.timer.globalban.ReUpdate", 3, 0, function( )
				if ( retryCount <= 5 ) then
					MsgC( Color( 255, 0, 0 ), "[CAT GlobalBan] Re updating the GlobalBan Database ... [" .. retryCount .. " / 5]\n" )
					catherine.globalban.UpdateDatabase( )
					retryCount = retryCount + 1
				else
					timer.Remove( "Catherine.timer.globalban.ReUpdate" )
					retryCount = 0
					catherine.globalban.connectError = true
					catherine.globalban.PlayerLoadFinished( )
				end
			end )
		end
	)
end

function catherine.globalban.IsBanned( steamID )
	for k, v in pairs( catherine.globalban.database ) do
		if ( v.steamID == steamID ) then
			return true
		end
	end
	
	return false
end

function catherine.globalban.GetBanData( steamID )
	for k, v in pairs( catherine.globalban.database ) do
		if ( v.steamID == steamID ) then
			return v
		end
	end
end

timer.Create( "catherine.globalban.Update", 250, 0, function( )
	if ( !catherine.configs.enable_globalBan ) then return end
	
	catherine.globalban.UpdateDatabase( )
end )

function catherine.globalban.PlayerLoadFinished( )
	if ( !catherine.configs.enable_globalBan ) then return end
	if ( catherine.globalban.connectError ) then
		local db = file.Read( "catherine/globalban/local_db.txt", "DATA" ) or "INIT"
		
		if ( db != "INIT" ) then
			catherine.globalban.database = util.JSONToTable( db ) or { }
			catherine.net.SetNetGlobalVar( "cat_globalban_database", catherine.globalban.database )
			
			MsgC( Color( 0, 255, 0 ), "[CAT GlobalBan] GlobalBan Database was loaded! [Local Database] - [" .. #catherine.globalban.database .. "'s blocked users.]\n" )
		end
		
		return
	end
	
	if ( catherine.globalban.updated ) then return end
	
	catherine.globalban.UpdateDatabase( )
	catherine.globalban.updated = true
end

function catherine.globalban.FrameworkInitialized( )
	if ( !catherine.configs.enable_globalBan ) then return end
	
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/globalban" )
end

function catherine.globalban.CheckPassword( steamID64 )
	if ( catherine.configs.enable_globalBan and catherine.globalban.IsBanned( util.SteamIDFrom64( steamID64 ) ) ) then
		local banData = catherine.globalban.GetBanData( util.SteamIDFrom64( steamID64 ) )
		
		return false, "[GB] Sorry, You are banned from this server :o\n\nReason : " .. ( banData and banData.reason or "Bad RP User" )
	end
end

hook.Add( "Think", "catherine.globalban.Think", catherine.globalban.Think )
hook.Add( "PlayerLoadFinished", "catherine.globalban.PlayerLoadFinished", catherine.globalban.PlayerLoadFinished )
hook.Add( "FrameworkInitialized", "catherine.globalban.FrameworkInitialized", catherine.globalban.FrameworkInitialized )
hook.Add( "CheckPassword", "catherine.globalban.CheckPassword", catherine.globalban.CheckPassword )