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

if ( game.IsDedicated( ) ) then
	concommand.Remove( "gm_save" )
	
	concommand.Add( "gm_save", function( pl )
		if ( IsValid( pl ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
		end
	end )
end

function GM:ShowHelp( pl )
	if ( hook.Run( "PlayerShouldOpenInformationMenu", pl ) == false ) then return end
	
	netstream.Start( pl, "catherine.ShowHelp" )
end

function GM:ShowTeam( pl )
	if ( hook.Run( "PlayerShouldOpenRecognizeOrDoorMenu", pl ) == false ) then return end
	
	local data = { }
	data.start = pl:GetShootPos( )
	data.endpos = data.start + pl:GetAimVector( ) * 70
	data.filter = pl
	local ent = util.TraceLine( data ).Entity
	
	if ( IsValid( ent ) and ent:IsDoor( ) and !catherine.door.IsDoorDisabled( ent ) and !ent:GetNoDraw( ) ) then
		local has, flag = catherine.door.IsHasDoorPermission( pl, ent )
		
		if ( has ) then
			if ( flag == CAT_DOOR_FLAG_BASIC ) then return end
			
			netstream.Start( pl, "catherine.door.DoorMenu", {
				ent:EntIndex( ),
				flag
			} )
		else
			local isBuyable = catherine.door.IsBuyableDoor( ent )
			
			if ( isBuyable ) then
				catherine.util.QueryReceiver( pl, "BuyDoor_Question", LANG( pl, "Door_Notify_BuyQ", catherine.cash.GetCompleteName( catherine.door.GetDoorCost( pl, ent ) ) ), function( _, bool )
					if ( bool ) then
						catherine.command.Run( pl, "&uniqueID_doorBuy" )
					end
				end )
			end
		end
	else
		netstream.Start( pl, "catherine.recognize.SelectMenu" )
	end
end

function GM:DatabaseError( query, err )
	local time = os.date( "*t" )
	local today = time.year .. "-" .. time.month .. "-" .. time.day
	
	file.Append( "catherine/database/error/" .. today .. ".txt", "[" .. os.date( "%X" ) .. "] DATABASE ERROR > " .. ( query or "UNKNOWN" ) .. " -> " .. ( err or "Unknown" ) .. "\r\n" )
end

function GM:PlayerShouldOpenInformationMenu( pl )
	return pl:IsCharacterLoaded( ) and !catherine.player.IsCharacterBanned( pl )
end

function GM:PlayerShouldOpenRecognizeOrDoorMenu( pl )
	return pl:IsCharacterLoaded( ) and !catherine.player.IsCharacterBanned( pl )
end

function GM:PlayerFirstSpawned( pl, id )
	catherine.character.SetCharVar( pl, "originalModel", pl:GetModel( ) )
end

function GM:OnPhysgunFreeze( weapon, physObject, ent, pl )
	if ( !physObject:IsMoveable( ) ) then return false end
	if ( ent:GetUnFreezable( ) ) then return false end
	
	physObject:EnableMotion( false )
	
	if ( table.HasValue( catherine.configs.physgunBoneFreezeList, ent:GetClass( ) ) ) then
		for i = 0, ent:GetPhysicsObjectCount( ) - 1 do
			ent:GetPhysicsObjectNum( i ):EnableMotion( false )
		end
	end
	
	pl:AddFrozenPhysicsObject( ent, physObject )
	
	return true
end

function GM:PlayerSwitchWeapon( pl, oldWep, newWep )
	if ( newWep.AlwaysRaised and catherine.configs.alwaysRaised[ newWep:GetClass( ) ] ) then
		pl:SetWeaponRaised( true, newWep )
	else
		pl:SetWeaponRaised( false, newWep )
	end
end

function GM:CharacterVarChanged( pl, key, value )
	if ( key == "_name" ) then
		hook.Run( "CharacterNameChanged", pl, value )
	elseif ( key == "_model" ) then
		pl:SetModel( value )
		pl:SetupHands( )
		catherine.character.SetCharVar( pl, "originalModel", value )
		hook.Run( "CharacterModelChanged", pl, value )
	end
end

function GM:OnReloaded( )

end

function GM:CharacterCharVarChanged( pl, key, value )
	if ( key == "skin" ) then
		value = tonumber( value ) or 0
		
		pl:SetSkin( value )
		hook.Run( "CharacterSkinChanged", pl, value )
	end
end

function GM:CanPlayerSuicide( pl )
	return hook.Run( "PlayerCanSuicide", pl ) or false
end

function GM:GetGameDescription( )
	return "CAT 1.0 : " .. ( Schema and Schema.Name or "Unknown" )
end

function GM:PlayerSpray( pl )
	return !hook.Run( "PlayerCanSpray", pl )
end

function GM:PlayerHealthSet( pl, newHealth, oldHealth )
	local maxHealth = pl:GetMaxHealth( )
	
	if ( newHealth > oldHealth ) then
		catherine.limb.HealBody( pl, ( newHealth - oldHealth ) / 2.2 )
		catherine.character.SetCharVar( pl, "isHealthRecover", true )
	end
	
	if ( newHealth >= maxHealth ) then
		catherine.limb.HealBody( pl, 100 )
		pl:RemoveAllDecals( )
	end
end

function GM:GetHealthRecoverInterval( pl )

end

function GM:PlayerShouldWorkItem( pl, itemTable, workID, ent_isMenu )
	if ( !pl:Alive( ) ) then
		catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
		return false
	end
	
	if ( pl:IsTied( ) ) then
		catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
		return false
	end
	
	if ( workID == "take" and hook.Run( "PlayerShouldTakeItem", pl, itemTable ) == false ) then
		return false
	end
	
	if ( workID == "drop" and hook.Run( "PlayerShouldDropItem", pl, itemTable ) == false ) then
		return false
	end
	
	return true
end

function GM:PlayerCharacterLoaded( pl )
	local health = catherine.character.GetCharVar( pl, "char_health", pl:Health( ) )
	local armor = catherine.character.GetCharVar( pl, "char_armor", 0 )
	
	if ( math.Round( health ) > 0 ) then
		pl:SetHealth( health )
	end
	
	pl:SetArmor( armor )
	
	local factionTable = catherine.faction.FindByIndex( pl:Team( ) )
	local class = pl:Class( )
	local timerID = "Catherine.timer.AutoSalary." .. pl:SteamID( )
	
	if ( class ) then
		local classTable = catherine.class.FindByIndex( class )
		
		if ( classTable and classTable.salary and classTable.salary > 0 ) then
			timer.Create( timerID, classTable.salaryTime or 350, 0, function( )
				if ( !IsValid( pl ) ) then
					timer.Remove( timerID )
					return
				end
				
				local amount = hook.Run( "GetClassSalaryAmount", pl, classTable ) or classTable.salary
				
				catherine.cash.Give( pl, amount )
				catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
			end )
		else
			if ( factionTable and factionTable.salary and factionTable.salary > 0 ) then
				timer.Create( timerID, factionTable.salaryTime or 350, 0, function( )
					if ( !IsValid( pl ) ) then
						timer.Remove( timerID )
						return
					end
					
					local amount = hook.Run( "GetSalaryAmount", pl, factionTable ) or factionTable.salary
					
					catherine.cash.Give( pl, amount )
					catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
				end )
			else
				timer.Remove( timerID )
			end
		end
	else
		if ( factionTable and factionTable.salary and factionTable.salary > 0 ) then
			timer.Create( timerID, factionTable.salaryTime or 350, 0, function( )
				if ( !IsValid( pl ) ) then
					timer.Remove( timerID )
					return
				end
				
				local amount = hook.Run( "GetSalaryAmount", pl, factionTable ) or factionTable.salary
				
				catherine.cash.Give( pl, amount )
				catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
			end )
		else
			timer.Remove( timerID )
		end
	end
	
	pl:SendLua( "catherine.bar.InitializeWide( )" )
end

function GM:PostSetClass( pl, classTable )
	local factionTable = catherine.faction.FindByIndex( pl:Team( ) )
	local class = pl:Class( )
	local timerID = "Catherine.timer.AutoSalary." .. pl:SteamID( )
	
	if ( class ) then
		if ( classTable and classTable.salary and classTable.salary > 0 ) then
			timer.Create( timerID, classTable.salaryTime or 350, 0, function( )
				if ( !IsValid( pl ) ) then
					timer.Remove( timerID )
					return
				end
				
				local amount = hook.Run( "GetClassSalaryAmount", pl, classTable ) or classTable.salary
				
				catherine.cash.Give( pl, amount )
				catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
			end )
		else
			if ( factionTable and factionTable.salary and factionTable.salary > 0 ) then
				timer.Create( timerID, factionTable.salaryTime or 350, 0, function( )
					if ( !IsValid( pl ) ) then
						timer.Remove( timerID )
						return
					end
					
					local amount = hook.Run( "GetSalaryAmount", pl, factionTable ) or factionTable.salary
					
					catherine.cash.Give( pl, amount )
					catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
				end )
			else
				timer.Remove( timerID )
			end
		end
	else
		if ( factionTable and factionTable.salary and factionTable.salary > 0 ) then
			timer.Create( timerID, factionTable.salaryTime or 350, 0, function( )
				if ( !IsValid( pl ) ) then
					timer.Remove( timerID )
					return
				end
				
				local amount = hook.Run( "GetSalaryAmount", pl, factionTable ) or factionTable.salary
				
				catherine.cash.Give( pl, amount )
				catherine.util.NotifyLang( pl, "Cash_Notify_Salary", catherine.cash.GetCompleteName( amount ) )
			end )
		else
			timer.Remove( timerID )
		end
	end
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.CAT_deathBody ) ) then
		pl.CAT_deathBody:Remove( )
		pl.CAT_deathBody = nil
	end
	
	if ( IsValid( pl.CAT_ragdoll ) ) then
		pl.CAT_ragdoll:Remove( )
		pl.CAT_ragdoll = nil
	end
	
	pl.CAT_deathSoundPlayed = nil
	pl.CAT_isDeadFunc = nil
	
	pl:SetNetVar( "noDrawOriginal", nil )
	pl:SetNetVar( "nextSpawnTime", nil )
	pl:SetNetVar( "deathTime", nil )
	pl:SetNetVar( "isTied", nil )
	pl:SetNetVar( "isRagdolled", nil )
	pl:SetNetVar( "ragdollIndex", nil )
	pl:SetNetVar( "isForceRagdolled", nil )
	
	pl:Freeze( false )
	pl:SetNoDraw( false )
	pl:SetNotSolid( false )
	player_manager.SetPlayerClass( pl, "cat_player" )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	pl:SetCanZoom( false )
	pl:Extinguish( )
	pl:SetupHands( )
	pl:CrosshairDisable( )
	pl:SetMaterial( "" )
	pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	pl:SetHealth( pl:GetMaxHealth( ) )
	
	for k, v in pairs( player.GetAll( ) ) do
		v:ConCommand( "r_cleardecals" )
	end
	
	if ( pl:FlashlightIsOn( ) ) then
		pl:Flashlight( false )
	end
	
	catherine.limb.HealBody( pl, 100 )
	
	catherine.util.ProgressBar( pl, false )
	catherine.util.TopNotify( pl, false )
	
	pl:Give( "cat_fist" )
	pl:Give( "cat_key" )
	
	if ( pl:IsCharacterLoaded( ) and !pl.CAT_loadingChar ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:PlayerLimbTakeDamage( pl, hitGroup, amount )
	if ( hitGroup == HITGROUP_HEAD ) then
		pl.CAT_isLimbForceMotionBlur = true
		
		local visibility = 1 - ( ( amount / 100 ) / 1 )
		
		catherine.util.StartMotionBlur( pl, math.max( visibility, 0.13 ), 1, 0.02 )
	end
end

function GM:PlayerLimbDamageHealed( pl, hitGroup, amount )
	if ( hitGroup == HITGROUP_HEAD ) then
		local visibility = 1 - ( amount / 100 )
		
		catherine.util.StartMotionBlur( pl, visibility, 1, 0.02 )
		
		if ( visibility == 1 ) then
			pl.CAT_isLimbForceMotionBlur = nil
			catherine.util.StopMotionBlur( pl )
		end
	end
end

function GM:GetLockTime( pl )
	return math.max( 5 * ( math.max( catherine.limb.GetDamage( pl, HITGROUP_LEFTARM ),
	catherine.limb.GetDamage( pl, HITGROUP_RIGHTARM ) ) / 100 ), 1.8 )
end

function GM:GetUnlockTime( pl )
	return math.max( 5 * ( math.max( catherine.limb.GetDamage( pl, HITGROUP_LEFTARM ),
	catherine.limb.GetDamage( pl, HITGROUP_RIGHTARM ) ) / 100 ), 1.8 )
end

function GM:PlayerJump( pl )

end

function GM:PlayerInfoTable( pl, infoTable )
	local jumpPower = infoTable.jumpPower
	local runSpeed = infoTable.runSpeed
	local walkSpeed = infoTable.walkSpeed
	local leftLegLimbDmg = catherine.limb.GetDamage( pl, HITGROUP_LEFTLEG )
	local rightLegLimbDmg = catherine.limb.GetDamage( pl, HITGROUP_RIGHTLEG )
	
	if ( pl.CAT_bulletHurtSpeedDown ) then
		return {
			runSpeed = walkSpeed
		}
	else
		local defJumpPower = catherine.player.GetPlayerDefaultJumpPower( pl )
		local defRunSpeed = catherine.player.GetPlayerDefaultRunSpeed( pl )
		
		if ( ( leftLegLimbDmg and leftLegLimbDmg != 0 ) or ( rightLegLimbDmg and rightLegLimbDmg != 0 ) ) then
			return {
				jumpPower = defJumpPower * ( 1 - math.max( leftLegLimbDmg, rightLegLimbDmg ) / 100 ),
				runSpeed = math.max( defRunSpeed * ( 1 - math.max( leftLegLimbDmg, rightLegLimbDmg ) / 100 ), walkSpeed )
			}
		else
			return {
				jumpPower = defJumpPower,
				runSpeed = defRunSpeed
			}
		end
	end
end

function GM:ScalePlayerDamage( pl, hitGroup, dmgInfo )
	if ( !pl:IsPlayer( ) ) then return end
	if ( hook.Run( "PlayerShouldDamage", pl, dmgInfo ) == false ) then return end
	
	if ( !catherine.player.IsIgnoreScreenColor( pl ) and ( pl.CAT_nextDamageScreenColorEffect or 0 ) <= CurTime( ) ) then
		catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.1, 0.05 )
		
		if ( hitGroup == CAT_BODY_ID_HEAD ) then
			catherine.util.ScreenColorEffect( pl, nil, 0.2, 0.05 )
		end
		
		pl.CAT_nextDamageScreenColorEffect = CurTime( ) + 1
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	catherine.util.StopMotionBlur( pl )
	catherine.util.ScreenColorEffect( pl, nil, 0.5, 0.1 )
	
	hook.Run( "OnSpawnedInCharacter", pl )
	
	pl:SetupHands( )
