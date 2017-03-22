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

function Derma_Message( strText, _, strButtonText, sound )
	if ( type( sound ) == "string" ) then
		surface.PlaySound( sound )
	elseif ( sound != false ) then
		surface.PlaySound( "CAT/notify01.wav" )
	end
	
	local blurAmount = 0
	
	local Background = vgui.Create( "DFrame" )
	Background:SetTitle( "" )
	Background:SetSize( ScrW( ), ScrH( ) )
	Background:Center( )
	Background:SetDraggable( false )
	Background:ShowCloseButton( false )
	Background:MakePopup( )
	Background.Paint = function( pnl, w, h )
		blurAmount = Lerp( 0.03, blurAmount, 5 )
		
		catherine.util.BlurDraw( 0, 0, w, h, blurAmount )
	end
	
	local Window = vgui.Create( "DFrame", Background )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), 0 )
	Window:Center( )
	Window:SizeTo( ScrW( ), 150, 0.1, 0 )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window.Paint = function( pnl, w, h )
		pnl:Center( )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 0, 0, 0, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, h, Color( 0, 0, 0, 255 ) )
		
		draw.SimpleText( LANG( "Basic_DermaUtil_MessageTitle" ):upper( ), "catherine_normal20", 15, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		local wrapTexts = catherine.util.GetWrapTextData( strText, w / 2, "catherine_normal15" )
		
		if ( #wrapTexts == 1 ) then
			draw.SimpleText( wrapTexts[ 1 ], "catherine_normal15", w / 2, 75, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			local textY = 75 - ( #wrapTexts * 20 ) / 2
			
			for k, v in pairs( wrapTexts ) do
				draw.SimpleText( v, "catherine_normal15", w / 2, textY + k * 20, Color( 255, 255, 255, 255 ), 1, 1 )
			end
		end
	end
	Window.Think = function( pnl )
		pnl:MoveToFront( )
		pnl:Center( )
	end
	Window.Close = function( pnl )
		Background:Remove( )
	end
	
	local Okay = vgui.Create( "catherine.vgui.button", Window )
	Okay:SetPos( 10, 10 )
	Okay:SetSize( 200, 25 )
	Okay:SetStr( strButtonText or LANG( "Basic_UI_OK" ) )
	Okay:SetStrColor( Color( 255, 255, 255, 255 ) )
	//Okay:SetGradientColor( Color( 255, 255, 255, 255 ) )
	Okay:SetStrFont( "catherine_normal15" )
	Okay.Click = function( )
		Window:SizeTo( ScrW( ), 0, 0.1, 0, nil, function( )
			Window:Close( )
		end )
	end
	Okay.PaintOverAll = function( pnl, w, h )
		pnl:SetPos( Window:GetWide( ) - 220, Window:GetTall( ) - 35 )
		
		surface.SetDrawColor( 255, 255, 255, math.max( math.sin( CurTime( ) * 8 ) * 255, 50 ) )
		surface.SetMaterial( Material( "gui/center_gradient" ) )
		surface.DrawTexturedRect( 0, h - 1, w, 1 )
	end
	
	return Window
end

function Derma_Query( strText, _, ... )
	surface.PlaySound( "CAT/notify01.wav" )
	
	local blurAmount = 0
	
	local Background = vgui.Create( "DFrame" )
	Background:SetTitle( "" )
	Background:SetSize( ScrW( ), ScrH( ) )
	Background:Center( )
	Background:SetDraggable( false )
	Background:ShowCloseButton( false )
	Background:MakePopup( )
	Background.Paint = function( pnl, w, h )
		blurAmount = Lerp( 0.03, blurAmount, 5 )
		
		catherine.util.BlurDraw( 0, 0, w, h, blurAmount )
	end
	
	local Window = vgui.Create( "DFrame", Background )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), 0 )
	Window:Center( )
	Window:SizeTo( ScrW( ), 150, 0.1, 0 )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 0, 0, 0, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, h, Color( 0, 0, 0, 255 ) )
		
		draw.SimpleText( LANG( "Basic_DermaUtil_QueryTitle" ):upper( ), "catherine_normal20", 15, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
		
		local wrapTexts = catherine.util.GetWrapTextData( strText, w / 2, "catherine_normal15" )
		
		if ( #wrapTexts == 1 ) then
			draw.SimpleText( wrapTexts[ 1 ], "catherine_normal15", w / 2, 75, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			local textY = 75 - ( #wrapTexts * 20 ) / 2
			
			for k, v in pairs( wrapTexts ) do
				draw.SimpleText( v, "catherine_normal15", w / 2, textY + k * 20, Color( 255, 255, 255, 255 ), 1, 1 )
			end
		end
	end
	Window.Think = function( pnl )
		pnl:MoveToFront( )
		pnl:Center( )
	end
	Window.Close = function( pnl )
		Background:Remove( )
	end
	
	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
	ButtonPanel:SetDrawBackground( false )
	
	local NumOptions = 0
	local x = 5
	local delta = 0.2
	
	for k = 1, 8, 2 do
		local Text = select( k, ... )
		if ( Text == nil ) then break end
		
		local Func = select( k + 1, ... ) or function( ) end
		
		local Button = vgui.Create( "catherine.vgui.button", ButtonPanel )
		Button:SetSize( 100, 20 )
		Button:SetStr( Text or LANG( "Basic_UI_OK" ) )
		Button:SetStrColor( Color( 255, 255, 255, 255 ) )
		Button:SetGradientColor( Color( 255, 255, 255, 255 ) )
		Button:SetStrFont( "catherine_normal15" )
		Button:SetAlpha( 0 )
		Button:AlphaTo( 255, 0.2, delta )
		Button.Click = function( )
			Window:SizeTo( ScrW( ), 0, 0.1, 0, nil, function( )
				Window:Close( )
				Func( )
			end )
		end
		Button:SetPos( x, 5 )
		
		x = x + Button:GetWide( ) + 5
		delta = delta + 0.1
		
		ButtonPanel:SetWide( x ) 
		NumOptions = NumOptions + 1
	end
	
	ButtonPanel:AlignBottom( 8 )
	
	if ( NumOptions == 0 ) then
		Window:Close( )
		
		return nil
	else
		ButtonPanel.Think = function( pnl )
			pnl:SetPos( Window:GetWide( ) - 20 - ( 100 * NumOptions ), Window:GetTall( ) - 35 )
		end
	end
	
	return Window
end

function Derma_StringRequest( _, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )
	surface.PlaySound( "CAT/notify01.wav" )
	
	local blurAmount = 0
	
	local Background = vgui.Create( "DFrame" )
	Background:SetTitle( "" )
	Background:SetSize( ScrW( ), ScrH( ) )
	Background:Center( )
	Background:SetDraggable( false )
	Background:ShowCloseButton( false )
	Background:MakePopup( )
	Background.Paint = function( pnl, w, h )
		blurAmount = Lerp( 0.03, blurAmount, 5 )
		
		catherine.util.BlurDraw( 0, 0, w, h, blurAmount )
	end
	
	local Window = vgui.Create( "DFrame", Background )
	Window:SetTitle( "" )
	Window:SetSize( ScrW( ), 0 )
	Window:Center( )
	Window:SizeTo( ScrW( ), 150, 0.1, 0 )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:MakePopup( )
	Window.Paint = function( pnl, w, h )
		pnl:Center( )
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )
		draw.RoundedBox( 0, 0, 0, w, 1, Color( 0, 0, 0, 255 ) )
		draw.RoundedBox( 0, 0, h - 1, w, h, Color( 0, 0, 0, 255 ) )
		
		draw.SimpleText( LANG( "Basic_DermaUtil_QueryTitle" ):upper( ), "catherine_normal20", 15, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
		draw.SimpleText( strText, "catherine_normal15", w / 2, 55, Color( 255, 255, 255, 255 ), 1, 1 )
	end
	Window.Think = function( pnl )
		pnl:MoveToFront( )
		pnl:Center( )
	end
	Window.Close = function( pnl )
		Background:Remove( )
	end
	
	local TextEntry = vgui.Create( "DTextEntry", Window )
	TextEntry:SetText( strDefaultText or "" )
	TextEntry.OnEnter = function( pnl )
		Window:SizeTo( ScrW( ), 0, 0.1, 0, nil, function( )
			Window:Close( )
			fnEnter( TextEntry:GetText( ) )
		end )
	end
	TextEntry.Paint = function( pnl, w, h )
		catherine.theme.Draw( CAT_THEME_TEXTENT, w, h )
		
		pnl:SetPos( Window:GetWide( ) / 2 - TextEntry:GetWide( ) / 2, Window:GetTall( ) * 0.7 )
		pnl:DrawTextEntryText( Color( 255, 255, 255 ), Color( 110, 110, 110 ), Color( 255, 255, 255 ) )
	end
	TextEntry:SetSize( ScrW( ) * 0.5, 20 )
	TextEntry:SetPos( Window:GetWide( ) / 2 - TextEntry:GetWide( ) / 2, Window:GetTall( ) / 2 - TextEntry:GetTall( ) / 2 )
	TextEntry:SetFont( "catherine_normal15" )
	
	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 20 )
	ButtonPanel:SetDrawBackground( false )
	ButtonPanel.Think = function( pnl )
		pnl:SetPos( Window:GetWide( ) - 220, Window:GetTall( ) - 35 )
	end
	
	local Button = vgui.Create( "catherine.vgui.button", ButtonPanel )
	Button:SetSize( 100, 20 )
	Button:SetStr( strButtonText or LANG( "Basic_UI_OK" ) )
	Button:SetStrColor( Color( 255, 255, 255, 255 ) )
	Button:SetGradientColor( Color( 255, 255, 255, 255 ) )
	Button:SetStrFont( "catherine_normal15" )
	Button:SetAlpha( 0 )
	Button:AlphaTo( 255, 0.2, 0.2 )
	Button.DoClick = function( )
		Window:SizeTo( ScrW( ), 0, 0.1, 0, nil, function( )
			Window:Close( )
			fnEnter( TextEntry:GetText( ) )
		end )
	end
	
	local ButtonCancel = vgui.Create( "catherine.vgui.button", ButtonPanel )
	ButtonCancel:SetSize( 100, 20 )
	ButtonCancel:SetStr( strButtonCancelText or LANG( "Basic_UI_NO" ) )
	ButtonCancel:SetStrColor( Color( 255, 255, 255, 255 ) )
	ButtonCancel:SetGradientColor( Color( 255, 255, 255, 255 ) )
	ButtonCancel:SetStrFont( "catherine_normal15" )
	ButtonCancel:SetAlpha( 0 )
	ButtonCancel:AlphaTo( 255, 0.2, 0.4 )
	ButtonCancel.DoClick = function( )
		Window:SizeTo( ScrW( ), 0, 0.1, 0, nil, function( )
			Window:Close( )
			
			if ( fnCancel ) then
				fnCancel( TextEntry:GetText( ) )
			end
		end )
	end
	ButtonCancel:MoveRightOf( Button, 5 )
	
	ButtonPanel:SetWide( Button:GetWide( ) + 5 + ButtonCancel:GetWide( ) + 10 )
	
	TextEntry:RequestFocus( )
	TextEntry:SelectAllText( true )
	
	ButtonPanel:CenterHorizontal( )
	ButtonPanel:AlignBottom( 8 )
	
	return Window
end