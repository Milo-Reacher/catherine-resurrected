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
PLUGIN.name = "^SavePos_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^SavePos_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "SavePos_Plugin_Name" ] = "Save Pos",
	[ "SavePos_Plugin_Desc" ] = "Saving the character position of the last."
} )

catherine.language.Merge( "korean", {
	[ "SavePos_Plugin_Name" ] = "위치 저장",
	[ "SavePos_Plugin_Desc" ] = "캐릭터의 위치를 저장합니다."
} )

if ( CLIENT ) then return end

function PLUGIN:PlayerSpawnedInCharacter( pl )
	local lastPos = catherine.character.GetCharVar( pl, "lastPos" )
	
	if ( lastPos and ( lastPos.map and lastPos.map:lower( ) == game.GetMap( ):lower( ) ) ) then
		if ( lastPos.pos ) then
			pl:SetPos( lastPos.pos )
		end
		
		if ( lastPos.ang ) then
			pl:SetEyeAngles( lastPos.ang )
		end
		
		catherine.character.SetCharVar( pl, "lastPos", nil )
	end
end

function PLUGIN:PlayerDeath( pl )
	if ( catherine.character.GetCharVar( pl, "lastPos" ) ) then
		catherine.character.SetCharVar( pl, "lastPos", nil )
	end
end

function PLUGIN:PostCharacterSave( pl )
	if ( !pl:IsCharacterLoaded( ) or pl:IsStuck( ) or pl:IsNoclipping( ) or pl:IsRagdolled( ) or !pl:Alive( ) or !pl:IsOnGround( ) ) then return end
	
	catherine.character.SetCharVar( pl, "lastPos", {
		pos = pl:GetPos( ),
		ang = pl:EyeAngles( ),
		map = game.GetMap( )
	} )
end