end

function GM:PlayerSetHandsModel( pl, ent )
	local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
	
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:PlayerAuthed( pl )
	timer.Simple( 2, function( )
		catherine.chat.Send( pl, "connect", nil, nil, pl:Name( ) )
		catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has connected a server." )
	end )
end

function GM:PlayerLoadFinished( pl )
	if ( catherine.chat.GetPlayerChatHistory( pl ) ) then
		catherine.chat.StartChatHistoryRestore( pl )
	end
	
	catherine.plugin.SendDeactivePlugins( pl )
end

function GM:PlayerDisconnected( pl )
	if ( catherine.patchx.initializing ) then return end
	
	if ( IsValid( pl.CAT_deathBody ) ) then
		pl.CAT_deathBody:Remove( )
	end
	
	if ( IsValid( pl.CAT_ragdoll ) ) then
		pl.CAT_ragdoll:Remove( )
	end
	
	timer.Remove( "Catherine.timer.AutoSalary." .. pl:SteamID( ) )
	
	catherine.chat.Send( pl, "disconnect", nil, nil, pl:SteamName( ) )
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has disconnected a server." )
	
	if ( pl:IsCharacterLoaded( ) ) then
		hook.Run( "PlayerDisconnectedInCharacter", pl )
	end
end

function GM:PlayerCanPickupWeapon( pl, wep )
	return pl.CAT_isForceGiveWeapon or ( pl:GetEyeTraceNoCursor( ).Entity == wep and pl:KeyDown( IN_USE ) )
