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

local PLUGIN = PLUGIN
PLUGIN.name = "^SPP_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SPP_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "SPP_Plugin_Name" ] = "Spawn Point",
	[ "SPP_Plugin_Desc" ] = "Adding the Spawn Point for the faction.",
	[ "Spawnpoint_Notify_Add" ] = "You added spawnpoint for '%s' faction.",
	[ "Spawnpoint_Notify_Remove" ] = "You removed %s's spawn points.",
	[ "Spawnpoint_Notify_Remove_No" ] = "This place hasn't spawnpoint!"
} )

catherine.language.Merge( "korean", {
	[ "SPP_Plugin_Name" ] = "스폰 포인트",
	[ "SPP_Plugin_Desc" ] = "팩션에 따른 스폰 포인트를 지정할 수 있습니다.",
	[ "Spawnpoint_Notify_Add" ] = "당신은 '%s' 팩션을 위한 스폰 포인트를 추가했습니다.",
	[ "Spawnpoint_Notify_Remove" ] = "당신은 %s개의 스폰 포인트를 지웠습니다.",
	[ "Spawnpoint_Notify_Remove_No" ] = "이 장소에는 스폰 포인트가 없습니다!"
} )

catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_spawnPointAdd",
	command = "spawnpointadd",
	syntax = "[Faction Name]",
	desc = "Add the Spawn Point for the target faction.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local factionTable = catherine.faction.FindByID( args[ 1 ] )
			
			if ( factionTable ) then
				local map = game.GetMap( )
				local faction = factionTable.uniqueID
				
				PLUGIN.lists[ map ] = PLUGIN.lists[ map ] or { }
				PLUGIN.lists[ map ][ faction ] = PLUGIN.lists[ map ][ faction ] or { }
				PLUGIN.lists[ map ][ faction ][ #PLUGIN.lists[ map ][ faction ] + 1 ] = pl:GetPos( )
				
				PLUGIN:SavePoints( )
				
				catherine.util.NotifyLang( pl, "Spawnpoint_Notify_Add", catherine.util.StuffLanguage( pl, factionTable.name ) )
			else
				catherine.util.NotifyLang( pl, "Faction_Notify_NotValid", args[ 1 ] )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_spawnPointRemove",
	command = "spawnpointremove",
	syntax = "[Range]",
	desc = "Remove the Spawn Point in the this position.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local rad = math.max( tonumber( args[ 1 ] or "" ) or 140, 8 )
		local pos = pl:GetPos( )
		local map = game.GetMap( )
		local i = 0

		for k, v in pairs( PLUGIN.lists[ map ] ) do
			for k1, v1 in pairs( PLUGIN.lists[ map ][ k ] ) do
				if ( catherine.util.CalcDistanceByPos( v1, pos ) <= rad ) then
					i = i + 1
					table.remove( PLUGIN.lists[ map ][ k ], k1 )
				end
			end
		end
		
		if ( i != 0 ) then
			catherine.util.NotifyLang( pl, "Spawnpoint_Notify_Remove", i )
		else
			catherine.util.NotifyLang( pl, "Spawnpoint_Notify_Remove_No" )
		end
	end
} )