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

catherine.chat = catherine.chat or { }
catherine.chat.lists = { }

function catherine.chat.Register( uniqueID, classTable )
	classTable = classTable or { }
	
	table.Merge( classTable, {
		uniqueID = uniqueID
	} )
	
	if ( classTable.command and #classTable.command > 1 ) then
		table.sort( classTable.command, function( a, b )
			return a:utf8len( ) > b:utf8len( )
		end )
	end
	
	catherine.chat.lists[ uniqueID ] = classTable
end

function catherine.chat.GetAll( )
	return catherine.chat.lists
end

function catherine.chat.FindByID( uniqueID )
	return catherine.chat.lists[ uniqueID ]
end

function catherine.chat.FindIDByText( text )
	for k, v in pairs( catherine.chat.GetAll( ) ) do
		local command = v.command or ""
		
		for k2, v2 in pairs( type( command ) == "table" and command or { } ) do
			if ( text:sub( 1, #v2 ):lower( ) != v2:lower( ) ) then continue end
			
			return k or "ic"
		end
	end
	
	return "ic"
end

function catherine.chat.PreSet( text )
	return "\"" .. text .. "\""
end

catherine.chat.Register( "ic", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", catherine.pl, pl )
		
		if ( hook.Run( "GetUnknownTargetName", catherine.pl, pl ) == name ) then
			name = desc
		end
		
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 255, 255, 150 ), LANG( "Chat_Str_IC", name, catherine.chat.PreSet( text ) ) )
		else
			chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_IC", name, catherine.chat.PreSet( text ) ) )
		end
	end,
	canHearRange = 300,
	canRun = function( pl ) return !pl:IsRagdolled( ) and pl:Alive( ) end,
	canHear = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "me", {
	func = function( pl, text )
		chat.AddText( Color( 193, 255, 193 ), "** " .. pl:Name( ) .. " - " .. text )
	end,
	font = "catherine_chat_italic",
	command = { "/me", "/ME", "/Me", "/mE" },
	canHearRange = 800,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "it", {
	func = function( pl, text )
		chat.AddText( Color( 193, 255, 193 ), "*** " .. pl:Name( ) .. " - " .. text )
	end,
	font = "catherine_chat_italic",
	command = { "/it", "/It", "/iT" },
	canHearRange = 550,
	canRun = function( pl ) return pl:Alive( ) end
} )

catherine.chat.Register( "roll", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", catherine.pl, pl )
		
		if ( hook.Run( "GetUnknownTargetName", catherine.pl, pl ) == name ) then
			name = desc
		end
		
		chat.AddText( Color( 158, 122, 19 ), LANG( "Chat_Str_Roll", name, catherine.chat.PreSet( text ) ) )
	end,
	canHearRange = 600,
	canRun = function( pl ) return !pl:IsRagdolled( ) and pl:Alive( ) end,
} )

catherine.chat.Register( "pm", {
	func = function( pl, text, ex )
		if ( ex[ 1 ] == pl ) then
			if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
				chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 142, 229, 238 ), "[PM] " .. pl:Name( ) .. " : " .. text )
			else
				chat.AddText( Color( 142, 229, 238 ), "[PM] " .. pl:Name( ) .. " : " .. text )
			end
			
			surface.PlaySound( "CAT/notify03.wav" )
		else
			if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
				chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 132, 112, 255 ), "[PM] " .. pl:Name( ) .. " : " .. text )
			else
				chat.AddText( Color( 132, 112, 255 ), "[PM] " .. pl:Name( ) .. " : " .. text )
			end
			
			surface.PlaySound( "CAT/notify03.wav" )
		end
	end,
	font = "catherine_chat_italic"
} )

catherine.chat.Register( "event", {
	func = function( _, text )
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 194, 93, 39 ), text )
		else
			chat.AddText( Color( 194, 93, 39 ), text )
		end
	end,
	canRun = function( pl ) return pl:IsSuperAdmin( ) end,
	command = { "/event", "/Event" }
} )

