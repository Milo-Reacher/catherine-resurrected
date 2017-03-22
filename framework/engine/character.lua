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

catherine.character = catherine.character or { networkRegistry = { } }
catherine.character.vars = { }
local META = FindMetaTable( "Player" )
local getSteamID = META.SteamID
local isPlayer = META.IsPlayer

function catherine.character.NewVar( uniqueID, varTable )
	varTable = varTable or { }
	
	table.Merge( varTable, {
		uniqueID = uniqueID
	} )
	
	catherine.character.vars[ uniqueID ] = varTable
end

function catherine.character.GetVarAll( )
	return catherine.character.vars
end

function catherine.character.FindVarByID( uniqueID )
	return catherine.character.vars[ uniqueID ]
end

function catherine.character.FindVarByField( field )
	for k, v in pairs( catherine.character.GetVarAll( ) ) do
		if ( v.field == field ) then
			return v
		end
	end
end

local emptyTableToJSON = util.TableToJSON( { } )

catherine.character.NewVar( "id", {
	field = "_id",
	doNetworking = true,
	static = true
} )

catherine.character.NewVar( "name", {
	field = "_name",
	doNetworking = true,
	default = "Johnson",
	checkValid = function( pl, data, isForce )
		if ( isForce ) then
			return true
		end
		
		if ( data == "" ) then
			return false, "^Character_Notify_SetNameError2"
		end
		
		if ( data:find( "#" ) ) then
			return false, "^Character_Notify_SetNameError"
		end
		
		if ( data:Trim( ):utf8len( ) < catherine.configs.characterNameMinLen or data:Trim( ):utf8len( ) > catherine.configs.characterNameMaxLen ) then
			return false, "^Character_Notify_SetNameError2"
		end
		
		if ( data:utf8len( ) >= catherine.configs.characterNameMinLen and data:utf8len( ) <= catherine.configs.characterNameMaxLen ) then
			return true
		end
		
		return false, "^Character_Notify_NameLimitHit"
	end
} )

catherine.character.NewVar( "desc", {
	field = "_desc",
	doNetworking = true,
	default = "No desc.",
	checkValid = function( pl, data, isForce )
		if ( isForce ) then
			return true
		end
		
		if ( data == "" ) then
			return false, "^Character_Notify_SetDescError2"
		end
		
		if ( data:find( "#" ) ) then
			return false, "^Character_Notify_SetDescError"
		end
		
		if ( data:Trim( ):utf8len( ) < catherine.configs.characterDescMinLen or data:Trim( ):utf8len( ) > catherine.configs.characterDescMaxLen ) then
			return false, "^Character_Notify_SetDescError2"
		end
		
		if ( data:utf8len( ) >= catherine.configs.characterDescMinLen and data:utf8len( ) <= catherine.configs.characterDescMaxLen ) then
			return true
		end
		
		return false, "^Character_Notify_DescLimitHit"
	end
} )

catherine.character.NewVar( "model", {
	field = "_model",
	default = "models/breen.mdl",
	checkValid = function( pl, data )
		if ( data == "" ) then
			return false, "^Character_Notify_SelectModel"
		end
		
		return true
	end
} )

catherine.character.NewVar( "att", {
	field = "_att",
	doNetworking = true,
	default = emptyTableToJSON,
	doConversion = true,
	doLocal = true,
	checkValid = function( pl, data )
		return true
	end
} )

catherine.character.NewVar( "schema", {
	field = "_schema",
	static = true,
	default = function( )
		return catherine.schema.GetUniqueID( )
	end
} )

catherine.character.NewVar( "registerTime", {
	field = "_registerTime",
	static = true,
	default = function( )
		return catherine.util.GetRealTime( )
	end
} )

catherine.character.NewVar( "steamID", {
	field = "_steamID",
	static = true,
	default = function( pl )
		return getSteamID( pl )
	end
} )

catherine.character.NewVar( "charVar", {
	field = "_charVar",
	doNetworking = true,
	default = emptyTableToJSON,
	doConversion = true,
	doLocal = true
} )

catherine.character.NewVar( "inventory", {
	field = "_inv",
	doNetworking = true,
	default = emptyTableToJSON,
	doConversion = true,
	doLocal = true
} )

