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
	catherine.vgui.recognize = self
	
	self.w, self.h = 500, 40 + ( 20 * 4 ) + ( 5 * 4 )
	self.x, self.y = ScrW( ) / 2 - self.w / 2, ScrH( ) / 2 - self.h / 2
	
	self:SetSize( self.w, self.h )
	self:SetPos( self.x, self.y )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
	self:MakePopup( )
	
	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h ) end
	
	self:BuildRecognizeOptions( )
end

function PANEL:Paint( w, h )
	catherine.theme.Draw( CAT_THEME_MENU_BACKGROUND_NOTITLE, w, h )
	
	draw.SimpleText( LANG( "Basic_UI_RecogniseMenuOptionTitle" ), "catherine_normal20", w / 2, 15, Color( 255, 255, 255, 255 ), 1, 1 )
end

function PANEL:OnKeyCodePressed( key )
	if ( key == KEY_F2 ) then
		self:Close( )
	end
end

function PANEL:BuildRecognizeOptions( )
	local funcData = {
		{
			title = LANG( "Recognize_UI_Option_LookingPlayer" ),
			func = function( )
				local pl = catherine.pl
			
				local data = { }
				data.start = pl:GetShootPos( )
				data.endpos = data.start + pl:GetAimVector( ) * 96
				data.filter = pl
				local ent = util.TraceLine( data ).Entity
				
				if ( IsValid( ent ) and ent:IsPlayer( ) ) then
					netstream.Start( "catherine.recognize.DoKnow", {
						0,
						ent
					} )
				else
					catherine.notify.Add( LANG( "Entity_Notify_NotPlayer" ), 5 )
				end
			end,
			icon = "icon16/status_online.png"
		},
		{
			title = LANG( "Recognize_UI_Option_TalkRange" ),
			func = function( )
				netstream.Start( "catherine.recognize.DoKnow", { 0 } )
			end,
			icon = "icon16/user.png"
		},
		{
			title = LANG( "Recognize_UI_Option_WhisperRange" ),
			func = function( )
				netstream.Start( "catherine.recognize.DoKnow", { 1 } )
			end,
			icon = "icon16/user_green.png"
		},
		{
			title = LANG( "Recognize_UI_Option_YellRange" ),
			func = function( )
				netstream.Start( "catherine.recognize.DoKnow", { 2 } )
			end,
			icon = "icon16/user_red.png"
		}
	}
	
	self.Lists:Clear( )
	
	for k, v in pairs( funcData ) do
		local onMouse = false
		local onMouseAlpha = 0
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( self.Lists:GetWide( ), 20 )
		panel.Paint = function( pnl, w, h ) end
		
		local button = vgui.Create( "DButton", panel )
		button:SetSize( panel:GetWide( ), 20 )
		button:Center( )
		button:SetText( "" )
		button.OnCursorEntered = function( pnl )
			onMouse = true
		end
		button.OnCursorExited = function( pnl )
			onMouse = false
		end
		button.Paint = function( pnl, w, h )
			if ( onMouse ) then
				onMouseAlpha = Lerp( 0.1, onMouseAlpha, 255 )
			else
				onMouseAlpha = Lerp( 0.1, onMouseAlpha, 0 )
			end
			
			draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, onMouseAlpha ) )
		end
		button.DoClick = function( )
			v.func( )
			self:Close( )
		end
		
		local image = vgui.Create( "DImage", panel )
		image:SetPos( 5, 3 )
		image:SetSize( 16, 16 )
		image:SetImage( v.icon )
		
		local text = vgui.Create( "DLabel", panel )
		text:SetPos( 40, 3 )
		text:SetText( v.title )
		text:SetFont( "catherine_normal15" )
		text:SetTextColor( Color( 255, 255, 255 ) )
		text:SizeToContents( )
		text:Center( )
		
		self.Lists:AddItem( panel )
	end
end

function PANEL:Close( )
	self:AlphaTo( 0, 0.1, 0, function( )
		self:Remove( )
		self = nil
	end )
end

vgui.Register( "catherine.vgui.recognize", PANEL, "DFrame" )

hook.Add( "VGUIMousePressed", "catherine.vgui.recognize.VGUIMousePressed", function( pnl, code )
	if ( !IsValid( catherine.vgui.recognize ) ) then return end
	
	if ( IsValid( pnl ) and pnl:GetName( ) == "GModBase" ) then
		catherine.vgui.recognize:Close( )
	end
end )