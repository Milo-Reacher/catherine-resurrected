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

catherine.limb = catherine.limb or { }
catherine.limb.bones = {
	[ "ValveBiped.Bip01_Head1" ] = HITGROUP_HEAD,
	[ "ValveBiped.Bip01_Neck1" ] = HITGROUP_HEAD,
	[ "ValveBiped.Bip01_R_UpperArm" ] = HITGROUP_RIGHTARM,
	[ "ValveBiped.Bip01_R_Forearm" ] = HITGROUP_RIGHTARM,
	[ "ValveBiped.Bip01_L_UpperArm" ] = HITGROUP_LEFTARM,
	[ "ValveBiped.Bip01_L_Forearm" ] = HITGROUP_LEFTARM,
	[ "ValveBiped.Bip01_R_Thigh" ] = HITGROUP_RIGHTLEG,
	[ "ValveBiped.Bip01_R_Calf" ] = HITGROUP_RIGHTLEG,
	[ "ValveBiped.Bip01_R_Foot" ] = HITGROUP_RIGHTLEG,
	[ "ValveBiped.Bip01_R_Hand" ] = HITGROUP_RIGHTARM,
	[ "ValveBiped.Bip01_L_Thigh" ] = HITGROUP_LEFTLEG,
	[ "ValveBiped.Bip01_L_Calf" ] = HITGROUP_LEFTLEG,
	[ "ValveBiped.Bip01_L_Foot" ] = HITGROUP_LEFTLEG,
	[ "ValveBiped.Bip01_L_Hand" ] = HITGROUP_LEFTARM,
	[ "ValveBiped.Bip01_Pelvis" ] = HITGROUP_STOMACH,
	[ "ValveBiped.Bip01_Spine1" ] = HITGROUP_CHEST,
	[ "ValveBiped.Bip01_Spine2" ] = HITGROUP_CHEST
}

function catherine.limb.BoneToHitGroup( boneID )
	return catherine.limb.bones[ boneID ] or HITGROUP_CHEST
end

if ( SERVER ) then
	local healAmount = catherine.configs.limbHealAmount
	local limbDamageAutoHealInterval = catherine.configs.limbDamageAutoHeal
	
	function catherine.limb.TakeDamage( pl, hitGroup, amount )
		local limbTable = catherine.character.GetCharVar( pl, "limbTable", { } )
		
		limbTable[ hitGroup ] = math.Clamp( ( limbTable[ hitGroup ] or 0 ) + amount, 0, 100 )

		catherine.character.SetCharVar( pl, "limbTable", limbTable )
		
		hook.Run( "PlayerLimbTakeDamage", pl, hitGroup, limbTable[ hitGroup ] )
	end
	
	function catherine.limb.HealBody( pl, amount )
		for k, v in pairs( catherine.character.GetCharVar( pl, "limbTable", { } ) ) do
			catherine.limb.HealDamage( pl, k, amount )
		end
	end
	
	function catherine.limb.HealDamage( pl, hitGroup, amount )
		local limbTable = catherine.character.GetCharVar( pl, "limbTable", { } )
		local limbData = limbTable[ hitGroup ]
		
		if ( limbData ) then
			limbData = math.Clamp( limbData - amount, 0, 100 )
			
			if ( limbData == 0 ) then
				limbData = nil
			end
			
			limbTable[ hitGroup ] = limbData
			
			catherine.character.SetCharVar( pl, "limbTable", limbTable )
			
			hook.Run( "PlayerLimbDamageHealed", pl, hitGroup, limbData or 0 )
		end
	end
	
	function catherine.limb.IsAnyDamaged( pl )
		return table.Count( catherine.character.GetCharVar( pl, "limbTable", { } ) ) > 0
	end
	
	function catherine.limb.GetDamage( pl, hitGroup )
		local limbTable = catherine.character.GetCharVar( pl, "limbTable", { } )
		
		return limbTable[ hitGroup ] or 0
	end

	function catherine.limb.InitializeDamage( pl )
		catherine.character.SetCharVar( pl, "limbTable", { } )
	end
	
	function catherine.limb.PlayerThink( pl )
		if ( !catherine.limb.IsAnyDamaged( pl ) ) then return end
		
		if ( ( pl.CAT_limbNextHealTick or 0 ) <= CurTime( ) ) then
			if ( hook.Run( "PlayerShouldAutoHealLimbDamage", pl ) == false ) then return end
			
			for k, v in pairs( catherine.character.GetCharVar( pl, "limbTable", { } ) ) do
				local healAmount = healAmount[ k ]

				if ( healAmount ) then
					catherine.limb.HealDamage( pl, k, healAmount )
				end
			end
			
			pl.CAT_limbNextHealTick = CurTime( ) + ( hook.Run( "GetAutoHealInterval", pl ) or limbDamageAutoHealInterval )
		end
	end
	
	hook.Add( "PlayerThink", "catherine.limb.PlayerThink", catherine.limb.PlayerThink )
else
	catherine.limb.materials = {
		[ HITGROUP_HEAD ] = Material( "CAT/Limb/head.png", "smooth" ),
		[ HITGROUP_CHEST ] = Material( "CAT/Limb/chest.png", "smooth" ),
		[ HITGROUP_STOMACH ] = Material( "CAT/Limb/stomach.png", "smooth" ),
		[ HITGROUP_RIGHTARM ] = Material( "CAT/Limb/right_arm.png", "smooth" ),
		[ HITGROUP_LEFTARM ] = Material( "CAT/Limb/left_arm.png", "smooth" ),
		[ HITGROUP_LEFTLEG ] = Material( "CAT/Limb/left_leg.png", "smooth" ),
		[ HITGROUP_RIGHTLEG ] = Material( "CAT/Limb/right_leg.png", "smooth" )
	}
	
	function catherine.limb.GetColor( damage )
		if ( damage > 75 ) then
			return Color( 255, 64, 64, 255 )
		elseif ( damage > 50 ) then
			return Color( 255, 127, 36, 255 )
		elseif ( damage > 25 ) then
			return Color( 255, 185, 15, 255 )
		else
			return Color( 255, 185, 15, 255 )
		end
	end
	
	function catherine.limb.GetTable( )
		return catherine.character.GetCharVar( catherine.pl, "limbTable", { } )
	end
	
	function catherine.limb.IsAnyDamaged( )
		return table.Count( catherine.character.GetCharVar( catherine.pl, "limbTable", { } ) ) > 0
	end
end