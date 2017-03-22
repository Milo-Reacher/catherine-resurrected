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
PLUGIN.name = "^AW_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^AW_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "AW_Plugin_Name" ] = "Auto Whitelist",
	[ "AW_Plugin_Desc" ] = "Give the whitelist if passed the long time."
} )

catherine.language.Merge( "korean", {
	[ "AW_Plugin_Name" ] = "자동 팩션 추가",
	[ "AW_Plugin_Desc" ] = "시간이 많이 지나면 자동으로 팩션을 줍니다."
} )

if ( SERVER ) then
	PLUGIN.enable = false
	PLUGIN.lists = {
		[ "cp" ] = 5000,
		[ "ow" ] = 240
	}
	PLUGIN.refreshTime = 50
	
	function PLUGIN:PlayerFirstSpawned( pl )
		if ( !self.enable ) then return end
		
		catherine.character.SetCharVar( pl, "aw_playTime", 0 )
	end
	
	function PLUGIN:PlayerSpawnedInCharacter( pl )
		if ( !self.enable ) then return end
		
		pl.CAT_aw_nextTick = pl.CAT_aw_nextTick or CurTime( ) + self.refreshTime
	end
	
	function PLUGIN:PlayerThink( pl )
		if ( !self.enable ) then return end
		
		if ( ( pl.CAT_aw_nextTick or 0 ) <= CurTime( ) ) then
			local prevTime = catherine.character.GetCharVar( pl, "aw_playTime", 0 )
			
			catherine.character.SetCharVar( pl, "aw_playTime", prevTime + self.refreshTime )
			
			for k, v in pairs( self.lists ) do
				local factionTable = catherine.faction.FindByID( k )
				
				if ( !factionTable or !factionTable.isWhitelist ) then continue end
				if ( catherine.faction.HasWhiteList( pl, k ) ) then continue end
				
				if ( prevTime + self.refreshTime >= v ) then
					catherine.faction.AddWhiteList( pl, k )
				end
			end
			
			pl.CAT_aw_nextTick = CurTime( ) + self.refreshTime
		end
	end
end