end

function GM:PlayerCanHearPlayersVoice( pl, target )
	if ( catherine.configs.voice3D ) then
		local distance = math.Round( pl:GetPos( ):Distance( target:GetPos( ) ) )
		
		if ( distance == 0 ) then
			return true, false
		end
		
		return distance <= catherine.configs.voiceRange, false
	end
	
	return catherine.configs.voiceAllow, catherine.configs.voice3D
end

function GM:PostCharacterSave( pl )
	if ( pl:Alive( ) ) then
		catherine.character.SetCharVar( pl, "char_health", pl:Health( ) )
		catherine.character.SetCharVar( pl, "char_armor", pl:Armor( ) )
	end
end

function GM:PlayerShouldRagdollDamage( pl, ent, dmgInfo )
	if ( pl:IsNoclipping( ) ) then
		return false
	end
end

function GM:PlayerGodMode( pl, status )
	if ( !status and pl.CAT_godmodeAlready ) then
		pl.CAT_godmodeAlready = nil
	end
end

function GM:PlayerShouldDamage( pl, dmgInfo )
	if ( pl:HasGodMode( ) ) then
		return false
	end
	
	if ( pl:IsNoclipping( ) ) then
		return false
	end
end

local allowDoorBreach = catherine.configs.doorBreach

function GM:EntityTakeDamage( ent, dmgInfo )
	if ( ent:GetClass( ) == "prop_ragdoll" ) then
		local pl = catherine.entity.GetPlayer( ent )
		
		if ( IsValid( pl ) and pl:IsPlayer( ) ) then
			if ( hook.Run( "PlayerShouldRagdollDamage", pl, ent, dmgInfo ) == false ) then return end
			local inflictor = dmgInfo:GetInflictor( )
			local attacker = dmgInfo:GetAttacker( )
			local amount = dmgInfo:GetDamage( )
			
			if ( !attacker:IsPlayer( ) or attacker:GetClass( ) == "prop_ragdoll" or attacker:IsDoor( ) or amount < 5 ) then // NEED FIX;
				return
			end
			
			if ( amount >= 20 or dmgInfo:IsBulletDamage( ) ) then
				catherine.player.SetIgnoreHurtSound( pl, true )
				
				pl:TakeDamage( amount, attacker, inflictor )
				
				catherine.log.Add( CAT_LOG_FLAG_BASIC, pl:Name( ) .. ", " .. pl:SteamName( ) .. " has taked a damage < ATTACKER : " .. attacker:Name( ) .. ">< AMOUNT : " .. amount .. " >", true )
				
				catherine.effect.Create( "BLOOD", {
					ent = ent,
					pos = dmgInfo:GetDamagePosition( ),
					scale = 1,
					decalCount = 1
				} )
				
				catherine.player.SetIgnoreHurtSound( pl, nil )
				
				if ( pl:Health( ) <= 0 and !pl.CAT_deathSoundPlayed ) then
					hook.Run( "PlayerDeathSound", pl, ent )
				else
					hook.Run( "PlayerTakeDamage", pl, attacker, dmgInfo, ent )
				end
			end
		end
	elseif ( ent:IsPlayer( ) ) then
		if ( hook.Run( "PlayerShouldDamage", ent, dmgInfo ) == false ) then return end
		
		hook.Run( "PlayerTakeDamage", ent, dmgInfo:GetAttacker( ), dmgInfo )
	end
	
	if ( allowDoorBreach ) then
		if ( ent:GetClass( ) == "prop_door_rotating" and dmgInfo:IsBulletDamage( ) ) then
			local pl = dmgInfo:GetAttacker( )
			
			if ( IsValid( pl ) and pl:IsPlayer( ) and !pl:IsNoclipping( ) and ( ent.CAT_nextDoorBreach or 0 ) <= CurTime( ) ) then
				local partner = catherine.util.GetDoorPartner( ent )
				
				if ( IsValid( ent.lock ) or ( IsValid( partner ) and IsValid( partner.lock ) ) ) then return end
				
				local index = ent:LookupBone( "handle" )
				
				if ( index ) then
					local pos = dmgInfo:GetDamagePosition( )
					
					if ( pl:GetEyeTrace( ).Entity != ent or pl:GetPos( ):Distance( pos ) < 130 and pos:Distance( ent:GetBonePosition( index ) ) <= 5 ) then
						ent:EmitSound( "physics/wood/wood_crate_break" .. math.random( 1, 5 ) .. ".wav", 150 )
						
						local effect = EffectData( )
						effect:SetStart( pos )
						effect:SetOrigin( pos )
						effect:SetScale( 10 )
						util.Effect( "GlassImpact", effect, true, true )
						
						local dummyName = pl:SteamID( ) .. CurTime( )
						pl:SetName( dummyName )
						
						ent:Fire( "SetSpeed", 100 )
						ent:Fire( "UnLock" )
						ent:Fire( "OpenAwayFrom", dummyName )
						
						if ( IsValid( partner ) ) then
							partner:Fire( "SetSpeed", 100 )
							partner:Fire( "UnLock" )
							partner:Fire( "OpenAwayFrom", dummyName )
						end
						
						ent:EmitSound( "physics/wood/wood_plank_break" .. math.random( 1, 4 ) .. ".wav", 100, 120 )
						
						ent.CAT_nextDoorBreach = CurTime( ) + 3
					end
				end
			end
		end
	end
	
	if ( ent:IsPlayer( ) and dmgInfo:IsBulletDamage( ) ) then
		local timerID = "Catherine.timer.RunSpamProtection." .. ent:SteamID( )
		
		ent.CAT_bulletHurtSpeedDown = true
		
		timer.Remove( timerID )
		timer.Create( timerID, math.random( 2, 4 ), 1, function( )
			if ( IsValid( ent ) ) then
				ent.CAT_bulletHurtSpeedDown = nil
			end
		end )
	end
