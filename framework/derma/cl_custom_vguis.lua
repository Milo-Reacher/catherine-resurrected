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

--[[   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DMenu

--]]

local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", 			"DrawBorder" )
AccessorFunc( PANEL, "m_bDeleteSelf", 		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth", 	"MinimumWidth" )
AccessorFunc( PANEL, "m_bDrawColumn", 		"DrawColumn" )
AccessorFunc( PANEL, "m_iMaxHeight", 		"MaxHeight" )

AccessorFunc( PANEL, "m_pOpenSubMenu", 		"OpenSubMenu" )


--[[---------------------------------------------------------
	Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetIsMenu( true )
	self:SetDrawBorder( true )
	self:SetDrawBackground( true )
	self:SetMinimumWidth( 100 )
	self:SetDrawOnTop( true )
	self:SetMaxHeight( ScrH() * 0.9 )
	self:SetDeleteSelf( true )
		
	self:SetPadding( 0 )
	
	-- Automatically remove this panel when menus are to be closed
	RegisterDermaMenuForClose( self )

end

--[[---------------------------------------------------------
	AddPanel
-----------------------------------------------------------]]
function PANEL:AddPanel( pnl )

	self:AddItem( pnl )
	pnl.ParentMenu = self
	
end

--[[---------------------------------------------------------
	AddOption
-----------------------------------------------------------]]
function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( "DMenuOption", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	self:AddPanel( pnl )
	
	return pnl

end

--[[---------------------------------------------------------
	AddCVar
-----------------------------------------------------------]]
function PANEL:AddCVar( strText, convar, on, off, funcFunction )

	local pnl = vgui.Create( "DMenuOptionCVar", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	pnl:SetConVar( convar )
	pnl:SetValueOn( on )
	pnl:SetValueOff( off )
	
	self:AddPanel( pnl )
	
	return pnl

end

--[[---------------------------------------------------------
	AddSpacer
-----------------------------------------------------------]]
function PANEL:AddSpacer( strText, funcFunction )

	local pnl = vgui.Create( "DPanel", self )
	pnl.Paint = function( p, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 100 ) )
		surface.DrawRect( 0, 0, w, h )
	end
	
	pnl:SetTall( 1 )	
	self:AddPanel( pnl )
	
	return pnl

end

--[[---------------------------------------------------------
	AddSubMenu
-----------------------------------------------------------]]
function PANEL:AddSubMenu( strText, funcFunction )

	local pnl = vgui.Create( "DMenuOption", self )
	local SubMenu = pnl:AddSubMenu( strText, funcFunction )

	pnl:SetText( strText )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return SubMenu, pnl

end

--[[---------------------------------------------------------
	Hide
-----------------------------------------------------------]]
function PANEL:Hide()

	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
		openmenu:Hide()
	end
	
	self:SetVisible( false )
	self:SetOpenSubMenu( nil )
	
end

--[[---------------------------------------------------------
	OpenSubMenu
-----------------------------------------------------------]]
function PANEL:OpenSubMenu( item, menu )

	-- Do we already have a menu open?
	local openmenu = self:GetOpenSubMenu()
	if ( IsValid( openmenu ) ) then
	
		-- Don't open it again!
		if ( menu && openmenu == menu ) then return end
	
		-- Close it!
		self:CloseSubMenu( openmenu )
	
	end
	
	if ( !IsValid( menu ) ) then return end

	local x, y = item:LocalToScreen( self:GetWide(), 0 )
	menu:Open( x-3, y, false, item )
	
	self:SetOpenSubMenu( menu )

end


--[[---------------------------------------------------------
	CloseSubMenu
-----------------------------------------------------------]]
function PANEL:CloseSubMenu( menu )

	menu:Hide()
	self:SetOpenSubMenu( nil )

end

--[[---------------------------------------------------------
	Paint
-----------------------------------------------------------]]
function PANEL:Paint( w, h )

	if ( !self:GetDrawBackground() ) then return end

	catherine.theme.Draw( CAT_THEME_DERMA_MENU_BACKGROUND, w, h )
	
	return true

end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild( num )
	return self:GetCanvas():GetChildren()[ num ]
end

--[[---------------------------------------------------------
	PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local w = self:GetMinimumWidth()
	
	-- Find the widest one
	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
	
		pnl:PerformLayout()
		w = math.max( w, pnl:GetWide() )
	
	end

	self:SetWide( w )
	
	local y = 0 -- for padding
	
	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
	
		pnl:SetWide( w )
		pnl:SetPos( 0, y )
		pnl:InvalidateLayout( true )
		
		y = y + pnl:GetTall()
	
	end
	
	y = math.min( y, self:GetMaxHeight() )
	
	self:SetTall( y )

	derma.SkinHook( "Layout", "Menu", self )
	
	DScrollPanel.PerformLayout( self )

end


--[[---------------------------------------------------------
	Open - Opens the menu. 
	x and y are optional, if they're not provided the menu 
		will appear at the cursor.
-----------------------------------------------------------]]
function PANEL:Open( x, y, skipanimation, ownerpanel )

	RegisterDermaMenuForClose( self )
	
	local maunal = x and y

	x = x or gui.MouseX()
	y = y or gui.MouseY()
	
	local OwnerHeight = 0
	local OwnerWidth = 0
	
	if ( ownerpanel ) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end
		
	self:PerformLayout()
		
	local w = self:GetWide()
	local h = self:GetTall()
	
	self:SetSize( w, h )
	
	
	if ( y + h > ScrH() ) then y = ((maunal and ScrH()) or (y + OwnerHeight)) - h end
	if ( x + w > ScrW() ) then x = ((maunal and ScrW()) or x) - w end
	if ( y < 1 ) then y = 1 end
	if ( x < 1 ) then x = 1 end
	
	self:SetPos( x, y )
	
	-- Popup!
	self:MakePopup()
	
	-- Make sure it's visible!
	self:SetVisible( true )
	
	-- Keep the mouse active while the menu is visible.
	self:SetKeyboardInputEnabled( false )
	
end

--
-- Called by DMenuOption
--
function PANEL:OptionSelectedInternal( option )

	self:OptionSelected( option, option:GetText() )

end

function PANEL:OptionSelected( option, text )

	-- For override

end

function PANEL:ClearHighlights()

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		pnl.Highlight = nil
	end

end

function PANEL:HighlightItem( item )

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		if ( pnl == item ) then
			pnl.Highlight = true
		end
	end

end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local MenuItemSelected = function()
		Derma_Message( "Choosing a menu item worked!" )
	end

	local ctrl = vgui.Create( "Button" )
		ctrl:SetText( "Test Me!" )
		ctrl.DoClick = function() 
						local menu = DermaMenu()
						
							menu:AddOption( "Option One", MenuItemSelected )
							menu:AddOption( "Option 2", MenuItemSelected )
							local submenu = menu:AddSubMenu( "Option Free" )
								submenu:AddOption( "Submenu 1", MenuItemSelected )
								submenu:AddOption( "Submenu 2", MenuItemSelected )
							menu:AddOption( "Option For", MenuItemSelected )
							
						menu:Open()
		
						end
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DMenu", "A Menu", PANEL, "DScrollPanel" )



--[[   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DMenuOption

--]]

local PANEL = {}

AccessorFunc( PANEL, "m_pMenu", 		"Menu" )
AccessorFunc( PANEL, "m_bChecked", 		"Checked" )
AccessorFunc( PANEL, "m_bCheckable", 	"IsCheckable" )

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Init()

	self:SetContentAlignment( 4 )
	self:SetTextInset( 30, 0 )			-- Room for icon on left
	self:SetChecked( false )
	self:SetFont( "catherine_normal15" )
	self:SetTextColor( catherine.theme.GetValue( CAT_THEME_DERMA_MENU_OPTION_TEXT_COLOR ) )
	
end


--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetSubMenu( menu )

	self.SubMenu = menu	
	
	if ( !self.SubMenuArrow ) then
	
		self.SubMenuArrow = vgui.Create( "DPanel", self )
		self.SubMenuArrow.Paint = function( panel, w, h ) derma.SkinHook( "Paint", "MenuRightArrow", panel, w, h ) end
	
	end
	
end

--
-- AddSubMenu
--
function PANEL:AddSubMenu()

	local SubMenu = DermaMenu( self )
		SubMenu:SetVisible( false )
		SubMenu:SetParent( self )

	self:SetSubMenu( SubMenu )
	
	return SubMenu

end


--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OnCursorEntered()
	self.m_cursorEntered = true
	
	if ( IsValid( self.ParentMenu ) ) then
		self.ParentMenu:OpenSubMenu( self, self.SubMenu )	
		return
	end
	
	self:GetParent():OpenSubMenu( self, self.SubMenu )	
end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OnCursorExited()
	self.m_cursorEntered = false
end



--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Paint( w, h )
	if ( self.m_cursorEntered ) then
		catherine.theme.Draw( CAT_THEME_DERMA_MENU_OPTION_SELECTED, w, h )
	end

	--
	-- Draw the button text
	--
	return false

end

--[[---------------------------------------------------------
	OnMousePressed
-----------------------------------------------------------]]
function PANEL:OnMousePressed( mousecode )

	self.m_MenuClicking = true
	
	DButton.OnMousePressed( self, mousecode )

end

--[[---------------------------------------------------------
	OnMouseReleased
-----------------------------------------------------------]]
function PANEL:OnMouseReleased( mousecode )

	DButton.OnMouseReleased( self, mousecode )

	if ( self.m_MenuClicking && mousecode == MOUSE_LEFT ) then
		
		self.m_MenuClicking = false
		CloseDermaMenus()
		
	end

end

--[[---------------------------------------------------------
	DoRightClick
-----------------------------------------------------------]]
function PANEL:DoRightClick()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

end

--[[---------------------------------------------------------
	DoClickInternal
-----------------------------------------------------------]]
function PANEL:DoClickInternal()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

	if ( self.m_pMenu ) then
	
		self.m_pMenu:OptionSelectedInternal( self )
	
	end

end

--[[---------------------------------------------------------
	ToggleCheck
-----------------------------------------------------------]]
function PANEL:ToggleCheck()

	self:SetChecked( !self:GetChecked() )
	self:OnChecked( self:GetChecked() )

end

--[[---------------------------------------------------------
	OnChecked
-----------------------------------------------------------]]
function PANEL:OnChecked( b )

end

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	self:SizeToContents()
	self:SetWide( self:GetWide() + 30 )
	
	local w = math.max( self:GetParent():GetWide(), self:GetWide() )

	self:SetSize( w, 30 )
	
	if ( self.SubMenuArrow ) then
	
		self.SubMenuArrow:SetSize( 15, 15 )
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight( 4 )
		
	end

	DButton.PerformLayout( self )
		
end

function PANEL:GenerateExample()

	// Do nothing!

end

derma.DefineControl( "DMenuOption", "Menu Option Line", PANEL, "DButton" )





--[[   _                                
	( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

--]]

--
-- The delay before a tooltip appears
--
local tooltip_delay = CreateClientConVar( "tooltip_delay", "0.5", true, false ) 

local PANEL = {}


--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Init()

	self:SetDrawOnTop( true )
	self.DeleteContentsOnClose = false
	self:SetText( "" )
	self:SetFont( "catherine_normal20" )
	self:SetTextColor( Color( 255, 255, 255 ) )
end

--[[---------------------------------------------------------
	UpdateColours
-----------------------------------------------------------]]
function PANEL:UpdateColours( skin )

	return self:SetTextStyleColor( skin.Colours.TooltipText )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetContents( panel, bDelete )

	panel:SetParent( self )

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false	
	self.Contents:SizeToContents()
	self:InvalidateLayout( true )
	
	self.Contents:SetVisible( false )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:PerformLayout()

	if ( self.Contents ) then
	
		self:SetWide( self.Contents:GetWide() + 8 )
		self:SetTall( self.Contents:GetTall() + 8 )
		self.Contents:SetPos( 4, 4 )
		
	else
	
		local w, h = self:GetContentSize()
		self:SetSize( w + 8, h + 6 )
		self:SetContentAlignment( 5 )
	
	end

end


function PANEL:PositionTooltip()

	if ( !IsValid( self.TargetPanel ) ) then
		self:Remove()
		return
	end

	self:PerformLayout()
	
	local x, y		= input.GetCursorPos()
	local w, h		= self:GetSize()
	
	local lx, ly	= self.TargetPanel:LocalToScreen( 0, 0 )
	
	y = y - 50
	
	y = math.min( y, ly - h * 1.5 )
	if ( y < 2 ) then y = 2 end
	
	// Fixes being able to be drawn off screen
	self:SetPos( math.Clamp( x - w * 0.5, 0, ScrW( ) - self:GetWide( ) ), math.Clamp( y, 0, ScrH( ) - self:GetTall( ) ) )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Paint( w, h )

	self:PositionTooltip()
	draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 255 ) )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OpenForPanel( panel )
	
	self.TargetPanel = panel
	self:PositionTooltip()
	
	if ( tooltip_delay:GetFloat() > 0 ) then
	
		self:SetVisible( false )
		timer.Simple( tooltip_delay:GetFloat(), function() 
		
			if ( !IsValid( self ) ) then return end
			if ( !IsValid( panel ) ) then return end

			self:PositionTooltip()
			self:SetVisible( true )
												
		end )
	end

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Close()

	if ( !self.DeleteContentsOnClose && self.Contents ) then
	
		self.Contents:SetVisible( false )
		self.Contents:SetParent( nil )
	
	end
	
	self:Remove()

end


--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( "DButton" )
		ctrl:SetText( "Hover me" )
		ctrl:SetWide( 200 )
		ctrl:SetTooltip( "This is a tooltip" )
	
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end


derma.DefineControl( "DTooltip", "", PANEL, "DLabel" )