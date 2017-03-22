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
PLUGIN.name = "^ESCMenu_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^ESCMenu_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "ESCMenu_Plugin_Name" ] = "ESC Menu",
	[ "ESCMenu_Plugin_Desc" ] = "Added the ESC Menu.",
	[ "ESCMenu_UI_Disconnect" ] = "Disconnect",
	[ "ESCMenu_UI_Close" ] = "Close",
	[ "ESCMenu_UI_ClassicMenu" ] = "To the Classic Menu"
} )

catherine.language.Merge( "korean", {
	[ "ESCMenu_Plugin_Name" ] = "ESC 메뉴",
	[ "ESCMenu_Plugin_Desc" ] = "ESC 메뉴를 추가합니다.",
	[ "ESCMenu_UI_Disconnect" ] = "서버 나가기",
	[ "ESCMenu_UI_Close" ] = "창 닫기",
	[ "ESCMenu_UI_ClassicMenu" ] = "클래식 메뉴로"
} )

if ( CLIENT ) then
	function PLUGIN:PreRender( )
		if ( input.IsKeyDown( KEY_ESCAPE ) and gui.IsGameUIVisible( ) ) then
			gui.HideGameUI( )
			
			if ( IsValid( catherine.vgui.escmenu ) ) then
				catherine.vgui.escmenu:Close( )
			else
				catherine.vgui.escmenu = vgui.Create( "catherine.vgui.escmenu" )
			end
			
			return true
		end
	end
end