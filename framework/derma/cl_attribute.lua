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
	catherine.vgui.attribute = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Attribute_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists:SetDrawBackground( false )

	self:BuildAttribute( )
end

function PANEL:OnMenuRecovered( )
	self:BuildAttribute( )
end

function PANEL:BuildAttribute( )
	self.Lists:Clear( )

	for k, v in pairs( catherine.attribute.GetAll( ) ) do
		local item = vgui.Create( "catherine.vgui.attributeItem" )
		item:SetTall( 90 )
		item:SetAttribute( v )
		item:SetProgress( catherine.attribute.GetProgress( k ) )
		item:SetTemporaryProgress( { catherine.attribute.GetTemporaryProgress( k ) } )

		self.Lists:AddItem( item )
	end
end

vgui.Register( "catherine.vgui.attribute", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	self.attributeTable = nil
	self.attAni = 0
	self.attIncreaseAni = 0
	self.attDecreaseAni = 0
	
	self.attTextAni = 0
	self.attProgress = 0
	
	self.attIncreaseProgress = 0
	self.attDecreaseProgress = 0
end

function PANEL:Paint( w, h )
	if ( !self.attributeTable ) then return end
	local per = self.attProgress / self.attributeTable.max
	local perForAni = per
	local per2 = 0
	local per3 = 0
	
	if ( self.attIncreaseProgress != 0 ) then
		per2 = self.attIncreaseProgress / self.attributeTable.max
		self.attIncreaseAni = Lerp( 0.08, self.attIncreaseAni, per2 * 360 )
	end
	
	if ( self.attDecreaseProgress != 0 ) then
		per3 = self.attDecreaseProgress / self.attributeTable.max
		perForAni = perForAni - per3
		self.attDecreaseAni = Lerp( 0.08, self.attDecreaseAni, per3 * 360 )
	end
	
	self.attAni = Lerp( 0.08, self.attAni, perForAni * 360 )
	self.attTextAni = Lerp( 0.1, self.attTextAni, per + per2 - per3 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 100, 100, 100, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, 360, 100 )
	
	draw.NoTexture( )
	surface.SetDrawColor( 255, 255, 255, 255 )
	catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90, self.attAni, 100 )
	
	if ( per2 != 0 ) then
		draw.NoTexture( )
		surface.SetDrawColor( 90, 255, 90, 255 )
		catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90 + self.attAni, self.attIncreaseAni, 100 )	
	end
	
	if ( per3 != 0 ) then
		draw.NoTexture( )
		surface.SetDrawColor( 255, 90, 90, 255 )
		catherine.geometry.DrawCircle( w - ( h / 3 ) - 15, h / 2, h / 3, 5, 90 + self.attAni + self.attIncreaseAni, self.attDecreaseAni, 100 )	
	end
	
	if ( self.attributeTable.image ) then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 10, 10, 70, 70 )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( self.attributeTable.image, "smooth" ) )
		surface.DrawTexturedRect( 15, 15, 60, 60 )
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 10, 10, 70, 70 )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( Material( "CAT/ui/icon_idk.png", "smooth" ) )
		surface.DrawTexturedRect( 15, 15, 60, 60 )
	end
	
	draw.SimpleText( self.attribute_name, "catherine_normal25", 100, 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.attribute_desc, "catherine_normal15", 100, 60, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
	
	draw.SimpleText( math.Round( self.attTextAni * 100 ) .. " %", "catherine_normal20", w - ( h / 3 ) - 15, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
end

function PANEL:SetAttribute( attributeTable )
	self.attributeTable = attributeTable
	self.attribute_name = catherine.util.StuffLanguage( attributeTable.name )
	self.attribute_desc = catherine.util.StuffLanguage( attributeTable.desc )
end

function PANEL:SetProgress( progress )
	self.attProgress = progress
end

function PANEL:SetTemporaryProgress( progressTable )
	self.attIncreaseProgress = progressTable[ 1 ]
	self.attDecreaseProgress = progressTable[ 2 ]
end

vgui.Register( "catherine.vgui.attributeItem", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Attribute_UI_Title" )
end, "att", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.attribute ) and catherine.vgui.attribute or vgui.Create( "catherine.vgui.attribute", menuPnl )
end )