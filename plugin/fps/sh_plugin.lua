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
PLUGIN.name = "^FPS_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^FPS_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "FPS_Plugin_Name" ] = "FPS",
	[ "FPS_Plugin_Desc" ] = "Showing the FPS.",
	[ "Option_Str_FPS_Name" ] = "Show FPS",
	[ "Option_Str_FPS_Desc" ] = "Displays the FPS.",
	[ "Hint_FPS_01" ] = "If you want look FPS?, go to the Setting menu!"
} )

catherine.language.Merge( "korean", {
	[ "FPS_Plugin_Name" ] = "FPS",
	[ "FPS_Plugin_Desc" ] = "FPS 를 표시합니다.",
	[ "Option_Str_FPS_Name" ] = "FPS 표시",
	[ "Option_Str_FPS_Desc" ] = "FPS 를 표시합니다.",
	[ "Hint_FPS_01" ] = "현재 FPS 를 보고 싶으신가요?, 설정 메뉴에 가세요!"
} )

if ( SERVER ) then return end

function PLUGIN:Initialize( )
	CAT_CONVAR_FPS = CreateClientConVar( "cat_convar_showfps", "0", true, true )
end

function PLUGIN:HUDDrawScoreBoard( )
	if ( GetConVarString( "cat_convar_showfps" ) == "0" ) then return end
	if ( !catherine.pl:IsCharacterLoaded( ) or IsValid( catherine.vgui.character ) or IsValid( catherine.vgui.question ) ) then return end
	local curFPS = math.Round( 1 / FrameTime( ) )
	local minFPS = self.minFPS or 60
	local maxFPS = self.maxFPS or 100

	if ( !self.barH ) then
		self.barH = 1
	end
	
	self.barH = math.Approach( self.barH, ( curFPS / maxFPS ) * 100, 1 )
	
	local barH = self.barH
	
	if ( curFPS > maxFPS ) then
		self.maxFPS = curFPS
	end
	
	if ( curFPS < minFPS ) then
		self.minFPS = curFPS
	end
	
	draw.SimpleText( curFPS .. " FPS", "catherine_fps", ScrW( ) - 10, ScrH( ) / 2 + 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.RoundedBox( 0, ScrW( ) - 30, ( ScrH( ) / 2 ) - barH, 20, barH, Color( 255, 255, 255, 255 ) )
	draw.SimpleText( "MAX : " .. maxFPS, "catherine_fps", ScrW( ) - 10, ScrH( ) / 2 + 40, Color( 150, 255, 150, 255 ), TEXT_ALIGN_RIGHT, 1 )
	draw.SimpleText( "MIN : " .. minFPS, "catherine_fps", ScrW( ) - 10, ScrH( ) / 2 + 55, Color( 255, 150, 150, 255 ), TEXT_ALIGN_RIGHT, 1 )
end

catherine.font.Register( "catherine_fps", {
	font = "Consolas",
	size = 15,
	weight = 1000
} )

catherine.hint.Register( "^Hint_FPS_01" )

catherine.option.Register( "CONVAR_FPS", "cat_convar_showfps", "^Option_Str_FPS_Name", "^Option_Str_FPS_Desc", "^Option_Category_02", CAT_OPTION_SWITCH )