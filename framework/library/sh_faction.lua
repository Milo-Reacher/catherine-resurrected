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

catherine.faction = catherine.faction or { }
catherine.faction.lists = { }
local META = FindMetaTable( "Player" )

function catherine.faction.Register( factionTable )
	if ( !factionTable or !factionTable.index ) then
		return
	end
	
	factionTable.color = factionTable.color or Color( 255, 255, 255 )
	factionTable.name = factionTable.name or "Error Name"
	
	catherine.faction.lists[ factionTable.index ] = factionTable
	team.SetUp( factionTable.index, factionTable.name, factionTable.color )
	
	for k, v in pairs( factionTable.models or { } ) do
		if ( catherine.faction.IsTableModel( v ) ) then
			if ( SERVER ) then
				resource.AddFile( v.model )
			end
			
			util.PrecacheModel( v.model )
		else
			if ( SERVER ) then
				resource.AddFile( v )
			end
			
			util.PrecacheModel( v )
		end
	end
	
	if ( SERVER and factionTable.factionImage ) then
		resource.AddFile( factionTable.factionImage )
	end
	
	return factionTable.index
end

function catherine.faction.IsTableModel( data )
	if ( data and type( data ) == "table" and data.model ) then
		return true
	end
	
	return false
end

function catherine.faction.New( uniqueID )
	return { uniqueID = uniqueID, index = #catherine.faction.lists + 1 }
end

function catherine.faction.GetAll( )
	return catherine.faction.lists
end

function catherine.faction.GetPlayerUsableFaction( pl )
	local factions = { }
	
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.isWhitelist and ( SERVER and catherine.faction.HasWhiteList( pl, v.uniqueID ) or catherine.faction.HasWhiteList( v.uniqueID ) ) == false ) then continue end
		
		factions[ #factions + 1 ] = v
	end
	
	return factions
end

function catherine.faction.FindByID( id )
	for k, v in pairs( catherine.faction.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
end

function catherine.faction.FindByIndex( index )
	return catherine.faction.lists[ index ]
end

function catherine.faction.Include( dir )
	for k, v in pairs( file.Find( dir .. "/faction/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/faction/" .. v, "SHARED" )
	end
end

catherine.faction.Include( catherine.FolderName .. "/framework" )

if ( SERVER ) then
	function catherine.faction.AddWhiteList( pl, id )
		local factionTable = catherine.faction.FindByID( id )

		if ( !factionTable or !factionTable.isWhitelist ) then
			return false, "Faction_Notify_NotValid", { id }
		end
		
		if ( !factionTable.isWhitelist ) then
			return false, "Faction_Notify_NotWhitelist", { id }
		end
		
		if ( catherine.faction.HasWhiteList( pl, id ) ) then
			return false, "Faction_Notify_AlreadyHas", { pl:Name( ), id }
		end
		
		local whiteLists = catherine.catData.GetVar( pl, "whitelists", { } )
		
		whiteLists[ #whiteLists + 1 ] = id
		
		catherine.catData.SetVar( pl, "whitelists", whiteLists, false, true )
		
		return true
	end

	function catherine.faction.RemoveWhiteList( pl, id )
		local factionTable = catherine.faction.FindByID( id )
		
		if ( !factionTable ) then
			return false, "Faction_Notify_NotValid", { id }
		end
		
		if ( !factionTable.isWhitelist ) then
			return false, "Faction_Notify_NotWhitelist", { id }
		end
		
		if ( !catherine.faction.HasWhiteList( pl, id ) ) then
			return false, "Faction_Notify_HasNot", { pl:Name( ), id }
		end
		
		local whiteLists = catherine.catData.GetVar( pl, "whitelists", { } )
		
		table.RemoveByValue( whiteLists, id )
		
		catherine.catData.SetVar( pl, "whitelists", whiteLists, false, true )
		
		return true
	end

	function catherine.faction.HasWhiteList( pl, id )
		return table.HasValue( catherine.catData.GetVar( pl, "whitelists", { } ), id )
	end
	
	function META:HasWhiteList( id )
		return catherine.faction.HasWhiteList( self, id )
	end
	
	function catherine.faction.PlayerFirstSpawned( pl )
		local factionTable = catherine.faction.FindByIndex( pl:Team( ) )
		
		if ( !factionTable or !factionTable.PlayerFirstSpawned ) then return end
		
		factionTable:PlayerFirstSpawned( pl )
	end
	
	hook.Add( "PlayerFirstSpawned", "catherine.faction.PlayerFirstSpawned", catherine.faction.PlayerFirstSpawned )
else
	function catherine.faction.HasWhiteList( id )
		return table.HasValue( catherine.catData.GetVar( "whitelists", { } ), id )
	end
	
	function META:HasWhiteList( id )
		return catherine.faction.HasWhiteList( id )
	end
end