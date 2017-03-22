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

local TOOL = catherine.tool.New( "cat_text" )

TOOL.Category = "Catherine"
TOOL.Name = "Text"
TOOL.Desc = "Add / Remove the wall text."
TOOL.HelpText = "Left Click : Add text. / Right Click : Remove text."
TOOL.UniqueID = "cat_text"

TOOL.ClientConVar[ "text" ] = "Text"
TOOL.ClientConVar[ "size" ] = "1"

function TOOL:LeftClick( trace )
	if ( CLIENT ) then return true end
	
	local pl = self:GetOwner( )
	local wallTextPlugin = catherine.plugin.Get( "walltext" )
	
	if ( wallTextPlugin ) then
		wallTextPlugin:AddText( pl, self:GetClientInfo( "text" ), self:GetClientNumber( "size" ) )
		
		catherine.util.NotifyLang( pl, "WallText_Notify_Add" )
		
		return true
	else
		return false
	end
	
	return true
end

function TOOL:RightClick( trace )
	if ( CLIENT ) then return true end
	
	local pl = self:GetOwner( )
	local wallTextPlugin = catherine.plugin.Get( "walltext" )
	
	if ( wallTextPlugin ) then
		local i = wallTextPlugin:RemoveText( pl:GetShootPos( ), 256 )
			
		if ( i == 0 ) then
			catherine.util.NotifyLang( pl, "WallText_Notify_NoText" )
		else
			catherine.util.NotifyLang( pl, "WallText_Notify_Remove", i )
		end
		
		return true
	else
		return false
	end
	
	return true
end

if ( CLIENT ) then
	function TOOL.BuildCPanel( pnl )
		pnl:AddControl( "TextBox", {
			Label = "Text",
			Description = "Value of the text.",
			Command = "cat_text_text",
			MaxLenth = "40"
		} )

		pnl:AddControl( "Slider", {
			Label	= "Text Size",
			Description = "Size of the text.",
			Type	= "Float",
			Min		= 0.1,
			Max		= 25,
			Command = "cat_text_size"
		} )
	end
end

catherine.tool.Register( TOOL )