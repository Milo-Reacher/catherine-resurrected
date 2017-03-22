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

	DVScrollBar

	
	Usage:
	
	Place this control in your panel. You will ideally have another panel or 
		control which is bigger than the original panel. This is the Canvas.
	
	scrollbar:SetUp( _barsize_, _canvassize_ ) should be called whenever
		the size of your 'canvas' changes.
		
	scrollbar:GetOffset() can be called to get the offset of the canvas.
		You should call this in your PerformLayout function and set the Y 
		pos of your canvas to this value.
		
	Example:
	

	function PANEL:PerformLayout()
	
		local Wide = self:GetWide()
		local YPos = 0
		
		-- Place the scrollbar
		self.VBar:SetPos( self:GetWide() - 16, 0 )
		self.VBar:SetSize( 16, self:GetTall() )
		
		-- Make sure the scrollbar knows how big our canvas is
		self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
		
		-- Get data from the scrollbar
		YPos = self.VBar:GetOffset()
		
		-- If the scrollbar is enabled make the canvas thinner so it will fit in.
		if ( self.VBar.Enabled ) then Wide = Wide - 16 end
			
		-- Position the canvas according to the scrollbar's data
		self.pnlCanvas:SetPos( self.Padding, YPos + self.Padding )
		self.pnlCanvas:SetSize( Wide - self.Padding * 2, self.pnlCanvas:GetTall() )
	
	end

	
--]]

local PANEL = {}

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.Offset = 0
	self.Scroll = 0
	self.CanvasSize = 1
	self.BarSize = 1	
	
	self.btnUp = vgui.Create( "DButton", self )
	self.btnUp:SetText( "" )
	self.btnUp.DoClick = function ( self )
		self:GetParent():AddScroll( -1 )
	end
	self.btnUp.Paint = function( panel, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
	end
	
	self.btnDown = vgui.Create( "DButton", self )
	self.btnDown:SetText( "" )
	self.btnDown.DoClick = function ( self )
		self:GetParent():AddScroll( 1 )
	end
	self.btnDown.Paint = function( panel, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
	end
	
	self.btnGrip = vgui.Create( "DScrollBarGrip", self )
	self.btnGrip.Paint = function( panel, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 190, 190, 190, 255 ) )
	end
	
	self:SetSize( 10, 15 )
end

--[[---------------------------------------------------------
   Name: SetEnabled
-----------------------------------------------------------]]
function PANEL:SetEnabled( b )
	
	if ( !b ) then
	
		self.Offset = 0
		self:SetScroll( 0 )
		self.HasChanged = true
		
	end
	
	self:SetMouseInputEnabled( b )
	self:SetVisible( b )
	
	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if ( self.Enabled != b ) then

		self:GetParent():InvalidateLayout()

		if ( self:GetParent().OnScrollbarAppear ) then
			self:GetParent():OnScrollbarAppear()
		end

	end
	
	self.Enabled = b	
	
end


--[[---------------------------------------------------------
   Name: Value
-----------------------------------------------------------]]
function PANEL:Value()
	return self.Pos
end

--[[---------------------------------------------------------
   Name: Value
-----------------------------------------------------------]]
function PANEL:BarScale()

	if ( self.BarSize == 0 ) then return 1 end
	
	return self.BarSize / (self.CanvasSize+self.BarSize)
end

--[[---------------------------------------------------------
   Name: SetPos
-----------------------------------------------------------]]
function PANEL:SetUp( _barsize_, _canvassize_ )

	self.BarSize 	= _barsize_
	self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

	self:SetEnabled( _canvassize_ > _barsize_ )

	self:InvalidateLayout()
end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	if ( !self:IsVisible() ) then return false end

	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel
	
	return self:AddScroll( dlta * -5 )
end

--[[---------------------------------------------------------
   Name: AddScroll (Returns true if changed)
-----------------------------------------------------------]]
function PANEL:AddScroll( dlta )

	local OldScroll = self:GetScroll()

	dlta = dlta * 25

	self:AnimateTo( self:GetScroll() + dlta, 0.1, 0, 0.65 )
	
	return OldScroll != self:GetScroll()
end

--[[---------------------------------------------------------
   Name: SetScroll
-----------------------------------------------------------]]
function PANEL:SetScroll( scrll )

	if ( !self.Enabled ) then self.Scroll = 0 return end

	self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )
	
	self:InvalidateLayout()
	
	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)
	
	local func = self:GetParent().OnVScroll
	if ( func ) then
	
		func( self:GetParent(), self:GetOffset() )
	
	else
	
		self:GetParent():InvalidateLayout()
	
	end
	
