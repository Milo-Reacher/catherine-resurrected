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
PLUGIN.name = "^CustomSpawn_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^CustomSpawn_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "CustomSpawn_Plugin_Name" ] = "Custom Spawn Point",
	[ "CustomSpawn_Plugin_Desc" ] = "Setting the Custom Spawn Point for the target.",
	[ "CustomSpawn_Notify_Add" ] = "You are setting a this position for target player.",
	[ "CustomSpawn_Notify_Remove" ] = "You are removed a spawn point for target player."
	
} )

catherine.language.Merge( "korean", {
	[ "CustomSpawn_Plugin_Name" ] = "커스텀 스폰 지점",
	[ "CustomSpawn_Plugin_Desc" ] = "특정 사람에 대한 커스텀 스폰 지점을 설정할 수 있습니다.",
	[ "CustomSpawn_Notify_Add" ] = "당신은 이 지점을 해당 사람의 스폰 포인트로 설정하셨습니다.",
	[ "CustomSpawn_Notify_Remove" ] = "당신은 해당 사람의 스폰 포인트를 지우셨습니다."
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_customSpawnPointAdd",
	command = "customspawnpointadd",
	syntax = "[Name]",
	desc = "Add the Custom Spawn Point for the target.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
			if ( IsValid( target ) and target:IsPlayer( ) ) then
				local point = pl:GetEyeTrace( ).HitPos
				
				catherine.character.SetCharVar( target, "customSpawnPoint", point )
				
				catherine.util.NotifyLang( pl, "CustomSpawn_Notify_Add" )
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_customSpawnPointRemove",
	command = "customspawnpointremove",
	syntax = "[Name]",
	desc = "Remove the Custom Spawn Point for the target.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
			if ( IsValid( target ) and target:IsPlayer( ) ) then
				catherine.character.SetCharVar( target, "customSpawnPoint", nil )
				
				catherine.util.NotifyLang( pl, "CustomSpawn_Notify_Remove" )
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

if ( SERVER ) then
	function PLUGIN:OnSpawnedInCharacter( pl )
		local customSpawnPoint = catherine.character.GetCharVar( pl, "customSpawnPoint" )
		
		if ( customSpawnPoint ) then
			pl:SetPos( customSpawnPoint )
		end
	end
end