end

function GM:PlayerShouldAutoHealLimbDamage( pl )

end

function GM:PlayerSwitchFlashlight( pl, bool )
	return true
end

function GM:AttributeChanged( pl, uniqueID, attributeData, action )

end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create( "Catherine.timer.WeaponToggle." .. pl:SteamID( ), 1, 1, function( )
			if ( IsValid( pl ) ) then
				pl:ToggleWeaponRaised( )
			end
		end )
	elseif ( key == IN_USE ) then
		local data = { }
		data.start = pl:GetShootPos( )
		data.endpos = data.start + pl:GetAimVector( ) * 100
		data.filter = pl
		local ent = util.TraceLine( data ).Entity
		
		if ( !IsValid( ent ) or ent.CAT_ignoreUse ) then return end
		
		if ( ent:GetClass( ) == "prop_ragdoll" ) then
			ent = catherine.entity.GetPlayer( ent )
		end
		
		if ( !IsValid( ent ) ) then return end
		
		if ( ent:IsDoor( ) ) then
			if ( GAMEMODE:PlayerUse( pl, ent ) ) then
				catherine.door.DoorSpamProtection( pl, ent )
			end
		elseif ( ent:IsPlayer( ) ) then
			return hook.Run( "PlayerInteract", pl, ent )
		elseif ( ent.isCustomUse ) then
			netstream.Start( pl, "catherine.entity.CustomUseMenu", ent:EntIndex( ) )
		end
	end
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Remove( "Catherine.timer.WeaponToggle." .. pl:SteamID( ) )
	end
