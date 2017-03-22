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
	self:SetDrawBackground( false )
	
	self.start = CurTime( )
	self.finish = CurTime( ) + 15
end

function PANEL:SetMaxWidth( w )
	self.maxWidth = w
end

function PANEL:SetFont( font )
	self.font = font
end

function PANEL:Run( ... )
	local data = ""
	local lastColor = Color( 255, 255, 255 )
	
	if ( self.font ) then
		data = "<font=" .. self.font .. ">"
	end

	for k, v in pairs( { ... } ) do
		local types = type( v )
		
		if ( types == "table" and v.r and v.g and v.b ) then
			if ( v != latestColor ) then
				data = data .. "</color>"
			end
			
			latestColor = v
			data = data .. "<color=" .. v.r .. "," .. v.g .. "," .. v.b .. ">"
		elseif ( types == "Player" ) then
			local col = team.GetColor( v:Team( ) )
			
			data = data .. "<color=" .. col.r .. "," .. col.g .. "," .. col.b .. ">" .. v:Name( ) .. "</color>"
		elseif ( types == "IMaterial" or types == "table" and type( v[ 1 ] ) == "IMaterial" ) then
			local w, h = 12, 12
			local material = v
			
			if ( type( v ) == "table" and v[ 2 ] and v[ 3 ] ) then
				material = v[ 1 ]
				w = v[ 2 ]
				h = v[ 3 ]
			end
			
			data = data .. "<img=" .. material:GetName( ) .. ".png," .. w .. "x" .. h .. "> "
		else
			v = tostring( v )
			v = v:gsub( "&", "&amp;" )
			v = v:gsub( "<", "&lt;" )
			v = v:gsub( ">", "&gt;" )
			
			data = data .. v
		end
	end

	if ( self.font ) then
		data = data .. "</font>"
	end

	self.markupObject = catherine.markup.Parse( data, self.maxWidth )

	function self.markupObject:DrawText( text, font, x, y, color, hAlign, vAlign, alpha )
		draw.SimpleTextOutlined( text, font, x, y, color, hAlign, vAlign, 1, Color( 0, 0, 0, 255 ) )
	end

	self:SetSize( self.markupObject:GetWidth( ), self.markupObject:GetHeight( ) )
end

function PANEL:Paint( w, h )
	if ( !self.markupObject ) then return end
	local a = 255
	
	if ( self.start and self.finish ) then
		a = math.Clamp( 255 - math.TimeFraction( self.start, self.finish, CurTime( ) ) * 255, 0, 255 )
	end
	
	if ( catherine.chat.isOpened ) then
		a = 255
	end
	
	self:SetAlpha( a )
	
	if ( a > 0 ) then
		self.markupObject:Draw( 1, 0, 0, 0 )
	end
end

vgui.Register( "catherine.vgui.chatmarkup", PANEL, "DPanel" )