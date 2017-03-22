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

catherine.intro = catherine.intro or {
	status = true,
	loading = true,
	errorMessage = nil,
	loadingR = 0,
	startTime = SysTime( ),
	isReloadNotify = nil,
	reloadCount = 0
}
catherine.voicePanels = { }
catherine.deathColAlpha = catherine.deathColAlpha or 0
catherine.screenResolution = catherine.screenResolution or { w = ScrW( ), h = ScrH( ) }
local entityCaches = { }
local nextEntityCacheWork = RealTime( )
local lastEntity = nil
local toscreen = FindMetaTable( "Vector" ).ToScreen
local gradientUpMat = Material( "gui/gradient_up" )
local gradientDownMat = Material( "gui/gradient_down" )
local gradientLeftMat = Material( "gui/gradient" )
local gradientCenterMat = Material( "gui/center_gradient" )
local math_app = math.Approach
local hook_run = hook.Run
local trace_line = util.TraceLine

function GM:InitPostEntity( )
	catherine.pl = LocalPlayer( )
	catherine.intro.startTime = SysTime( )
end

function GM:PostDrawViewModel( viewMdl, pl, wep )
	if ( wep.UseHands or !wep:IsScripted( ) ) then
		local ent = pl:GetHands( )
		
		if ( IsValid( ent ) ) then
			local info = player_manager.TranslatePlayerHands( player_manager.TranslateToPlayerModelName( pl:GetModel( ) ) )
			
			if ( info ) then
				if ( ent:GetModel( ) != info.model ) then
					ent:SetModel( info.model )
				end
				
				if ( ent:GetSkin( ) != info.skin ) then
					ent:SetSkin( info.skin )
				end
				
				ent:SetBodyGroups( info.body )
			end
			
			ent:DrawModel( ) 
		end
	end
end

function GM:Initialize( )
	CAT_CONVAR_ADMIN_ESP = CreateClientConVar( "cat_convar_adminesp", "1", true, true )
	CAT_CONVAR_ITEM_ESP = CreateClientConVar( "cat_convar_itemesp", "0", true, true )
	CAT_CONVAR_ALWAYS_ADMIN_ESP = CreateClientConVar( "cat_convar_alwaysadminesp", "0", true, true )
	CAT_CONVAR_HUD = CreateClientConVar( "cat_convar_hud", "1", true, true )
	CAT_CONVAR_BAR = CreateClientConVar( "cat_convar_bar", "1", true, true )
	CAT_CONVAR_CHAT_TIMESTAMP = CreateClientConVar( "cat_convar_chat_timestamp", "1", true, true )
	CAT_CONVAR_HINT = CreateClientConVar( "cat_convar_hint", "1", true, true )
end