end

function GM:PlayerCanUseDoor( pl, ent )
	return !pl.CAT_cantUseDoor
end

function GM:PlayerUse( pl, ent )
	if ( pl:IsTied( ) ) then
		if ( ( pl.CAT_tiedMSG or 0 ) <= CurTime( ) ) then
			catherine.util.NotifyLang( pl, "Item_Notify03_ZT" )
			pl.CAT_tiedMSG = CurTime( ) + 3
		end
		
		return false
	end
	
	local isDoor = ent:IsDoor( )
	
	if ( isDoor ) then
		local result = hook.Run( "PlayerCanUseDoor", pl, ent )
		
		if ( result == false or catherine.entity.GetIgnoreUse( ent ) ) then
			return false
		else
			hook.Run( "PlayerUseDoor", pl, ent )
		end
	end
	
	return true
end

function GM:PlayerSay( pl, text )
	catherine.chat.AddPlayerChatHistory( pl, text )
	catherine.chat.Run( pl, text )
	catherine.log.Add( CAT_LOG_FLAG_BASIC, pl:Name( ) .. ", " .. pl:SteamName( ) .. " typed chat " .. text )
end

function GM:PlayerInitialSpawn( pl )
	pl:SetNoDraw( true )
	pl:SetNotSolid( true )
	pl:SetPos( Vector( 0, 0, 10000 ) )
	pl:Freeze( true )
	pl:Lock( )
	pl:GodEnable( )
	
	timer.Simple( 2, function( )
		if ( !IsValid( pl ) ) then return end
		
		pl:SetNoDraw( true )
		pl:SetNotSolid( true )
		pl:SetPos( Vector( 0, 0, 10000 ) )
		pl:Freeze( true )
		pl:Lock( )
		pl:GodEnable( )
		
		catherine.player.Initialize( pl )
	end )
	
	timer.Create( "Catherine.timer.player.Initialize.Reload", 6, 0, function( )
		if ( !IsValid( pl ) ) then
			timer.Remove( "Catherine.timer.player.Initialize.Reload" )
			return
		end
		
		pl:SetNoDraw( true )
		pl:SetNotSolid( true )
		pl:SetPos( Vector( 0, 0, 10000 ) )
		pl:Freeze( true )
		pl:Lock( )
		pl:GodEnable( )
		
		catherine.player.Initialize( pl )
	end )
