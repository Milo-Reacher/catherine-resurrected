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
	local rgb = Color
	self.Font = "catherine_normal20"
	self.Text = ""
	self.Status = true
	self.CursorIsOn = false
	self.ButtonPressed = false
	self.ButtonPressing = false
	self.PressingCurTime = nil
	self.IsCoolText = false
	
	self.gradientColor_original = Color( 255, 255, 255, 200 )
	self.gradientColor = Color( 255, 255, 255, 0 )
	self.textColor = Color( 50, 50, 50, 255 )
	
	self:SetText( "" )
end

function PANEL:Think( )
	if ( self.ButtonPressed ) then
		self.ButtonPressing = true
		self:IsPressing( )
	else
		self.ButtonPressing = false
		self:IsNotPressing( )
	end
end

function PANEL:SetGradientColor( col )
	self.gradientColor_original = col
	self.gradientColor = Color( col.r, col.g, col.b, 0 )
end

function PANEL:SetCoolText( bool )
	self.IsCoolText = bool
end

function PANEL:SetStrColor( col )
	self.textColor = col
end

function PANEL:SetStr( str )
	self.Text = str
end

function PANEL:GetStr( )
	return self.Text
end

function PANEL:SetStrFont( font )
	self.Font = font
end

function PANEL:CursorOn( ) end

function PANEL:CursorNotOn( ) end

function PANEL:OnCursorEntered( )
	self.CursorIsOn = true
	self:CursorOn( )
end

function PANEL:OnCursorExited( )
	self.CursorIsOn = false
	self:CursorNotOn( )
end

function PANEL:OnMousePressed( )
	self.ButtonPressed = true
	self:OnPress( )
	self:DoClick( )
end

function PANEL:OnMouseReleased( )
	self.ButtonPressed = false
	self:OnRelease( )
end

function PANEL:OnPress( ) end

function PANEL:OnRelease( ) end

function PANEL:IsPressing( ) end

function PANEL:IsNotPressing( ) end

function PANEL:RunFadeInAnimation( time, delay )
	self:SetAlpha( 0 )
	self:AlphaTo( 255, time or 0.1, delay or 0 )
end

function PANEL:SetStatus( bool )
	self.Status = bool
	if ( bool ) then
		self:SetAlpha( 255 )
	else
		self:SetAlpha( 50 )
	end
end

function PANEL:Click( ) end

function PANEL:DoClick( )
	if ( !self.Status ) then return end
	self:Click( func )
end

function PANEL:PaintOverAll( w, h ) end
function PANEL:PaintBackground( w, h ) end

function PANEL:Paint( w, h )
	self:PaintBackground( w, h )
	
	if ( self.CursorIsOn ) then
		self.gradientColor.r = Lerp( 0.05, self.gradientColor.r, self.gradientColor_original.r )
		self.gradientColor.g = Lerp( 0.05, self.gradientColor.g, self.gradientColor_original.g )
		self.gradientColor.b = Lerp( 0.05, self.gradientColor.b, self.gradientColor_original.b )
		self.gradientColor.a = Lerp( 0.05, self.gradientColor.a, self.gradientColor_original.a )
	else
		self.gradientColor.a = Lerp( 0.05, self.gradientColor.a, 0 )
	end
	
	surface.SetDrawColor( self.gradientColor.r, self.gradientColor.g, self.gradientColor.b, self.gradientColor.a )
	surface.SetMaterial( Material( "gui/center_gradient" ) )
	surface.DrawTexturedRect( 0, h - 1, w, 1 )
	
	draw.SimpleText( self.Text, self.Font, w / 2, h / 2, self.textColor, 1, 1 )
	
	self:PaintOverAll( w, h )
end

vgui.Register( "catherine.vgui.button", PANEL, "DButton" )