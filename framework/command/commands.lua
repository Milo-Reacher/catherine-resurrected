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

catherine.command.Register( {
	uniqueID = "&uniqueID_charFallOver",
	command = "charfallover",
	desc = "Going to stunned state.",
	syntax = "[Getting up time]",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( pl.CAT_falloverNextCan and pl.CAT_falloverNextCan >= CurTime( ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_BlockFallover", math.ceil( pl.CAT_falloverNextCan - CurTime( ) ) )
			return
		end
		
		if ( pl:IsRagdolled( ) ) then
			catherine.util.NotifyLang( pl, "Player_Message_AlreadyFallovered" )
			return
		end

		if ( args[ 1 ] ) then
			args[ 1 ] = tonumber( args[ 1 ] )
		end
		
		catherine.player.RagdollWork( pl, !pl:IsRagdolled( ), args[ 1 ], true )
		pl.CAT_falloverNextCan = CurTime( ) + catherine.configs.nextFalloverTime
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charGetUp",
	command = "chargetup",
	desc = "Takes place in a stunned state.",
	canRun = function( pl ) return pl:Alive( ) end,
	runFunc = function( pl, args )
		if ( pl:GetNetVar( "isForceRagdolled" ) ) then
			return
		end
		
		if ( !pl:GetNetVar( "gettingup" ) ) then
			if ( pl:IsRagdolled( ) ) then
				pl:SetNetVar( "gettingup", true )
				
				catherine.util.TopNotify( pl, false )
				catherine.util.ProgressBar( pl, LANG( pl, "Player_Message_GettingUp" ), 3, function( )
					catherine.player.RagdollWork( pl, false )
					pl:SetNetVar( "gettingup", nil )
				end )
			else
				catherine.util.NotifyLang( pl, "Player_Message_NotFallovered" )
			end
		else
			catherine.util.NotifyLang( pl, "Player_Message_AlreayGettingUp" )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charSetName",
	command = "charsetname",
	syntax = "[Name] [Name]",
	desc = "Setting a character name as target player.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )

				if ( IsValid( target ) and target:IsPlayer( ) ) then
					if ( !args[ 2 ]:find( "#" ) ) then
						local localBuffer = pl:Name( )
						local targetBuffer = target:Name( )
						
						catherine.character.SetVar( target, "_name", args[ 2 ], nil, true )
						catherine.character.SendPlayerCharacterList( target )
						catherine.util.NotifyAllLang( "Character_Notify_SetName", localBuffer, args[ 2 ], targetBuffer )
					else
						catherine.util.NotifyLang( pl, "Character_Notify_SetNameError" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charBan",
	command = "charban",
	syntax = "[Name]",
	desc = "Toggle a banned state. (Ban, Unban)",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local target = catherine.util.FindPlayerByName( args[ 1 ] )
			
			if ( IsValid( target ) and target:IsPlayer( ) ) then
				if ( catherine.player.IsCharacterBanned( target ) ) then
					local success, langKey, par = catherine.player.SetCharacterBan( target, false, function( )
						target:Freeze( false )
						
						if ( target.CAT_charBanLatestPos ) then
							target:SetPos( target.CAT_charBanLatestPos )
						else
							target:KillSilent( )
						end
					end )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Character_Notify_CharUnBan", pl:Name( ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					local success, langKey, par = catherine.player.SetCharacterBan( target, true, function( )
						target.CAT_charBanLatestPos = target:GetPos( )
						
						target:SetPos( Vector( 0, 0, 10000 ) )
						target:Freeze( true )
					end )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Character_Notify_CharBan", pl:Name( ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charUnBan",
	command = "charsetbanquery",
	syntax = "[Target Player SteamID] [Target Player Character ID / Name] [Ban Status (true / false)]",
	desc = "Set a banned state for target player character.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByStuff( "SteamID", args[ 1 ] )
				
				catherine.character.GetTargetCharacterFromQuery( args[ 1 ], function( status, data )
					if ( status ) then
						local toNumber = tonumber( args[ 2 ] )
						
						if ( toNumber ) then
							for k, v in pairs( data ) do
								if ( tonumber( v._id ) == toNumber ) then
									local currentBanStatus = v._charVar[ "charBanned" ]
									
									if ( args[ 3 ] ) then
										v._charVar[ "charBanned" ] = tobool( args[ 3 ] ) or false
										catherine.util.NotifyAllLang( "Character_Notify_CharSetBan", pl:Name( ), v._name, tostring( args[ 3 ] or false ) )
									else
										if ( currentBanStatus ) then
											v._charVar[ "charBanned" ] = !currentBanStatus
											catherine.util.NotifyAllLang( "Character_Notify_CharSetBan", pl:Name( ), v._name, tostring( !currentBanStatus ) )
										else
											catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 3 )
											return
										end
									end
									
									catherine.database.UpdateDatas( "catherine_characters", "_steamID = '" .. v._steamID .. "' AND _schema = '" .. catherine.schema.GetUniqueID( ) .. "' AND _id = '" .. v._id .. "'", v )
									return
								end
							end
							
							catherine.util.NotifyLang( pl, "Basic_Notify_CantFindCharacter" )
						else
							for k, v in pairs( data ) do
								if ( tostring( v._name ):find( args[ 2 ] ) ) then
									local currentBanStatus = data[ k ]._charVar[ "charBanned" ]
									
									if ( args[ 3 ] ) then
										data[ k ]._charVar[ "charBanned" ] = tobool( args[ 3 ] ) or false
										catherine.util.NotifyAllLang( "Character_Notify_CharSetBan", pl:Name( ), v._name, tostring( args[ 3 ] or false ) )
									else
										if ( currentBanStatus ) then
											data[ k ]._charVar[ "charBanned" ] = !currentBanStatus
											catherine.util.NotifyAllLang( "Character_Notify_CharSetBan", pl:Name( ), v._name, tostring( !currentBanStatus ) )
										else
											catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 3 )
											return
										end
									end
									
									catherine.database.UpdateDatas( "catherine_characters", "_steamID = '" .. v._steamID .. "' AND _schema = '" .. catherine.schema.GetUniqueID( ) .. "' AND _id = '" .. v._id .. "'", data[ k ], function( )
										if ( IsValid( target ) and target:IsPlayer( ) ) then
											catherine.character.SendPlayerCharacterList( target )
										end
									end )
									
									return
								end
							end
							
							catherine.util.NotifyLang( pl, "Basic_Notify_CantFindCharacter" )
						end
					else
						catherine.util.NotifyLang( pl, "Basic_Notify_CantFindCharacter" )
					end
				end )
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charSetDesc",
	command = "charsetdesc",
	desc = "Setting a character description as target player.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				if ( !args[ 2 ]:find( "#" ) ) then
					local target = catherine.util.FindPlayerByName( args[ 1 ] )
					
					if ( IsValid( target ) and target:IsPlayer( ) ) then
						catherine.character.SetVar( target, "_desc", args[ 2 ], nil, true )
						catherine.character.SendPlayerCharacterList( target )
						catherine.util.NotifyAllLang( "Character_Notify_SetDesc", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
					end
				else
					catherine.util.NotifyLang( pl, "Character_Notify_SetDescError" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charSetSkin",
	command = "charsetskin",
	desc = "Setting a character skin as target player.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local skin = tonumber( args[ 2 ] )
				
				if ( skin ) then
					skin = math.max( skin, 0 )
					
					local target = catherine.util.FindPlayerByName( args[ 1 ] )
					
					if ( IsValid( target ) and target:IsPlayer( ) ) then
						catherine.character.SetCharVar( target, "skin", skin )
						catherine.util.NotifyAllLang( "Character_Notify_SetSkin", pl:Name( ), skin, target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
					end
				else
					catherine.util.NotifyLang( pl, "Character_Notify_SetSkinError" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charSetModel",
	command = "charsetmodel",
	desc = "Setting a character model as target player.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					catherine.character.SetVar( target, "_model", args[ 2 ], nil, true )
					catherine.character.SendPlayerCharacterList( target )
					catherine.util.NotifyAllLang( "Character_Notify_SetModel", pl:Name( ), args[ 2 ], target:Name( ) )
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charPhysDesc",
	command = "charphysdesc",
	desc = "Change a character description.",
	runFunc = function( pl, args )
		local newDesc = table.concat( args, " " )
		
		if ( args[ 1 ] ) then
			if ( !newDesc:find( "#" ) ) then
				if ( newDesc:utf8len( ) >= catherine.configs.characterDescMinLen and newDesc:utf8len( ) < catherine.configs.characterDescMaxLen ) then
					catherine.character.SetVar( pl, "_desc", newDesc, nil, true )
					catherine.character.SendPlayerCharacterList( pl )
					catherine.util.NotifyLang( pl, "Character_Notify_SetDescLC", newDesc )
				else
					catherine.util.NotifyLang( pl, "Character_Notify_DescLimitHit" )
				end
			else
				catherine.util.NotifyLang( pl, "Character_Notify_SetDescError" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorLock",
	command = "doorlock",
	desc = "Lock the looking door.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and ent:IsDoor( ) ) then
			ent:Fire( "Lock" )
			ent:EmitSound( "doors/door_latch3.wav" )
			catherine.util.NotifyLang( pl, "Door_Notify_CMD_Locked" )
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorUnlock",
	command = "doorunlock",
	desc = "Unlock the looking door.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and ent:IsDoor( ) ) then
			ent:Fire( "UnLock" )
			ent:EmitSound( "doors/door_latch3.wav" )
			catherine.util.NotifyLang( pl, "Door_Notify_CMD_UnLocked" )
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_flagGive",
	command = "flaggive",
	desc = "Gives the flag to the target player.",
	syntax = "[Name] [Flag ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Give( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Give", pl:Name( ), table.concat( par[ 1 ], ", " ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_flagTake",
	command = "flagtake",
	desc = "Takes the flag to the target player.",
	syntax = "[Name] [Flag ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.flag.Take( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Flag_Notify_Take", pl:Name( ), table.concat( par[ 1 ], ", " ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_itemSpawn",
	command = "itemspawn",
	desc = "Spawn item as the looking position.",
	syntax = "[Item ID]",
	canRun = function( pl ) return pl:HasFlag( "i" ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local success = catherine.item.Spawn( args[ 1 ], catherine.util.GetItemDropPos( pl ) )
			
			if ( !success ) then
				catherine.util.NotifyLang( pl, "Item_Notify_NoItemData" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_itemGive",
	command = "itemgive",
	desc = "Gives items to the target player.",
	syntax = "[Name] [Item ID] [Count]",
	canRun = function( pl ) return pl:HasFlag( "i" ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				if ( args[ 3 ] ) then
					args[ 3 ] = tonumber( args[ 3 ] )
				end
				
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, errorID = catherine.item.Give( target, args[ 2 ], args[ 3 ] or 1 )
					
					if ( success ) then
						catherine.util.NotifyLang( pl, "Item_GiveCommand_Fin", args[ 3 ] or 1, args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, ( errorID == 1 and "Inventory_Notify_HasNotSpaceTarget" or "Item_Notify_NoItemData" ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charSetCash",
	command = "charsetcash",
	desc = "Setting a cash to the target player.",
	syntax = "[Name] [Amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Set( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Set", pl:Name( ), catherine.cash.GetCompleteName( tonumber( args[ 2 ] ) ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charGiveCash",
	command = "chargivecash",
	desc = "Gives a cash to the target player.",
	syntax = "[Name] [Amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Give( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Give", pl:Name( ), catherine.cash.GetCompleteName( tonumber( args[ 2 ] ) ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_charTakeCash",
	command = "chartakecash",
	desc = "Takes a cash to the target player.",
	syntax = "[Name] [Amount]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success = catherine.cash.Take( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Cash_Notify_Take", pl:Name( ), catherine.cash.GetCompleteName( tonumber( args[ 2 ] ) ), target:Name( ) )
					else
						catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorBuy",
	command = "doorbuy",
	desc = "Buying a door.",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Buy( pl, pl:GetEyeTrace( 70 ).Entity )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Buy" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorSell",
	command = "doorsell",
	desc = "Selling a door.",
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.Sell( pl, pl:GetEyeTrace( 70 ).Entity )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_Sell" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorSetTitle",
	command = "doorsettitle",
	desc = "Setting a force door title. (Setting a 'Blank' text to reset door title.)",
	syntax = "[Text]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local text = nil
		
		if ( args[ 1 ] ) then
			text = table.concat( args, " " )
		else
			text = ""
		end
		
		local success, langKey, par = catherine.door.SetDoorTitle( pl, pl:GetEyeTrace( 70 ).Entity, text, true )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_SetTitle" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorSetDesc",
	command = "doorsetdesc",
	desc = "Setting a force door description. (Setting a 'Blank' text to reset door description.)",
	syntax = "[Text]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local text = nil
		
		if ( args[ 1 ] ) then
			text = table.concat( args, " " )
		else
			text = ""
		end
		
		local success, langKey, par = catherine.door.SetDoorDescription( pl, pl:GetEyeTrace( 70 ).Entity, text )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_SetDesc" )
		else
			catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorSetStatus",
	command = "doorsetstatus",
	desc = "Toggles a door status. (Ownable, Unownable)",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.SetDoorStatus( pl, pl:GetEyeTrace( 70 ).Entity )
		
		catherine.util.NotifyLang( pl, langKey )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_doorSetActive",
	command = "doorsetactive",
	desc = "Toggles a door active. (Show, Hide)",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local success, langKey, par = catherine.door.SetDoorActive( pl, pl:GetEyeTrace( 70 ).Entity )
		
		catherine.util.NotifyLang( pl, langKey )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_plyGiveWhitelist",
	command = "plygivewhitelist",
	desc = "Gives whitelist to the target player.",
	syntax = "[Name] [Faction ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.faction.AddWhiteList( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Faction_Notify_Give", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_plyTakeWhitelist",
	command = "plytakewhitelist",
	desc = "Takes a target player whitelist.",
	syntax = "[Name] [Faction ID]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					local success, langKey, par = catherine.faction.RemoveWhiteList( target, args[ 2 ] )
					
					if ( success ) then
						catherine.util.NotifyAllLang( "Faction_Notify_Take", pl:Name( ), args[ 2 ], target:Name( ) )
					else
						catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_pm",
	command = "pm",
	desc = "Send PM (Private Message) to target player.",
	syntax = "[Name] [Text]",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				local target = catherine.util.FindPlayerByName( args[ 1 ] )
				
				if ( IsValid( target ) and target:IsPlayer( ) ) then
					if ( pl != target ) then
						if ( !catherine.block.IsBlocked( pl, target, CAT_BLOCK_TYPE_PM_CHAT ) ) then
							target.CAT_lastSender = pl
							
							local text = table.concat( args, " ", 2, #args )
							
							catherine.chat.Send( pl, "pm", text, { pl, target }, target )
						else
							catherine.util.NotifyLang( pl, "Block_Notify_IsBlocked" )
						end
					else
						catherine.util.NotifyLang( pl, "Command_PM_Error01" )
					end
				else
					catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_reply",
	command = "reply",
	desc = "Send PM (Private Message) to last received PM (Private Message) message sender.",
	syntax = "[Text]",
	runFunc = function( pl, args )
		if ( pl.CAT_lastSender and IsValid( pl.CAT_lastSender ) and pl.CAT_lastSender:IsPlayer( ) ) then
			if ( args[ 1 ] ) then
				local target = pl.CAT_lastSender
				
				if ( pl != target ) then
					if ( !catherine.block.IsBlocked( pl, target, CAT_BLOCK_TYPE_PM_CHAT ) ) then
						local text = table.concat( args, " " )
						
						catherine.chat.Send( pl, "pm", text, { pl, target }, target )
					else
						catherine.util.NotifyLang( pl, "Block_Notify_IsBlocked" )
					end
				else
					catherine.util.NotifyLang( pl, "Command_PM_Error01" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
			end
		else
			catherine.util.NotifyLang( pl, "Command_Reply_Error01" )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_roll",
	command = "roll",
	desc = "Roll a dice. (for RP)",
	runFunc = function( pl, args )
		local number = tonumber( args[ 1 ] ) or 100
		
		if ( number > 100 ) then
			number = 100
		end
		
		catherine.chat.Send( pl, "roll", math.random( 1, number ) )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_dropCash",
	command = "dropcash",
	desc = "Drop a Cash.",
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local amount = tonumber( args[ 1 ] )
			
			if ( !amount ) then
				catherine.util.NotifyLang( pl, "Cash_Notify_NotValidAmount" )
				return
			end
			
			if ( !catherine.cash.Has( pl, amount ) ) then
				catherine.util.NotifyLang( pl, "Cash_Notify_HasNot", catherine.cash.GetOnlySingular( ) )
				return
			end
			
			catherine.cash.Take( pl, amount )
			catherine.cash.Spawn( catherine.util.GetItemDropPos( pl ), nil, amount )
			
			catherine.util.NotifyLang( pl, "Cash_Notify_Drop", catherine.cash.GetCompleteName( amount ) )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_clearDecals",
	command = "cleardecals",
	desc = "Clear all map decals. (Blood etc ..)",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		for k, v in pairs( player.GetAll( ) ) do
			v:ConCommand( "r_cleardecals" )
		end
		
		catherine.util.NotifyLang( pl, "Command_ClearDecals_Fin" )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_restartLevel",
	command = "restartlevel",
	desc = "Restart server as the same map.",
	syntax = "[Delay]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local delay = args[ 1 ] or 5
		
		catherine.util.NotifyAllLang( "Command_RestartLevel_Fin", delay )
		
		timer.Simple( delay, function( )
			RunConsoleCommand( "changelevel", game.GetMap( ) )
		end )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_changeLevel",
	command = "changelevel",
	desc = "Restart server as the typed map.",
	syntax = "[Map] [Delay]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		local map = args[ 1 ]
		local delay = args[ 2 ] or 5
		
		if ( file.Exists( "maps/" .. map .. ".bsp", "GAME" ) ) then
			catherine.util.NotifyAllLang( "Command_ChangeLevel_Fin", delay, map )
			
			timer.Simple( delay, function( )
				RunConsoleCommand( "changelevel", map )
			end )
		else
			catherine.util.NotifyLang( pl, "Command_ChangeLevel_Error01" )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_setTimeHour",
	command = "settimehour",
	desc = "Change RP hour as the typed hour.",
	syntax = "[0 ~ 24]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local newHour = tonumber( args[ 1 ] )
			
			if ( newHour ) then
				newHour = math.Clamp( newHour, 1, 24 )
				
				catherine.environment.SetHour( newHour )
				catherine.environment.SendAllEnvironmentConfig( )
				catherine.environment.AutomaticDayNight( )
			end
			
			catherine.util.NotifyLang( pl, "Command_SetTimeHour_Fin", newHour or catherine.environment.buffer.hour )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_printPlayerBodyGroups",
	command = "printplayerbodygroups",
	desc = "Print player body groups on the Console.",
	syntax = "[Name]",
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local target = catherine.util.FindPlayerByName( args[ 1 ] )
			
			if ( IsValid( target ) and target:IsPlayer( ) ) then
				netstream.Start( pl, "catherine.command.printplayerbodygroups", target:GetBodyGroups( ) )
				catherine.util.NotifyLang( pl, "Command_PrintBodyGroup_Fin" )
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_UnknownPlayer" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_printItems",
	command = "printitems",
	desc = "Print items on the Console.",
	canRun = function( pl ) return pl:HasFlag( "i" ) end,
	runFunc = function( pl, args )
		netstream.Start( pl, "catherine.command.printitems" )
		catherine.util.NotifyLang( pl, "Command_PrintItems_Fin" )
	end
} )

catherine.command.Register( {
	command = "storagesetpwd",
	uniqueID = "&uniqueID_storageSetPwd",
	desc = "Setting a Storage Password. (If you are change to 'None' does it change to default value.)",
	syntax = "[Password]",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local data = { }
		data.start = pl:GetShootPos( )
		data.endpos = data.start + pl:GetAimVector( ) * 70
		data.filter = pl
		local ent = util.TraceLine( data ).Entity
	
		if ( IsValid( ent ) and ent:GetNetVar( "isStorage" ) ) then
			if ( args[ 1 ] ) then
				local pwd = table.concat( args, "" )

				catherine.storage.Work( pl, ent:EntIndex( ), CAT_STORAGE_ACTION_SETPASSWORD, pwd )

				catherine.util.NotifyLang( pl, "Storage_CMD_SetPWD", pwd == "" and "NONE" or pwd )
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
			end
		else
			catherine.util.NotifyLang( pl, "Storage_Notify_NoStorage" )
		end
	end
} )

if ( CLIENT ) then
	netstream.Hook( "catherine.command.printplayerbodygroups", function( data )
		PrintTable( data )
		
		if ( #data > 0 ) then
			MsgC( Color( 255, 255, 0 ), "[CAT]This is target player Body groups, look at 'id' and 'name'.\n" )
		else
			MsgC( Color( 255, 255, 0 ), "[CAT]This player doesn't have any Body groups!\n" )
		end
	end )
	
	netstream.Hook( "catherine.command.printitems", function( )
		local convert = { }
		
		for k, v in pairs( catherine.item.GetAll( ) ) do
			local category = catherine.util.StuffLanguage( v.category )
			
			convert[ category ] = convert[ category ] or { }
			convert[ category ][ #convert[ category ] + 1 ] = {
				Item_Name = catherine.util.StuffLanguage( v.name ),
				Item_Description = catherine.util.StuffLanguage( v.desc ),
				Item_UniqueID = v.uniqueID,
				Item_Cost = v.cost,
				Item_Weight = v.weight
			}
		end
		
		PrintTable( convert )
	end )
end