end

function GM:PlayerGiveSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnEffect( pl )
	return pl:HasFlag( "s" )
end

function GM:PlayerSpawnRagdoll( pl )
	return pl:HasFlag( "R" )
end

function GM:PlayerSpawnNPC( pl )
	return pl:HasFlag( "n" )
end

function GM:PlayerSpawnVehicle( pl )
	return pl:HasFlag( "V" )
end

function GM:PlayerSpawnSENT( pl )
	return pl:HasFlag( "x" )
end

function GM:PlayerSpawnObject( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "e" )
end

function GM:GetPlayerPainSound( pl )
	if ( pl:WaterLevel( ) >= 3 ) then
		return "player/pl_drown" .. math.random( 1, 3 ) .. ".wav"
	end
end

function GM:PlayerTakeDamage( pl, attacker, dmgInfo, ragdollEntity )
	if ( pl:HasGodMode( ) ) then
		return true
	end
	
	if ( pl:Health( ) <= 0 ) then
		return true
	end
	
	catherine.character.SetCharVar( pl, "isHealthRecover", true )
	
	if ( !catherine.player.IsIgnoreScreenColor( pl ) and ( pl.CAT_nextDamageScreenColorEffect or 0 ) <= CurTime( ) ) then
		catherine.util.ScreenColorEffect( pl, Color( 255, 150, 150 ), 0.2, 0.05 )
		
		pl.CAT_nextDamageScreenColorEffect = CurTime( ) + 1
	end
	
	local hitGroup = catherine.player.GetHitGroup( pl, dmgInfo:GetDamagePosition( ) )
	pl.CAT_lastHitGroup = hitGroup
	local dataTable = hook.Run( "PlayerScaleDamage", pl, attacker, dmgInfo, hitGroup ) or { false, false }
	
	if ( dmgInfo:IsDamageType( DMG_FALL ) ) then
		catherine.limb.TakeDamage( pl, HITGROUP_LEFTLEG, dmgInfo:GetDamage( ) )
		catherine.limb.TakeDamage( pl, HITGROUP_RIGHTLEG, dmgInfo:GetDamage( ) )
	else
		if ( !dataTable[ 1 ] ) then
			catherine.limb.TakeDamage( pl, hitGroup, dmgInfo:GetDamage( ) )
		end
	end
	
	catherine.log.Add( CAT_LOG_FLAG_BASIC, pl:Name( ) .. ", " .. pl:SteamName( ) .. " has taked a damage < ATTACKER : " .. ( attacker:IsPlayer( ) and ( attacker:Name( ) .. ", " .. attacker:SteamName( ) .. ", " .. attacker:SteamID( ) ) or attacker:GetClass( ) ) .. ">< AMOUNT : " .. dmgInfo:GetDamage( ) .. " >", true )
	
	if ( !catherine.player.IsIgnoreHurtSound( pl ) and !dataTable[ 2 ] and ( pl.CAT_nextHurtDelay or 0 ) <= CurTime( ) ) then
		pl.CAT_nextHurtDelay = CurTime( ) + 2
		
		local sound = hook.Run( "GetPlayerPainSound", pl )
		local gender = pl:GetGender( )
		
		if ( sound == nil ) then
			if ( hitGroup == HITGROUP_HEAD ) then
				sound = "vo/npc/" .. gender .. "01/ow0" .. math.random( 1, 2 ) .. ".wav"
			elseif ( hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC ) then
				sound = "vo/npc/" .. gender .. "01/hitingut0" .. math.random( 1, 2 ) .. ".wav"
			elseif ( hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG ) then
				sound = "vo/npc/" .. gender .. "01/myleg0" .. math.random( 1, 2 ) .. ".wav"
			elseif ( hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM ) then
				sound = "vo/npc/" .. gender .. "01/myarm0" .. math.random( 1, 2 ) .. ".wav"
			elseif ( hitGroup == HITGROUP_GEAR ) then
				sound = "vo/npc/" .. gender .. "01/startle0" .. math.random( 1, 2 ) .. ".wav"
			end
		end
		
		if ( sound != false ) then
			if ( IsValid( ragdollEntity ) ) then
				ragdollEntity:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
				
				return true
			end
			
			pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 1, 6 ) .. ".wav" )
		end
	end
	
	return true
end

function GM:PlayerHurt( pl, attacker )
	return true
end

