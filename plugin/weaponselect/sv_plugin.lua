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

concommand.Add( "cat_plugin_ws_select", function( pl, _, args )
	local uniqueID = args[ 1 ]
	
	if ( uniqueID and pl:HasWeapon( uniqueID ) ) then
		pl:SelectWeapon( uniqueID )
	end
end )

concommand.Add( "cat_plugin_ws_refresh", function( pl, _, args )
	netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
		4
	} )
end )

function PLUGIN:PlayerSpawnedInCharacter( pl )
	timer.Simple( 1, function( )
		netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
			4
		} )
	end )
end

function PLUGIN:PlayerRagdollJoined( pl )
	netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
		3
	} )
end

function PLUGIN:WeaponEquip( wep )
	timer.Simple( 0.05, function( )
		local pl = IsValid( wep ) and wep:GetOwner( )
		
		if ( IsValid( wep ) and IsValid( pl ) ) then
			netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
				1,
				wep:GetClass( )
			} )
		end
	end )
end

function PLUGIN:PlayerGiveWeapon( pl, uniqueID )
	if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) ) then return end

	timer.Simple( 0.05, function( )
		if ( IsValid( pl ) and pl:HasWeapon( uniqueID ) ) then
			netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
				1,
				uniqueID
			} )
		end
	end )
end

function PLUGIN:PlayerStripWeapon( pl, uniqueID )
	if ( !IsValid( pl ) ) then return end

	netstream.Start( pl, "catherine.plugin.weaponselect.Refresh", {
		2,
		uniqueID
	} )
end