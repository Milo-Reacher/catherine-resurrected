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

catherine.notify = catherine.notify or { }
catherine.notify.lists = { }

--[[ Function Optimize :> ]]--
local math_round = math.Round
local lerp = Lerp
local draw_simpleText = draw.SimpleText
local draw_roundedBox = draw.RoundedBox
local table_remove = table.remove
local math_clamp = math.Clamp
local color = Color

function catherine.notify.Add( message, time, sound )
	local index = #catherine.notify.lists + 1
	
	message = message or "Error"
	
	MsgN( "[CAT Notify] " .. message )
	
	surface.SetFont( "catherine_normal15" )
	local tw, th = surface.GetTextSize( message )
	
	if ( sound != false ) then
		surface.PlaySound( sound or "buttons/button24.wav" )
	end
	
	local w = ScrW( ) * 0.4
	
	if ( tw >= ScrW( ) * 0.4 ) then
		w = math_clamp( w + ( tw - w ) + 50, 0, ScrW( ) - 10 )
	end
	
	catherine.notify.lists[ index ] = {
		message = message,
		endTime = CurTime( ) + ( time or 5 ),
		x = ScrW( ) / 2 - w / 2,
		y = ( ScrH( ) - 10 ) - ( index * 25 ),
		w = w,
		h = 20,
		a = 0,
		tw = tw,
		th = th
	}
end

function catherine.notify.Draw( )
	for k, v in pairs( catherine.notify.lists ) do
		if ( v.endTime <= CurTime( ) ) then
			v.a = lerp( 0.05, v.a, 0 )
			
			if ( math_round( v.a ) <= 0 ) then
				table_remove( catherine.notify.lists, k )
				continue
			end
		else
			v.a = lerp( 0.05, v.a, 255 )
		end
		
		v.y = lerp( 0.05, v.y, ( ScrH( ) - 10 ) - ( k * 25 ) )
		
		draw_roundedBox( 0, v.x, v.y, v.w, v.h, color( 50, 50, 50, v.a ) )
		draw_simpleText( v.message, "catherine_slight15", v.x + v.w / 2, v.y + v.h / 2, color( 255, 255, 255, v.a ), 1, 1 )
	end
end