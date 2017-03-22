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

local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadFinished( pl )
	self:SyncTextAll( pl )
end

function PLUGIN:SaveTexts( )
	catherine.data.Set( "walltext", self.textLists )
end

function PLUGIN:LoadTexts( )
	self.textLists = catherine.data.Get( "walltext", { } )
end

function PLUGIN:PreCleanupMap( )
	self:SaveTexts( )
end

function PLUGIN:PostCleanupMapDelayed( )
	self:LoadTexts( )
end

function PLUGIN:DataSave( )
	self:SaveTexts( )
end

function PLUGIN:DataLoad( )
	self:LoadTexts( )
end

function PLUGIN:AddText( pl, text, size, col )
	local tr = pl:GetEyeTraceNoCursor( )
	local index = #self.textLists + 1
	local data = {
		index = index,
		pos = tr.HitPos + tr.HitNormal,
		ang = tr.HitNormal:Angle( ),
		text = text,
		size = math.max( math.abs( size or 1 ) / 8, 0.005 ),
		col = col
	}
	local ang = data.ang
	
	ang:RotateAroundAxis( ang:Up( ), 90 )
	ang:RotateAroundAxis( ang:Forward( ), 90 )

	self.textLists[ index ] = data
	
	self:SyncTextAll( )
	self:SaveTexts( )
end

function PLUGIN:RemoveText( pos, rad )
	rad = tonumber( rad )
	
	if ( !rad ) then return 0 end
	local i = 0
	
	for k, v in pairs( self.textLists ) do
		if ( pos:Distance( v.pos ) <= rad ) then
			netstream.Start( nil, "catherine.plugin.walltext.RemoveText", v.index )
			self.textLists[ k ] = nil
			i = i + 1
		end
	end
	
	self:SaveTexts( )
	
	return i
end

function PLUGIN:SyncTextAll( pl )
	for k, v in pairs( self.textLists ) do
		netstream.Start( pl, "catherine.plugin.walltext.SyncText", {
			index = k,
			text = v.text,
			pos = v.pos,
			ang = v.ang,
			size = v.size,
			col = v.col
		} )
	end
end