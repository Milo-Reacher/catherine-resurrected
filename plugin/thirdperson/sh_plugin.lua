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
PLUGIN.name = "^Thirdperson_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^Thirdperson_Plugin_Desc"
PLUGIN.enable = true

catherine.language.Merge( "english", {
	[ "Thirdperson_Plugin_Name" ] = "Third Person",
	[ "Thirdperson_Plugin_Desc" ] = "Adding the Third Person View.",
	[ "Option_Str_Thirdperson_Name" ] = "Enable Third Person View",
	[ "Option_Str_Thirdperson_Desc" ] = "Switch to Third Person view."
} )

catherine.language.Merge( "korean", {
	[ "Thirdperson_Plugin_Name" ] = "3인칭",
	[ "Thirdperson_Plugin_Desc" ] = "3인칭 시점을 추가합니다.",
	[ "Option_Str_Thirdperson_Name" ] = "3인칭 시점 활성화",
	[ "Option_Str_Thirdperson_Desc" ] = "3인칭 시점으로 전환합니다."
} )

if ( SERVER or !PLUGIN.enable ) then return end

local META = FindMetaTable( "Player" )

function META:CanOverrideView( )
	if (
		IsValid( self ) and
		!IsValid( catherine.vgui.character ) and
		GetConVarString( "cat_convar_thirdperson" ) == "1" and
		!IsValid( self:GetVehicle( ) ) and
		!IsValid( Entity( self:GetNetVar( "ragdollIndex", 0 ) ) ) and
		self:IsCharacterLoaded( ) and
		!self:IsActioning( ) and
		self:Alive( ) and
		( self:IsOnGround( ) or !self:IsNoclipping( ) )
	) then
		return true
	end
end

function PLUGIN:Initialize( )
	CAT_CONVAR_THIRDPERSON = CreateClientConVar( "cat_convar_thirdperson", "0", true, true )
end
	
function PLUGIN:CalcView( pl, pos, ang, fov )
	if ( pl:CanOverrideView( ) and pl:GetViewEntity( ) == pl ) then
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos - ( ang:Forward( ) * 100 ),
			filter = pl
		} )
		
		return {
			origin = tr.Fraction < 1 and ( tr.HitPos + tr.HitNormal * 5 ) or tr.HitPos,
			angles = ang,
			fov = fov
		}
	end
end

function PLUGIN:ShouldDrawLocalPlayer( pl )
	if ( pl:GetViewEntity( ) == pl and !IsValid( pl:GetVehicle( ) ) and pl:CanOverrideView( ) ) then
		return true
	end
end

catherine.option.Register( "CONVAR_THIRD_PERSON", "cat_convar_thirdperson", "^Option_Str_Thirdperson_Name", "^Option_Str_Thirdperson_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )