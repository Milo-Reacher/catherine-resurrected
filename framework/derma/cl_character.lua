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

local PANEL = { }

function PANEL:Init( )
	hook.Run( "CharacterMenuJoined", catherine.pl )
	
	catherine.vgui.character = self
	
	self.player = catherine.pl
	self.w, self.h = ScrW( ), ScrH( )
	self.blurAmount = 0
	self.mainButtons = { }
	self.mode = 0
	self.logoA = 255
	
	local layoutX, layoutY = self.w * 0.1, self.h * 0.3
	local loadingR = 0
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:MakePopup( )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.3, 0 )
	self.Paint = function( pnl, w, h )
		if ( self.mode == 0 ) then
			self.logoA = math.Approach( self.logoA, 255, 10 )
		else
			self.logoA = math.Approach( self.logoA, 0, 10 )
		end
		
		if ( !catherine.character.IsCustomBackground( ) ) then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 255 ) )
			
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.SetMaterial( Material( "gui/gradient_down" ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		else
			if ( catherine.configs.enableCharacterPanelBlur ) then
				if ( self.closing ) then
					self.blurAmount = Lerp( 0.03, self.blurAmount, 0 )
				else
					self.blurAmount = Lerp( 0.03, self.blurAmount, 3 )
				end
				
				draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 150 ) )
				catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
			end
		end
		
		local schemaLogo = Material( catherine.configs.schemaLogo, "smooth" )
		
		if ( schemaLogo and !schemaLogo:IsError( ) ) then
			surface.SetDrawColor( 255, 255, 255, pnl.logoA )
			surface.SetMaterial( schemaLogo )
			surface.DrawTexturedRect( layoutX, layoutY, 512, 90 )
		end
		
		draw.SimpleText( catherine.GetVersion( ) .. " " .. catherine.GetBuild( ), "catherine_normal15", 10, h - 20, Color( 255, 255, 255, self.logoA ), TEXT_ALIGN_LEFT, 1 )
		
		if ( self.createData and self.createData.creating ) then
			self.back:SetVisible( false )
			
			loadingR = loadingR + 10
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, 255 )
			catherine.geometry.DrawCircle( w / 2, h / 2 - 60, 15, 5, loadingR, 70, 100 )
			
			draw.SimpleText( LANG( "Basic_UI_ReqToServer" ), "catherine_normal25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			self.back:SetVisible( true )
		end
	end
	
	self.create = vgui.Create( "catherine.vgui.button", self )
	self.create:SetPos( layoutX, layoutY + 100 )
	self.create:SetSize( self.w * 0.2, 30 )
	self.create:SetStr( LANG( "Character_UI_CreateCharStr" ):upper( ) )
	self.create:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.create:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.create:SetStrFont( "catherine_lightUI20" )
	self.create.Click = function( )
		if ( #catherine.character.localCharacters >= catherine.configs.maxCharacters ) then
			Derma_Message( LANG( "Character_Notify_MaxLimitHit" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			return
		end
		
		hook.Remove( "PostRenderVGUI", "catherine.vgui.character.PostRenderVGUI" )
		
		self:JoinMenu( function( )
			self:CreateCharacterPanel( )
		end )
	end
	self.create.PaintOverAll = function( pnl, w, h )
		if ( #catherine.character.localCharacters >= catherine.configs.maxCharacters ) then
			surface.SetDrawColor( 255, 0, 0, 30 )
			surface.SetMaterial( Material( "gui/center_gradient" ) )
			surface.DrawTexturedRect( 0, h - 1, w, 1 )
		else
			surface.SetDrawColor( 255, 255, 255, 20 )
			surface.SetMaterial( Material( "gui/center_gradient" ) )
			surface.DrawTexturedRect( 0, h - 1, w, 1 )
		end
	end
	
	self.mainButtons[ #self.mainButtons + 1 ] = self.create
	
	self.load = vgui.Create( "catherine.vgui.button", self )
	self.load:SetPos( layoutX, layoutY + 140 )
	self.load:SetSize( self.w * 0.2, 30 )
	self.load:SetStr( LANG( "Character_UI_LoadCharStr" ):upper( ) )
	self.load:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.load:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.load:SetStrFont( "catherine_lightUI20" )
	self.load.Click = function( )
		hook.Remove( "PostRenderVGUI", "catherine.vgui.character.PostRenderVGUI" )
		
		self:JoinMenu( function( )
			self:UseCharacterPanel( )
		end )
	end
	self.load.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self.mainButtons[ #self.mainButtons + 1 ] = self.load
	
	self.exit = vgui.Create( "catherine.vgui.button", self )
	self.exit:SetPos( layoutX, layoutY + 180 )
	self.exit:SetSize( self.w * 0.2, 30 )
	self.exit:SetStr( "" )
	self.exit:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.exit:SetGradientColor( Color( 255, 0, 0, 255 ) )
	self.exit:SetStrFont( "catherine_lightUI20" )
	self.exit.Click = function( )
		if ( self.player:IsCharacterLoaded( ) ) then
			self:Close( )
		else
			Derma_Query( LANG( "Character_Notify_ExitQ" ), "", LANG( "Basic_UI_YES" ), function( )
				self:JoinMenu( function( )
					RunConsoleCommand( "disconnect" )
				end )
			end, LANG( "Basic_UI_NO" ), function( ) end )
		end
	end
	self.exit.PaintOverAll = function( pnl, w, h )
		if ( self.player:IsCharacterLoaded( ) ) then
			pnl:SetStr( LANG( "Character_UI_Close" ):upper( ) )
		else
			pnl:SetStr( LANG( "Character_UI_ExitServerStr" ):upper( ) )
		end
		
		surface.SetDrawColor( 255, 0, 0, 20 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self.mainButtons[ #self.mainButtons + 1 ] = self.exit
	
	self.changeLanguage = vgui.Create( "catherine.vgui.button", self )
	self.changeLanguage:SetPos( self.w - ( self.w * 0.2 ) - 30, self.h - 50 )
	self.changeLanguage:SetSize( self.w * 0.2, 30 )
	self.changeLanguage:SetStr( "" )
	self.changeLanguage:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.changeLanguage:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.changeLanguage.Click = function( pnl )
		local menu = DermaMenu( )
		
		for k, v in pairs( catherine.language.GetAll( ) ) do
			menu:AddOption( v.name:upper( ), function( )
				if ( GetConVarString( "cat_convar_language" ) != v.uniqueID ) then
					RunConsoleCommand( "cat_convar_language", k )
					catherine.help.lists = { }
					catherine.menu.Rebuild( )
					
					timer.Simple( 0, function( )
						hook.Run( "LanguageChanged" )
						
						self.create:SetStr( LANG( "Character_UI_CreateCharStr" ):upper( ) )
						self.load:SetStr( LANG( "Character_UI_LoadCharStr" ):upper( ) )
						self.back:SetStr( LANG( "Character_UI_BackStr" ):upper( ) )
					end )
				end
			end )
		end
		
		menu:Open( )
	end
	self.changeLanguage.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
		
		local languageTable = catherine.language.FindByID( GetConVarString( "cat_convar_language" ) )
		
		if ( languageTable ) then
			pnl:SetStr( languageTable.name:upper( ) )
		end
	end
	self.mainButtons[ #self.mainButtons + 1 ] = self.changeLanguage
	
	self.back = vgui.Create( "catherine.vgui.button", self )
	self.back:SetPos( 30, 20 )
	self.back:SetSize( self.w * 0.2, 30 )
	self.back:SetStr( LANG( "Character_UI_BackStr" ):upper( ) )
	self.back:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.back:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.back:SetVisible( false )
	self.back:SetAlpha( 0 )
	self.back.Click = function( )
		if ( self.mode == 0 ) then return end
		if ( self.createData and self.createData.currentStage and self.createData.currentStage.moving ) then return end
		
		self:BackToMainMenu( )
	end
	self.back.Think = function( pnl )
		pnl:MoveToFront( )
	end
	self.back.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 20 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self:PlayMusic( )
	self:ShowHint( )
end

function PANEL:ShowHint( )
	if ( catherine.catData.GetVar( "charHintShowed", "0" ) == "0" ) then
		local languageTable = catherine.language.FindByGmodLangID( GetConVarString( "gmod_language" ) )
		local circleW = self.w
		local run = RealTime( ) + 7
		
		surface.PlaySound( "CAT/notify03.wav" )
		
		hook.Add( "PostRenderVGUI", "catherine.vgui.character.PostRenderVGUI", function( )
			local x, y = self.changeLanguage:GetPos( )
			local wave = 0
			
			if ( run >= RealTime( ) ) then
				circleW = Lerp( 0.06, circleW, self.changeLanguage:GetWide( ) / 2 )
				wave = math.sin( CurTime( ) * 8 ) * 5
			else
				circleW = Lerp( 0.08, circleW, self.w + 300 )
				
				if ( math.Round( circleW ) >= self.w + 150 ) then
					hook.Remove( "PostRenderVGUI", "catherine.vgui.character.PostRenderVGUI" )
				end
			end
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, 255 )
			catherine.geometry.DrawCircle( x + ( self.changeLanguage:GetWide( ) / 2 ), y + 30 / 2, circleW, 15 + wave, 90, 360, 100 )
			
			draw.SimpleText( FORCE_LANG( ( languageTable and languageTable.uniqueID or "english" ), "Character_UI_Hint01_Short" ), "catherine_normal20", x + ( self.changeLanguage:GetWide( ) / 2 ), y - circleW / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end )
		
		catherine.catData.SetVar( "charHintShowed", "1", false, true )
	end
end

function PANEL:PlayMusic( )
	local musicDir = catherine.configs.characterMenuMusic
	musicDir = type( musicDir ) == "table" and table.Random( musicDir ) or musicDir
	
	if ( musicDir and type( musicDir ) == "string" ) then
		if ( musicDir:find( "http://" ) or musicDir:find( "https://" ) ) then
			sound.PlayURL( musicDir, "noblock", function( musicEnt, errorID, errorCode )
				if ( IsValid( musicEnt ) ) then
					musicEnt:Play( )
					
					if ( catherine.configs.enabledCharacterMenuMusicLooping ) then
						musicEnt:EnableLooping( true )
					end
					
					catherine.character.panelMusic = musicEnt
				else
					Derma_Message( LANG( "Character_UI_MusicError", errorCode ), "", LANG( "Basic_UI_OK" ) )
				end
			end )
		else
			sound.PlayFile( musicDir, "", function( musicEnt, errorID, errorCode )
				if ( IsValid( musicEnt ) ) then
					musicEnt:Play( )
					
					if ( catherine.configs.enabledCharacterMenuMusicLooping ) then
						musicEnt:EnableLooping( true )
					end
					
					catherine.character.panelMusic = musicEnt
				else
					Derma_Message( LANG( "Character_UI_MusicError", errorCode ), "", LANG( "Basic_UI_OK" ) )
				end
			end )
		end
	end
end

function PANEL:CreateCharacterPanel( )
	self.createData = { datas = { }, creating = false }
	self.createData.currentStageInt = 1
	self.createData.currentStage = vgui.Create( "catherine.character.stageOne", self )
end

function PANEL:UseCharacterPanel( )
	self.loadCharacter = { Lists = { }, curr = 1 }
	
	local baseW = 300
	local pl = catherine.pl
	
	for k, v in pairs( catherine.character.localCharacters ) do
		self.loadCharacter.Lists[ #self.loadCharacter.Lists + 1 ] = {
			characterDatas = v,
			panel = nil
		}
	end
	
	local loadingR = 0
	
	self.CharacterPanel = vgui.Create( "DPanel", self )
	self.CharacterPanel:SetPos( 0, 60 )
	self.CharacterPanel:SetSize( self.w, self.h - 120 )
	self.CharacterPanel:SetAlpha( 0 )
	self.CharacterPanel:AlphaTo( 255, 0.2, 0 )
	self.CharacterPanel.Paint = function( pnl, w, h )
		if ( #self.loadCharacter.Lists == 0 ) then
			draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( LANG( "Character_UI_DontHaveAny" ), "catherine_lightUI25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
		
		if ( pnl.loading ) then
			for k, v in pairs( self.loadCharacter.Lists ) do
				if ( IsValid( v.panel ) ) then
					v.panel:SetVisible( false )
				end
			end
			
			self.back:SetVisible( false )
			
			loadingR = loadingR + 10
			
			draw.NoTexture( )
			surface.SetDrawColor( 255, 255, 255, 255 )
			catherine.geometry.DrawCircle( w / 2, h / 2 - 60, 15, 5, loadingR, 70, 100 )
			
			draw.SimpleText( LANG( "Basic_UI_ReqToServer" ), "catherine_lightUI25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			for k, v in pairs( self.loadCharacter.Lists ) do
				if ( IsValid( v.panel ) ) then
					v.panel:SetVisible( true )
				end
			end
			
			self.back:SetVisible( true )
		end
	end
	
	local function SetTargetPanelPos( pnl, pos )
		if ( !IsValid( pnl ) ) then return end
		
		if ( !pnl.targetPos ) then
			pnl.targetPos = pos
		end
		
		pnl.targetPos = Lerp( 0.15, pnl.targetPos, pos )
		
		pnl:SetPos( pnl.targetPos, 30 )
	end
	
	for k, v in pairs( self.loadCharacter.Lists ) do
		local factionData = catherine.faction.FindByID( v.characterDatas._faction )
		
		if ( !factionData ) then continue end
		
		local factionName = catherine.util.StuffLanguage( factionData.name )
		local overrideModel = hook.Run( "GetCharacterPanelLoadModel", v.characterDatas ) or v.characterDatas._model
		
		v.panel = vgui.Create( "DPanel", self.CharacterPanel )
		v.panel:SetSize( baseW, self.CharacterPanel:GetTall( ) - 60 )
		v.panel.x = 0
		v.panel.y = 0
		v.panel:Center( )
		v.panel.Paint = function( pnl, w, h ) end
		
		local panel = v.panel
		local panel_w, panel_h = panel:GetWide( ), panel:GetTall( )
		
		panel.factionName = vgui.Create( "DLabel", panel )
		panel.factionName:SetTextColor( Color( 255, 255, 255 ) )
		panel.factionName:SetFont( "catherine_normal20" )
		panel.factionName:SetText( factionName:upper( ) )
		panel.factionName:SizeToContents( )
		panel.factionName:SetPos( panel_w / 2 - panel.factionName:GetWide( ) / 2, 10 )
		panel.factionName.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, 10 )
			end
		end
		
		panel.charName = vgui.Create( "DLabel", panel )
		panel.charName:SetTextColor( Color( 255, 255, 255 ) )
		panel.charName:SetFont( "catherine_normal25" )
		panel.charName:SetText( v.characterDatas._name )
		panel.charName:SizeToContents( )
		panel.charName:SetPos( panel_w / 2 - panel.charName:GetWide( ) / 2, panel_h - 110 )
		panel.charName.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, panel_h - 110 )
			end
		end
		
		panel.charDesc = vgui.Create( "DLabel", panel )
		panel.charDesc:SetTextColor( Color( 235, 235, 235 ) )
		panel.charDesc:SetFont( "catherine_normal15" )
		panel.charDesc:SetText( v.characterDatas._desc )
		panel.charDesc:SizeToContents( )
		panel.charDesc:SetPos( panel_w / 2 - panel.charDesc:GetWide( ) / 2, panel_h - 70 )
		panel.charDesc.PerformLayout = function( pnl, w, h )
			if ( w >= panel_w ) then
				pnl:SetWide( panel_w - 15 )
				pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, panel_h - 70 )
			end
		end
		
		panel.button = vgui.Create( "DButton", panel )
		panel.button:SetSize( panel_w, panel_h )
		panel.button:Center( )
		panel.button:SetText( "" )
		panel.button:SetDrawBackground( false )
		panel.button.DoClick = function( )
			self.loadCharacter.curr = k
		end
		
		panel.useCharacter = vgui.Create( "DButton", panel )
		panel.useCharacter:SetSize( 35, 35 )
		panel.useCharacter:SetPos( panel_w * 0.3, panel_h - 39 )
		panel.useCharacter:SetText( "✔" )
		panel.useCharacter:SetFont( "catherine_normal35" )
		panel.useCharacter:SetTextColor( Color( 255, 255, 255 ) )
		panel.useCharacter:SetToolTip( LANG( "Character_UI_UseCharacter" ) )
		panel.useCharacter.Paint = function( pnl, w, h ) end
		panel.useCharacter.DoClick = function( )
			self.CharacterPanel.loading = true
			
			timer.Create( "catherine.vgui.character.CharacterLoadTimeout", 10, 1, function( )
				self.CharacterPanel.loading = false
				Derma_Message( LANG( "Basic_UI_ReqToServerFail" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
			end )
			
			netstream.Start( "catherine.character.Use", v.characterDatas._id )
		end
		
		panel.deleteCharacter = vgui.Create( "DButton", panel )
		panel.deleteCharacter:SetSize( 35, 35 )
		panel.deleteCharacter:SetPos( panel_w * 0.6, panel_h - 39 )
		panel.deleteCharacter:SetText( "X" )
		panel.deleteCharacter:SetFont( "catherine_normal35" )
		panel.deleteCharacter:SetTextColor( Color( 255, 255, 255 ) )
		panel.deleteCharacter:SetToolTip( LANG( "Character_UI_DeleteCharacter" ) )
		panel.deleteCharacter.Paint = function( pnl, w, h ) end
		panel.deleteCharacter.DoClick = function( )
			Derma_Query( LANG( "Character_Notify_DeleteQ" ), "", LANG( "Basic_UI_YES" ), function( )
				self.CharacterPanel.loading = true
			
				timer.Create( "catherine.vgui.character.CharacterDeleteTimeout", 10, 1, function( )
					self.CharacterPanel.loading = false
					Derma_Message( LANG( "Basic_UI_ReqToServerFail" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
				end )
				
				netstream.Start( "catherine.character.Delete", v.characterDatas._id )
			end, LANG( "Basic_UI_NO" ), function( ) end )
		end
		
		panel.model = vgui.Create( "DModelPanel", panel )
		panel.model:SetSize( panel_w, panel_h - 160 )
		panel.model:SetPos( panel_w / 2 - panel.model:GetWide( ) / 2, 40 )
		panel.model:MoveToBack( )
		panel.model:SetModel( overrideModel )
		panel.model:SetDrawBackground( false )
		panel.model:SetDisabled( true )
		panel.model:SetFOV( 40 )
		panel.model.LayoutEntity = function( pnl, ent )
			ent:SetAngles( Angle( 0, 45, 0 ) )
			ent:SetIK( false )
			
			if ( k == self.loadCharacter.curr ) then
				pnl:RunAnimation( )
			end
		end
		
		if ( IsValid( panel.model.Entity ) ) then
			local min, max = panel.model.Entity:GetRenderBounds( )
			
			panel.model:SetCamPos( min:Distance( max ) * Vector( 0.5, 0.5, 0.5 ) )
			panel.model:SetLookAt( ( max + min ) / 2 )
			
			if ( v.characterDatas._charVar and v.characterDatas._charVar.subMaterial ) then
				for k1, v1 in pairs( v.characterDatas._charVar.subMaterial ) do
					panel.model.Entity:SetSubMaterial( v1[ 1 ], v1[ 2 ] )
				end
			end
			
			for k, v in pairs( panel.model.Entity:GetSequenceList( ) ) do
				if ( v:find( "idle" ) ) then
					local seq = panel.model.Entity:LookupSequence( v )
					panel.model.Entity:SetSequence( seq )
					
					break
				end
			end
		end
		
		panel.useCharacter:MoveToFront( )
		panel.deleteCharacter:MoveToFront( )
		
		hook.Run( "PostInitLoadCharacterList", pl, panel, v.characterDatas )
	end
	
	self.CharacterPanel.Think = function( )
		if ( !self.loadCharacter ) then return end
		
		if ( self.loadCharacter.curr == 0 ) then
			self.loadCharacter.curr = 1
		end
		
		if ( !self.loadCharacter.Lists[ self.loadCharacter.curr ] ) then
			self.loadCharacter.curr = #catherine.character.localCharacters
			return
		end
		
		local uniquePanel = self.loadCharacter.Lists[ self.loadCharacter.curr ].panel
		
		if ( !IsValid( uniquePanel ) ) then return end
		
		SetTargetPanelPos( uniquePanel, self.CharacterPanel:GetWide( ) / 2 - uniquePanel:GetWide( ) / 2 )
		
		local right, left = uniquePanel.x + uniquePanel:GetWide( ) + 24, uniquePanel.x - 24
		
		for i = self.loadCharacter.curr - 1, 1, -1 do
			local prevPanel = self.loadCharacter.Lists[ i ].panel
			
			if ( !IsValid( prevPanel ) ) then continue end
			
			SetTargetPanelPos( prevPanel, left - prevPanel:GetWide( ) )
			left = prevPanel.x - 24
		end
		
		for k, v in pairs( self.loadCharacter.Lists ) do
			if ( k > self.loadCharacter.curr ) then
				SetTargetPanelPos( v.panel, right )
				right = v.panel.x + v.panel:GetWide( ) + 24
			end
		end
	end
end

function PANEL:BackToMainMenu( )
	if ( self.mode == 0 ) then return end
	local delta = 0
	
	for k, v in pairs( self.mainButtons ) do
		v:SetVisible( true )
		v:AlphaTo( 255, 0.2, delta )
		
		delta = delta + 0.05
	end
	
	self.back:AlphaTo( 0, 0.2, 0, function( _, pnl )
		pnl:SetVisible( false )
	end )
	
	self.mode = 0
	
	if ( self.createData and IsValid( self.createData.currentStage ) ) then
		self.createData.currentStage:AlphaTo( 0, 0.2, 0, function( _, pnl )
			pnl:Remove( )
			pnl = nil
		end )
	end
	
	if ( self.loadCharacter and IsValid( self.CharacterPanel ) ) then
		self.CharacterPanel:AlphaTo( 0, 0.2, 0, function( _, pnl )
			pnl:Remove( )
			pnl = nil
		end )
	end
	
	if ( IsValid( catherine.vgui.resource ) ) then
		catherine.vgui.resource:Show( )
	end
end

function PANEL:JoinMenu( func )
	if ( self.mode == 1 ) then return end
	local delta = 0
	
	for k, v in pairs( self.mainButtons ) do
		v:AlphaTo( 0, 0.2, delta, function( )
			v:SetVisible( false )
		end )
		
		delta = delta + 0.1
	end
	
	self.back:SetVisible( true )
	self.back:AlphaTo( 255, 0.2, delta, function( )
		if ( func ) then
			func( )
		end
	end )
	
	if ( IsValid( catherine.vgui.resource ) ) then
		catherine.vgui.resource:Hide( )
	end
	
	self.mode = 1
end

function PANEL:Close( )
	if ( self.closing ) then return end
	local music = catherine.character.panelMusic
	
	self.closing = true
	
	if ( music ) then
		local vol = 1
		
		hook.Remove( "Think", "catherine.character.FadeOutBackgroundMusic" )
		
		hook.Add( "Think", "catherine.character.FadeOutBackgroundMusic", function( )
			if ( vol > 0 ) then
				vol = vol - 0.005
			else
				hook.Remove( "Think", "catherine.character.FadeOutBackgroundMusic" )
				music:Stop( )
				catherine.character.panelMusic = nil
				return
			end
			
			music:SetVolume( vol )
		end )
	end
	
	if ( IsValid( catherine.vgui.resource ) ) then
		catherine.vgui.resource:Close( )
	end
	
	self:AlphaTo( 0, 0.3, 0, function( )
		hook.Run( "CharacterMenuExited", self.player )
		hook.Remove( "PostRenderVGUI", "catherine.vgui.character.PostRenderVGUI" )
		
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.character", PANEL, "DFrame" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w, self.parent.h
	self.data = { faction = nil }
	self.selectedFaction = 1
	self.factionList = { }
	self.moveAniList = { }
	
	for k, v in SortedPairs( catherine.faction.GetPlayerUsableFaction( self.parent.player ) ) do
		self.factionList[ #self.factionList + 1 ] = {
			factionData = v,
			panel = nil
		}
	end
	
	local autoSelect = math.Round( #self.factionList / 2 )
	
	if ( self.factionList[ autoSelect ] and self.factionList[ autoSelect ].factionData ) then
		self.data = { faction = self.factionList[ autoSelect ].factionData.uniqueID }
		self.selectedFaction = autoSelect
	end
	
	local alphaDelta = 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( 0, 0 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetColor( Color( 255, 255, 255, 255 ) )
	self.label01:SetFont( "catherine_lightUI30" )
	self.label01:SetText( LANG( "Character_UI_CharFaction" ):upper( ) )
	self.label01:SetPos( 0, 20 )
	self.label01:SizeToContents( )
	self.label01:CenterHorizontal( )
	self.label01:SetAlpha( 0 )
	self.label01:AlphaTo( 255, 0.5, alphaDelta )
	alphaDelta = alphaDelta + 0.2
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.label01
	
	for k, v in pairs( self.factionList ) do
		local factionData = v.factionData
		
		v.panel = vgui.Create( "DPanel", self )
		v.panel:SetSize( 512, 312 )
		v.panel.x = 0
		v.panel.y = 0
		v.panel:Center( )
		v.panel.Paint = function( pnl, w, h )
			local material = nil
			
			if ( factionData.factionImage ) then
				material = Material( factionData.factionImage )
			end
			
			local name = catherine.util.StuffLanguage( factionData.name )
			
			if ( material and !material:IsError( ) ) then
				local material_w, material_h = material:Width( ), material:Height( )
				
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( material )
				surface.DrawTexturedRect( w / 2 - material_w / 2, h - material_h, material_w, material_h )
				
				draw.SimpleText( name:upper( ), "catherine_lightUI30", w / 2, 30, Color( 255, 255, 255, 255 ), 1, 1 )
			else
				draw.SimpleText( name:upper( ), "catherine_lightUI30", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
			end
		end
		
		local panel = v.panel
		local panel_w, panel_h = panel:GetWide( ), panel:GetTall( )
		
		panel.button = vgui.Create( "DButton", panel )
		panel.button:SetSize( panel_w, panel_h )
		panel.button:Center( )
		panel.button:SetText( "" )
		panel.button:SetDrawBackground( false )
		panel.button.DoClick = function( )
			if ( self.selectedFaction != k ) then
				surface.PlaySound( "buttons/button24.wav" )
				
				self.selectedFaction = k
				self.data.faction = factionData.uniqueID
			end
		end
		
		self.moveAniList[ #self.moveAniList + 1 ] = v.panel
	end
	
	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 20 )
	self.nextStage:SetSize( self.w * 0.2, 30 )
	self.nextStage:SetStr( LANG( "Character_UI_NextStage" ):upper( ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.nextStage:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.nextStage.Click = function( )
		if ( self.moving ) then return end
		
		if ( self.data.faction ) then
			if ( catherine.faction.FindByID( self.data.faction ) ) then
				surface.PlaySound( "garrysmod/ui_click.wav" )
				
				self.parent.createData.datas.faction = self.data.faction
				
				local delta = 0
				self.moving = true
				
				for k, v in pairs( self.moveAniList ) do
					local x, y = v:GetPos( )
					
					if ( k == #self.moveAniList ) then
						v:MoveTo( 0 - self.w, y, 0.5, delta, nil, function( )
							self:Remove( )
							
							self.parent.createData.currentStageInt = self.parent.createData.currentStageInt + 1
							self.parent.createData.currentStage = vgui.Create( "catherine.character.stageTwo", self.parent )
						end )
						
						break
					else
						v:MoveTo( 0 - self.w, y, 0.5, delta )
					end
					
					delta = delta + 0.1
				end
			else
				self:PrintErrorMessage( LANG( "Faction_Notify_NotValid", self.data.faction ) )
			end
		else
			self:PrintErrorMessage( LANG( "Faction_Notify_SelectPlease" ) )
		end
	end
	self.nextStage.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 80 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 2, w, 2 )
	end
	self.nextStage:SetAlpha( 0 )
	self.nextStage:AlphaTo( 255, 0.5, alphaDelta )
	alphaDelta = alphaDelta + 0.2
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.nextStage
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
end

function PANEL:SetTargetPanelPos( pnl, pos, alpha )
	if ( !IsValid( pnl ) ) then return end
	
	if ( !pnl.targetPos ) then
		pnl.targetPos = pos
	end
	
	if ( !pnl.targetAlpha ) then
		pnl.targetAlpha = 0
	end
	
	pnl.targetPos = Lerp( 0.2, pnl.targetPos, pos )
	pnl.targetAlpha = Lerp( 0.1, pnl.targetAlpha, alpha )
	
	pnl:SetPos( pnl.targetPos, self.h / 2 - pnl:GetTall( ) / 2 )
	pnl:SetAlpha( pnl.targetAlpha )
end

function PANEL:Think( )
	if ( self.moving ) then return end
	if ( !self.factionList[ self.selectedFaction ] ) then return end
	
	local uniquePanel = self.factionList[ self.selectedFaction ].panel
	
	if ( !IsValid( uniquePanel ) ) then return end
	
	self:SetTargetPanelPos( uniquePanel, self:GetWide( ) / 2 - uniquePanel:GetWide( ) / 2, 255 )
	
	local right, left = uniquePanel.x + uniquePanel:GetWide( ) + 64, uniquePanel.x - 64
	
	for i = self.selectedFaction - 1, 1, -1 do
		local prevPanel = self.factionList[ i ].panel
		
		if ( !IsValid( prevPanel ) ) then continue end
		
		self:SetTargetPanelPos( prevPanel, left - prevPanel:GetWide( ), ( 150 / self.selectedFaction ) * i )
		left = prevPanel.x - 64
	end
	
	for k, v in pairs( self.factionList ) do
		if ( k > self.selectedFaction ) then
			self:SetTargetPanelPos( v.panel, right, ( 150 / ( ( #self.factionList + 1 ) - self.selectedFaction ) ) * ( ( #self.factionList + 1 ) - k ) )
			right = v.panel.x + v.panel:GetWide( ) + 64
		end
	end
end

function PANEL:Paint( w, h )
	if ( #self.factionList == 0 ) then
		draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( LANG( "Character_UI_FactionHaveAny" ), "catherine_lightUI25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		
		self.nextStage:SetVisible( false )
	end
end

vgui.Register( "catherine.character.stageOne", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w, self.parent.h
	self.data = {
		name = "",
		desc = "",
		model = ""
	}
	self.moveAniList = { }
	self.forceName = false
	self.forceDesc = false
	
	local alphaDelta = 0
	local selectedIndex = 0
	
	self:SetSize( self.w, self.h )
	self:SetPos( 0, 0 )
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetColor( Color( 255, 255, 255, 255 ) )
	self.label01:SetFont( "catherine_lightUI30" )
	self.label01:SetText( LANG( "Character_UI_CharInfo" ):upper( ) )
	self.label01:SetPos( 0, 20 )
	self.label01:SizeToContents( )
	self.label01:CenterHorizontal( )
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.label01
	
	self.name = vgui.Create( "DLabel", self )
	self.name:SetPos( 15, 90 )
	self.name:SetColor( Color( 255, 255, 255, 255 ) )
	self.name:SetFont( "catherine_lightUI25" )
	self.name:SetText( LANG( "Character_UI_CharName" ) )
	self.name:SizeToContents( )
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.name
	
	self.nameEnt = vgui.Create( "DTextEntry", self )
	self.nameEnt:SetPos( 15, 120 )
	self.nameEnt:SetSize( self.w * 0.5 - 15, 30 )	
	self.nameEnt:SetFont( "catherine_lightUI25" )
	self.nameEnt:SetText( "" )
	self.nameEnt:SetAllowNonAsciiCharacters( true )
	self.nameEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT_UNDERLINE, w, h )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 45, 45, 45 ), Color( 255, 255, 255 ) )
	end
	self.nameEnt.OnTextChanged = function( pnl )
		self.data.name = pnl:GetText( )
	end
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.nameEnt
	
	self.desc = vgui.Create( "DLabel", self )
	self.desc:SetPos( 15, 170 )
	self.desc:SetColor( Color( 255, 255, 255, 255 ) )
	self.desc:SetFont( "catherine_lightUI25" )
	self.desc:SetText( LANG( "Character_UI_CharDesc" ) )
	self.desc:SizeToContents( )
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.desc
	
	self.descEnt = vgui.Create( "DTextEntry", self )
	self.descEnt:SetPos( 15, 200 )
	self.descEnt:SetSize( self.w * 0.7 - 15, 20 )	
	self.descEnt:SetFont( "catherine_normal15" )
	self.descEnt:SetText( "" )
	self.descEnt:SetAllowNonAsciiCharacters( true )
	self.descEnt.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT_UNDERLINE, w, h )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 45, 45, 45 ), Color( 255, 255, 255 ) )
	end
	self.descEnt.OnTextChanged = function( pnl )
		self.data.desc = pnl:GetText( )
	end
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.descEnt
	
	self.modelLabel = vgui.Create( "DLabel", self )
	self.modelLabel:SetPos( 15, 240 )
	self.modelLabel:SetColor( Color( 255, 255, 255, 255 ) )
	self.modelLabel:SetFont( "catherine_lightUI25" )
	self.modelLabel:SetText( LANG( "Character_UI_CharModel" ) )
	self.modelLabel:SizeToContents( )
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.modelLabel
	
	self.previewModel = vgui.Create( "DModelPanel", self )
	self.previewModel:SetPos( self.w - ( self.w * 0.2 ) - 10, 60 )
	self.previewModel:SetSize( self.w * 0.2, self.h - 70 )
	self.previewModel:SetFOV( 40 )
	self.previewModel:MoveToBack( )
	self.previewModel:SetDisabled( true )
	self.previewModel.LayoutEntity = function( pnl, ent )
		ent:SetIK( false )
		ent:SetAngles( Angle( 0, 45, 0 ) )
		
		pnl:RunAnimation( )
	end
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.previewModel
	
	self.model = vgui.Create( "DPanelList", self )
	self.model:SetPos( 15, 280 )
	self.model:SetSize( self.w - ( self.w * 0.2 ) - 35, self.h - 295 )
	self.model:SetSpacing( 5 )
	self.model:EnableHorizontal( true )
	self.model:EnableVerticalScrollbar( false )
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.model
	
	local factionTable = catherine.faction.FindByID( self.parent.createData.datas.faction )
	
	if ( factionTable ) then
		local delta = 0
		
		if ( #factionTable.models == 1 ) then
			local model = factionTable.models[ 1 ]
			
			if ( catherine.faction.IsTableModel( factionTable.models[ 1 ] ) ) then
				model = factionTable.models[ 1 ].model
			end
			
			self.data.model = model
			self.previewModel:SetModel( model )
			
			if ( IsValid( self.previewModel.Entity ) ) then
				if ( istable( factionTable.models[ 1 ] ) and factionTable.models[ 1 ].subMaterials ) then
					for k, v in pairs( factionTable.models[ 1 ].subMaterials ) do
						self.previewModel.Entity:SetSubMaterial( v[ 1 ], v[ 2 ] )
					end
				end
				
				for k, v in pairs( self.previewModel.Entity:GetSequenceList( ) ) do
					if ( v:find( "idle" ) ) then
						local seq = self.previewModel.Entity:LookupSequence( v )
						self.previewModel.Entity:SetSequence( seq )
						
						break
					end
				end
			end
			
			self.modelLabel:SetVisible( false )
			self.model:SetVisible( false )
		else
			for k, v in pairs( factionTable.models ) do
				local model = v
				
				if ( catherine.faction.IsTableModel( v ) ) then
					model = v.model
				end
				
				local iconA = 0
				
				local icon = vgui.Create( "DModelPanel" )
				icon:SetSize( 100, 100 )
				icon:SetFOV( 15 )
				icon:SetModel( model )
				icon:MoveToBack( )
				icon:SetDisabled( true )
				icon.LayoutEntity = function( pnl, ent )
					if ( selectedIndex == k ) then
						iconA = Lerp( 0.09, iconA, 255 / 1.5 )
					else
						iconA = Lerp( 0.09, iconA, 0 )
					end
					
					draw.RoundedBox( 0, 0, 0, 100, 100, Color( 255, 255, 255, iconA ) )
					
					ent:SetIK( false )
					
					local boneIndex = ent:LookupBone( "ValveBiped.Bip01_Head1" )
					local entMin, entMax = ent:GetRenderBounds( )
					
					if ( boneIndex ) then
						local pos, ang = ent:GetBonePosition( boneIndex )
						
						if ( pos ) then
							pnl:SetLookAt( pos )
						end
					else
						pnl:SetLookAt( ( entMax + entMin ) / 2 )
					end
					
					ent:SetAngles( Angle( 0, 45, 0 ) )
				end
				icon.PaintOver = function( pnl, w, h )
					surface.SetDrawColor( 255, 255, 255, 50 )
					surface.DrawOutlinedRect( 0, 0, w, h )
				end
				
				if ( istable( v ) and v.subMaterials ) then
					for k1, v1 in pairs( v.subMaterials ) do
						icon.Entity:SetSubMaterial( v1[ 1 ], v1[ 2 ] )
					end
				end
				
				local button = vgui.Create( "DButton", icon )
				button:SetText( "" )
				button:Dock( FILL )
				button.Paint = function( pnl, w, h ) end
				button.DoClick = function( pnl )
					self.data.model = model
					self.previewModel:SetModel( model )
					selectedIndex = k
					
					if ( IsValid( self.previewModel.Entity ) ) then
						if ( istable( v ) and v.subMaterials ) then
							for k1, v1 in pairs( v.subMaterials ) do
								self.previewModel.Entity:SetSubMaterial( v1[ 1 ], v1[ 2 ] )
							end
						end
						
						for k1, v1 in pairs( self.previewModel.Entity:GetSequenceList( ) ) do
							if ( v1:find( "idle" ) ) then
								local seq = self.previewModel.Entity:LookupSequence( v1 )
								self.previewModel.Entity:SetSequence( seq )
								
								break
							end
						end
					end
				end
				
				delta = delta + 0.03
				self.model:AddItem( icon )
			end
		end
		
		if ( factionTable.PostSetName ) then
			local name = factionTable:PostSetName( self.parent.player )
			
			if ( name ) then
				self.nameEnt:SetText( name )
				self.nameEnt:SetEditable( false )
				self.data.name = self.nameEnt:GetText( )
				self.forceName = true
			end
		end
		
		if ( factionTable.PostSetDesc ) then
			local desc = factionTable:PostSetDesc( self.parent.player )
			
			if ( desc ) then
				self.descEnt:SetText( desc )
				self.descEnt:SetEditable( false )
				self.data.desc = self.descEnt:GetText( )
				self.forceDesc = true
			end
		end
	else
		self:PrintErrorMessage( LANG( "Faction_Notify_NotValid", self.parent.createData.datas.faction ) )
	end

	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 20 )
	self.nextStage:SetSize( self.w * 0.2, 30 )
	self.nextStage:SetStr( LANG( "Character_UI_NextStage" ):upper( ) )
	self.nextStage:SetStrFont( "catherine_normal20" )
	self.nextStage:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.nextStage:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.nextStage.Click = function( )
		if ( self.moving ) then return end
		local i = 0
		local pl = self.parent.player
		
		for k, v in pairs( self.data ) do
			local vars = catherine.character.FindVarByID( k )
			
			if ( vars and vars.checkValid ) then
				i = i + 1
				local isForce = false
				
				if ( k == "name" ) then
					isForce = self.forceName
				elseif ( k == "name" ) then
					isForce = self.forceDesc
				end
				
				local success, reason = vars.checkValid( pl, self.data[ k ], isForce )
				
				if ( success == false ) then
					self:PrintErrorMessage( catherine.util.StuffLanguage( reason ) )
					return
				else
					if ( i == 3 ) then
						surface.PlaySound( "garrysmod/ui_click.wav" )
						
						self.parent.createData.datas.name = self.data.name:Trim( )
						self.parent.createData.datas.desc = self.data.desc:Trim( )
						self.parent.createData.datas.model = self.data.model
						self.moving = true
						
						local delta = 0
						
						for k, v in pairs( self.moveAniList ) do
							local x, y = v:GetPos( )
							
							if ( k == #self.moveAniList ) then
								v:MoveTo( 0 - self.w, y, 0.5, delta, nil, function( )
									self:Remove( )
									
									self.parent.createData.currentStageInt = self.parent.createData.currentStageInt + 1
									self.parent.createData.currentStage = vgui.Create( "catherine.character.stageThree", self.parent )
								end )
								
								break
							else
								v:MoveTo( 0 - self.w, y, 0.5, delta )
							end
							
							delta = delta + 0.1
						end
						
						return
					end
				end
			end
		end
	end
	self.nextStage.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 80 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 2, w, 2 )
	end
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.nextStage
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
end

function PANEL:Paint( w, h )
	if ( !self.forceName ) then
		local nameLen = self.data.name:utf8len( )
		
		if ( nameLen > catherine.configs.characterNameMaxLen ) then
			draw.RoundedBox( 0, 30 + self.nameEnt:GetWide( ), 120 + 15 / 2, 15, 15, Color( 255, 0, 0, 255 ) )
		elseif ( nameLen < catherine.configs.characterNameMinLen ) then
			draw.RoundedBox( 0, 30 + self.nameEnt:GetWide( ), 120 + 15 / 2, 15, 15, Color( 255, 150, 0, 255 ) )
		end
	end
	
	if ( !self.forceDesc ) then
		local descLen = self.data.desc:utf8len( )
		
		if ( descLen > catherine.configs.characterDescMaxLen ) then
			draw.RoundedBox( 0, 30 + self.descEnt:GetWide( ), 200, 15, 15, Color( 255, 0, 0, 255 ) )
		elseif ( descLen < catherine.configs.characterDescMinLen ) then
			draw.RoundedBox( 0, 30 + self.descEnt:GetWide( ), 200, 15, 15, Color( 255, 150, 0, 255 ) )
		end
	end
end

vgui.Register( "catherine.character.stageTwo", PANEL, "DPanel" )

local PANEL = { }

function PANEL:Init( )
	self.parent = self:GetParent( )
	self.w, self.h = self.parent.w, self.parent.h
	self.haveAtt = false
	self.createdAtt = false
	self.data = {
		att = nil
	}
	self.moveAniList = { }
	self.noDrawPaint = false
	
	self:SetSize( self.w, self.h )
	self:SetPos( 0, 0 )
	
	local alphaDelta = 0
	
	self.label01 = vgui.Create( "DLabel", self )
	self.label01:SetColor( Color( 255, 255, 255, 255 ) )
	self.label01:SetFont( "catherine_lightUI30" )
	self.label01:SetText( LANG( "Character_UI_CharAtt" ):upper( ) )
	self.label01:SetPos( 0, 20 )
	self.label01:SizeToContents( )
	self.label01:CenterHorizontal( )
	self.label01:SetAlpha( 0 )
	self.label01:AlphaTo( 255, 0.5, alphaDelta )
	alphaDelta = alphaDelta + 0.2
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.label01
	
	self.att = vgui.Create( "DPanelList", self )
	self.att:SetSize( 140, self.h * 0.4 )
	self.att:SetPos( self.w / 2 - self.att:GetWide( ) / 2, self.h / 2 - self.att:GetTall( ) / 2 )
	self.att:SetSpacing( 20 )
	self.att:EnableHorizontal( true )
	self.att:EnableVerticalScrollbar( false )
	self.att.Rebuild = function( pnl )
		local offset = 0
		
		if ( pnl.Horizontal ) then
			local x, y = 0, 0
			
			for k, v in pairs( pnl.Items ) do
				local w, h = v:GetWide( ), v:GetTall( )
				
				if ( x + w  > pnl:GetWide( ) ) then
					x = 0
					y = y + h + pnl.Spacing
				end
				
				v:MoveTo( x, y, 0.2, 0 )
				
				x = x + w + pnl.Spacing
				offset = y + h + pnl.Spacing
			end
		else
		
			for k, v in pairs( pnl.Items ) do
				v:SetSize( pnl:GetCanvas( ):GetWide( ), v:GetTall( ) )
				v:MoveTo( 0, offset, 0.2, 0 )
				offset = offset + v:GetTall( ) + pnl.Spacing
			end
		end
		
		pnl:GetCanvas( ):SetSize( pnl:GetCanvas( ):GetWide( ), offset + pnl.Padding * 2 - pnl.Spacing ) 
	end
	self.att:SetAlpha( 0 )
	self.att:AlphaTo( 255, 0.5, alphaDelta )
	alphaDelta = alphaDelta + 0.2
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.att
	
	self.nextStage = vgui.Create( "catherine.vgui.button", self )
	self.nextStage:SetPos( self.w - self.w * 0.2 - 10, 20 )
	self.nextStage:SetSize( self.w * 0.2, 30 )
	self.nextStage:SetStr( LANG( "Character_UI_CREATE" ):upper( ) )
	self.nextStage:SetStrFont( "catherine_normal25" )
	self.nextStage:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.nextStage:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.nextStage.Click = function( )
		if ( self.noAtt or ( self.data.att and self.createdAtt ) ) then
			surface.PlaySound( "garrysmod/ui_click.wav" )
			
			if ( !self.parent.createData.creating ) then
				Derma_Query( LANG( "Character_Notify_CreateQ" ), "", LANG( "Basic_UI_YES" ), function( )
					if ( !self.parent.createData.creating ) then
						self.parent.createData.creating = true
						self.noDrawPaint = true
						local delta = 0
				
						for k, v in pairs( self.moveAniList ) do
							local x, y = v:GetPos( )
							
							if ( k == #self.moveAniList ) then
								v:MoveTo( 0 - self.w, y, 0.5, delta, nil, function( )
									timer.Create( "catherine.vgui.character.CharacterCreateTimeout", 10, 1, function( )
										Derma_Message( LANG( "Basic_UI_ReqToServerFail" ), LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
										
										if ( IsValid( self ) ) then
											self:Remove( )
										end
									end )
									
									table.Merge( self.parent.createData.datas, self.data )
									netstream.Start( "catherine.character.Create", self.parent.createData.datas )
								end )
								
								break
							else
								v:MoveTo( 0 - self.w, y, 0.5, delta )
							end
							
							delta = delta + 0.1
						end
					else
						self:PrintErrorMessage( LANG( "Basic_UI_ReqToServer" ) )
					end
				end, LANG( "Basic_UI_NO" ), function( ) end )
			else
				self:PrintErrorMessage( LANG( "Basic_UI_ReqToServer" ) )
			end
		else
			self:PrintErrorMessage( LANG( "Character_Notify_IsSelectingAttribute" ) )
		end
	end
	self.nextStage.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 255, 255, 80 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 2, w, 2 )
	end
	self.nextStage:SetAlpha( 0 )
	self.nextStage:AlphaTo( 255, 0.5, alphaDelta )
	alphaDelta = alphaDelta + 0.2
	
	self.moveAniList[ #self.moveAniList + 1 ] = self.nextStage
	
	timer.Simple( 1, function( )
		if ( IsValid( self ) ) then
			netstream.Start( "catherine.character.GetRandomAttribute" )
		end
	end )
end

function PANEL:BuildRandomAttributeList( )
	if ( !self.data.att ) then return end
	local delta = 0
	local delay = 0
	
	for k, v in SortedPairs( self.data.att ) do
		local attributeTable = catherine.attribute.FindByID( v.uniqueID )
		if ( !attributeTable ) then continue end
		local attAni = 0
		local attTextAni = 0
		
		timer.Simple( delay, function( )
			if ( !IsValid( self ) ) then return end
			surface.PlaySound( "buttons/button24.wav" )
			
			local panel = vgui.Create( "DPanel" )
			panel:SetSize( 140, self.att:GetTall( ) )
			panel:SetAlpha( 0 )
			panel:AlphaTo( 255, 0.1, delta )
			delta = delta + 0.1
			panel.Paint = function( pnl, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
				
				if ( attributeTable.image ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawRect( w / 2 - 70 / 2, 10, 70, 70 )
					
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( attributeTable.image, "smooth" ) )
					surface.DrawTexturedRect( w / 2 - 60 / 2, 15, 60, 60 )
				else
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawRect( w / 2 - 70 / 2, 10, 70, 70 )
				end
				
				local per = v.amount / attributeTable.max
				
				attAni = Lerp( 0.08, attAni, per * 360 )
				attTextAni = Lerp( 0.08, attTextAni, per )
				
				draw.NoTexture( )
				surface.SetDrawColor( 100, 100, 100, 255 )
				catherine.geometry.DrawCircle( w / 2, h - 60, 40, 5, 90, 360, 100 )
				
				draw.NoTexture( )
				surface.SetDrawColor( 255, 255, 255, 255 )
				catherine.geometry.DrawCircle( w / 2, h - 60, 40, 5, 90, attAni, 100 )
				
				draw.SimpleText( math.Round( attTextAni * 100 ) .. " %", "catherine_lightUI30", w / 2, h - 60, Color( 255, 255, 255, 255 ), 1, 1 )
			end
			
			local panel_w, panel_h = panel:GetWide( ), panel:GetTall( )
			
			local attName = vgui.Create( "DLabel", panel )
			attName:SetColor( Color( 255, 255, 255, 255 ) )
			attName:SetFont( "catherine_normal20" )
			attName:SetText( catherine.util.StuffLanguage( attributeTable.name ) )
			attName:SizeToContents( )
			attName:SetPos( panel_w / 2 - attName:GetWide( ) / 2, 90 )
			attName.PerformLayout = function( pnl, w, h )
				if ( w >= panel_w ) then
					pnl:SetWide( panel_w - 15 )
					pnl:SetPos( panel_w / 2 - pnl:GetWide( ) / 2, 90 )
				end
			end
			
			self.att:AddItem( panel )
			self.att:SetWide( math.Clamp( 160 * k, 0, self.w ) )
			self.att:SetPos( self.w / 2 - self.att:GetWide( ) / 2, self.h / 2 - self.att:GetTall( ) / 2 )
		end )
		
		delay = delay + 0.5
	end
	
	timer.Simple( delay, function( )
		if ( IsValid( self ) ) then
			self.createdAtt = true
		end
	end )
end

function PANEL:PrintErrorMessage( msg )
	Derma_Message( msg, LANG( "Basic_UI_Notify" ), LANG( "Basic_UI_OK" ) )
end

function PANEL:Paint( w, h )
	if ( self.noDrawPaint ) then return end
	
	if ( self.data.att ) then
		if ( table.Count( self.data.att ) > 0 ) then
			draw.SimpleText( LANG( "Character_UI_ThisisAttribute" ), "catherine_normal25", w / 2, h * 0.2, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( LANG( "Character_UI_NoneAttribute" ), "catherine_normal25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		end
	else
		draw.SimpleText( ":)", "catherine_normal50", w / 2, h / 2 - 50, Color( 255, 255, 255, 255 ), 1, 1 )
		draw.SimpleText( LANG( "Character_UI_WaitAttribute" ), "catherine_normal20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
	end
end

vgui.Register( "catherine.character.stageThree", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Character_UI_Title" )
end, "character", function( menuPnl, itemPnl )
	vgui.Create( "catherine.vgui.character" )
	menuPnl:Close( )
end )