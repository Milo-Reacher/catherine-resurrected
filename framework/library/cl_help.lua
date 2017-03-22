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

if ( !catherine.language ) then
	catherine.util.Include( "sh_language.lua" )
end

catherine.help = catherine.help or { }
catherine.help.lists = { }
CAT_HELP_HTML = 1
CAT_HELP_WEBPAGE = 2

function catherine.help.Register( types, category, codes, noPrefix )
	catherine.help.lists[ category ] = {
		types = types,
		category = category,
		codes = codes,
		noPrefix = noPrefix
	}
end

function catherine.help.GetAll( )
	return catherine.help.lists
end

local function rebuildHelp( )
	catherine.help.Register( CAT_HELP_HTML, LANG( "Help_Category_Credit" ), LANG( "Help_HTMLValue_Credit" ), true )
	catherine.help.Register( CAT_HELP_HTML, LANG( "Help_Category_Changelog" ), Format( catherine.UpdateLog, ScrW( ) / 2, ScrW( ) / 2 ) )
end

function catherine.help.LanguageChanged( )
	rebuildHelp( )
end

hook.Add( "LanguageChanged", "catherine.help.LanguageChanged", catherine.help.LanguageChanged )

rebuildHelp( )