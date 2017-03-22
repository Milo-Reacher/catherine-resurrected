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

catherine.bar = catherine.bar or { }
catherine.bar.lists = { }
local barW = ScrW( ) * catherine.configs.mainBarWideScale
local barH = catherine.configs.mainBarTallSize
local bar_material = Material( catherine.configs.mainBarMaterial )

--[[ Function Optimize :> ]]--
local math_approach = math.Approach
local math_min = math.min
local math_round = math.Round
local lerp = Lerp
local hook_run = hook.Run
local draw_roundedBox = draw.RoundedBox
local getconVar = GetConVarString
local table_remove = table.remove
local color = Color

function catherine.bar.Register( uniqueID, alwaysShowing, getFunc, maxFunc, col, lifeTimeFade )
	for k, v in pairs( catherine.bar.lists ) do
		if ( ( v.uniqueID and uniqueID ) and v.uniqueID == uniqueID ) then
			return
		end
	end
	
	local index = #catherine.bar.lists + 1
	
	catherine.bar.lists[ index ] = {
		getFunc = getFunc,
		maxFunc = maxFunc,
		col = col,
		uniqueID = uniqueID,
		w = 0,
		y = -( barH / 2 ) + ( index * barH / 2 ),
		a = 0,
		alwaysShowing = alwaysShowing,
		lifeTime = 0,
		prevValue = 0,
		lifeTimeFade = lifeTimeFade
	}
end

function catherine.bar.InitializeWide( )
	for k, v in pairs( catherine.bar.lists ) do
		v.w = 0
	end
end

function catherine.bar.Remove( uniqueID )
	for k, v in pairs( catherine.bar.lists ) do
		if ( v.uniqueID and v.uniqueID == uniqueID ) then
			table_remove( catherine.bar.lists, k )
		end
	end
end

function catherine.bar.Draw( pl )
	if ( #catherine.bar.lists == 0 or getconVar( "cat_convar_bar" ) == "0" ) then return end
	
	if ( hook_run( "ShouldDrawBar", pl ) == false ) then
		hook_run( "HUDDrawBarBottom", 5, 5 )
		return
	end
	
	local i = 0
	local curTime = CurTime( )
	
	for k, v in pairs( catherine.bar.lists ) do
		if ( hook_run( "ShouldDrawTargetBar", pl, v ) == false ) then continue end
		
		local per = math_min( v.getFunc( pl ) / v.maxFunc( pl ), 1 )
		
		if ( v.prevValue != per ) then
			v.lifeTime = curTime + ( v.lifeTimeFade or 5 )
		end
		
		v.prevValue = per
		
		if ( !v.alwaysShowing ) then
			if ( v.lifeTime <= curTime ) then
				v.a = lerp( FrameTime( ) * 90, v.a, 0 )
			else
				if ( per != 0 ) then
					i = i + 1
					v.a = lerp( FrameTime( ) * 90, v.a, 255 )
				else
					v.a = lerp( FrameTime( ) * 90, v.a, 0 )
				end
			end
		else
			if ( per != 0 ) then
				i = i + 1
				v.a = lerp( FrameTime( ) * 90, v.a, 255 )
			else
				v.a = lerp( FrameTime( ) * 90, v.a, 0 )
			end
		end
		
		v.w = math_approach( v.w, barW * per, FrameTime( ) * 90 )
		v.y = lerp( 0.09, v.y, -( barH / 2 ) + ( ( barH + 3 ) * i ) )
		
		if ( math_round( v.a ) > 0 ) then
			local col = v.col
			
			if ( bar_material and !bar_material:IsError( ) ) then
				surface.SetDrawColor( col.r - 100, col.g - 100, col.b - 100, v.a )
				surface.SetMaterial( bar_material )
				surface.DrawTexturedRect( 5, v.y, barW, barH )
				
				surface.SetDrawColor( col.r, col.g, col.b, v.a )
				surface.SetMaterial( bar_material )
				surface.DrawTexturedRect( 5, v.y, v.w, barH )
			else
				draw.RoundedBox( 0, 5, v.y, barW, barH, Color( col.r - 100, col.g - 100, col.b - 100, v.a ) )
				draw.RoundedBox( 0, 5, v.y, v.w, barH, Color( col.r, col.g, col.b, v.a ) )
			end
		end
	end
	
	hook_run( "HUDDrawBarBottom", 5, catherine.bar.lists[ #catherine.bar.lists ].y )
end

do
	catherine.bar.Register( "health", true, function( pl )
			return pl:Health( )
		end, function( pl )
			return pl:GetMaxHealth( )
		end, color( 255, 50, 50 ), 10
	)
	
	catherine.bar.Register( "armor", true, function( pl )
			return pl:Armor( )
		end, function( pl )
			return 255
		end, color( 50, 50, 255 ), 10
	)
end