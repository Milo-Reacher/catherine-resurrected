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
	catherine.vgui.option = self

	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( LANG( "Option_UI_Title" ) )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 10, 35 )
	self.Lists:SetSize( self.w - 20, self.h - 45 )
	self.Lists:SetSpacing( 0 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )
	self.Lists.Paint = function( pnl, w, h ) end
	
	self:InitializeOption( )
end

function PANEL:OnMenuSizeChanged( )

end

function PANEL:OnMenuRecovered( )
	self:InitializeOption( )
end

function PANEL:InitializeOption( )
	local option = { }
	
	for k, v in pairs( catherine.option.GetAll( ) ) do
		local category = v.category
		
		option[ category ] = option[ category ] or { }
		option[ category ][ #option[ category ] + 1 ] = v
	end
	
	self.optionTable = option
	
	self:BuildOption( )
end

function PANEL:BuildOption( )
	local scrollBar = self.Lists.VBar
	local scroll = scrollBar.Scroll
	
	self.Lists:Clear( )
	
	for k, v in SortedPairs( self.optionTable or { } ) do
		local form = vgui.Create( "DForm" )
		form:SetName( catherine.util.StuffLanguage( k ) )
		form:SetSpacing( 0 )
		form.Paint = function( pnl, w, h ) end
		form.Header:SetFont( "catherine_lightUI25" )
		form.Header:SetTall( 25 )
		form.Header:SetTextColor( Color( 255, 255, 255, 255 ) )
		
		for k1, v1 in SortedPairs( v ) do
			local item = vgui.Create( "catherine.vgui.optionItem" )
			item:SetSize( self.Lists:GetWide( ), 40 )
			item:SetOption( v1 )
			
			form:AddItem( item )
		end
		
		self.Lists:AddItem( form )
	end
	
	scrollBar:AnimateTo( scroll, 0.3, 0, 0.1 )
end

vgui.Register( "catherine.vgui.option", PANEL, "catherine.vgui.menuBase" )

local PANEL = { }

function PANEL:Init( )
	self.Button = vgui.Create( "DButton", self )
	self.Button:SetSize( 40, 40 )
	self.Button:SetPos( self:GetWide( ) - self.Button:GetWide( ) - 20, self:GetTall( ) / 2 - self.Button:GetTall( ) / 2 )
	self.Button:SetText( "" )
	self.Button.Paint = function( pnl, w, h )
		if ( !self.optionTable ) then return end
		
		self.val = catherine.option.Get( self.optionTable.uniqueID )
		
		if ( tobool( self.val ) == true ) then
			draw.SimpleText( "✔", "catherine_normal35", 15, 15, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
		end
	end
	self.Button.DoClick = function( pnl )
		surface.PlaySound( "common/talk.wav" )
		catherine.option.Toggle( self.optionTable.uniqueID )
	end
	
	self.List = vgui.Create( "DButton", self )
	self.List:SetSize( self:GetWide( ) * 0.3, 30 )
	self.List:SetPos( self:GetWide( ) - self.List:GetWide( ) - 20, self:GetTall( ) / 2 - self.List:GetTall( ) / 2 )
	self.List:SetVisible( false )
	self.List:SetFont( "catherine_normal15" )
	self.List:SetTextColor( Color( 255, 255, 255 ) )
	self.List.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, h - 1, w, 1, Color( 255, 255, 255, 255 ) )
	end
end

function PANEL:Paint( w, h )
	if ( !self.optionTable ) then return end
	
	draw.SimpleText( "< " .. self.name .. " >", "catherine_normal15", 15, 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, 1 )
	draw.SimpleText( self.desc, "catherine_normal15", 15, 25, Color( 235, 235, 235, 255 ), TEXT_ALIGN_LEFT, 1 )
end

function PANEL:PerformLayout( w, h, optionData )
	self.Button:SetSize( 40, 40 )
	self.Button:SetPos( w - self.Button:GetWide( ) - 20, h / 2 - self.Button:GetTall( ) / 2 )
	
	self.List:SetSize( self:GetWide( ) * 0.4, 20 )
	self.List:SetPos( self:GetWide( ) - self.List:GetWide( ) - 20, self:GetTall( ) / 2 - self.List:GetTall( ) / 2 )
end

function PANEL:SetOption( optionTable )
	self.optionTable = optionTable
	self.name = catherine.util.StuffLanguage( optionTable.name )
	self.desc = catherine.util.StuffLanguage( optionTable.desc )
	
	if ( optionTable.typ == CAT_OPTION_LIST ) then
		self.Button:SetVisible( false )
		self.List:SetVisible( true )
		
		local data = optionTable.data( )
		
		self.List:SetText( data.curVal )
		
		self.List.DoClick = function( )
			local menu = DermaMenu( )
			
			for k, v in pairs( data.data ) do
				menu:AddOption( v.name, function( )
					v.func( )
					self.List:SetText( v.name )
				end )
			end
			
			menu:Open( )
		end
	end
end

vgui.Register( "catherine.vgui.optionItem", PANEL, "DPanel" )

catherine.menu.Register( function( )
	return LANG( "Option_UI_Title" )
end, "option", function( menuPnl, itemPnl )
	return IsValid( catherine.vgui.option ) and catherine.vgui.option or vgui.Create( "catherine.vgui.option", menuPnl )
end )