catherine.chat.Register( "yell", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", catherine.pl, pl )
		
		if ( hook.Run( "GetUnknownTargetName", catherine.pl, pl ) == name ) then
			name = desc
		end
		
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 255, 255, 150 ), LANG( "Chat_Str_Yell", name, catherine.chat.PreSet( text ) ) )
		else
			chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_Yell", name, catherine.chat.PreSet( text ) ) )
		end
	end,
	canHearRange = 600,
	font = "catherine_normal20",
	command = { "/y", "/Y", "/yell", "/Yell", "/YELL" },
	canRun = function( pl ) return !pl:IsRagdolled( ) and pl:Alive( ) end,
} )

catherine.chat.Register( "whisper", {
	func = function( pl, text )
		local name, desc = hook.Run( "GetPlayerInformation", catherine.pl, pl )
		
		if ( hook.Run( "GetUnknownTargetName", catherine.pl, pl ) == name ) then
			name = desc
		end

		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 255, 255, 150 ), LANG( "Chat_Str_Whisper", name, catherine.chat.PreSet( text ) ) )
		else
			chat.AddText( Color( 255, 255, 150 ), LANG( "Chat_Str_Whisper", name, catherine.chat.PreSet( text ) ) )
		end
	end,
	canHearRange = 150,
	font = "catherine_normal15",
	command = { "/w", "/W", "/whisper", "/Whisper", "/WHISPER" },
	canRun = function( pl ) return !pl:IsRagdolled( ) and pl:Alive( ) end,
} )

catherine.chat.Register( "ooc", {
	func = function( pl, text )
		if ( !IsValid( pl ) ) then return end
		
		local icon = Material( "icon16/user.png" )
		
		if ( pl:SteamID( ) == "STEAM_0:1:25704824" ) then
			icon = Material( "icon16/thumb_up.png" )
		elseif ( pl:IsSuperAdmin( ) ) then
			icon = Material( "icon16/shield.png" )
		elseif ( pl:IsAdmin( ) ) then
			icon = Material( "icon16/star.png" )
		end
		
		local override = hook.Run( "GetChatIcon", pl, "ooc", text )
		
		if ( override ) then
			icon = Material( override )
		end
		
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", icon, Color( 250, 40, 40 ), "[OOC] ", pl, Color( 255, 255, 255 ), " : ".. text )
		else
			chat.AddText( icon, Color( 250, 40, 40 ), "[OOC] ", pl, Color( 255, 255, 255 ), " : ".. text )
		end
	end,
	isGlobal = true,
	command = { "/ooc", "/OOC", "/Ooc", "//" },
	noSpace = true,
	canRun = function( pl )
		if ( !catherine.configs.enable_oocDelay ) then return true end
		local forceAllow = catherine.configs.forceAllowOOC
		
		if ( forceAllow and type( forceAllow ) == "function" ) then
			local success, langKey, par = forceAllow( pl )
			
			if ( success != nil ) then
				return success, langKey, par
			end
		end
		
		if ( ( pl.CAT_nextCanOOC or 0 ) <= CurTime( ) ) then
			pl.CAT_nextCanOOC = CurTime( ) + catherine.configs.oocDelay
			
			return true
		else
			return false, "Command_OOC_Error", { math.ceil( pl.CAT_nextCanOOC - CurTime( ) ) }
		end
	end
} )