catherine.character.NewVar( "cash", {
	field = "_cash",
	doNetworking = true,
	default = catherine.configs.defaultCash
} )

catherine.character.NewVar( "faction", {
	field = "_faction",
	doNetworking = true,
	default = "citizen",
	checkValid = function( pl, data )
		local factionTable = catherine.faction.FindByID( data )
		
		if ( SERVER and factionTable and ( ( factionTable.isWhitelist and catherine.faction.HasWhiteList( pl, data ) ) or ( !factionTable.isWhitelist ) ) ) then
			return true
		end
		
		return false, "^Character_Notify_CantUseThisFaction"
	end
} )

if ( SERVER ) then
	catherine.character.buffers = catherine.character.buffers or { }
	
	function catherine.character.New( pl, id )
		if ( pl:IsTied( ) ) then
			return false, "^Character_Notify_CantSwitchTied"
		end
		
		if ( pl:GetCharacterID( ) and !pl:Alive( ) ) then
			return false, "^Character_Notify_CantSwitchDeath"
		end
		
		if ( pl:IsRagdolled( ) ) then
			return false, "^Character_Notify_CantSwitchRagdolled"
		end
		
		if ( hook.Run( "PlayerShouldLoadCharacter", pl ) == false ) then
			return false, "^Character_Notify_CantSwitch"
		end
		
		local character = catherine.character.GetTargetCharacterByID( pl, id )
		
		if ( !character ) then
			return false, "^Character_Notify_IsNotValid"
		end
		
		local prevID = pl:GetCharacterID( )
		
		if ( prevID == id ) then
			return false, "^Character_Notify_CantSwitchUsing"
		end
		
		if ( character._charVar and character._charVar[ "charBanned" ] ) then
			return false, "^Character_Notify_CharBanned"
		end
		
		if ( !prevID ) then
			pl:GodDisable( )
			pl:Freeze( false )
			pl:UnLock( )
		else
			isGodMode = pl:HasGodMode( )
		end
		
		local factionTable = catherine.faction.FindByID( character._faction )
		
		if ( !factionTable ) then
			return false, "^Character_Notify_IsNotValidFaction"
		end
		
		hook.Run( "CharacterLoadingStart", pl, prevID, id )
		
		if ( prevID != nil ) then
			catherine.character.Save( pl )
			catherine.character.DeleteNetworkRegistry( pl )
		else
			netstream.Start( pl, "catherine.hud.WelcomeIntroStart" )
		end
		
		pl.CAT_loadingChar = true
		
		pl:KillSilent( )
		pl:Spawn( )
		pl:SetTeam( factionTable.index )
		pl:SetModel( character._model )
		pl:SetWalkSpeed( catherine.configs.playerDefaultWalkSpeed )
		pl:SetRunSpeed( catherine.player.GetPlayerDefaultRunSpeed( pl ) )
		
		if ( isGodMode ) then
			pl:GodEnable( )
		end
		
		catherine.character.CreateNetworkRegistry( pl, id, character )
		catherine.character.SetCharVar( pl, "class", nil )
		
		pl:SetSkin( catherine.character.GetCharVar( pl, "skin", 0 ) )
		
		for k, v in pairs( pl:GetMaterials( ) ) do
			pl:SetSubMaterial( k - 1, "" )
		end
		
		for k, v in pairs( catherine.character.GetCharVar( pl, "subMaterial", { } ) ) do
			pl:SetSubMaterial( v[ 1 ], v[ 2 ] )
		end
		
		pl:SetNetVar( "charID", id )
		pl:SetNetVar( "charLoaded", true )
		
		hook.Run( "PlayerSpawnedInCharacter", pl )
		hook.Run( "PlayerCharacterLoaded", pl )
		
		if ( catherine.character.GetCharVar( pl, "isFirst", 1 ) == 1 ) then
			catherine.character.SetCharVar( pl, "isFirst", 0 )
			hook.Run( "PlayerFirstSpawned", pl, id )
		end
		
		pl.CAT_loadingChar = nil
		
		if ( !pl.CAT_characterLoadBuffer ) then
			pl.CAT_characterLoadBuffer = { }
		end
		
		if ( !pl.CAT_characterLoadBuffer[ id ] ) then
			hook.Run( "PlayerCharacterTodayFirstLoaded", pl )
			pl.CAT_characterLoadBuffer[ id ] = true
		end
		
		return true
	end
	
	function catherine.character.Create( pl, data )
		local steamID = getSteamID( pl )
		
		if ( catherine.character.buffers[ steamID ] and #catherine.character.buffers[ steamID ] >= catherine.configs.maxCharacters ) then
			netstream.Start( pl, "catherine.character.CreateResult", "^Character_Notify_MaxLimitHit" )
			return
		end
		
		local charVars = { }
		local faction = data[ "faction" ]
		local factionTable = catherine.faction.FindByID( faction )
		local isForceSetName = false
		local isForceSetDesc = false
		local subMaterial = { }
		
		if ( factionTable ) then
			isForceSetName = tobool( factionTable.PostSetName )
			isForceSetDesc = tobool( factionTable.PostSetDesc )
		end
		
		if ( data[ "att" ] ) then
			charVars[ "_att" ] = { }
			
			for k, v in pairs( table.Copy( data[ "att" ] ) ) do
				charVars[ "_att" ][ v.uniqueID ] = {
					per = 0,
					progress = v.amount
				}
			end
			charVars[ "_att" ] = util.TableToJSON( charVars[ "_att" ] )
			
			data[ "att" ] = nil
		end
		
		for k, v in pairs( catherine.character.GetVarAll( ) ) do
			local var = type( v.default ) == "function" and v.default( pl, data[ k ] ) or v.default
			
			if ( data[ k ] ) then
				var = data[ k ]
				
				if ( v.checkValid ) then
					local isForce = false
					
					if ( k == "name" ) then
						isForce = isForceSetName
					elseif( k == "desc" ) then
						isForce = isForceSetDesc
					end
					
					local success, reason = v.checkValid( pl, var, isForce )
					
					if ( success == false ) then
						netstream.Start( pl, "catherine.character.CreateResult", reason or "Unknown Error" )
						return
					end
				end
			end
			
			if ( k != "att" ) then
				charVars[ v.field ] = var
			end
		end
		
		if ( factionTable ) then
			charVars[ "_charVar" ] = util.JSONToTable( charVars[ "_charVar" ] )
			
			for k, v in pairs( factionTable.models ) do
				if ( catherine.faction.IsTableModel( v ) and v.model == data[ "model" ] and v.subMaterials ) then
					subMaterial = v.subMaterials
				end
			end
			
			charVars[ "_charVar" ][ "subMaterial" ] = subMaterial
			charVars[ "_charVar" ] = util.TableToJSON( charVars[ "_charVar" ] )
		end
		
		hook.Add( "DatabaseError", "catherine.database.DatabaseError." .. steamID, function( query, err )
			netstream.Start( pl, "catherine.character.CreateResult", LANG( pl, "Character_Error_DBErrorBasic", err ) )
			hook.Remove( "DatabaseError", "catherine.database.DatabaseError." .. steamID )
		end )
		
		catherine.database.InsertDatas( "catherine_characters", charVars, function( )
			catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. steamID .. " has created a '" .. charVars._name .. "' character.", true )
			netstream.Start( pl, "catherine.character.CreateResult", true )
			catherine.character.SendPlayerCharacterList( pl )
			catherine.attribute.ResetRandom( pl )
			
			hook.Remove( "DatabaseError", "catherine.database.DatabaseError." .. steamID )
		end )
	end
	
	function catherine.character.Use( pl, id )
		local success, reason = catherine.character.New( pl, id )
		
		if ( success ) then
			netstream.Start( pl, "catherine.character.UseResult", true )
			
			catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. getSteamID( pl ) .. " has loaded a '" .. pl:Name( ) .. "' character.", true )
		else
			netstream.Start( pl, "catherine.character.UseResult", reason )
		end
	end
	
	function catherine.character.Delete( pl, id )
		if ( pl:GetCharacterID( ) == id ) then
			netstream.Start( pl, "catherine.character.DeleteResult", "^Character_Notify_CantDeleteUsing" )
			return
		end
		
		local steamID = getSteamID( pl )
		
		catherine.database.Query( "DELETE FROM `catherine_characters` WHERE _steamID = '" .. steamID .. "' AND _id = '" .. id .. "'", function( data )
			catherine.character.SendPlayerCharacterList( pl, function( )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, pl:SteamName( ) .. ", " .. steamID .. " has deleted a '" .. id .. "' character.", true )
				netstream.Start( pl, "catherine.character.DeleteResult", true )
			end )
		end )
	end
	
	function catherine.character.SetVar( pl, key, value, noSync, save )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		local varTable = catherine.character.FindVarByField( key )
		
		if ( ( varTable and varTable.static ) or !catherine.character.networkRegistry[ steamID ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ key ] = value
		
		if ( !noSync ) then
			local target = nil
			
			if ( varTable and varTable.doLocal ) then
				target = pl
			end
			
			netstream.Start( target, "catherine.character.SetVar", {
				pl,
				key,
				value
			} )
		end
		
		if ( save ) then
			catherine.character.Save( pl )
		end
		
		hook.Run( "CharacterVarChanged", pl, key, value )
	end
	
	function catherine.character.SetCharVar( pl, key, value, noSync )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] = value
		
		if ( !noSync ) then
			netstream.Start( pl, "catherine.character.SetCharVar", { pl, key, value } )
		end
		
		hook.Run( "CharacterCharVarChanged", pl, key, value )
	end
	
	function META:SetVar( key, value, noSync )
		catherine.character.SetVar( self, key, value, noSync )
	end
	
	function META:SetCharVar( key, value, noSync )
		catherine.character.SetCharVar( self, key, value, noSync )
	end
	
	function catherine.character.SetMenuActive( pl, active )
		netstream.Start( pl, "catherine.character.SetMenuActive", active )
	end
	
	function catherine.character.SendPlayerCharacterList( pl, func )
		local steamID = getSteamID( pl )
		
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. steamID .. "' AND _schema = '" .. catherine.schema.GetUniqueID( ) .. "'", function( data )
			if ( !data or #data == 0 ) then
				catherine.character.buffers[ steamID ] = { }
				netstream.Start( pl, "catherine.character.SendPlayerCharacterList", { } )
				
				if ( func ) then
					func( )
				end
				return
			end
			
			for k, v in pairs( catherine.character.GetVarAll( ) ) do
				for k1, v1 in pairs( data ) do
					if ( !v.doConversion ) then continue end
					
					data[ k1 ][ v.field ] = util.JSONToTable( data[ k1 ][ v.field ] ) or { }
				end
			end
			
			for k, v in pairs( data ) do
				if ( !catherine.faction.FindByID( v._faction ) ) then
					catherine.database.Query( "DELETE FROM `catherine_characters` WHERE _steamID = '" .. steamID .. "' AND _id = '" .. v._id .. "'" )
					table.remove( data, k )
				end
			end
			
			catherine.character.buffers[ steamID ] = data
			netstream.Start( pl, "catherine.character.SendPlayerCharacterList", data )
			
			if ( func ) then
				func( )
			end
		end )
	end
	
	function catherine.character.RefreshCharacterBuffer( pl )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. steamID .. "' AND _schema = '" .. catherine.schema.GetUniqueID( ) .. "'", function( data )
			if ( !data ) then return end
			
			catherine.character.buffers[ steamID ] = data
		end )
	end
	
	function catherine.character.GetTargetCharacterFromQuery( steamID, func )
		catherine.database.GetDatas( "catherine_characters", "_steamID = '" .. steamID .. "' AND _schema = '" .. catherine.schema.GetUniqueID( ) .. "'", function( data )
			if ( !data ) then
				if ( func ) then
					func( false )
				end
				
				return
			end
			
			if ( func ) then
				local buffer = table.Copy( data )
				
				for k, v in pairs( buffer ) do
					buffer[ k ] = catherine.character.ConvertDataTable( v )
				end
				
				func( true, buffer )
			end
		end )
	end
	
	function catherine.character.GetTargetCharacterByID( pl, id )
		for k, v in pairs( catherine.character.buffers[ getSteamID( pl ) ] or { } ) do
			for k1, v1 in pairs( v ) do
				if ( k1 == "_id" and v1 == id ) then
					return catherine.character.ConvertDataTable( v )
				end
			end
		end
	end
	
	function catherine.character.ConvertDataTable( data )
		for k, v in pairs( data ) do
			local varTable = catherine.character.FindVarByField( k )
			
			if ( ( varTable and !varTable.doConversion ) or type( v ) == "table" ) then continue end
			
			data[ k ] = util.JSONToTable( v ) or { }
		end
		
		return data
	end
	
	function catherine.character.CreateNetworkRegistry( pl, id, data )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		catherine.character.networkRegistry[ steamID ] = { }
		
		for k, v in pairs( data ) do
			local varTable = catherine.character.FindVarByField( k )
			
			if ( varTable and !varTable.doNetworking ) then continue end
			
			catherine.character.networkRegistry[ steamID ][ k ] = v
		end
		
		netstream.Start( nil, "catherine.character.CreateNetworkRegistry", { pl, catherine.character.networkRegistry[ steamID ] } )
		
		hook.Run( "CreateNetworkRegistry", pl, catherine.character.networkRegistry[ steamID ] )
	end
	
	function catherine.character.SendAllNetworkRegistries( pl )
		netstream.Start( pl, "catherine.character.SendAllNetworkRegistries", catherine.character.networkRegistry )
	end
	
	function catherine.character.GetNetworkRegistry( pl )
		return catherine.character.networkRegistry[ getSteamID( pl ) ]
	end
	
	function catherine.character.DeleteNetworkRegistry( pl )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		local steamID = getSteamID( pl )
		
		catherine.character.networkRegistry[ steamID ] = nil
		netstream.Start( nil, "catherine.character.DeleteNetworkRegistry", steamID )
	end
	
	local function removeDummyInTable( tab )
		for k, v in pairs( tab ) do
			local keyType, valueType = type( k ), type( v )
			
			if ( ( keyType == "Entity" or keyType == "Player" ) and !IsValid( k ) ) then
				tab[ k ] = nil
			end
			
			if ( valueType == "table" ) then
				removeDummyInTable( v )
			else
				if ( ( valueType == "Entity" or valueType == "Player" ) and !IsValid( v ) ) then
					tab[ k ] = nil
				end
			end
		end
	end
	
	function catherine.character.RemoveDummy( send, pl )
		for k, v in pairs( catherine.character.networkRegistry ) do
			local keyType = type( k )
			
			if ( ( keyType == "Entity" or keyType == "Player" ) and !IsValid( k ) ) then
				catherine.character.networkRegistry[ k ] = nil
			end
			
			if ( type( v ) == "table" ) then
				removeDummyInTable( v )
			end
		end
		
		if ( send ) then
			catherine.character.SendAllNetworkRegistries( pl )
		end
	end
	
	function catherine.character.Save( pl, deleteNetRegistry )
		if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
		if ( hook.Run( "PlayerShouldSaveCharacter", pl ) == false ) then return end
		local networkRegistry = catherine.character.GetNetworkRegistry( pl )
		
		if ( !networkRegistry ) then return end
		
		hook.Run( "PostCharacterSave", pl )
		
		local steamID = getSteamID( pl )
		
		for k, v in pairs( networkRegistry ) do
			if ( type( v ) == "Entity" ) then
				catherine.character.networkRegistry[ steamID ][ k ] = nil
			end
		end
		
		local id = pl:GetCharacterID( )
		
		if ( !id ) then return end
		
		catherine.database.UpdateDatas( "catherine_characters", "_id = '" .. tostring( id ) .. "' AND _steamID = '" .. steamID .. "'", networkRegistry, function( )
			if ( !IsValid( pl ) or !isPlayer( pl ) ) then return end
			
			catherine.character.RefreshCharacterBuffer( pl )
			catherine.util.Print( Color( 0, 255, 0 ), pl:SteamName( ) .. "'s character has been saved. [ ID : " .. id .. " ]" )
			
			if ( deleteNetRegistry ) then
				catherine.character.DeleteNetworkRegistry( pl )
			end
		end )
	end
	
	timer.Create( "Catherine.timer.character.AutoSaveCharacter", catherine.configs.characterSaveInterval, 0, function( )
		if ( table.Count( catherine.character.buffers ) == 0 ) then return end
		local players = player.GetAllByLoaded( )
		
		if ( #players > 0 ) then
			local delta = 0
			
			for k, v in pairs( players ) do
				timer.Simple( delta, function( )
					catherine.character.Save( v )
				end )
				
				delta = delta + 1
			end
			
			timer.Simple( delta + 3, function( )
				catherine.log.Add( CAT_LOG_FLAG_IMPORTANT, #players .. "'s characters has been saved.", true )
			end )
		end
	end )
	
	function catherine.character.PlayerDisconnected( pl )
		catherine.character.Save( pl, true )
	end
	
	function catherine.character.ServerShutDown( )
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.character.Save( v )
		end
	end
	
	hook.Add( "PlayerDisconnected", "catherine.character.PlayerDisconnected", catherine.character.PlayerDisconnected )
	hook.Add( "ServerShutDown", "catherine.character.ServerShutDown", catherine.character.ServerShutDown )
	
	concommand.Add( "cat_saveallchar", function( pl )
		if ( !pl:IsSuperAdmin( ) ) then return end
		
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			catherine.character.Save( v )
		end
	end )
	
	netstream.Hook( "catherine.character.Create", function( pl, data )
		catherine.character.Create( pl, data )
	end )
	
	netstream.Hook( "catherine.character.Use", function( pl, data )
		catherine.character.Use( pl, data )
	end )
	
	netstream.Hook( "catherine.character.Delete", function( pl, data )
		catherine.character.Delete( pl, data )
	end )
	
	netstream.Hook( "catherine.character.SendPlayerCharacterListRequest", function( pl, data )
		catherine.character.SendPlayerCharacterList( pl )
	end )
	
	netstream.Hook( "catherine.character.GetRandomAttribute", function( pl )
		netstream.Start( pl, "catherine.character.GetRandomAttributeReceive", catherine.attribute.GetRandom( pl ) )
	end )
else
	catherine.character.panelMusic = catherine.character.panelMusic or nil
	catherine.character.localCharacters = catherine.character.localCharacters or { }
	
	netstream.Hook( "catherine.character.GetRandomAttributeReceive", function( data )
		if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.createData.currentStage ) ) then
			if ( #data == 0 ) then
				catherine.vgui.character.createData.currentStage.noAtt = true
			else
				catherine.vgui.character.createData.currentStage.data.att = data
				catherine.vgui.character.createData.currentStage:BuildRandomAttributeList( )
			end
		end
	end )
	
	netstream.Hook( "catherine.character.CreateResult", function( data )
		timer.Remove( "catherine.vgui.character.CharacterCreateTimeout" )
		
		if ( data == true and IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.createData.currentStage ) ) then
			catherine.vgui.character:BackToMainMenu( )
			catherine.vgui.character.createData.currentStage:Remove( )
			
			catherine.vgui.character.createData = nil
		else
			Derma_Message( catherine.util.StuffLanguage( data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.UseResult", function( data )
		timer.Remove( "catherine.vgui.character.CharacterLoadTimeout" )
		
		if ( data == true and IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Close( )
		else
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.CharacterPanel ) ) then
				catherine.vgui.character.CharacterPanel.loading = false
			end
			
			Derma_Message( catherine.util.StuffLanguage( data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.DeleteResult", function( data )
		timer.Remove( "catherine.vgui.character.CharacterDeleteTimeout" )
		
		if ( data == true ) then
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.CharacterPanel ) ) then
				local backup = catherine.vgui.character.loadCharacter.curr
				
				catherine.vgui.character.CharacterPanel:Remove( )
				catherine.vgui.character:UseCharacterPanel( )
				
				catherine.vgui.character.loadCharacter.curr = #catherine.character.localCharacters
			end
			
			Derma_Message( LANG( "Character_Notify_DeleteResult" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		else
			if ( IsValid( catherine.vgui.character ) and IsValid( catherine.vgui.character.CharacterPanel ) ) then
				catherine.vgui.character.CharacterPanel.loading = false
			end
			
			Derma_Message( catherine.util.StuffLanguage( data ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
		end
	end )
	
	netstream.Hook( "catherine.character.SetMenuActive", function( data )
		if ( data == true ) then
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
			
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
		end
	end )
	
	netstream.Hook( "catherine.character.CreateNetworkRegistry", function( data )
		local pl = data[ 1 ]
		local registry = data[ 2 ]
		
		if ( !IsValid( pl ) ) then return end
		
		catherine.character.networkRegistry[ getSteamID( pl ) ] = registry
		
		hook.Run( "CreateNetworkRegistry", pl, registry )
	end )
	
	netstream.Hook( "catherine.character.DeleteNetworkRegistry", function( data )
		catherine.character.networkRegistry[ data ] = nil
	end )
	
	netstream.Hook( "catherine.character.SendAllNetworkRegistries", function( data )
		catherine.character.networkRegistry = data
	end )
	
	netstream.Hook( "catherine.character.SetVar", function( data )
		local pl = data[ 1 ]
		
		if ( !IsValid( pl ) ) then return end
		
		local key = data[ 2 ]
		local value = data[ 3 ]
		local steamID = getSteamID( pl )
		
		if ( !catherine.character.networkRegistry[ steamID ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ key ] = value
		
		hook.Run( "CharacterVarChanged", pl, key, value )
	end )
	
	netstream.Hook( "catherine.character.SetCharVar", function( data )
		local pl = data[ 1 ]
		
		if ( !IsValid( pl ) ) then return end
		
		local key = data[ 2 ]
		local value = data[ 3 ]
		local steamID = getSteamID( pl )
		
		if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return end
		
		catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] = value
		
		hook.Run( "CharacterCharVarChanged", pl, key, value )
	end )
	
	netstream.Hook( "catherine.character.SendPlayerCharacterList", function( data )
		catherine.character.localCharacters = data
	end )
	
	function catherine.character.SetCustomBackground( bool )
		catherine.character.customBackgroundEnabled = bool
	end
	
	function catherine.character.IsCustomBackground( )
		return catherine.character.customBackgroundEnabled
	end
	
	function catherine.character.SetMenuActive( active )
		if ( active == true ) then
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
			
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			if ( IsValid( catherine.vgui.character ) ) then
				catherine.vgui.character:Close( )
			end
		end
	end
	
	function catherine.character.IsMenuActive( )
		return IsValid( catherine.vgui.character )
	end
	
	function catherine.character.SendPlayerCharacterListRequest( )
		netstream.Start( "catherine.character.SendPlayerCharacterListRequest" )
	end
end

function catherine.character.GetVar( pl, key, default )
	if ( !IsValid( pl ) or !isPlayer( pl ) or !key ) then return default end
	local steamID = getSteamID( pl )
	
	if ( !catherine.character.networkRegistry[ steamID ] ) then return default end
	
	return catherine.character.networkRegistry[ steamID ][ key ] or default
end

function catherine.character.GetCharVar( pl, key, default )
	if ( !IsValid( pl ) or !isPlayer( pl ) or !key ) then return default end
	local steamID = getSteamID( pl )
	
	if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return default end
	
	return catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] or default
end

function META:GetVar( key, default )
	if ( !IsValid( self ) or !isPlayer( self ) or !key ) then return default end
	local steamID = getSteamID( self )
	
	if ( !catherine.character.networkRegistry[ steamID ] ) then return default end
	
	return catherine.character.networkRegistry[ steamID ][ key ] or default
end

function META:GetCharVar( key, default )
	if ( !IsValid( self ) or !isPlayer( self ) or !key ) then return default end
	local steamID = getSteamID( self )
	
	if ( !catherine.character.networkRegistry[ steamID ] or !catherine.character.networkRegistry[ steamID ][ "_charVar" ] ) then return default end
	
	return catherine.character.networkRegistry[ steamID ][ "_charVar" ][ key ] or default
end

function META:GetCharacterID( )
	return self:GetNetVar( "charID", nil )
end

function META:IsCharacterLoaded( )
	return self:GetNetVar( "charLoaded", false )
end

META.RealName = META.RealName or META.Name
META.SteamName = META.RealName

function META:Name( )
	return self:GetVar( "_name", self:SteamName( ) )
end

function META:Desc( )
	return self:GetVar( "_desc", "A Description." )
end

function META:Faction( )
	return self:GetVar( "_faction", "citizen" )
end

function META:FactionName( )
	return catherine.util.StuffLanguage( team.GetName( self:Team( ) ) )
end

META.Nick = META.Name
META.GetName = META.Name