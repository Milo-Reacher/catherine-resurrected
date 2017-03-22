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

catherine.log = catherine.log or { }
CAT_LOG_FLAG_IMPORTANT = 1
CAT_LOG_FLAG_BASIC = 2
local printColor = Color( 50, 200, 50 )

if ( SERVER ) then
	function catherine.log.Add( flag, str, isStream )
		if ( !catherine.configs.enable_Log ) then return end
		
		flag = flag or CAT_LOG_FLAG_BASIC
		
		local time = os.date( "*t" )
		local today = time.year .. "-" .. time.month .. "-" .. time.day

		if ( isStream ) then
			netstream.Start( catherine.util.GetAdmins( ), "catherine.log.Send", str )
		end
		
		MsgC( printColor, "[CAT LOG] " .. str .. "\n" )
		file.Append( "catherine/log/" .. today .. ".txt", ( flag == CAT_LOG_FLAG_IMPORTANT and "*****" or "" ) .. "[" .. os.date( "%X" ) .. "]" .. ( str or "No Str" ) .. "\r\n" )
	end
	
	function catherine.log.Initialize( )
		if ( !catherine.configs.enable_Log ) then return end
		
		file.CreateDir( "catherine" )
		file.CreateDir( "catherine/log" )
	end

	hook.Add( "Initialize", "catherine.log.Initialize", catherine.log.Initialize )
else
	netstream.Hook( "catherine.log.Send", function( data )
		MsgC( printColor, "[CAT LOG] " .. data .. "\n" )
	end )
end