function GM:PlayerDeathSound( pl, ragdollEntity )
	local sound = hook.Run( "GetPlayerDeathSound", pl )
	local gender = pl:GetGender( )
	
	if ( sound != false ) then
		if ( IsValid( ragdollEntity ) ) then
			ragdollEntity:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
			pl.CAT_deathSoundPlayed = true
			
			return true
		end
		
		pl:EmitSound( sound or "vo/npc/" .. gender .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
		pl.CAT_deathSoundPlayed = true
	end
	
	return true
end

function GM:PlayerDeathThink( pl )

end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )
	pl:SetNotSolid( true )
	pl:Freeze( true )
	
	if ( !IsValid( pl.CAT_ragdoll ) ) then
		local ent = ents.Create( "prop_ragdoll" )
		ent:SetAngles( pl:GetAngles( ) )
		ent:SetModel( pl:GetModel( ) )
		ent:SetPos( pl:GetPos( ) )
		ent:SetSkin( pl:GetSkin( ) )
		ent:SetMaterial( pl:GetMaterial( ) )
		ent:SetColor( pl:GetColor( ) )
		ent:Spawn( )
		ent:Activate( )
		ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		ent.player = self
		ent:SetNetVar( "player", pl )
		
		for k, v in pairs( pl:GetBodyGroups( ) ) do
			ent:SetBodygroup( v.id, pl:GetBodygroup( v.id ) )
		end
		
		pl:SetNetVar( "ragdollIndex", ent:EntIndex( ) )
		pl.CAT_deathBody = ent
	end
	
	pl:SetNetVar( "noDrawOriginal", true )
	pl:SetNetVar( "isRagdolled", nil )
end

function GM:PlayerDeathThink( pl )
	-- 가끔 플레이어가 자동으로 스폰되지 않는 경우를 방지.
	if ( pl:IsCharacterLoaded( ) and !pl.CAT_isSilentDeath ) then
		self:DoPlayerDeath( pl )
		self:PlayerDeath( pl )
		
		pl.CAT_isSilentDeath = true
		
		return false
	end
end

function GM:PlayerDeath( pl )
	catherine.character.SetCharVar( pl, "isHealthRecover", nil )
	
	local respawnTime = hook.Run( "GetRespawnTime", pl ) or catherine.configs.spawnTime
	
	pl:SetViewEntity( NULL )
	pl:UnSpectate( )
	pl:SetNetVar( "isTied", nil )
	pl:SetNetVar( "isRagdolled", nil )
	
	pl.CAT_isDeadFunc = true
	
	catherine.util.ProgressBar( pl, false )
	catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_Dead_01" ), respawnTime, function( )
		if ( IsValid( pl.CAT_ragdoll ) ) then
			pl.CAT_ragdoll:Remove( )
			pl.CAT_ragdoll = nil
		end
		
		pl.CAT_isDeadFunc = nil
		pl.CAT_isSilentDeath = nil
		
		pl:Spawn( )
	end )
	
	catherine.util.TopNotify( pl, false )
	
	catherine.attribute.ClearTemporaryProgress( pl )
	catherine.recognize.Initialize( pl )
	
	pl:SetNetVar( "nextSpawnTime", CurTime( ) + respawnTime )
	pl:SetNetVar( "deathTime", CurTime( ) )
	
	catherine.log.Add( nil, pl:SteamName( ) .. ", " .. pl:SteamID( ) .. " has a died [Character Name : " .. pl:Name( ) .. "]", true )
	
	pl:SendLua( "catherine.bar.InitializeWide( )" )
end

function GM:PlayerThink( pl )
	if ( ( pl.CAT_playerInfoTableTick or 0 ) <= CurTime( ) ) then
		local infoOverride = hook.Run( "PlayerInfoTable", pl, {
			jumpPower = pl:GetJumpPower( ),
			runSpeed = pl:GetRunSpeed( ),
			walkSpeed = pl:GetWalkSpeed( )
		} ) or { }
		local jumpPower, runSpeed, walkSpeed = infoOverride.jumpPower, infoOverride.runSpeed, infoOverride.walkSpeed
		
		if ( jumpPower and jumpPower != pl:GetJumpPower( ) ) then
			pl:SetJumpPower( jumpPower )
		end
		
		if ( runSpeed and runSpeed != pl:GetRunSpeed( ) ) then
			pl:SetRunSpeed( runSpeed )
		end
		
		if ( walkSpeed and walkSpeed != pl:GetWalkSpeed( ) ) then
			pl:SetWalkSpeed( walkSpeed )
		end
		
		pl.CAT_playerInfoTableTick = CurTime( ) + 0.1
	end
	
	if ( hook.Run( "PlayerShouldDrown", pl ) == false ) then return end
	
	if ( pl:Alive( ) ) then
		if ( pl:WaterLevel( ) >= 3 ) then
			if ( !pl.CAT_drowningTick or !pl.CAT_drownDamage ) then
				pl.CAT_drowningTick = CurTime( ) + 30
				pl.CAT_drownDamage = pl.CAT_drownDamage or 0
			end
			
			if ( pl.CAT_drowningTick <= CurTime( ) ) then
				if ( ( pl.CAT_nextDrowning or 0 ) <= CurTime( ) ) then
					catherine.player.SetIgnoreScreenColor( pl, true )
					catherine.util.ScreenColorEffect( pl, Color( 50, 50, 255 ), 0.2, 0.05 )
					
					pl:TakeDamage( 10 )
					
					catherine.player.SetIgnoreScreenColor( pl, nil )
					
					pl.CAT_drownDamage = pl.CAT_drownDamage + 10
					pl.CAT_nextDrowning = CurTime( ) + 2
				end
			end
		else
			if ( pl.CAT_drowningTick ) then
				pl.CAT_drowningTick = nil
				pl.CAT_nextDrowning = nil
				pl.CAT_nextDrownDamageRecoverTick = CurTime( ) + 3
			end
			
			if ( pl.CAT_nextDrownDamageRecoverTick and pl.CAT_nextDrownDamageRecoverTick <= CurTime( ) ) then
				if ( pl.CAT_drownDamage and pl.CAT_drownDamage > 0 ) then
					pl.CAT_drownDamage = pl.CAT_drownDamage - 1
					pl:SetHealth( math.Clamp( pl:Health( ) + 1, 0, pl:GetMaxHealth( ) ) )
					pl.CAT_nextDrownDamageRecoverTick = CurTime( ) + 0.2
				else
					pl.CAT_nextDrownDamageRecoverTick = nil
					pl.CAT_drownDamage = nil
				end
			end
		end
	else
		if ( pl.CAT_nextDrownDamageRecoverTick and pl.CAT_drownDamage ) then
			pl.CAT_nextDrownDamageRecoverTick = nil
			pl.CAT_drownDamage = nil
		end
	end
