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
PLUGIN.lists = PLUGIN.lists or { }

function PLUGIN:SavePoints( )
	catherine.data.Set( "spawnpoints", self.lists )
end

function PLUGIN:LoadPoints( )
	self.lists = catherine.data.Get( "spawnpoints", { } )
end

function PLUGIN:DataSave( )
	self:SavePoints( )
end

function PLUGIN:DataLoad( )
	self:LoadPoints( )
end

function PLUGIN:GetRandomPos( faction )
	local map = game.GetMap( )
	
	if ( !faction or !self.lists[ map ] or !self.lists[ map ][ faction ] or #self.lists[ map ][ faction ] == 0 ) then return end
	
	return table.Random( self.lists[ map ][ faction ] )
end

function PLUGIN:PlayerSpawnedInCharacter( pl )
	local pos = self:GetRandomPos( pl:Faction( ) )

	if ( pos ) then
		pl:SetPos( pos )
	end
end