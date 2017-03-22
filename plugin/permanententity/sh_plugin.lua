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
PLUGIN.name = "^PermanentE_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^PermanentE_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "PermanentE_Notify_Add" ] = "Now this entity are permanently save.",
	[ "PermanentE_Notify_Remove" ] = "Now this entity aren't saved.",
	[ "PermanentE_Notify_Cant" ] = "This entity cannot be add to permanent entities!",
	[ "PermanentE_Plugin_Name" ] = "Permanent Entity",
	[ "PermanentE_Plugin_Desc" ] = "Save the entity as Permanent."
} )

catherine.language.Merge( "korean", {
	[ "PermanentE_Notify_Add" ] = "이제 이 물체는 영구적으로 저장됩니다.",
	[ "PermanentE_Notify_Remove" ] = "이제 이 물체는 저장되지 않습니다.",
	[ "PermanentE_Notify_Cant" ] = "이 물체는 영구 물체로 설정할 수 없습니다!",
	[ "PermanentE_Plugin_Name" ] = "영구 물체",
	[ "PermanentE_Plugin_Desc" ] = "물체를 영구적으로 저장합니다.",
} )

catherine.util.Include( "sv_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_permanentEntity",
	command = "staticentity",
	desc = "Add / Remove the Permanent Entity list.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) ) then
			if ( table.HasValue( PLUGIN.entClass, ent:GetClass( ):lower( ) ) ) then
				local curStatus = ent:GetNetVar( "isStatic" )
				
				ent:SetNetVar( "isStatic", !curStatus )
				
				catherine.util.NotifyLang( pl, !curStatus and "PermanentE_Notify_Add" or "PermanentE_Notify_Remove" )
			else
				catherine.util.NotifyLang( pl, "PermanentE_Notify_Cant" )
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotValid" )
		end
	end
} )