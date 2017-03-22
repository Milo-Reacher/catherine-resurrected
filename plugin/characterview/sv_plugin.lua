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
	self:SyncViews( pl )
end

function PLUGIN:SaveCharViews( )
	catherine.data.Set( "charviews", self.charViews )
end

function PLUGIN:LoadCharViews( )
	self.charViews = catherine.data.Get( "charviews", { } )
end

function PLUGIN:DataLoad( )
	self:LoadCharViews( )
end

function PLUGIN:DataSave( )
	self:SaveCharViews( )
end

function PLUGIN:SyncViews( pl )
	netstream.Start( pl, "catherine.plugin.characterview.SyncViews", self.charViews )
end

function PLUGIN:AddCharView( pos, ang )
	self.charViews[ #self.charViews + 1 ] = {
		pos = pos,
		ang = ang
	}
	
	self:SyncViews( )
	self:SaveCharViews( )
end