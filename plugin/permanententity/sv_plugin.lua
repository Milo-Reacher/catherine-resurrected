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
PLUGIN.entClass = {
	"gmod_light",
	"gmod_lamp",
	"prop_physics"
}

function PLUGIN:DataSave( )
	local data = { }
	
	for k, v in pairs( ents.GetAll( ) ) do
		if ( !v:GetNetVar( "isStatic" ) ) then continue end
		
		data[ #data + 1 ] = v
	end
	
	if ( #data == 0 ) then return end
	
	local persistentData = duplicator.CopyEnts( data )
	
	if ( persistentData ) then
		catherine.data.Set( "static_entity", persistentData )
	end
end

function PLUGIN:ConvertFromStaticProp( )
	catherine.data.Set( "static_entity", catherine.data.Get( "staticprops" ) )
	catherine.data.Set( "convert_from_staticprops", "true" )
	
	MsgC( Color( 0, 255, 0 ), "[CAT PLUGIN] Finished the convert progress.\n" )
end

function PLUGIN:DataLoad( )
	if ( catherine.data.Get( "convert_from_staticprops", false ) == false ) then
		MsgC( Color( 255, 255, 0 ), "[CAT PLUGIN] Processing the convert to Static entity from Static prop ...\n" )
		self:ConvertFromStaticProp( )
	end

	local data = catherine.data.Get( "static_entity" )
	
	if ( !data ) then return end
	
	local ents, consts = duplicator.Paste( nil, data.Entities or { }, data.Contraints or { } )
	local i = 1
	
	for k, v in pairs( ents ) do
		if ( v:GetClass( ) == "gmod_lamp" or v:GetClass( ) == "gmod_light" ) then
			local physObject = v:GetPhysicsObject( )
		
			if ( IsValid( physObject ) ) then
				physObject:EnableMotion( false )
				physObject:Sleep( )
			end
		end
		
		v:SetNetVar( "isStatic", true )
		v.CAT_staticIndex = i
		i = i + 1
	end
end