catherine.chat.Register( "looc", {
	func = function( pl, text )
		if ( !IsValid( pl ) ) then return end
		
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Color( 255, 127, 80 ), "[LOOC] ", pl, Color( 255, 255, 255 ), " : ".. text )
		else
			chat.AddText( Color( 255, 127, 80 ), "[LOOC] ", pl, Color( 255, 255, 255 ), " : ".. text )
		end
	end,
	canHearRange = 600,
	command = { "/looc", "/Looc", "/LOOC", ".//", "[[" },
	noSpace = true,
	canRun = function( pl )
		if ( !catherine.configs.enable_loocDelay ) then return true end
		local forceAllow = catherine.configs.forceAllowLOOC
		
		if ( forceAllow and type( forceAllow ) == "function" ) then
			local success, langKey, par = forceAllow( pl )
			
			if ( success != nil ) then
				return success, langKey, par
			end
		end
		
		if ( ( pl.CAT_nextCanLOOC or 0 ) <= CurTime( ) ) then
			pl.CAT_nextCanLOOC = CurTime( ) + catherine.configs.loocDelay
			
			return true
		else
			return false, "Command_LOOC_Error", { math.ceil( pl.CAT_nextCanLOOC - CurTime( ) ) }
		end
	end
} )

catherine.chat.Register( "connect", {
	func = function( pl, text, ex )
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Material( "icon16/server.png" ), Color( 238, 232, 170 ), LANG( "Chat_Str_Connect", ex[ 1 ] ) )
		else
			chat.AddText( icon, Color( 238, 232, 170 ), LANG( "Chat_Str_Connect", ex[ 1 ] ) )
		end
	end,
	isGlobal = true
} )

catherine.chat.Register( "disconnect", {
	func = function( pl, text, ex )
		if ( GetConVarString( "cat_convar_chat_timestamp" ) == "1" ) then
			chat.AddText( Color( 150, 150, 150 ), "(" .. catherine.util.GetChatTimeStamp( ) .. ") ", Material( "icon16/server.png" ), Color( 238, 232, 170 ), LANG( "Chat_Str_Disconnect", ex[ 1 ] ) )
		else
			chat.AddText( icon, Color( 238, 232, 170 ), LANG( "Chat_Str_Disconnect", ex[ 1 ] ) )
		end
	end,
	isGlobal = true
} )

