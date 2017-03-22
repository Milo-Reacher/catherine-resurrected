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

catherine.theme = catherine.theme or { }
CAT_THEME_MENU_BACKGROUND = 1
CAT_THEME_PNLLIST = 2
CAT_THEME_FORM = 3
CAT_THEME_TEXTENT = 4
CAT_THEME_MENU_BACKGROUND_NOTITLE = 5
CAT_THEME_TEXTENT_UNDERLINE = 6
CAT_THEME_WEIGHT_BACKGROUND = 7
CAT_THEME_DERMA_MENU_BACKGROUND = 8
CAT_THEME_DERMA_MENU_OPTION_SELECTED = 9
CAT_THEME_DERMA_MENU_OPTION_TEXT_COLOR = 10

--[[ Function Optimize :> ]]--
local color = Color
local gradient_up = Material( "gui/gradient_up" )
local draw_roundedBox = draw.RoundedBox
local setDrawColor = surface.SetDrawColor
local setMaterial = surface.SetMaterial
local drawTexturedRect = surface.DrawTexturedRect

local themes = {
	[ CAT_THEME_MENU_BACKGROUND ] = function( w, h )
		draw_roundedBox( 0, 0, 25, w, h, color( 50, 50, 50, 235 ) )
		
		setDrawColor( 20, 20, 20, 235 )
		setMaterial( gradient_up )
		drawTexturedRect( 0, 25, w, h )
	end,
	[ CAT_THEME_MENU_BACKGROUND_NOTITLE ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, h, color( 50, 50, 50, 235 ) )
		
		setDrawColor( 20, 20, 20, 235 )
		setMaterial( gradient_up )
		drawTexturedRect( 0, 0, w, h )
	end,
	[ CAT_THEME_PNLLIST ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, h, color( 235, 235, 235, 255 ) )
	end,
	[ CAT_THEME_FORM ] = function( w, h )
		draw_roundedBox( 0, 0, 25, w, 1, color( 255, 255, 255, 255 ) )
	end,
	[ CAT_THEME_TEXTENT ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, 2, color( 255, 255, 255, 150 ) )
		draw_roundedBox( 0, 0, h - 2, w, 2, color( 255, 255, 255, 150 ) )
	end,
	[ CAT_THEME_TEXTENT_UNDERLINE ] = function( w, h )
		draw_roundedBox( 0, 0, h - 2, w, 2, color( 255, 255, 255, 255 ) )
	end,
	[ CAT_THEME_WEIGHT_BACKGROUND ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, h, color( 50, 50, 50, 255 ) )
	end,
	[ CAT_THEME_WEIGHT_BACKGROUND ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, h, color( 50, 50, 50, 255 ) )
	end,
	[ CAT_THEME_DERMA_MENU_BACKGROUND ] = function( w, h )
		draw_roundedBox( 0, 0, 0, w, h, color( 50, 50, 50, 255 ) )
	end,
	[ CAT_THEME_DERMA_MENU_OPTION_SELECTED ] = function( w, h )
		draw_roundedBox( 0, 10, h - 1, w - 20, 1, color( 255, 255, 255, 255 ) )
	end,
	[ CAT_THEME_DERMA_MENU_OPTION_TEXT_COLOR ] = function( )
		return color( 255, 255, 255, 255 )
	end
}

function catherine.theme.Draw( typ, w, h )
	themes[ typ ]( w, h )
end

function catherine.theme.GetValue( typ )
	return themes[ typ ]( )
end

function catherine.theme.Override( typ, func )
	themes[ typ ] = func
end