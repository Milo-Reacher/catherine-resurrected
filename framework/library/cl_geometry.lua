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

catherine.geometry = catherine.geometry or { }

--[[
	- catherine.geometry.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter ) function source -
	: Night-Eagle's circle drawing library
	: 1.1
	: https://code.google.com/p/wintersurvival/source/browse/trunk/gamemode/cl_circle.lua?r=154
--]]
function catherine.geometry.DrawCircle( originX, originY, radius, thick, startAng, distAng, iter )
	startAng = math.rad( startAng )
	distAng = math.rad( distAng )
	if ( !iter or iter <= 1 ) then
		iter = 8
	else
		iter = math.Round( iter )
	end
        
	local stepAng = math.abs( distAng ) / iter
        
	if ( thick ) then
		if ( distAng > 0 ) then
			for i = 0, iter - 1 do
				local eradius = radius + thick
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				local points = {
					{
						x = math.cos( cur2 ) * radius + originX,
						y = -math.sin( cur2 ) * radius + originY,
						u = 0,	
						v = 0,
					},
					{
						x = math.cos( cur2 ) * eradius + originX,
						y = -math.sin( cur2 ) * eradius + originY,
						u = 1,
						v = 0,
					},
					{
						x = math.cos( cur1 ) * eradius + originX,
						y = -math.sin( cur1 ) * eradius + originY,
						u = 1,
						v = 1,
					},
					{
						x = math.cos( cur1 ) * radius + originX,
						y = -math.sin( cur1 ) * radius + originY,
						u = 0,
						v = 1,
					},
				}
                                
				surface.DrawPoly( points )
			end
		else
			for i = 0, iter - 1 do
				local eradius = radius + thick
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				local points = {
					{
						x = math.cos( cur1 ) * radius + originX,
						y = math.sin( cur1 ) * radius + originY,
						u = 0,
						v = 0,
					},
					{
						x = math.cos( cur1 ) * eradius + originX,
						y = math.sin( cur1 ) * eradius + originY,
						u = 1,
						v = 0,
					},
					{
						x = math.cos( cur2 ) * eradius + originX,
						y = math.sin( cur2 ) * eradius + originY,
						u = 1,
						v = 1,
					},
					{
						x = math.cos( cur2 ) * radius + originX,
						y = math.sin( cur2 ) * radius + originY,
						u = 0,
						v = 1,
					},
				}
				
				surface.DrawPoly( points )
			end
		end
	else
		if ( distAng > 0 ) then
			local points = { }
                        
			if ( math.abs( distAng ) < 360 ) then
				points[ 1 ] = {
					x = originX,
					y = originY,
					u = .5,
					v = .5,
				}
				iter = iter + 1
			end
                        
			for i = iter - 1, 0, -1 do
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				table.insert( points, {
					x = math.cos( cur1 ) * radius + originX,
					y = -math.sin( cur1 ) * radius + originY,
					u = ( 1 + math.cos( cur1 ) ) / 2,
					v = ( 1 + math.sin( -cur1 ) ) / 2,
				} )
			end
                        
			surface.DrawPoly( points )
		else
			local points = { }
 
			if ( math.abs( distAng ) < 360 ) then
				points[ 1 ] = {
					x = originX,
					y = originY,
					u = .5,
					v = .5,
				}
				iter = iter + 1
			end
			
			for i = 0, iter - 1 do
				local cur1 = stepAng * i + startAng
				local cur2 = cur1 + stepAng
				table.insert( points, {
				x = math.cos( cur1 ) * radius + originX,
				y = math.sin( cur1 ) * radius + originY,
				u = ( 1 + math.cos( cur1 ) ) / 2,
				v = ( 1 + math.sin( cur1 ) ) / 2,
				} )
			end
			
			surface.DrawPoly( points )
		end
	end
end

// By Vein Gamemode
// http://facepunch.com/showthread.php?t=1148261
function catherine.geometry.SlickBackground( x, y, w, h, nograd, gridColor, backColor )
	if ( !nograd ) then
		gridColor = gridColor or Color( 100, 100, 100 )
		
		for i = 0, math.min( h, 32 ) do
			surface.SetDrawColor( gridColor.r, gridColor.g, gridColor.b, math.min( h, 32 ) - i )
			surface.DrawLine( x, y + i, x + w, y + i )
		end
	end
	
	h = h - 1
	w = w - 1
	
	surface.SetDrawColor( backColor or Color( 255, 10, 10, 100 ) )
	
	for i = 0, w + h, 20 do
		if ( i < h ) then
			surface.DrawLine( x + i, y, x, y + i )
		elseif ( i > w ) then
			surface.DrawLine( x + w, y + i - w, x - h + i, y + h )
		else
			surface.DrawLine( x + i, y, x + i - h, y + h )
		end
	end
end