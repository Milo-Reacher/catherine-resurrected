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
	catherine.vgui.help = self
	
	self.helps = { }
	self.isDef = true
	
	self:SetMenuSize( ScrW( ) * 0.95, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Help_UI_Title" ) )
	
	self.category = vgui.Create( "DHorizontalScroller", self )
	self.category:SetPos( 10, 35 )
	self.category:SetSize( self.w - 20, 20 )
	
	local defTitle = LANG( "Help_UI_DefPageTitle" )
	local defDesc = LANG( "Help_UI_DefPageDesc" )
	
	self.html = vgui.Create( "DHTML", self )
	self.html:SetPos( 10, 65 )
	self.html:SetSize( self.w - 20, self.h - 75 )
	self.html.Paint = function( pnl, w, h )
		if ( self.isDef ) then
			draw.SimpleText( defTitle, "catherine_slight25", w / 2, h / 2 - 25, Color( 255, 255, 255, 255 ), 1, 1 )
			draw.SimpleText( defDesc, "catherine_slight20", w / 2, h / 2 + 10, Color( 235, 235, 235, 255 ), 1, 1 )
		end
	end
	
	self:InitalizeHelps( )
end

function PANEL:OnMenuRecovered( )
	self.category:Remove( )
	
	self.category = vgui.Create( "DHorizontalScroller", self )
	self.category:SetPos( 10, 35 )
	self.category:SetSize( self.w - 20, 20 )
	
	self:InitalizeHelps( )
end

function PANEL:InitalizeHelps( )
	self.helps = { }
	
	for k, v in pairs( catherine.help.GetAll( ) ) do
		self.helps[ v.category ] = v
	end
	
	self:BuildHelps( )
end

function PANEL:DoWork( data )
	if ( data.types == CAT_HELP_WEBPAGE ) then
		self.html:OpenURL( data.codes )
		
		return
	end
	
	local prefix = [[
		<head>
		<style>
			body {
				background-color: #fbfcfc;
				color: #2c3e50;
				font-family: "나눔고딕", "NanumGothic", "맑은 고딕", "Malgun Gothic", "함초롬돋움", "HCR Dotum", "굴림", "Gulim", "sans-serif";
			}
		</style>
		</head>
	]]
	
	self.html:SetHTML( data.noPrefix and data.codes or ( prefix .. data.codes ) )
end

function PANEL:BuildHelps( )
	for k, v in SortedPairs( self.helps ) do
		surface.SetFont( "catherine_slight20" )
		
		local tw, th = surface.GetTextSize( k )
		
		local panel = vgui.Create( "catherine.vgui.button", self )
		panel:SetSize( tw + 40, 30 )
		panel:SetStr( k )
		panel:SetStrFont( "catherine_slight20" )
		panel:SetStrColor( Color( 255, 255, 255, 255 ) )
		panel:SetGradientColor( Color( 255, 255, 255, 255 ) )
		panel.Click = function( )
			self.isDef = false
			self:DoWork( v )
		end
		
		self.category:AddPanel( panel )
	end
end

vgui.Register( "catherine.vgui.help", PANEL, "catherine.vgui.menuBase" )

catherine.menu.Register( function( )
	return LANG( "Help_UI_Title" )
end, "help", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.help ) and catherine.vgui.help or vgui.Create( "catherine.vgui.help", menuPnl )
end )