function GM:HUDDrawScoreBoard( )
	if ( !catherine.intro.status ) then return end
	local w, h = ScrW( ), ScrH( )
	local data = catherine.intro
	
	if ( data.loading ) then
		data.loadingR = data.loadingR + 15
	else
		data.status = false
		
		if ( catherine.question.CanQuestion( ) ) then
			catherine.question.Start( )
		else
			catherine.character.SetMenuActive( true )
		end
	end

	if ( !data.isReloadNotify and SysTime( ) - data.startTime > 10 ) then
		data.isReloadNotify = true
		data.reloadCount = data.reloadCount + 1
		
		if ( data.reloadCount > 3 ) then
			surface.PlaySound( "buttons/button2.wav" )
			
			data.isReloadNotify = true
			data.isRetryConnect = true
			data.startTime = SysTime( )
			
			timer.Simple( 5, function( )
				RunConsoleCommand( "retry" )
			end )
		else
			timer.Simple( 5, function( )
				netstream.Start( "catherine.player.Initialize.IsRetry" )
				
				data.isReloadNotify = false
				data.startTime = SysTime( )
			end )
		end
	end
	
	if ( catherine.character.IsCustomBackground( ) ) then
		catherine.util.BlurDraw( 0, 0, w, h, 10 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
		
		local frameworkLogo = Material( catherine.configs.frameworkLogo, "smooth" )
		
		if ( frameworkLogo and !frameworkLogo:IsError( ) ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( frameworkLogo )
			surface.DrawTexturedRect( w / 2 - 212 / 2, h / 2 - 212 / 2, 212, 212 )
		end
	else
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		
		surface.SetDrawColor( 90, 90, 90, 255 )
		surface.SetMaterial( gradientDownMat )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		local frameworkLogo = Material( catherine.configs.frameworkLogo, "smooth" )
		
		if ( frameworkLogo and !frameworkLogo:IsError( ) ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( frameworkLogo )
			surface.DrawTexturedRect( w / 2 - 212 / 2, h / 2 - 212 / 2, 212, 212 )
		end
	end
	
	if ( data.isReloadNotify ) then
		if ( data.isRetryConnect ) then
			surface.SetFont( "catherine_lightUI20" )
			local tw, th = surface.GetTextSize( LANG( "Basic_Error_LoadCantRetry" ) )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 0, 0, 255 )
			catherine.geometry.DrawCircle( ( w / 2 - 10 / 2 - tw / 2 ) - 20, h - 30, 7, 5, 0, 360, 100 )
			
			draw.SimpleText( LANG( "Basic_Error_LoadCantRetry" ), "catherine_lightUI20", w / 2, h - 30, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			surface.SetFont( "catherine_lightUI20" )
			local tw, th = surface.GetTextSize( LANG( "Basic_Error_LoadTimeoutWait", data.reloadCount ) )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 0, 0, 255 )
			catherine.geometry.DrawCircle( ( w / 2 - 10 / 2 - tw / 2 ) - 20, h - 30, 7, 5, 0, 360, 100 )
			
			draw.SimpleText( LANG( "Basic_Error_LoadTimeoutWait", data.reloadCount ), "catherine_lightUI20", w / 2, h - 30, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	else
		if ( data.errorMessage ) then
			surface.SetFont( "catherine_lightUI20" )
			local tw, th = surface.GetTextSize( data.errorMessage )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 0, 0, 255 )
			catherine.geometry.DrawCircle( ( w / 2 - 10 / 2 - tw / 2 ) - 20, h - 30, 7, 5, 0, 360, 100 )
			
			draw.SimpleText( data.errorMessage, "catherine_lightUI20", w / 2, h - 30, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			surface.SetFont( "catherine_lightUI20" )
			local tw, th = surface.GetTextSize( LANG( "Basic_Info_Loading" ) )
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, 255 )
			catherine.geometry.DrawCircle( ( w / 2 - 10 / 2 - tw / 2 ) - 20, h - 30, 7, 5, data.loadingR, 70, 100 )
			
			draw.SimpleText( LANG( "Basic_Info_Loading" ), "catherine_lightUI20", w / 2, h - 30, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	end
end

if ( catherine.configs.enable_customVoiceHeadNotify ) then
	function GM:DrawVoiceHeadNotify( pl )
		if ( !pl:IsSpeaking( ) ) then return end
		
		local lp = catherine.pl
		
		if ( pl == lp ) then return end
		
		local a = catherine.util.GetAlphaFromDistance( lp:GetPos( ), pl:GetPos( ), catherine.configs.voiceRange )
		
		if ( a <= 0 ) then return end
		
		local index = pl:LookupBone( "ValveBiped.Bip01_Head1" )
		
		if ( index ) then
			local pos = pl:GetBonePosition( index )
			
			if ( pos ) then
				if ( !pl.CAT_voiceVolume or !pl.CAT_voiceColor ) then
					pl.CAT_voiceVolume = 0
					pl.CAT_voiceColor = Color( 255, 255, 255 )
				end
				
				if ( !pl.CAT_voiceProfileImageVGUI or !IsValid( pl.CAT_voiceProfileImageVGUI ) ) then
					local panel = vgui.Create( "AvatarImage" )
					panel:SetSize( 32, 32 )
					panel:SetPos( 0 - 19, 4 )
					panel:SetPlayer( pl, 128 )
					panel:SetPaintedManually( true )
					panel:SetAlpha( a )
					
					pl.CAT_voiceProfileImageVGUI = panel
				else
					pl.CAT_voiceProfileImageVGUI:SetPos( 0 - 19, 4 )
					pl.CAT_voiceProfileImageVGUI:SetPlayer( pl, 128 )
					pl.CAT_voiceProfileImageVGUI:SetAlpha( a )
				end
				
				pl.CAT_voiceVolume = Lerp( 0.05, pl.CAT_voiceVolume, pl:VoiceVolume( ) * 50 )
				
				local volume = math.Round( pl.CAT_voiceVolume )
				
				if ( volume <= 18 ) then
					pl.CAT_voiceColor.r = Lerp( 0.08, pl.CAT_voiceColor.r, 255 )
					pl.CAT_voiceColor.g = Lerp( 0.08, pl.CAT_voiceColor.g, 255 )
					pl.CAT_voiceColor.h = Lerp( 0.08, pl.CAT_voiceColor.b, 255 )
				elseif ( volume > 18 and volume <= 23 ) then
					pl.CAT_voiceColor.r = Lerp( 0.08, pl.CAT_voiceColor.r, 255 )
					pl.CAT_voiceColor.g = Lerp( 0.08, pl.CAT_voiceColor.g, 255 )
					pl.CAT_voiceColor.h = Lerp( 0.08, pl.CAT_voiceColor.b, 150 )
				elseif ( volume > 23 ) then
					pl.CAT_voiceColor.r = Lerp( 0.08, pl.CAT_voiceColor.r, 255 )
					pl.CAT_voiceColor.g = Lerp( 0.08, pl.CAT_voiceColor.g, 150 )
					pl.CAT_voiceColor.h = Lerp( 0.08, pl.CAT_voiceColor.b, 150 )
				end
				
				pos = pos + Vector( 0, 0, 25 )
				local ang = lp:EyeAngles( )
				
				pos = pos + ang:Up( )
				ang:RotateAroundAxis( ang:Forward( ), 90 )
				ang:RotateAroundAxis( ang:Right( ), 90 )
				
				cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.15 )
					draw.RoundedBox( 0, 0 - 47 / 2, 0, 47, 40, Color( 20, 20, 20, a / 2 ) )
					draw.RoundedBox( 0, 17, 40 - pl.CAT_voiceVolume, 7, pl.CAT_voiceVolume, Color( pl.CAT_voiceColor.r, pl.CAT_voiceColor.g, pl.CAT_voiceColor.b, a ) )
					
					if ( IsValid( pl.CAT_voiceProfileImageVGUI ) ) then
						pl.CAT_voiceProfileImageVGUI:PaintManual( )
					end
				cam.End3D2D( )
			end
		end
	end
end

function GM:PostPlayerDraw( pl )
	if ( catherine.configs.enable_customVoiceHeadNotify ) then
		self:DrawVoiceHeadNotify( pl )
	end
end

function GM:HUDShouldDraw( name )
	for k, v in pairs( catherine.hud.GetBlockModules( ) ) do
		if ( v == name ) then
			return false
		end
	end
	
	return true
end

function GM:ContextMenuOpen( )
	return catherine.pl:IsAdmin( )
end

function GM:OnReloaded( )

end

function GM:AddHint( name, delay )

end

function GM:AddNotify( message, _, time )
	if ( message:sub( 1, 6 ) == "#Hint_" ) then return end
	
	catherine.notify.Add( message, time, false )
end

function GM:HUDPaintBackground( )
	local pl = catherine.pl
	
	if ( !pl:IsAdmin( ) or ( GetConVarString( "cat_convar_alwaysadminesp" ) == "0" and !pl:IsNoclipping( ) ) or GetConVarString( "cat_convar_adminesp" ) == "0" ) then return end
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( pl == v ) then continue end
		local pos = toscreen( v:LocalToWorld( v:OBBCenter( ) + Vector( 0, 0, 50 ) ) )

		draw.SimpleText( v:Name( ), "catherine_outline15", pos.x, pos.y, team.GetColor( v:Team( ) ), 1, 1 )

		hook.Run( "AdminESPDrawed", pl, v, pos.x, pos.y )
	end
	
	if ( GetConVarString( "cat_convar_itemesp" ) == "1" ) then
		if ( !catherine.itemESPName ) then
			catherine.itemESPName = LANG( "Basic_ItemESP_Name" )
		end
		
		for k, v in pairs( ents.FindByClass( "cat_item" ) ) do
			if ( !IsValid( v ) ) then continue end
			local pos = toscreen( v:LocalToWorld( v:OBBCenter( ) ) )
			
			draw.SimpleText( catherine.itemESPName .. " - " .. ( v:GetItemUniqueID( ) or "Unknown" ) .. "", "catherine_outline15", pos.x, pos.y, Color( 0, 255, 255, 255 ), 1, 1 )
		end
	end
end

function GM:LanguageChanged( )
	catherine.itemESPName = LANG( "Basic_ItemESP_Name" )
end

function GM:SpawnMenuOpen( )
	return catherine.pl:IsAdmin( ) and catherine.pl:IsCharacterLoaded( )
end

function GM:CalcView( pl, pos, ang, fov )
	local viewData = self.BaseClass.CalcView( self.BaseClass, pl, pos, ang, fov )
	
	local ent = Entity( pl:GetNetVar( "ragdollIndex", 0 ) )
	
	if ( IsValid( ent ) and ent:GetClass( ) == "prop_ragdoll" ) then
		local index = ent:LookupAttachment( "eyes" )
		
		if ( index ) then
			local data = ent:GetAttachment( index )
			
			if ( data ) then
				return {
					origin = data.Pos,
					angles = data.Ang
				}
			end
		end
	end
	
	return self.BaseClass.CalcView( self.BaseClass, pl, pos, ang, fov )
end

local serverIconMat = Material( "icon16/server.png" )

function GM:OnPlayerChat( pl, text, teamOnly, isDead )
	if ( !IsValid( pl ) ) then
		chat.AddText( serverIconMat, Color( 150, 150, 150 ), LANG( "Chat_Str_Console" ), Color( 255, 255, 255 ), " : ".. text )
	end
	
	return true
end

function GM:ChatText( index, name, text )
	if ( index == 0 ) then
		chat.AddText( serverIconMat, Color( 255, 255, 255 ), text )
	end
end

function GM:ShouldDrawBar( pl )
	return !IsValid( catherine.vgui.question ) and pl:Alive( ) and pl:IsCharacterLoaded( )
end

function GM:ShouldDrawHint( pl, hintTable )

end

function GM:GetChatIcon( pl, chatClass, text )

end

function GM:PostDrawTranslucentRenderables( depth, skybox )
	if ( depth or skybox ) then return end
	
	for k, v in pairs( ents.FindInSphere( catherine.pl:GetPos( ), 256 ) ) do
		if ( !IsValid( v ) or !v:IsDoor( ) or v:GetNoDraw( ) or catherine.door.IsDoorDisabled( v ) ) then continue end
		if ( hook.Run( "ShouldDrawDoorText", v ) == false ) then continue end
		
		hook.Run( "DrawDoorText", v )
	end
end

function GM:GetCharacterPanelLoadModel( characterDatas )
	return characterDatas._model
end

function GM:Think( )
	local pl = catherine.pl
	
	if ( IsValid( pl ) and pl:IsCharacterLoaded( ) ) then
		local hp, maxHP = pl:Health( ), pl:GetMaxHealth( )
		
		if ( hp <= 30 ) then
			if ( pl:Alive( ) ) then
				if ( !self.heartbeatEnt ) then
					self.heartbeatEnt = CreateSound( pl, "player/heartbeat1.wav" )
				end
				
				self.heartbeatEnt:Play( )
			else
				if ( self.heartbeatEnt ) then
					if ( !self.heartbeatEntFadeOuting ) then
						self.heartbeatEntFadeOuting = true
						self.heartbeatEnt:FadeOut( 3 )
						
						timer.Simple( 3, function( )
							if ( self.heartbeatEnt ) then
								self.heartbeatEnt:Stop( )
								self.heartbeatEnt = nil
								self.heartbeatEntFadeOuting = nil
							end
						end )
					end
				end
			end
		else
			if ( self.heartbeatEnt ) then
				if ( !self.heartbeatEntFadeOuting ) then
					self.heartbeatEntFadeOuting = true
					self.heartbeatEnt:FadeOut( 3 )
					
					timer.Simple( 3, function( )
						if ( self.heartbeatEnt ) then
							self.heartbeatEnt:Stop( )
							self.heartbeatEnt = nil
							self.heartbeatEntFadeOuting = nil
						end
					end )
				end
			end
		end
	end
end

function GM:PostInitLoadCharacterList( pl, pnl, characterDatas )
	local modelPanel = pnl.model
	
	if ( IsValid( modelPanel ) and IsValid( modelPanel.Entity ) ) then
		if ( characterDatas._charVar and characterDatas._charVar[ "skin" ] ) then
			modelPanel.Entity:SetSkin( tonumber( characterDatas._charVar[ "skin" ] ) or 0 )
		end
		
		if ( characterDatas._inv ) then
			for k, v in pairs( characterDatas._inv ) do
				local itemTable = catherine.item.FindByID( k )
				
				if ( !itemTable ) then continue end
				if ( !itemTable.isBodygroupCloth or !v.itemData[ "wearing" ] ) then continue end
				
				modelPanel.Entity:SetBodygroup( itemTable.bodyGroup, itemTable.bodyGroupSubModelIndex )
			end
		end
	end
end

function GM:PlayerBindPress( pl, code, pressed )
	if ( code:find( "messagemode" ) and pressed ) then
		catherine.chat.Show( )
		
		return true
	end
	
	if ( !pl:GetNetVar( "gettingup" ) and pl:IsRagdolled( ) and !pl:GetNetVar( "isForceRagdolled" ) and code:find( "+jump" ) and pressed ) then
		catherine.command.Run( "&uniqueID_charGetUp" )
		
		return true
	end
end

function GM:DrawDoorText( ent )
	local a = catherine.util.GetAlphaFromDistance( ent:GetPos( ), catherine.pl:GetPos( ), 256 )
	
	if ( a <= 0 ) then return end
	
	local data = catherine.door.CalcDoorTextPos( ent )
	local title = ent:GetNetVar( "title", LANG( "Door_UI_Default" ) )
	local desc = catherine.door.GetDetailString( ent )
	
	surface.SetFont( "catherine_outline35" )
	
	local titleW, titleH = surface.GetTextSize( title )
	local descW, descH = surface.GetTextSize( desc )
	local longW = descW > titleW and descW or titleW
	//local longH = titleH + descScale + 8 // We don't need this :)
	local scale = math.abs( ( data.w * 0.8 ) / longW )
	local titleScale = math.min( scale, 0.1 )
	local descScale = math.min( scale, 0.03 )
	local pos, posBack = data.pos, data.posBack
	local ang, angBack = data.ang, data.angBack
	
	cam.Start3D2D( pos, ang, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 3 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 3 )
		
		draw.SimpleText( title, "catherine_outline35", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( posBack, angBack, titleScale )
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 0 - 40, longW, 3 )
		
		surface.SetDrawColor( 255, 255, 255, a )
		surface.SetMaterial( gradientCenterMat )
		surface.DrawTexturedRect( 0 - longW / 2, 80, longW, 3 )
		
		draw.SimpleText( title, "catherine_outline35", 0, 0, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( pos, ang, descScale )
		draw.SimpleText( desc, "catherine_outline50", 0, 140, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
	
	cam.Start3D2D( posBack, angBack, descScale )
		draw.SimpleText( desc, "catherine_outline50", 0, 140, Color( 235, 235, 235, a ), 1, 1 )
	cam.End3D2D( )
end

function GM:StartChatDelay( )
	netstream.Start( "catherine.IsTyping", true )
end

function GM:FinishChatDelay( )
	netstream.Start( "catherine.IsTyping", false )
end

function GM:FinishChat( )
	if ( IsValid( catherine.pl ) and catherine.pl:IsChatTyping( ) ) then
		netstream.Start( "catherine.IsTyping", false )
	end
end

function GM:DrawEntityTargetID( pl, ent, a )
	if ( ent:IsPlayer( ) or ent:GetClass( ) == "prop_ragdoll" ) then
		if ( ent:GetNetVar( "noDrawOriginal" ) == true or ( ent:IsPlayer( ) and ent:IsRagdolled( ) ) ) then return end
		
		local entPlayer = ent:GetClass( ) == "prop_ragdoll" and ent:GetNetVar( "player" ) or ent
		
		if ( !IsValid( entPlayer ) or !entPlayer:IsPlayer( ) ) then return end
		
		local index = ent:LookupBone( "ValveBiped.Bip01_Head1" )
		
		if ( index ) then
			local pos = toscreen( ent:GetBonePosition( index ) )
			local x, y = pos.x, pos.y - 100
			local name, desc = hook.Run( "GetPlayerInformation", pl, entPlayer, true )
			local col = team.GetColor( entPlayer:Team( ) )
			
			draw.SimpleText( name, "catherine_outline25", x, y, Color( col.r, col.g, col.b, a ), 1, 1 )
			y = y + 25
			
			local descTexts = catherine.util.GetWrapTextData( desc, ScrW( ) / 2, "catherine_outline15" )
			
			for k, v in pairs( descTexts ) do
				draw.SimpleText( v, "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
				y = y + 20
			end
			
			hook.Run( "PlayerInformationDraw", pl, entPlayer, x, y, a )
		end
	elseif ( ent:IsWeapon( ) ) then
		local pos = toscreen( ent:LocalToWorld( ent:OBBCenter( ) ) )
		local x, y = pos.x, pos.y
		
		draw.SimpleText( ent:GetPrintName( ), "catherine_outline25", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 25
		
		draw.SimpleText( LANG( "Weapon_MapEntity_Desc" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
	end
end

function GM:PlayerInformationDraw( pl, target, x, y, a )
	if ( !target:Alive( ) ) then
		draw.SimpleText( LANG( "Player_Message_Dead_HUD" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
		return
	end
	
	if ( target:IsRagdolled( ) ) then
		draw.SimpleText( LANG( "Player_Message_Ragdolled_HUD" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
	
	if ( target:IsTied( ) ) then
		draw.SimpleText( LANG( "Player_Message_UnTie" ), "catherine_outline15", x, y, Color( 255, 255, 255, a ), 1, 1 )
		y = y + 20
	end
end

function GM:GetUnknownTargetName( pl, target )
	return LANG( "Recognize_UI_Unknown" )
end

function GM:EntityCacheWork( pl )
	local realTime = RealTime( )
	local ignoreDefault = false
	
	if ( nextEntityCacheWork <= realTime ) then
		for k, v in pairs( ents.FindInSphere( pl:GetPos( ), 160 ) ) do
			if ( IsValid( v ) and v:IsPlayer( ) and v:Alive( ) and !v:IsRagdolled( ) and v:InVehicle( ) and !v:GetNoDraw( ) and v:IsSolid( ) ) then
				if ( pl:GetEyeTraceNoCursor( ).HitPos:Distance( v:GetPos( ) ) <= 80 ) then
					ignoreDefault = true
					lastEntity = v
					
					if ( IsValid( lastEntity ) ) then
						entityCaches[ lastEntity ] = true
					end
				else
					if ( IsValid( lastEntity ) and lastEntity == v ) then
						lastEntity = nil
					end
				end
			end
		end
		
		if ( !ignoreDefault ) then
			local data = { }
			data.start = pl:GetShootPos( )
			data.endpos = data.start + pl:GetAimVector( ) * 160
			data.filter = pl
			
			lastEntity = trace_line( data ).Entity
			
			if ( IsValid( lastEntity ) ) then
				entityCaches[ lastEntity ] = true
			end
		end
		
		nextEntityCacheWork = realTime + 0.5
	end
	
	for k, v in pairs( entityCaches ) do
		if ( !IsValid( k ) ) then
			entityCaches[ k ] = nil
			continue
		end
		
		if ( lastEntity != k ) then
			entityCaches[ k ] = false
		end
		
		local targetAlpha = v and 255 or 0
		local a = math_app( k.CAT_entityCacheAlpha or 0, targetAlpha, FrameTime( ) * 120 )
		
		if ( a > 0 and hook_run( "ShouldDrawEntityTargetID", pl, k, a ) != true ) then
			if ( k.DrawEntityTargetID ) then
				k:DrawEntityTargetID( pl, k, a )
			else
				hook_run( "DrawEntityTargetID", pl, k, a )
			end
		end
		
		k.CAT_entityCacheAlpha = a
		
		if ( targetAlpha == 0 and a == 0 ) then
			entityCaches[ k ] = nil
		end
	end
end

local getCharVar = catherine.character.GetCharVar

function GM:HUDPaint( )
	if ( IsValid( catherine.vgui.character ) or catherine.intro.status ) then return end
	local pl = catherine.pl
	
	if ( getCharVar( pl, "charBanned" ) ) then
		local scrW, scrH = ScrW( ), ScrH( )
		
		draw.RoundedBox( 0, 0, 0, scrW, scrH, Color( 255, 255, 255, 255 ) )
		
		surface.SetDrawColor( 200, 200, 200, 255 )
		surface.SetMaterial( gradientUpMat )
		surface.DrawTexturedRect( 0, 0, scrW, scrH )
		
		draw.SimpleText( ":(", "catherine_normal50", scrW / 2, scrH / 2, Color( 0, 0, 0, 255 ), 1, 1 )
		draw.SimpleText( LANG( "Character_Notify_CharBanned" ), "catherine_normal25", scrW / 2, scrH / 2 + 60, Color( 0, 0, 0, 255 ), 1, 1 )
		
		return
	end
	
	hook_run( "HUDBackgroundDraw" )
	catherine.hud.Draw( pl )
	catherine.bar.Draw( pl )
	catherine.hint.Draw( pl )
	hook_run( "HUDDraw" )
	
	if ( pl:Alive( ) and pl:IsCharacterLoaded( ) ) then
		hook_run( "EntityCacheWork", pl )
	end
	
	hook_run( "HUDDrawTop" )
end

function GM:HUDDrawTop( )
	if ( !catherine.util.dermaMenuTitle ) then return end
	local dermaMenuData = catherine.util.dermaMenuTitle
	
	if ( IsValid( dermaMenuData.menuPanel ) ) then
		local panel = dermaMenuData.menuPanel
		local w, h = panel:GetSize( )
		local x, y = panel:GetPos( )
		
		draw.RoundedBox( 0, x - 2, y - 2, w + 4, h + 4, Color( 255, 255, 255, 255 ) )
		draw.SimpleText( dermaMenuData.title or "", "catherine_lightUIoutline20", x + w / 2, y - 20, Color( 255, 255, 255, 255 ), 1, 1 )
	else
		catherine.util.dermaMenuTitle = nil
	end
end

function GM:PostRenderVGUI( )
	if ( hook.Run( "ShouldDrawNotify" ) == false or IsValid( catherine.vgui.character ) ) then return end
	
	catherine.notify.Draw( )
end

function GM:MainMenuJoined( )

end

function GM:MainMenuExited( )

end

function GM:CalcViewModelView( wep, viewMdl, oldEyePos, oldEyeAngles, eyePos, eyeAng )
	if ( !IsValid( wep ) ) then return end
	local pl = catherine.pl
	local fraction = ( pl.CAT_wepRaisedFraction or 0 ) / 100
	local lowerAng = wep.LowerAngles or Angle( 30, -30, -25 )
	
	eyeAng:RotateAroundAxis( eyeAng:Up( ), lowerAng.p * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Forward( ), lowerAng.y * fraction )
	eyeAng:RotateAroundAxis( eyeAng:Right( ), lowerAng.r * fraction )
	
	pl.CAT_wepRaisedFraction = Lerp( FrameTime( ) * 2, pl.CAT_wepRaisedFraction or 0, pl:GetWeaponRaised( ) and 0 or 100 )
	
	viewMdl:SetAngles( eyeAng )
	
	return oldEyePos, eyeAng
end

function GM:ShouldOpenScoreboard( pl )

end

function GM:ScoreboardPlayerListPanelPaint( pl, target, w, h )
	if ( target:SteamID( ) == "STEAM_0:1:25704824" ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( "icon16/award_star_gold_1.png" ) )
		surface.DrawTexturedRect( w - 40, h / 2 - 16 / 2, 16, 16 )
		
		draw.SimpleText( LANG( "Scoreboard_UI_Author" ), "catherine_normal15", w - 50, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	end
end

function GM:ScoreboardPlayerOption( pl, target )
	local menu = DermaMenu( )
	
	menu:AddOption( LANG( "Scoreboard_PlayerOption01_Str" ), function( )
		gui.OpenURL( "http://steamcommunity.com/profiles/" .. target:SteamID64( ) )
	end )
	
	if ( pl != target ) then
		menu:AddOption( LANG( "Scoreboard_PlayerOption08_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption08_Q" ), "", function( val )
					catherine.command.Run( "&uniqueID_pm", target:Name( ), val )
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
	end
	
	if ( pl:IsSuperAdmin( ) ) then
		local whitelistGive = menu:AddSubMenu( LANG( "Scoreboard_PlayerOption03_Str" ) )
		
		for k, v in pairs( catherine.faction.GetAll( ) ) do
			if ( !v.isWhitelist ) then continue end
			
			whitelistGive:AddOption( catherine.util.StuffLanguage( v.name ), function( )
				catherine.command.Run( "&uniqueID_plyGiveWhitelist", target:Name( ), v.uniqueID )
			end ):SetToolTip( catherine.util.StuffLanguage( v.desc ) )
		end
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption05_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption05_Q" ), "", function( val )
					catherine.command.Run( "&uniqueID_flagGive", target:Name( ), val )
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption06_Str" ), function( )
			netstream.Start( "catherine.flag.Scoreboard_PlayerOption06", target )
		end )
	end
	
	if ( pl:IsAdmin( ) ) then
		menu:AddOption( LANG( "Scoreboard_PlayerOption04_Str" ), function( )
			Derma_Query( LANG( "Scoreboard_PlayerOption04_Q" ), "", LANG( "Basic_UI_OK" ), function( )
					catherine.command.Run( "&uniqueID_charBan", target:Name( ) )
				end, LANG( "Basic_UI_NO" ), function( ) end
			)
		end )
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption02_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption02_Q" ), target:Name( ), function( val )
					catherine.command.Run( "&uniqueID_charSetName", target:Name( ), val )
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
		
		menu:AddOption( LANG( "Scoreboard_PlayerOption09_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption09_Q" ), "0", function( val )
					Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption09_Q2" ), "No reason.", function( val2 )
							netstream.Start( "catherine.BAN", {
								target,
								val,
								val2
							} )
						end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
					)
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
	end
	
	if ( pl:HasFlag( "i" ) ) then
		menu:AddOption( LANG( "Scoreboard_PlayerOption07_Str" ), function( )
			Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption07_Q1" ), "", function( val )
					Derma_StringRequest( "", LANG( "Scoreboard_PlayerOption07_Q2" ), "1", function( val2 )
							catherine.command.Run( "&uniqueID_itemGive", target:Name( ), val, val2 or 1 )
						end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
					)
				end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
			)
		end )
	end
	
	menu:Open( )
end

function GM:GetFrameworkInformation( )
	return {
		title = GAMEMODE.Name,
		desc = GAMEMODE.Desc,
		author = LANG( "Basic_Framework_Author", GAMEMODE.Author )
	}
end

function GM:GetSchemaInformation( )
	return {
		title = GAMEMODE.Name,
		desc = GAMEMODE.Desc,
		author = LANG( "Basic_Framework_Author", GAMEMODE.Author )
	}
end

function GM:ScoreboardShow( )
	if ( !catherine.pl:IsCharacterLoaded( ) ) then return end
	
	if ( getCharVar( catherine.pl, "charBanned" ) ) then
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Remove( )
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		else
			catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		end
	else
		if ( IsValid( catherine.vgui.menu ) and !catherine.vgui.menu:IsVisible( ) ) then
			catherine.vgui.menu:Show( )
			gui.EnableScreenClicker( false )
		else
			catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
			gui.EnableScreenClicker( true )
		end
	end
end

function GM:PostRenderScreenColor( pl )
	if ( pl:Alive( ) ) then
		catherine.deathColAlpha = Lerp( 0.03, catherine.deathColAlpha, 1 )
	else
		catherine.deathColAlpha = Lerp( 0.03, catherine.deathColAlpha, 0 )
	end
	
	return {
		colour = catherine.deathColAlpha
	}
end

function GM:RenderScreenspaceEffects( )
	local data = hook.Run( "PostRenderScreenColor", catherine.pl ) or { }
	
	local tab = { }
	tab[ "$pp_colour_addr" ] = data.addr or 0
	tab[ "$pp_colour_addg" ] = data.addg or 0
	tab[ "$pp_colour_addb" ] = data.addb or 0
	tab[ "$pp_colour_brightness" ] = data.brightness or 0
	tab[ "$pp_colour_contrast" ] = data.contrast or 1
	tab[ "$pp_colour_colour" ] = data.colour or 0.9
	tab[ "$pp_colour_mulr" ] = data.mulr or 0
	tab[ "$pp_colour_mulg" ] = data.mulg or 0
	tab[ "$pp_colour_mulb" ] = data.mulb or 0
	
	DrawColorModify( tab )
	
	if ( catherine.util.motionBlur ) then
		local motionBlurData = catherine.util.motionBlur
		
		if ( motionBlurData.status == false and motionBlurData.fadeTime ) then
			motionBlurData.drawAlpha = Lerp( motionBlurData.fadeTime, motionBlurData.drawAlpha, 0 )
			
			if ( math.Round( motionBlurData.drawAlpha ) <= 0 ) then
				catherine.util.motionBlur = nil
				return
			end
		end
		
		DrawMotionBlur( motionBlurData.addAlpha, motionBlurData.drawAlpha, motionBlurData.delay )
	end
end

function GM:CharacterMenuJoined( pl )
	catherine.character.SendPlayerCharacterListRequest( )
	
	if ( IsValid( catherine.chat.backPanel ) ) then
		catherine.chat.backPanel:SetVisible( false )
	end
	
	timer.Simple( 0, function( )
		if ( IsValid( catherine.vgui.character ) and !steamworks.IsSubscribed( "491904294" ) ) then
			vgui.Create( "catherine.vgui.resource", catherine.vgui.character )
		end
	end )
end

function GM:CharacterMenuExited( pl )
	if ( IsValid( catherine.chat.backPanel ) ) then
		catherine.chat.backPanel:SetVisible( true )
	end
end

function GM:AddRPInformation( pnl, data, pl )
	data[ #data + 1 ] = LANG( "Cash_UI_HasStr", catherine.cash.GetCompleteName( catherine.cash.Get( pl ) ) )
end

function GM:ScreenResolutionFix( )
	catherine.hud.WelcomeIntroInitialize( true )
	
	catherine.chat.SetSizePosData( ScrW( ) * 0.5, ScrH( ) * 0.3, 5, ScrH( ) - ( ScrH( ) * 0.3 ) - 5 )
	catherine.chat.SizePosFix( )
	
	catherine.menu.Rebuild( )
end

function GM:ShouldStartChat( pl )
	return pl:IsCharacterLoaded( )
end

function GM:ShouldFinishChat( pl )

end

function GM:PopulateToolMenu( )
	local toolGun = weapons.GetStored( "gmod_tool" )
	
	for k, v in pairs( catherine.tool.GetAll( ) ) do
		toolGun.Tool[ v.Mode ] = v
		
		if ( v.AddToMenu != false ) then
			spawnmenu.AddToolMenuOption( v.Tab or "Main",
				v.Category or "Category",
				k,
				v.Name or "#" .. k,
				v.Command or "gmod_tool " .. k,
				v.ConfigName or k,
				v.BuildCPanel
			)
		end
		
		language.Add( "tool." .. v.UniqueID .. ".name", v.Name )
		language.Add( "tool." .. v.UniqueID .. ".desc", v.Desc )
		language.Add( "tool." .. v.UniqueID .. ".0", v.HelpText )
	end
end

timer.Create( "Catherine.timer.ScreenResolutionCheck", 3, 0, function( )
	if ( catherine.screenResolution.w != ScrW( ) or catherine.screenResolution.h != ScrH( ) ) then
		hook.Run( "ScreenResolutionFix" )
		
		catherine.screenResolution = {
			w = ScrW( ),
			h = ScrH( )
		}
	end
end )

timer.Remove( "HintSystem_Annoy1" )
timer.Remove( "HintSystem_Annoy2" )
timer.Remove( "HintSystem_OpeningMenu" )

netstream.Hook( "catherine.ShowHelp", function( )
	if ( IsValid( catherine.vgui.information ) ) then
		catherine.vgui.information:Close( )
	else
		catherine.vgui.information = vgui.Create( "catherine.vgui.information" )
	end
end )

netstream.Hook( "catherine.SetModel", function( data )
	local pl = data[ 1 ]
	local model = data[ 2 ]
	
	if ( IsValid( pl ) and model ) then
		pl:SetModel( model )
	end
end )

netstream.Hook( "catherine.sendConfigTable", function( data )
	local ui = catherine.vgui.system
	
	if ( IsValid( ui ) and IsValid( ui.configPanel ) ) then
		ui.configPanel:RefreshConfigs( data )
	end
end )

netstream.Hook( "catherine.introStop", function( )
	catherine.intro.status = false
end )

netstream.Hook( "catherine.loadingFinished", function( )
	catherine.intro.loading = false
end )

netstream.Hook( "catherine.loadingError", function( data )
	catherine.intro.loading = true
	catherine.intro.errorMessage = data
	
	MsgC( Color( 255, 0, 0 ), "[CAT ERROR] " .. data .. "\n" )
end )