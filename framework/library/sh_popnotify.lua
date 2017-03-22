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

catherine.popNotify = catherine.popNotify or { }

if ( SERVER ) then
	function catherine.popNotify.Send( pl, message, time, sound )
		netstream.Start( pl, "catherine.popNotify.Send", {
			message,
			time,
			sound
		} )
	end
else
	catherine.popNotify.lists = { }
	
	netstream.Hook( "catherine.popNotify.Send", function( data )
		catherine.popNotify.lists[ #catherine.popNotify.lists + 1 ] = {
			message = data[ 1 ],
			time = CurTime( ) + data[ 2 ],
			a = 0,
			y = ScrH( ) - ( 90 * #catherine.popNotify.lists + 1 )
		}
		
		if ( data[ 3 ] ) then
			surface.PlaySound( data[ 3 ] )
		end
	end )
	
	function catherine.popNotify.Draw( )
		local w, h = ScrW( ), ScrH( )
		
		for k, v in pairs( catherine.popNotify.lists ) do
			local box_w = w * 0.2
			
			if ( v.time <= CurTime( ) ) then
				v.a = Lerp( 0.05, v.a, 0 )
				v.y = Lerp( 0.05, v.y, h )
				
				if ( math.Round( v.a ) <= 0 ) then
					table.remove( catherine.popNotify.lists, k )
					continue
				end
			else
				v.y = Lerp( 0.05, v.y, h - ( 90 * k ) )
				v.a = Lerp( 0.05, v.a, 255 )
			end
			
			surface.SetFont( "catherine_normal15" )
			local tw, th = surface.GetTextSize( v.message )
			
			if ( tw > box_w ) then
				box_w = math.Clamp( tw + 20, 0, w )
			end
			
			draw.RoundedBox( 0, w - box_w, v.y, box_w, 90, Color( 50, 50, 50, v.a ) )
			draw.SimpleText( LANG( "Basic_PopNotify_Title" ), "catherine_normal20", ( w - box_w ) + 10, v.y + 15, Color( 255, 255, 255, v.a ), TEXT_ALIGN_LEFT, 1 )
			draw.SimpleText( v.message, "catherine_normal15", w - box_w / 2, v.y + 60, Color( 255, 255, 255, v.a ), 1, 1 )
			draw.SimpleText( math.max( math.floor( v.time - CurTime( ) ), 0 ), "catherine_normal20", w - 15, v.y + 20, Color( 255, 255, 255, v.a ), TEXT_ALIGN_RIGHT, 1 )
		end
	end
	
	hook.Add( "PostRenderVGUI", "catherine.popNotify.Draw", catherine.popNotify.Draw )
end