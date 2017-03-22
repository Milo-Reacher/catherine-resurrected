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

--[[ Catherine Lime 4.0 : Last Update 2015-08-17 ]]--

if ( !catherine.configs.enable_Lime ) then return end

catherine.lime = catherine.lime or { libVersion = "2015-08-17", XCode = "CVX" .. math.random( 10000, 99999 ) }
_G[ catherine.lime.XCode ] = _G[ catherine.lime.XCode ] or GetConVarString
	
if ( SERVER ) then
	catherine.lime.masterData = catherine.lime.masterData or { }
	catherine.lime.doing = catherine.lime.doing or false
	
	function catherine.lime.Work( )
		if ( !catherine.lime or catherine.lime.doing ) then return end
		local masterData = {
			serverConfig = {
				cheat = _G[ catherine.lime.XCode ]( "sv_cheats" ),
				csLua = _G[ catherine.lime.XCode ]( "sv_allowcslua" )
			},
			receiveData = { },
			startTime = SysTime( )
		}
		local serverCheat = masterData.serverConfig.cheat
		local serverCSLua = masterData.serverConfig.csLua
		local receiveData = masterData.receiveData
		local startTimeOutChecker = false
		local playerAll = player.GetAll( )
		local playerAllCount = #playerAll
		local i = 0
		local nextCheck = CurTime( ) + 0.05
		
		if ( playerAllCount == 0 ) then
			MsgC( Color( 0, 255, 0 ), "[CAT Lime] No players.\n" )
			return
		end
		
		for k, v in pairs( playerAll ) do
			if ( !IsValid( v ) or !v:IsPlayer( ) ) then
				playerAllCount = playerAllCount - 1
				continue
			end
			
			receiveData[ v ] = {
				clientFetch = { },
				sendTime = SysTime( ),
				fin = false
			}

			i = i + 1
			
			if ( i >= playerAllCount ) then
				startTimeOutChecker = true
			end
		end

		catherine.lime.masterData = masterData
		catherine.lime.doing = true
		netstream.Start( nil, "catherine.lime.CheckRequest" )

		hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
		hook.Add( "Think", "catherine.lime.Work.TimeOutChecker", function( )
			if ( !catherine.lime or !startTimeOutChecker or !catherine.lime.doing ) then return end
			
			if ( nextCheck <= CurTime( ) ) then
				for k, v in pairs( playerAll ) do
					if ( IsValid( v ) and receiveData[ v ] and receiveData[ v ].fin == true ) then
						local isHack = false
						local steamName, steamID = v:SteamName( ), v:SteamID( )

						if ( receiveData[ v ].sendTime - SysTime( ) >= 15 ) then
							MsgC( Color( 255, 255, 0 ), "[CAT Lime] Kicked time out player.[" .. steamName .. "/" .. steamID	.. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked time out player.[" .. steamName .. "/" .. steamID .. "]", true )
							v:Kick( LANG( v, "AntiHaX_KickMessage_TimeOut" ) )
							receiveData[ v ] = nil
							continue
						end
						
						if ( serverCheat != receiveData[ v ].clientFetch.cheat ) then
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_cheats mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( serverCSLua != receiveData[ v ].clientFetch.csLua ) then
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "WARNING !!! : sv_allowcslua mismatch found !!![" .. steamName .. "/" .. steamID .. "]", true )
							isHack = true
						end
						
						if ( isHack ) then
							MsgC( Color( 255, 0, 0 ), "[CAT Lime] Kicked hack player.[" .. steamName .. "/" .. steamID .. "]\n" )
							catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Kicked hack player.[" .. steamName .. "/" .. steamID .. "]", true )
							
							for k, v in pairs( catherine.util.GetAdmins( ) ) do
								catherine.util.NotifyLang( v, "AntiHaX_KickMessageNotifyAdmin", steamName, steamID )
								v:ChatPrint( LANG( v, "AntiHaX_KickMessageNotifyAdmin", steamName, steamID ) )
							end
							
							v:Kick( LANG( v, "AntiHaX_KickMessage" ) )
							receiveData[ v ] = nil
							continue
						else
							receiveData[ v ] = nil
						end
					end
				end
				
				nextCheck = CurTime( ) + 0.05
			end
			
			if ( table.Count( receiveData ) == 0 ) then
				MsgC( Color( 0, 255, 0 ), "[CAT Lime] Finished progress.\n" )
				hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
				catherine.lime.masterData = { }
				catherine.lime.doing = false
			elseif ( masterData.startTime - SysTime( ) >= 50 ) then
				MsgC( Color( 255, 255, 0 ), "[CAT Lime] Checking progress has timed out.\n" )
				hook.Remove( "Think", "catherine.lime.Work.TimeOutChecker" )
				catherine.lime.masterData = { }
				catherine.lime.doing = false
			end
		end )
	end
	
	timer.Create( "Catherine.timer.lime.AutoCheck", catherine.configs.limeCheckInterval, 0, function( )
		if ( !catherine.configs.enable_Lime ) then return end
		if ( !catherine.lime or catherine.lime.doing ) then return end
		
		MsgC( Color( 255, 255, 0 ), "[CAT Lime] Checking the players ...\n" )
		catherine.lime.Work( )
	end )

	netstream.Hook( "catherine.lime.CheckRequest_Receive", function( pl, data )
		if ( !catherine.lime or !catherine.lime.doing ) then return end
		local masterData = catherine.lime.masterData
		
		masterData.receiveData[ pl ].clientFetch = {
			cheat = data[ 1 ],
			csLua = data[ 2 ]
		}
		masterData.receiveData[ pl ].fin = true

		catherine.lime.masterData = masterData
	end )
else
	netstream.Hook( "catherine.lime.CheckRequest", function( )
		if ( !catherine.lime ) then return end
		
		netstream.Start( "catherine.lime.CheckRequest_Receive", {
			_G[ catherine.lime.XCode ]( "sv_cheats" ),
			_G[ catherine.lime.XCode ]( "sv_allowcslua" )
		} )
	end )
end

do
	timer.Remove( "Catherine.timer.lime.CheckSystem" )
	timer.Create( "Catherine.timer.lime.CheckSystem", 30, 0, function( )
		if ( catherine.configs.enable_Lime and !catherine.lime ) then
			MsgC( Color( 255, 0, 0 ), "[CAT Lime WARNING] 'catherine.lime' variable is nil!, This happened from the unknown Lime Exploit!!!\n" )
		end
	end )
end