end

--[[---------------------------------------------------------
   Name: AnimateTo
-----------------------------------------------------------]]
function PANEL:AnimateTo( scrll, length, delay, ease )

	local anim = self:NewAnimation( length, delay, ease )
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function( anim, pnl, fraction )
	
		pnl:SetScroll( Lerp( fraction, anim.StartPos, anim.TargetPos ) )
	
	end
end

--[[---------------------------------------------------------
   Name: GetScroll
-----------------------------------------------------------]]
function PANEL:GetScroll()

	if ( !self.Enabled ) then self.Scroll = 0 end
	return self.Scroll
	
end

--[[---------------------------------------------------------
   Name: GetOffset
-----------------------------------------------------------]]
function PANEL:GetOffset()

	if ( !self.Enabled ) then return 0 end
	return self.Scroll * -1
	
end

--[[---------------------------------------------------------
   Name: Think
-----------------------------------------------------------]]
function PANEL:Think()

end


--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint( w, h )

end

--[[---------------------------------------------------------
   Name: OnMouseReleased
-----------------------------------------------------------]]
function PANEL:OnMousePressed()

	local x, y = self:CursorPos()

	local PageSize = self.BarSize
	
	if ( y > self.btnGrip.y ) then
		self:AnimateTo( self:GetScroll() + PageSize, 0.1, 0, 0.25 )
	else
		self:AnimateTo( self:GetScroll() - PageSize, 0.1, 0, 0.25 )
	end	
	
end

--[[---------------------------------------------------------
   Name: OnMouseReleased
-----------------------------------------------------------]]
function PANEL:OnMouseReleased()

	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture( false )
	
	self.btnGrip.Depressed = false
	
end

--[[---------------------------------------------------------
   Name: OnCursorMoved
-----------------------------------------------------------]]
function PANEL:OnCursorMoved( x, y )

	if ( !self.Enabled ) then return end
	if ( !self.Dragging ) then return end

	local x = 0
	local y = gui.MouseY()
	local x, y = self:ScreenToLocal( x, y )
	
	-- Uck. 
	y = y - self.btnUp:GetTall()
	y = y - self.HoldPos
	
	local TrackSize = self:GetTall() - self:GetWide() * 2 - self.btnGrip:GetTall()
	
	y = y / TrackSize
	
	self:SetScroll( y * self.CanvasSize )
end

--[[---------------------------------------------------------
   Name: Grip
-----------------------------------------------------------]]
function PANEL:Grip()

	if ( !self.Enabled ) then return end
	if ( self.BarSize == 0 ) then return end

	self:MouseCapture( true )
	self.Dragging = true
	
	local x, y = 0, gui.MouseY()
	local x, y = self.btnGrip:ScreenToLocal( x, y )
	self.HoldPos = y 
	
	self.btnGrip.Depressed = true
	
end

--[[---------------------------------------------------------
	PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max( self:BarScale() * (self:GetTall() - (Wide * 2)), 10 )
	local Track = self:GetTall() - (Wide * 2) - BarSize
	Track = Track + 1
	
	Scroll = Scroll * Track
	
	self.btnGrip:SetPos( 0, Wide + Scroll )
	self.btnGrip:SetSize( Wide, BarSize )
	
	self.btnUp:SetPos( 0, 0, Wide, Wide )
	self.btnUp:SetSize( Wide, Wide )
	
	self.btnDown:SetPos( 0, self:GetTall() - Wide, Wide, Wide )
	self.btnDown:SetSize( Wide, Wide )

	self:SetWide( 5 )
end


derma.DefineControl( "DVScrollBar", "A Scrollbar", PANEL, "Panel" )