if ( SERVER ) then
	catherine.chat.chatTypedHistoryBackup = catherine.chat.chatTypedHistoryBackup or { }
	
	function catherine.chat.Run( pl, text )
		local classTable = catherine.chat.FindByID( catherine.chat.FindIDByText( text ) )
		
		if ( !classTable ) then return end

		local success, langKey, par = catherine.chat.CanChat( pl, classTable )
		
		if ( success == false ) then
			if ( langKey ) then
				catherine.util.NotifyLang( pl, langKey, unpack( par or { } ) )
			else
				catherine.util.NotifyLang( pl, "Player_Message_HasNotPermission" )
			end
			
			return
		end

		local commandTable = classTable.command or { }
		local noSpace = classTable.noSpace
		
		for k, v in pairs( type( commandTable ) == "table" and commandTable or { commandTable } ) do
			if ( text:sub( 1, #v + ( noSpace and 0 or 1 ) ) == v .. ( noSpace and "" or " " ) ) then
				text = text:sub( #( v .. ( noSpace and "" or " " ) ) + 1 )
			
				if ( noSpace and text:sub( 1, 1 ):match( "%s" ) ) then
					text = text:sub( 2 )
				end

				break
			end
		end
		
		local isCommand = catherine.command.IsCommand( text )
		
		if ( isCommand ) then
			if ( isCommand == 1 ) then
				catherine.util.NotifyLang( pl, "Command_Notify_NotFound" )
				return
			else
				catherine.command.RunByText( pl, text )
				return
			end
		end
		
		if ( text == "" ) then
			catherine.util.NotifyLang( pl, "Basic_Notify_InputText" )
			return
		end
		
		local chatInformation = {
			text = text,
			uniqueID = classTable.uniqueID,
			pl = pl
		}
		
		local chatOverride = hook.Run( "OnChatControl", chatInformation )
		
		if ( chatOverride == false ) then
			return
		elseif ( chatOverride == nil ) then
			chatOverride = chatInformation
		end
		
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, classTable ) or "" ) .. chatOverride.text )
		
		hook.Run( "ChatPosted", chatOverride )
	end
	
	function catherine.chat.Send( pl, classTable, text, forceTarget, ... )
		classTable = type( classTable ) == "string" and catherine.chat.FindByID( classTable ) or classTable
		
		if ( !classTable or type( classTable ) != "table" ) then return end
		
		local uniqueID = classTable.uniqueID

		if ( classTable.isGlobal and !forceTarget ) then
			netstream.Start( nil, "catherine.chat.Post", {
				pl,
				uniqueID,
				text or "",
				{ ... }
			} )
		else
			if ( type( forceTarget ) == "table" and #forceTarget > 0 ) then
				for k, v in pairs( forceTarget ) do
					if ( uniqueID != "pm" and ( catherine.block.IsBlocked( pl, v, CAT_BLOCK_TYPE_ALL_CHAT ) or catherine.block.IsBlocked( v, pl, CAT_BLOCK_TYPE_ALL_CHAT ) ) ) then continue end
					if ( catherine.block.IsBlocked( pl, v, CAT_BLOCK_TYPE_PM_CHAT ) or catherine.block.IsBlocked( v, pl, CAT_BLOCK_TYPE_PM_CHAT ) ) then continue end
					
					netstream.Start( v, "catherine.chat.Post", {
						pl,
						uniqueID,
						text or "",
						{ ... }
					} )
				end
			else
				netstream.Start( catherine.chat.GetListener( pl, classTable ), "catherine.chat.Post", {
					pl,
					uniqueID,
					text or "",
					{ ... }
				} )
			end
		end
	end
	
	function catherine.chat.GetListener( pl, classTable )
		classTable = type( classTable ) == "string" and catherine.chat.FindByID( classTable ) or classTable
		
		if ( !classTable or !classTable.canHearRange ) then return { pl } end
		
		local target = { pl }
		local range = classTable.canHearRange
		
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( classTable.canHear and classTable.canHear( pl ) == false ) then continue end
			if ( pl == v ) then continue end
			if ( catherine.block.IsBlocked( pl, v, CAT_BLOCK_TYPE_ALL_CHAT ) or catherine.block.IsBlocked( v, pl, CAT_BLOCK_TYPE_ALL_CHAT ) ) then continue end
			
			if ( catherine.util.CalcDistanceByPos( pl, v ) <= range ) then
				target[ #target + 1 ] = v
			end
		end
		
		return target
	end
	
	function catherine.chat.CanChat( pl, classTable )
		if ( classTable.canRun ) then
			return classTable.canRun( pl )
		end
		
		return true
	end
	
	function catherine.chat.AddPlayerChatHistory( pl, text )
		local steamID = pl:SteamID( )
		
		catherine.chat.chatTypedHistoryBackup[ steamID ] = catherine.chat.chatTypedHistoryBackup[ steamID ] or { }
		catherine.chat.chatTypedHistoryBackup[ steamID ][ #catherine.chat.chatTypedHistoryBackup[ steamID ] + 1 ] = text
		
		if ( #catherine.chat.chatTypedHistoryBackup[ steamID ] > 20 ) then
			table.remove( catherine.chat.chatTypedHistoryBackup[ steamID ], 1 )
		end
	end
	
	function catherine.chat.GetPlayerChatHistory( pl )
		return catherine.chat.chatTypedHistoryBackup[ pl:SteamID( ) ]
	end
	
	function catherine.chat.StartChatHistoryRestore( pl )
		netstream.Start( pl, "catherine.chat.RestoreChatHistory", catherine.chat.GetPlayerChatHistory( pl ) )
	end
	
	function catherine.chat.RunByID( pl, uniqueID, text, target, ... )
		local classTable = catherine.chat.FindByID( uniqueID )
		
		if ( !classTable ) then return end
		
		local chatInformation = {
			text = text,
			uniqueID = classTable.uniqueID,
			pl = pl,
			target = target
		}
		
		local chatOverride = hook.Run( "OnChatControl", chatInformation ) or chatInformation

		if ( chatOverride == false ) then
			return
		elseif ( chatOverride == nil ) then
			chatOverride = chatInformation
		end
		
		catherine.chat.Send( pl, classTable, ( hook.Run( "ChatPrefix", pl, classTable ) or "" ) .. chatOverride.text, target, ... )
		
		hook.Run( "ChatPosted", chatOverride )
	end
	
	netstream.Hook( "catherine.chat.Run", function( pl, data )
		hook.Run( "PlayerSay", pl, data, true )
	end )
else
	catherine.chat.backPanel = catherine.chat.backPanel or nil
	catherine.chat.chatPanel = catherine.chat.chatPanel or nil
	catherine.chat.isOpened = catherine.chat.isOpened or false
	catherine.chat.chatLines = catherine.chat.chatLines or { }
	catherine.chat.chatTypedHistory = catherine.chat.chatTypedHistory or { }
	catherine.chat.overrideChatFont = catherine.chat.overrideChatFont or nil
	catherine.chat.sizePosData = {
		w = ScrW( ) * 0.5,
		h = ScrH( ) * 0.3,
		x = 5,
		y = ScrH( ) - ( ScrH( ) * 0.3 ) - 5
	}
	
	local typingText = ""
	local maxchatLine = catherine.configs.maxChatboxLine
	local vgui_Create = vgui.Create
	
	netstream.Hook( "catherine.chat.Post", function( data )
		local speaker = data[ 1 ]
		local classTable = catherine.chat.FindByID( data[ 2 ] )
		
		if ( classTable ) then
			if ( classTable.font ) then
				catherine.chat.SetOverrideFont( classTable.font )
				
				classTable.func( speaker, data[ 3 ], data[ 4 ] )
				
				catherine.chat.SetOverrideFont( nil )
			else
				classTable.func( speaker, data[ 3 ], data[ 4 ] )
			end
		end
	end )
	
	netstream.Hook( "catherine.chat.RestoreChatHistory", function( data )
		catherine.chat.chatTypedHistory = data
	end )
	
	catherine.hud.RegisterBlockModule( "CHudChat" )
	
	chat.AddTextBuffer = chat.AddTextBuffer or chat.AddText
	
	function chat.AddText( ... )
		if ( !IsValid( catherine.pl ) or !catherine.pl:IsCharacterLoaded( ) ) then return end
		local data = { }
		local lastColor = Color( 255, 255, 255 )

		for k, v in pairs( { ... } ) do
			data[ k ] = v
		end

		catherine.chat.AddText( unpack( data ) )
		
		surface.PlaySound( "common/talk.wav" )

		for k, v in pairs( data ) do
			if ( type( v ) != "Player" ) then continue end
			local pl = v
			local index = k
			
			table.remove( data, index )
			table.insert( data, index, team.GetColor( pl:Team( ) ) )
			table.insert( data, index + 1, pl:Name( ) )
		end
		
		return chat.AddTextBuffer( unpack( data ) )
	end
	
	function catherine.chat.SetOverrideFont( font )
		catherine.chat.overrideChatFont = font
	end
	
	function catherine.chat.GetOverrideFont( )
		return catherine.chat.overrideChatFont
	end
	
	function catherine.chat.AddText( ... )
		local msg = vgui_Create( "catherine.vgui.chatmarkup" )
		msg:Dock( TOP )
		msg:SetFont( catherine.chat.overrideChatFont or "catherine_chat" )
		msg:SetMaxWidth( catherine.chat.sizePosData.w - 16 )
		msg:Run( ... )
		
		catherine.chat.chatLines[ #catherine.chat.chatLines + 1 ] = msg
		
		if ( IsValid( catherine.chat.backPanel ) ) then
			local scrollBar = catherine.chat.backPanel.history.VBar
			
			catherine.chat.backPanel.history:AddItem( msg )
			
			if ( scrollBar.Scroll == scrollBar.CanvasSize or !catherine.chat.isOpened ) then
				scrollBar.CanvasSize = scrollBar.CanvasSize + msg:GetTall( )
				scrollBar:AnimateTo( scrollBar.CanvasSize, 0.25, 0, 0.25 )
			end
		end
		
		if ( #catherine.chat.chatLines > maxchatLine ) then
			local firstPanel = catherine.chat.chatLines[ 1 ]
			
			if ( IsValid( firstPanel ) ) then
				firstPanel:Remove( )
			end

			table.remove( catherine.chat.chatLines, 1 )
		end
	end
	
	function catherine.chat.SetSizePosData( w, h, x, y )
		local oldData = catherine.chat.sizePosData
		
		catherine.chat.sizePosData = {
			w = w or oldData.w,
			h = h or oldData.h,
			x = x or oldData.x,
			y = y or oldData.y
		}
	end
	
	function catherine.chat.GetSizePosData( )
		local data = catherine.chat.sizePosData
		
		return data.w, data.h, data.x, data.y
	end

	function catherine.chat.Create( force )
		if ( !force and IsValid( catherine.chat.backPanel ) ) then return end
		local w, h, x, y = catherine.chat.GetSizePosData( )
		
		local base = vgui_Create( "DPanel" )
		base:SetPos( x, y )
		base:SetSize( w, h - 25 )
		base.Paint = function( ) end
		
		local history = vgui_Create( "DScrollPanel", base )
		history:Dock( FILL )
		history.VBar:SetWide( 0 )
		history.alpha = 255
		
		catherine.chat.backPanel = base
		catherine.chat.backPanel.history = history
	end
	
	function catherine.chat.Rebuild( )
		if ( IsValid( catherine.chat.backPanel ) ) then
			catherine.chat.backPanel:Remove( )
		end

		catherine.chat.Create( true )
	end
	
	function catherine.chat.SizePosFix( )
		if ( IsValid( catherine.chat.backPanel ) ) then
			local w, h, x, y = catherine.chat.GetSizePosData( )
			
			catherine.chat.backPanel:SetPos( x, y )
			catherine.chat.backPanel:SetSize( w, h - 25 )
			
			if ( IsValid( catherine.chat.backPanel.history ) ) then
				catherine.chat.backPanel.history:Dock( FILL )
			end
		end
	end
	
	function catherine.chat.IsOpened( )
		return catherine.chat.isOpened
	end
	
	local chatPostFunction = function( self, pnl )
		local text = pnl:GetText( )
		
		if ( text != "" ) then
			text = text:utf8sub( 1 )
			netstream.Start( "catherine.chat.Run", text )
			catherine.chat.chatTypedHistory[ #catherine.chat.chatTypedHistory + 1 ] = text
			
			if ( #catherine.chat.chatTypedHistory > 20 ) then
				table.remove( catherine.chat.chatTypedHistory, 1 )
			end
			
			hook.Run( "FinishChatDelay" )
		end
		
		catherine.chat.isOpened = false
		
		self:Remove( )
		self = nil
		
		hook.Run( "FinishChat" )
		
		typingText = ""
	end
	
	function catherine.chat.Show( )
		if ( hook.Run( "ShouldStartChat", catherine.pl ) == false ) then return end
		local chatBoxW, chatBoxH, chatBoxX, chatBoxY = catherine.chat.GetSizePosData( )
		
		if ( !IsValid( catherine.chat.backPanel ) ) then
			catherine.chat.Create( true )
		end
		
		catherine.chat.isOpened = true
		
		local init = false
		local self = catherine.chat.chatPanel
		local historyIndex = #catherine.chat.chatTypedHistory + 1

		catherine.chat.backPanel.PaintOver = function( pnl, w, h )
			if ( !init and typingText != "" ) then
				hook.Run( "StartChatDelay" )
				init = true
			end
			
			if ( typingText:sub( 1, 1 ) == "/" and typingText:sub( 1, 2 ) != "//" ) then
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.SetMaterial( Material( "gui/gradient_up" ) )
				surface.DrawTexturedRect( 0, 0, w, h )
				
				local commands, sub = catherine.command.GetMatchCommands( typingText )
				local chatY = chatBoxH - 25

				if ( #commands == 1 ) then
					local commandTable = commands[ 1 ]
					
					if ( commandTable ) then
						local commandText = "/" .. commandTable.command
						
						surface.SetFont( "catherine_slight25" )
						
						local tw, th = surface.GetTextSize( commandText )
						
						draw.SimpleText( commandText, "catherine_slight25", 15, chatY - 50, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
						draw.SimpleText( commandTable.syntax, "catherine_slight15", 30 + tw, chatY - 48, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
						draw.SimpleText( catherine.util.StuffLanguage( commandTable.desc ), "catherine_slight20", 15, chatY - 20, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
					end
				else
					for k, v in pairs( commands ) do
						local yPos = chatY - ( 20 * k )
						
						if ( yPos <= 10 ) then continue end
						
						draw.SimpleText( "/" .. v.command, "catherine_slight20", 15, yPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
					end
				end
				
				if ( pnl.history.alpha > 50 ) then
					pnl.history.alpha = Lerp( 0.05, pnl.history.alpha, 50 )
					pnl.history:SetAlpha( pnl.history.alpha )
				end
			else
				if ( pnl.history.alpha < 255 ) then
					pnl.history.alpha = Lerp( 0.05, pnl.history.alpha, 255 )
					pnl.history:SetAlpha( pnl.history.alpha )
				end
			end
		end

		self = vgui_Create( "EditablePanel", self )
		self:SetPos( chatBoxX, chatBoxY + chatBoxH - 25 )
		self:SetSize( chatBoxW, 25 )
		self.Paint = function( ) end
		
		local textEnt = vgui_Create( "DTextEntry", self )
		textEnt:Dock( FILL )
		textEnt.OnEnter = function( pnl )
			chatPostFunction( self, pnl )
		end
		textEnt:SetAllowNonAsciiCharacters( true )
		textEnt.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
			
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawOutlinedRect( 0, 0, w, h )
			
			pnl:DrawTextEntryText( color_black, color_black, color_black )
		end
		textEnt.OnTextChanged = function( pnl )
			typingText = pnl:GetText( )
			
			if ( typingText:utf8len( ) >= 130 ) then
				typingText = typingText:utf8sub( 1, 130 )
				
				pnl:SetText( typingText )
			end
			
			hook.Run( "ChatTextChanged", typingText )
		end
		textEnt.OnKeyCodeTyped = function( pnl, code )
			if ( code == KEY_ENTER ) then
				chatPostFunction( self, pnl )
			elseif ( code == KEY_UP ) then
				if ( historyIndex > 1 ) then
					historyIndex = historyIndex - 1
					
					local savedText = catherine.chat.chatTypedHistory[ historyIndex ]
					
					pnl:SetText( savedText )
					pnl:SetCaretPos( savedText:utf8len( ) )
				end
			elseif ( code == KEY_DOWN ) then
				if ( historyIndex < #catherine.chat.chatTypedHistory ) then
					historyIndex = historyIndex + 1
					
					local savedText = catherine.chat.chatTypedHistory[ historyIndex ]
					
					pnl:SetText( savedText )
					pnl:SetCaretPos( savedText:utf8len( ) )
				end
			end
		end
		
		self:MakePopup( )
		textEnt:RequestFocus( )
		
		self.textEnt = textEnt

		hook.Run( "StartChat" )
	end
	
	function catherine.chat.Hide( )
		if ( hook.Run( "ShouldFinishChat", catherine.pl ) == false ) then return end
		
		catherine.chat.isOpened = false
		
		local self = catherine.chat.chatPanel
		
		if ( IsValid( self ) ) then
			self:Remove( )
			self = nil
		end
		
		hook.Run( "FinishChat" )
		
		typingText = ""
	end
	
	do
		catherine.chat.Create( )
	end
end

hook.Remove( "PlayerSay", "ULXMeCheck" ) // Remove ULX ME command :>