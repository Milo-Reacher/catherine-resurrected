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

catherine.option = catherine.option or { }
catherine.option.lists = { }
CAT_OPTION_SWITCH = 0
CAT_OPTION_LIST = 1

function catherine.option.Register( uniqueID, conVar, name, desc, category, typ, data )
	catherine.option.lists[ uniqueID ] = {
		uniqueID = uniqueID,
		name = name,
		desc = desc,
		conVar = conVar,
		typ = typ,
		category = category,
		data = data
	}
end

function catherine.option.GetAll( )
	return catherine.option.lists
end

function catherine.option.FindByID( uniqueID )
	return catherine.option.lists[ uniqueID ]
end

function catherine.option.Remove( uniqueID )
	catherine.option.lists[ uniqueID ] = nil
end

function catherine.option.Set( uniqueID, val )
	local optionTable = catherine.option.FindByID( uniqueID )
	
	if ( !optionTable or !optionTable.onSet ) then return end
	
	optionTable.onSet( optionTable.conVar, val )
end

function catherine.option.Toggle( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	
	if ( !optionTable or optionTable.typ != CAT_OPTION_SWITCH or !optionTable.conVar ) then return end
	
	RunConsoleCommand( optionTable.conVar, tostring( tobool( GetConVarString( optionTable.conVar ) ) == true and 0 or 1 ) )
end

function catherine.option.Get( uniqueID )
	local optionTable = catherine.option.FindByID( uniqueID )
	
	if ( !optionTable ) then return end
	
	return optionTable.onGet and optionTable.onGet( optionTable ) or GetConVarString( optionTable.conVar )
end

local category = "^Option_Category_01"

catherine.option.Register( "CONVAR_ADMIN_ESP", "cat_convar_adminesp", "^Option_Str_ADMIN_ESP_Name", "^Option_Str_ADMIN_ESP_Desc", "^Option_Category_03", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_ITEM_ESP", "cat_convar_itemesp", "^Option_Str_ITEM_ESP_Name", "^Option_Str_ITEM_ESP_Desc", "^Option_Category_03", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_ALWAYS_ADMIN_ESP", "cat_convar_alwaysadminesp", "^Option_Str_Always_ADMIN_ESP_Name", "^Option_Str_Always_ADMIN_ESP_Desc", "^Option_Category_03", CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_CHAT_TIMESTAMP", "cat_convar_chat_timestamp", "^Option_Str_CHAT_TIMESTAMP_Name", "^Option_Str_CHAT_TIMESTAMP_Desc", category, CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_HINT", "cat_convar_hint", "^Option_Str_HINT_Name", "^Option_Str_HINT_Desc", category, CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_BAR", "cat_convar_bar", "^Option_Str_BAR_Name", "^Option_Str_BAR_Desc", category, CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_MAINHUD", "cat_convar_hud", "^Option_Str_MAINHUD_Name", "^Option_Str_MAINHUD_Desc", category, CAT_OPTION_SWITCH )
catherine.option.Register( "CONVAR_LANGUAGE", "cat_convar_language", "^Option_Str_MAINLANG_Name", "^Option_Str_MAINLANG_Desc", category, CAT_OPTION_LIST, function( )
	local lang = {
		data = { },
		curVal = "English"
	}
	local languageTable = catherine.language.FindByID( GetConVarString( "cat_convar_language" ) )
	
	if ( languageTable ) then
		lang.curVal = languageTable.name
	else
		lang.curVal = "Unknown"
	end
	
	for k, v in pairs( catherine.language.GetAll( ) ) do
		lang.data[ #lang.data + 1 ] = {
			func = function( )
				RunConsoleCommand( "cat_convar_language", k )
				catherine.help.lists = { }
				catherine.menu.Rebuild( )
				
				timer.Simple( 0, function( )
					hook.Run( "LanguageChanged" )
				end )
			end,
			name = v.name
		}
	end
	
	return lang
end )