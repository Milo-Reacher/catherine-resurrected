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
PLUGIN.name = "^WT_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^WT_Plugin_Desc"
PLUGIN.textLists = PLUGIN.textLists or { }
PLUGIN.colorMap = {
	"black", "white", "red", "green", "blue", "yellow", "purple", "cyan", "turq"
}

catherine.language.Merge( "english", {
	[ "WT_Plugin_Name" ] = "Wall Text",
	[ "WT_Plugin_Desc" ] = "Write text to wall.",
	[ "WallText_Notify_Add" ] = "You have added text to your desired location.",
	[ "WallText_Notify_Remove" ] = "You have removed %s's texts.",
	[ "WallText_Notify_NoText" ] = "There are no texts at that location!",
	[ "WallText_Notify_NotValidColor" ] = "The text color not a valid!"
} )

catherine.language.Merge( "korean", {
	[ "WT_Plugin_Name" ] = "벽 글씨",
	[ "WT_Plugin_Desc" ] = "벽에 글씨를 쓸 수 있습니다.",
	[ "WallText_Notify_Add" ] = "해당 위치에 글씨를 추가했습니다.",
	[ "WallText_Notify_Remove" ] = "당신은 %s개의 글씨를 지웠습니다.",
	[ "WallText_Notify_NoText" ] = "해당 위치에는 글씨가 없습니다!",
	[ "WallText_Notify_NotValidColor" ] = "글씨 색깔이 올바르지 않습니다!"
} )

catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_textAdd",
	command = "textadd",
	syntax = "[Text] [Size]",
	desc = "Add the Text at the looking position.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			PLUGIN:AddText( pl, args[ 1 ], tonumber( args[ 2 ] ) )
			
			catherine.util.NotifyLang( pl, "WallText_Notify_Add" )
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_textColorAdd",
	command = "textcoloradd",
	syntax = "[Text] [Color (black/white/red/green/blue/yellow/purple/cyan/turq)] [Size]",
	desc = "Add the Color Text at the looking position.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			if ( args[ 2 ] ) then
				if ( table.HasValue( PLUGIN.colorMap, args[ 2 ] ) ) then
					PLUGIN:AddText( pl, args[ 1 ], tonumber( args[ 3 ] ), args[ 2 ] )
					
					catherine.util.NotifyLang( pl, "WallText_Notify_Add" )
				else
					catherine.util.NotifyLang( pl, "WallText_Notify_NotValidColor" )
				end
			else
				catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 2 )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_textRemove",
	command = "textremove",
	syntax = "[Distance]",
	desc = "Remove the Text at the looking position.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local i = PLUGIN:RemoveText( pl:GetEyeTraceNoCursor( ).HitPos, args[ 1 ] or 256 )
		
		if ( i == 0 ) then
			catherine.util.NotifyLang( pl, "WallText_Notify_NoText" )
		else
			catherine.util.NotifyLang( pl, "WallText_Notify_Remove", i )
		end
	end
} )