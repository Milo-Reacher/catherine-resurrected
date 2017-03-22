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
	catherine.vgui.question = self

	self.answers = { }
	self.player = catherine.pl
	self.backgroundPanelH = 0
	self.blurAmount = 0
	self.w, self.h = ScrW( ), ScrH( )
	self.questionTitle = LANG( "Question_UIStr" )
	
	self:SetSize( self.w, self.h )
	self:Center( )
	self:SetTitle( "" )
	self:MakePopup( )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	
	self.List = vgui.Create( "DPanelList", self )
	self.List:SetSpacing( 0 )
	self.List:EnableHorizontal( false )
	self.List:EnableVerticalScrollbar( true )
	self.List:SetDrawBackground( false )
	
	self.start = vgui.Create( "catherine.vgui.button", self )
	self.start:SetPos( self.w * 0.7, self.h - self.h * 0.1 / 2 - 30 / 2 )
	self.start:SetSize( self.w * 0.2, 30 )
	self.start:SetStr( LANG( "Question_UI_Continue" ) )
	self.start:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.start:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.start.Click = function( pnl )
		if ( table.Count( self.answers ) != #catherine.question.GetAll( ) ) then return end
		
		Derma_Query( LANG( "Question_Notify_ContinueQ" ), "", LANG( "Basic_UI_YES" ), function( )
			netstream.Start( "catherine.question.Check", self.answers )
		end, LANG( "Basic_UI_NO" ), function( ) end )
	end
	self.start.PaintOverAll = function( pnl, w, h )
		if ( table.Count( self.answers ) != #catherine.question.GetAll( ) ) then
			pnl:SetAlpha( 100 )
		else
			pnl:SetAlpha( 255 )
		end
		
		surface.SetDrawColor( 255, 255, 255, 30 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self.changeLanguage = vgui.Create( "catherine.vgui.button", self )
	self.changeLanguage:SetPos( self.w - ( self.w * 0.2 ) - 50, self.h * 0.1 / 2 - 30 / 2 )
	self.changeLanguage:SetSize( self.w * 0.2, 30 )
	self.changeLanguage:SetStr( "" )
	self.changeLanguage:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.changeLanguage:SetGradientColor( Color( 255, 255, 255, 255 ) )
	self.changeLanguage.Click = function( pnl )
		local menu = DermaMenu( )
			
		for k, v in pairs( catherine.language.GetAll( ) ) do
			menu:AddOption( v.name, function( )
				RunConsoleCommand( "cat_convar_language", k )
				catherine.help.lists = { }
				catherine.menu.Rebuild( )
				
				timer.Simple( 0, function( )
					self.start:SetStr( LANG( "Question_UI_Continue" ) )
					self.disconnect:SetStr( LANG( "Question_UI_Disconnect" ) )
					self.questionTitle = LANG( "Question_UIStr" )
					
					self.answers = { }
					self:RebuildQuestion( )
					
					hook.Run( "LanguageChanged" )
				end )
			end )
		end
		
		menu:Open( )
	end
	self.changeLanguage.PaintOverAll = function( pnl, w, h )
		local languageTable = catherine.language.FindByID( GetConVarString( "cat_convar_language" ) )
		
		if ( languageTable ) then
			pnl:SetStr( languageTable.name )
		end
		
		surface.SetDrawColor( 255, 255, 255, 30 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self.disconnect = vgui.Create( "catherine.vgui.button", self )
	self.disconnect:SetPos( self.w * 0.1, self.h - self.h * 0.1 / 2 - 30 / 2 )
	self.disconnect:SetSize( self.w * 0.2, 30 )
	self.disconnect:SetStr( LANG( "Question_UI_Disconnect" ) )
	self.disconnect:SetStrColor( Color( 255, 255, 255, 255 ) )
	self.disconnect:SetGradientColor( Color( 255, 0, 0, 255 ) )
	self.disconnect.Click = function( )
		Derma_Query( LANG( "Question_Notify_DisconnectQ" ), "", LANG( "Basic_UI_YES" ), function( )
			RunConsoleCommand( "disconnect" )
		end, LANG( "Basic_UI_NO" ), function( ) end )
	end
	self.disconnect.PaintOverAll = function( pnl, w, h )
		surface.SetDrawColor( 255, 50, 50, 30 )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	self:RebuildQuestion( )
end

function PANEL:RebuildQuestion( )
	local questionTable = catherine.question.GetAll( )
	
	self.List:SetSize( self.w * 0.8, math.min( 60 * #questionTable, self.h - self.h * 0.2 ) )
	self.List:SetPos( self.w / 2 - self.List:GetWide( ) / 2, self.h / 2 - self.List:GetTall( ) / 2 )
	
	self.List:Clear( )
	
	if ( #questionTable == 0 ) then
		self:Close( )
		return
	end
	
	for k, v in pairs( questionTable ) do
		local title = catherine.util.StuffLanguage( v.title )
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.List:GetWide( ), 60 )
		panel.Paint = function( pnl, w, h )
			draw.SimpleText( k .. ".", "catherine_normal25", 10, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( title, "catherine_normal20", 40, 10, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ) * 0.5 - 20, 20 )
		button:SetPos( panel:GetWide( ) * 0.5, panel:GetTall( ) - 30 )
		button:SetFont( "catherine_normal15" )
		button:SetText( "" )
		button:SetTextColor( Color( 255, 255, 255 ) )
		button.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 100 ) )
		end
		button.DoClick = function( )
			local menu = DermaMenu( )
			
			for k1, v1 in pairs( v.answerList ) do
				local val = catherine.util.StuffLanguage( v1 )
				
				menu:AddOption( val, function( )
					button:SetText( val )
					self.answers[ k ] = k1
				end )
			end
			
			menu:Open( )
		end
		
		self.List:AddItem( panel )
	end
end

function PANEL:Paint( w, h )
	self.backgroundPanelH = Lerp( 0.05, self.backgroundPanelH, h * 0.1 )
	
	if ( !catherine.character.IsCustomBackground( ) ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 255 ) )
		
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.SetMaterial( Material( "gui/gradient_down" ) )
		surface.DrawTexturedRect( 0, self.backgroundPanelH, w, h - self.backgroundPanelH )
	else
		if ( self.closing ) then
			self.blurAmount = Lerp( 0.03, self.blurAmount, 0 )
		else
			self.blurAmount = Lerp( 0.03, self.blurAmount, 3 )
		end
		
		catherine.util.BlurDraw( 0, 0, w, h, self.blurAmount )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
	end
	
	draw.RoundedBox( 0, 0, 0, w, self.backgroundPanelH, Color( 50, 50, 50, 255 ) )
	draw.RoundedBox( 0, 0, h - self.backgroundPanelH, w, self.backgroundPanelH, Color( 50, 50, 50, 255 ) )
	
	draw.SimpleText( self.questionTitle, "catherine_normal25", 25, self.backgroundPanelH / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
end

function PANEL:Close( )
	if ( self.closing ) then return end
	
	self.closing = true
	
	self:Remove( )
	self = nil
	
	timer.Simple( 0, function( )
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:SetVisible( true )
		end
	end )
end

vgui.Register( "catherine.vgui.question", PANEL, "DFrame" )