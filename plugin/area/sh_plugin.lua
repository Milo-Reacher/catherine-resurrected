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
PLUGIN.name = "^Area_Plugin_Name"
PLUGIN.author = "L7D, Chessnut"
PLUGIN.desc = "^Area_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Area_Plugin_Name" ] = "Area",
	[ "Area_Plugin_Desc" ] = "Adding the Area.",
	[ "Area_Notify_AreaIsNotValid" ] = "Area is not a valid!",
	[ "Area_Notify_PlayerNoInArea" ] = "You are not joined any areas!",
	[ "Area_Notify_AreaAddStep1" ] = "Now set the end point of the area.",
	[ "Area_Notify_AreaAddStep2" ] = "You are added area.",
	[ "Area_Notify_AreaRemove" ] = "You are removed it your joining area.",
	[ "Area_Notify_AreaShow" ] = "You are showing All Area Position at %s(sec).",
	[ "Option_Str_Area_Name" ] = "Show Area Message",
	[ "Option_Str_Area_Desc" ] = "Displays message if you are joined area."
} )

catherine.language.Merge( "korean", {
	[ "Area_Plugin_Name" ] = "구역",
	[ "Area_Plugin_Desc" ] = "구역을 추가합니다.",
	[ "Area_Notify_AreaIsNotValid" ] = "구역이 올바르지 않습니다!",
	[ "Area_Notify_PlayerNoInArea" ] = "당신은 어떠한 구역에도 속해있지 않습니다!",
	[ "Area_Notify_AreaAddStep1" ] = "이제 구역의 끝점을 설정하세요.",
	[ "Area_Notify_AreaAddStep2" ] = "당신은 구역을 추가했습니다.",
	[ "Area_Notify_AreaRemove" ] = "당신은 현재 당신이 있는 구역을 삭제하였습니다.",
	[ "Area_Notify_AreaShow" ] = "당신은 모든 구역의 위치를 %s초 동안 표시하도록 하였습니다.",
	[ "Option_Str_Area_Name" ] = "구역 입장 표시",
	[ "Option_Str_Area_Desc" ] = "구역에 입장할 시 메세지를 표시합니다."
} )

catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_areaAdd",
	command = "areaadd",
	syntax = "[Area Name]",
	desc = "Add the Area.",
	canRun = function( pl )
		if ( IsValid( pl ) ) then
			return pl:IsAdmin( )
		end
		
		return false
	end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local areaName = table.concat( args, " " ) or "Basic Area"
			local pos = pl:GetEyeTraceNoCursor( ).HitPos

			if ( !pl:GetNetVar( "areaMin" ) ) then
				pl:SetNetVar( "areaMin", pos )
				pl:SetNetVar( "areaName", areaName )

				catherine.util.NotifyLang( pl, "Area_Notify_AreaAddStep1" )
				netstream.Start( pl, "catherine.plugin.area.DisplayPosition", pos )
			else
				local minVector = pl:GetNetVar( "areaMin" )
				local maxVector = pos
				local name = pl:GetNetVar( "areaName" )
				
				pl:SetNetVar( "areaMin", nil )
				pl:SetNetVar( "areaName", nil )

				PLUGIN:AddArea( name, minVector, maxVector )
				
				catherine.util.NotifyLang( pl, "Area_Notify_AreaAddStep2" )
				netstream.Start( pl, "catherine.plugin.area.DisplayPosition", pos )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_areaEdit",
	command = "areaedit",
	syntax = "[New Area Name]",
	desc = "Edit the Area.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		if ( args[ 1 ] ) then
			local areaName = table.concat( args, " " ) or "Basic Area"
			
			local currArea = pl:GetCurrentArea( )
			
			if ( !currArea ) then
				catherine.util.NotifyLang( pl, "Area_Notify_PlayerNoInArea" )
				return
			end
			
			local areaTable = PLUGIN:FindAreaByID( currArea )
			
			if ( areaTable ) then
				areaTable.name = areaName
			else
				catherine.util.NotifyLang( pl, "Area_Notify_AreaIsNotValid" )
			end
		else
			catherine.util.NotifyLang( pl, "Basic_Notify_NoArg", 1 )
		end
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_areaRemove",
	command = "arearemove",
	desc = "Remove the Area.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local currArea = pl:GetCurrentArea( )
			
		if ( !currArea ) then
			catherine.util.NotifyLang( pl, "Area_Notify_PlayerNoInArea" )
			return
		end
			
		PLUGIN:RemoveArea( currArea )

		catherine.util.NotifyLang( pl, "Area_Notify_AreaRemove" )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_areaShow",
	command = "areashow",
	syntax = "[Showing Time]",
	desc = "Show the all Areas.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local time = math.max( tonumber( args[ 1 ] ) or 5, 5 )
		
		for k, v in pairs( PLUGIN:GetAllAreas( ) ) do
			netstream.Start( pl, "catherine.plugin.area.DisplayPosition_Custom", {
				v.minVector,
				time
			} )
			
			netstream.Start( pl, "catherine.plugin.area.DisplayPosition_Custom", {
				v.maxVector,
				time
			} )
		end
		
		catherine.util.NotifyLang( pl, "Area_Notify_AreaShow", time )
	end
} )