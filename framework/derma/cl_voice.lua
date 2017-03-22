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
	self.volume = 0
	self.index = 1
	self.volumeColor = Color( 255, 255, 255, 255 )
	
	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.1, 0 )
end

function PANEL:Setup( talker )
	self.index = #catherine.voicePanels + 1
	
	catherine.voicePanels[ self.index ] = {
		panel = self,
		talker = talker
	}
	
	self.avatar = vgui.Create( "AvatarImage", self )
	self.avatar:SetSize( 32, 32 )
	self.avatar:SetPos( 4, 4 )
	self.avatar:SetPlayer( talker )
	self.avatar.PaintOver = function( pnl, w, h ) end
	
	self.avatar:SetPos( 4, 4 )
	self:SetSize( 50, 40 )
	self:SetPos( 0, 45 * ( self.index - 1 ) )
	
	self.player = talker
end

function PANEL:Think( )
	if ( !IsValid( self.player ) or !self.player:IsSpeaking( ) ) then
		catherine.voicePanels[ self.index ] = nil
		
		self:AlphaTo( 0, 0.1, 0, function( )
			if ( IsValid( self ) ) then
				self:Remove( )
			end
		end )
	end
end

function PANEL:Paint( w, h )
	if ( !IsValid( self.player ) ) then return end
	
	self.volume = Lerp( 0.05, self.volume, self.player:VoiceVolume( ) * h )
	
	local volume = math.Round( self.volume )
	
	if ( volume <= 18 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 255 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 255 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 255 )
	elseif ( volume > 18 and volume <= 23 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 255 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 255 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 150 )
	elseif ( volume > 23 ) then
		self.volumeColor.r = Lerp( 0.08, self.volumeColor.r, 255 )
		self.volumeColor.g = Lerp( 0.08, self.volumeColor.g, 150 )
		self.volumeColor.h = Lerp( 0.08, self.volumeColor.b, 150 )
	end
	
	draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
	draw.RoundedBox( 0, w - 7, h - self.volume, 7, self.volume, Color( self.volumeColor.r, self.volumeColor.g, self.volumeColor.b, 255 ) )
end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

if ( IsValid( g_VoicePanelList ) ) then
	g_VoicePanelList:SetSize( 50, ScrH( ) - 250 )
	g_VoicePanelList:SetPos( ScrW( ) - 60, 200 )
end

hook.Add( "InitPostEntity", "catherine.vgui.VoiceNotify.InitPostEntity", function( )
	if ( IsValid( g_VoicePanelList ) ) then
		g_VoicePanelList:SetSize( 50, ScrH( ) - 250 )
		g_VoicePanelList:SetPos( ScrW( ) - 60, 200 )
	end
end )

hook.Add( "ScreenResolutionFix", "catherine.vgui.VoiceNotify.ScreenResolutionFix", function( )
	if ( IsValid( g_VoicePanelList ) ) then
		g_VoicePanelList:SetSize( 50, ScrH( ) - 250 )
		g_VoicePanelList:SetPos( ScrW( ) - 60, 200 )
	end
end )