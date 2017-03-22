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

catherine.class = catherine.class or { }
catherine.class.lists = { }

function catherine.class.Register( classTable )
	if ( !classTable or !classTable.index ) then return end
	
	if ( !classTable.onCanJoin ) then
		function classTable:onCanJoin( pl )
			return true
		end
	end
	
	catherine.class.lists[ classTable.index ] = classTable
	
	return classTable.index
end

function catherine.class.New( uniqueID )
	return { uniqueID = uniqueID, index = #catherine.class.lists + 1 }
end

function catherine.class.GetAll( )
	return catherine.class.lists
end

function catherine.class.FindByID( id )
	for k, v in pairs( catherine.class.GetAll( ) ) do
		if ( v.uniqueID == id ) then
			return v
		end
	end
end

function catherine.class.FindByIndex( index )
	return catherine.class.lists[ index ]
end

function catherine.class.CanJoin( pl, index, isMenu )
	local classTable = catherine.class.FindByIndex( index )
	
	if ( !classTable ) then
		return false, "Class_UI_NotValid"
	end
	
	if ( classTable.cantJoinUsingMenu and isMenu ) then
		return false, "Class_UI_CantJoinable"
	end
	
	if ( pl:Team( ) != classTable.faction ) then
		return false, "Class_UI_TeamError"
	end
	
	if ( catherine.character.GetCharVar( pl, "class", "" ) == index ) then
		return false, "Class_UI_AlreadyJoined"
	end
	
	if ( classTable.limit and ( #catherine.class.GetPlayers( index ) >= classTable.limit ) ) then
		return false, "Class_UI_HitLimit"
	end
	
	return classTable:onCanJoin( pl )
end

function catherine.class.GetPlayers( index )
	local players = { }
	
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( catherine.character.GetCharVar( v, "class", "" ) != index ) then continue end
		
		players[ #players + 1 ] = v
	end
	
	return players
end

function catherine.class.Include( dir )
	for k, v in pairs( file.Find( dir .. "/class/*.lua", "LUA" ) ) do
		catherine.util.Include( dir .. "/class/" .. v, "SHARED" )
	end
end

if ( SERVER ) then
	function catherine.class.Set( pl, index, isMenu )
		if ( !index ) then
			local defaultClass = catherine.class.GetDefaultClass( pl:Team( ) )
			
			if ( !defaultClass ) then return end
			
			local defaultModel = catherine.character.GetCharVar( pl, "originalModel" )
			
			if ( !defaultModel ) then return end
			
			catherine.character.SetCharVar( pl, "class", defaultClass.index )
			pl:SetModel( defaultModel )
			
			return
		end
		
		local success, reason = catherine.class.CanJoin( pl, index, isMenu )
		
		if ( !success ) then
			catherine.util.NotifyLang( pl, reason )
			return
		end
		
		local classTable = table.Copy( catherine.class.FindByIndex( index ) )
		
		classTable = hook.Run( "AdjustSetClassTable", pl, classTable, isMenu ) or classTable
		
		if ( classTable.model ) then
			pl:SetModel( type( classTable.model ) == "table" and table.Random( classTable.model ) or classTable.model )
		end
		
		catherine.character.SetCharVar( pl, "class", index )
		
		hook.Run( "PostSetClass", pl, classTable, isMenu )
	end
	
	function catherine.class.GetDefaultClass( factionID )
		for k, v in pairs( catherine.class.GetAll( ) ) do
			if ( v.faction == factionID and v.isDefault ) then
				return v
			end
		end
	end
	
	netstream.Hook( "catherine.class.Set", function( pl, data )
		catherine.class.Set( pl, data[ 1 ], data[ 2 ] )
	end )
else
	function catherine.class.GetJoinable( )
		local pl = catherine.pl
		local team = pl:Team( )
		local class = pl:Class( )
		local classes = { }
		
		for k, v in pairs( catherine.class.GetAll( ) ) do
			local classTable = catherine.class.FindByIndex( k )
			
			if ( !v.cantJoinUsingMenu and ( ( v.faction == team and class != k ) or ( class != nil and v.isDefault and k != class ) ) ) then
				classes[ #classes + 1 ] = v
			end
		end
		
		return classes
	end
	
	function catherine.class.CharacterCharVarChanged( pl )
		if ( pl == catherine.pl and IsValid( catherine.vgui.class ) and !catherine.vgui.class:IsHiding( ) ) then
			catherine.vgui.class:InitializeClasses( )
		end
	end
	
	hook.Add( "CharacterCharVarChanged", "catherine.class.CharacterCharVarChanged", catherine.class.CharacterCharVarChanged )
end

local META = FindMetaTable( "Player" )

function META:Class( )
	return catherine.character.GetCharVar( self, "class", nil )
end

function META:ClassName( )
	local classTable = catherine.class.FindByIndex( self:Class( ) )
	
	return classTable and classTable.name or nil
end