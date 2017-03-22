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

local TOOL = catherine.tool.New( "cat_permanent_entity" )

TOOL.Category = "Catherine"
TOOL.Name = "Permanent Entity"
TOOL.Desc = "Add / Remove on Permanent Entity."
TOOL.HelpText = "Left Click : Add / Remove on Permanent Entity."
TOOL.UniqueID = "cat_permanent_entity"

function TOOL:LeftClick( trace )
	if ( CLIENT ) then return true end

	local pl = self:GetOwner( )
	local ent = trace.Entity

	local plugin = catherine.plugin.Get( "permanententity" )
	
	if ( plugin ) then
		if ( IsValid( ent ) ) then
			if ( table.HasValue( plugin.entClass, ent:GetClass( ):lower( ) ) ) then
				local curStatus = ent:GetNetVar( "isStatic" )

				ent:SetNetVar( "isStatic", !curStatus )

				catherine.util.NotifyLang( pl, !curStatus and "PermanentE_Notify_Add" or "PermanentE_Notify_Remove" )
				
				return true
			else
				catherine.util.NotifyLang( pl, "PermanentE_Notify_Cant" )
				
				return false
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
			
			return false
		end
	else
		return false
	end
	
	return true
end

function TOOL:RightClick( trace )
	return false
end

if ( CLIENT ) then
	function TOOL.BuildCPanel( pnl )
		pnl:AddControl( "Header", {
			Text = "Add / Remove on the Permanent Entity.",
			Description	= "Add / Remove on the Permanent Entity."
		} )
	end
end

catherine.tool.Register( TOOL )