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

--[[
	This library reference LauScript's Attachment Plugin.
	Thanks :)
	
	https://github.com/Chessnut/NutScript/tree/master/plugins/attachments
]]--

catherine.attachment = catherine.attachment or { lists = { } }
local attachment_blacklist = catherine.configs.attachmentBlacklist

function catherine.attachment.Register( holdType, boneIndex, pos, ang )
	catherine.attachment.lists[ holdType ] = {
		boneIndex = boneIndex,
		pos = pos,
		ang = ang
	}
end

function catherine.attachment.Refresh( pl )
	if ( !pl.CAT_weaponAttachments ) then
		pl.CAT_weaponAttachments = { }
	end

	for k, v in pairs( pl:GetWeapons( ) ) do
		local class = v:GetClass( )
		
		if ( pl.CAT_weaponAttachments[ class ] or table.HasValue( attachment_blacklist, class ) ) then continue end
		
		local dataTable = catherine.attachment.lists[ v:GetHoldType( ) ]

		if ( dataTable ) then
			local offsetPos = dataTable.pos or Vector( -3.96, 4.95, -2.97 )
			local offsetAng = dataTable.ang or Angle( )
			local boneIndex = pl:LookupBone( dataTable.boneIndex or "ValveBiped.Bip01_Spine" )
		
			if ( !boneIndex ) then continue end
			
			local attachmentEnt = ents.Create( "cat_weapon_attachment" )
			attachmentEnt:DrawShadow( false )
			attachmentEnt:SetNotSolid( true )
			attachmentEnt:SetAttachmentParent( pl )
			attachmentEnt:SetAttachmentOffSet( offsetPos )
			attachmentEnt:SetAttachmentAngles( offsetAng )
			attachmentEnt:SetAttachmentBoneIndex( boneIndex )
			attachmentEnt:SetAttachmentWeaponClass( class )
			attachmentEnt:SetParent( pl )
			attachmentEnt:SetModel( v:GetModel( ) )
			
			pl.CAT_weaponAttachments[ class ] = attachmentEnt
		end
	end
	
	for k, v in pairs( pl.CAT_weaponAttachments ) do
		local wep = pl:GetWeapon( k )

		if ( !IsValid( wep ) and IsValid( v ) ) then
			v:Remove( )
			pl.CAT_weaponAttachments[ k ] = nil
		end
	end
end

function catherine.attachment.PlayerSpawnedInCharacter( pl )
	timer.Simple( 2, function( )
		if ( !IsValid( pl ) ) then return end
		
		catherine.attachment.Refresh( pl )
		pl.CAT_enableAttachmentRefresher = true
	end )
end

function catherine.attachment.PlayerSwitchWeapon( pl, oldWep, newWep )
	if ( pl.CAT_enableAttachmentRefresher ) then
		catherine.attachment.Refresh( pl )
	end
end

hook.Add( "PlayerSpawnedInCharacter", "catherine.attachment.PlayerSpawnedInCharacter", catherine.attachment.PlayerSpawnedInCharacter )
hook.Add( "PlayerSwitchWeapon", "catherine.attachment.PlayerSwitchWeapon", catherine.attachment.PlayerSwitchWeapon )

catherine.attachment.Register( "ar2", "ValveBiped.Bip01_Spine", Vector( -3.96, 4.95, -2.97 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "shotgun", "ValveBiped.Bip01_Spine", Vector( -3.96, 4.95, -2.97 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "rpg", "ValveBiped.Bip01_Spine", Vector( -3.96, 4.95, -2.97 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "smg", "ValveBiped.Bip01_Spine", Vector( -3.96, 4.95, -2.97 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "pistol", "ValveBiped.Bip01_Pelvis", Vector( -1, 2.5, -8.5 ), Angle( 0, 0, 80 ) )
catherine.attachment.Register( "revolver", "ValveBiped.Bip01_Pelvis", Vector( -4.19, 0, -8.54 ), Angle( -180, 360, 90 ) )
catherine.attachment.Register( "slam", "ValveBiped.Bip01_Pelvis", Vector( -4.19, 0, -8.54 ), Angle( -180, 180, 90 ) )
catherine.attachment.Register( "grenade", "ValveBiped.Bip01_Pelvis", Vector( 0, -5.55, 8.72 ), Angle( 90, 0, 0 ) )
catherine.attachment.Register( "knife", "ValveBiped.Bip01_Pelvis", Vector( 0, 6.55, 8.72 ), Angle( 90, 0, 0 ) )
catherine.attachment.Register( "duel", "ValveBiped.Bip01_Spine", Vector( -4.19, 0, -8.54 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "melee", "ValveBiped.Bip01_Spine", Vector( 5, 2.55, -3 ), Angle( 0, 0, 0 ) )
catherine.attachment.Register( "melee2", "ValveBiped.Bip01_Spine", Vector( 5, 2.55, -3 ), Angle( 0, 0, 0 ) )