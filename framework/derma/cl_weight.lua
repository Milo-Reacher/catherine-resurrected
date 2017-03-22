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
	self.invWeight = 0
	self.invMaxWeight = 0
	self.invWeightAni = 0
	self.invWeightTextAni = 0
	self.showText = true
end

function PANEL:Paint( w, h )
	local per = ( self.invWeight / self.invMaxWeight )
	self.invWeightAni = Lerp( 0.08, self.invWeightAni, per * h )
	self.invWeightTextAni = Lerp( 0.08, self.invWeightTextAni, per )
	
	catherine.theme.Draw( CAT_THEME_WEIGHT_BACKGROUND, w, h )
	draw.RoundedBox( 0, 0, h - self.invWeightAni, w, self.invWeightAni, Color( 255, 255, 255, 255 ) )
	
	if ( self.showText ) then
		if ( per < 0.5 ) then
			draw.SimpleText( math.Clamp( math.Round( self.invWeightTextAni * 100 ), 0, 100 ) .. " %", "catherine_lightUI20", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
		else
			draw.SimpleText( math.Clamp( math.Round( self.invWeightTextAni * 100 ), 0, 100 ) .. " %", "catherine_lightUI20", w / 2, h / 2, Color( 20, 20, 20, 255 ), 1, 1 )
		end
	end
end

function PANEL:SetShowText( bool )
	self.showText = bool
end

function PANEL:SetWeight( weight, maxWeight )
	self.invWeight = weight
	self.invMaxWeight = maxWeight
end

vgui.Register( "catherine.vgui.weight", PANEL, "DPanel" )