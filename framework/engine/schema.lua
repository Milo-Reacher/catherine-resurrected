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

catherine.schema = catherine.schema or { loaded = false }

function catherine.schema.Initialization( )
	Schema = Schema or {
		Name = "Example Schema",
		Author = "L7D",
		UniqueID = GM.FolderName,
		FolderName = GM.FolderName,
		Title = "Example",
		Desc = "A schema.",
		IntroTitle = "Example",
		IntroDesc = "A schema."
	}
	
	local schemaFolderName = Schema.FolderName
	
	if ( SERVER ) then
		catherine.plugin.LoadActiveList( )
	end
	
	catherine.faction.Include( schemaFolderName .. "/schema" )
	catherine.class.Include( schemaFolderName .. "/schema" )
	catherine.item.Include( schemaFolderName .. "/schema" )
	catherine.attribute.Include( schemaFolderName .. "/schema" )
	catherine.util.Include( schemaFolderName .. "/schema/sh_schema.lua" )
	catherine.language.Include( schemaFolderName .. "/schema", "schema" )
	catherine.util.IncludeInDir( "library", schemaFolderName .. "/schema/" )
	catherine.util.IncludeInDir( "derma", schemaFolderName .. "/schema/" )
	
	catherine.plugin.Include( schemaFolderName )
	catherine.plugin.Include( catherine.FolderName )
	
	if ( SERVER ) then
		catherine.plugin.SendDeactivePlugins( nil )
	end
	
	if ( !catherine.schema.loaded ) then
		catherine.schema.loaded = true
	end
	
	hook.Run( "SchemaInitialized" )
end

function catherine.schema.GetUniqueID( )
	return Schema and Schema.UniqueID or "catherine"
end

function catherine.schema.IsLoaded( )
	return catherine.schema.loaded
end