end

function GM:Tick( )
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		catherine.player.BunnyHopProtection( v )
		catherine.player.HealthRecoverTick( v )
		
		if ( ( v.CAT_nextJumpUpdate or 0 ) <= CurTime( ) and v:Alive( ) and !v:IsRagdolled( ) and !v:InVehicle( ) and v:GetMoveType( ) == MOVETYPE_WALK and v:IsInWorld( ) and !v:IsOnGround( ) ) then
			hook.Run( "PlayerJump", v )
			v.CAT_nextJumpUpdate = CurTime( ) + 1
		end
		
		hook.Run( "PlayerThink", v )
	end
end

function GM:PlayerGiveWeapon( pl, uniqueID )

end

function GM:PlayerStripWeapon( pl, uniqueID )

end

function GM:GetUnknownTargetName( pl, target )
	return LANG( pl, "Recognize_UI_Unknown" )
end

function GM:PlayerShouldTakeDamage( pl, attacker )
	return pl:IsCharacterLoaded( ) != false
end

function GM:GetFallDamage( pl, speed )
	return hook.Run( "GetOverrideFallDamage", pl, speed ) or ( speed - 580 ) * 0.8
end

function GM:InitPostEntity( )
	if ( catherine.configs.clearMap ) then
		catherine.util.RemoveEntityByClass( "item_healthcharger" )
		catherine.util.RemoveEntityByClass( "item_suitcharger" )
		catherine.util.RemoveEntityByClass( "prop_vehicle*" )
		catherine.util.RemoveEntityByClass( "weapon_*" )
	end
	
	for k, v in pairs( ents.GetAll( ) ) do
		if ( IsValid( v ) and v:GetModel( ) ) then
			catherine.entity.SetMapEntity( v, true )
		end
	end
	
	hook.Run( "DataLoad" )
	
	catherine.door.DataLoad( )
	catherine.storage.DataLoad( )
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Catherine (Framework, Schema, Plugin) data has been loaded." )
end

function GM:PostCleanupMap( )
	for k, v in pairs( ents.GetAll( ) ) do
		if ( IsValid( v ) and v:GetModel( ) ) then
			catherine.entity.SetMapEntity( v, true )
		end
	end
	
	hook.Run( "PostCleanupMapDelayed" )
end

function GM:ShutDown( )
	catherine.shuttingDown = true
	
	catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, "Shutting down ... :)" )
	
	hook.Run( "ServerShutDown" )
	hook.Run( "DataSave" )
	
	if ( Schema and Schema.DataSave ) then
		Schema:DataSave( )
	end
end

function GM:Initialize( )
	MsgC( Color( 0, 255, 0 ), "[CAT] You have been using Catherine '" .. catherine.GetVersion( ) .. "' Version.\n" )
	
	hook.Run( "FrameworkInitialized" )
	
	if ( catherine.configs.enable_customVoiceHeadNotify ) then
		RunConsoleCommand( "mp_show_voice_icons", "0" )
	else
		RunConsoleCommand( "mp_show_voice_icons", "1" )
	end
end

netstream.Hook( "catherine.IsTyping", function( pl, data )
	pl:SetNetVar( "isTyping", data )
	
	hook.Run( "ChatTypingChanged", pl, data )
end )

netstream.Hook( "catherine.requestConfigTable", function( pl, data )
	if ( IsValid( pl ) and pl:IsSuperAdmin( ) ) then
		local sendOnly = { }
		
		for k, v in pairs( table.Copy( catherine.configs ) ) do
			if ( type( v ) == "function" ) then continue end
			
			sendOnly[ k ] = v
		end
		
		netstream.Start( pl, "catherine.sendConfigTable", sendOnly )
	end
end )

netstream.Hook( "catherine.BAN", function( pl, data )
	if ( !pl:IsAdmin( ) ) then return end
	
	if ( IsValid( data[ 1 ] ) and data[ 1 ]:IsPlayer( ) ) then
		data[ 1 ]:Ban( tonumber( data[ 2 ] ) or 0, data[ 3 ] or "No reason." ) // Bug;
	end
end )