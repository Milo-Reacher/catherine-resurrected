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

local TOOL = catherine.tool.New( "cat_door" )

TOOL.Category = "Catherine"
TOOL.Name = "Door"
TOOL.Desc = "Change lot a Door settings on Easy and Faster."
TOOL.HelpText = "Left Click : Do something."
TOOL.UniqueID = "cat_door"

TOOL.ClientConVar[ "mode" ] = "1"
TOOL.ClientConVar[ "doorname" ] = "Door"
TOOL.ClientConVar[ "doordesc" ] = "A description."

function TOOL:LeftClick( trace )
	if ( CLIENT ) then return true end
	
	local pl = self:GetOwner( )
	local mode = self:GetClientNumber( "mode" )
	local ent = trace.Entity

	if ( mode == 1 ) then
		if ( IsValid( ent ) and ent:IsDoor( ) ) then
			if ( ent.CAT_doorLocked ) then
				ent:Fire( "UnLock" )
				ent:EmitSound( "doors/door_latch3.wav" )
				catherine.util.NotifyLang( pl, "Door_Notify_CMD_UnLocked" )
				ent.CAT_doorLocked = nil
				
				return true
			else
				ent:Fire( "Lock" )
				ent:EmitSound( "doors/door_latch3.wav" )
				catherine.util.NotifyLang( pl, "Door_Notify_CMD_Locked" )
				ent.CAT_doorLocked = true
				
				return true
			end
		else
			catherine.util.NotifyLang( pl, "Entity_Notify_NotDoor" )
			
			return false
		end
	elseif ( mode == 2 ) then
		local success, langKey = catherine.door.SetDoorTitle( pl, ent, self:GetClientInfo( "doorname" ), true )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_SetTitle" )
			
			return true
		else
			catherine.util.NotifyLang( pl, langKey )
			
			return false
		end
	elseif ( mode == 3 ) then
		local success, langKey = catherine.door.SetDoorDescription( pl, ent, self:GetClientInfo( "doordesc" ) )
		
		if ( success ) then
			catherine.util.NotifyLang( pl, "Door_Notify_SetDesc" )
			
			return true
		else
			catherine.util.NotifyLang( pl, langKey )
			
			return false
		end
	elseif ( mode == 4 ) then
		local success, langKey = catherine.door.SetDoorStatus( pl, ent )
		
		catherine.util.NotifyLang( pl, langKey )

		return success
	elseif ( mode == 5 ) then
		local success, langKey = catherine.door.SetDoorActive( pl, ent )
		
		catherine.util.NotifyLang( pl, langKey )

		return success
	end
	
	return true
end

function TOOL:RightClick( trace )
	return false
end

if ( CLIENT ) then
	local function UpdateControlPanel( pnl )
		pnl:ClearControls( )
		
		local mode = catherine.pl:GetInfoNum( "cat_door_mode", 0 )
		
		local list = vgui.Create( "DListView" )
		list:SetSize( 30, 103 )
		list:AddColumn( "Tool Mode" )
		list:SetMultiSelect( false )
		list.OnRowSelected = function( pnl, id, line )
			if ( mode != id ) then
				RunConsoleCommand( "cat_door_changemode", id )
			end
		end

		if ( mode == 1 ) then
			list:AddLine( "> Lock / Unlock Door" )
		else
			list:AddLine( "Lock / Unlock Door" )
		end
		
		if ( mode == 2 ) then
			list:AddLine( "> Change Door Title" )
		else
			list:AddLine( "Change Door Title" )
		end
		
		if ( mode == 3 ) then
			list:AddLine( "> Change Door Description" )
		else
			list:AddLine( "Change Door Description" )
		end
		
		if ( mode == 4 ) then
			list:AddLine( "> Change Door Status" )
		else
			list:AddLine( "Change Door Status" )
		end
		
		if ( mode == 5 ) then
			list:AddLine( "> Change Door Active" )
		else
			list:AddLine( "Change Door Active" )
		end
		
		list:SortByColumn( 1 )
		pnl:AddItem( list )
		
		if ( mode == 1 ) then
			pnl:AddControl( "Header", {
				Text = "Lock / Unlook Door",
				Description	= "Lock and unlock door."
			} )
		elseif ( mode == 2 ) then
			pnl:AddControl( "TextBox", { 
				Label = "Door Title",
				MaxLenth = "30",
				Command = "cat_door_doorname"
			} )
			
			pnl:AddControl( "Header", {
				Text = "Change door title.",
				Description	= "Change door title.\nIf you are change to 'Blank' does it change to default value."
			} )
		elseif ( mode == 3 ) then
			pnl:AddControl( "TextBox", { 
				Label = "Door Description",
				MaxLenth = "50",
				Command = "cat_door_doordesc"
			} )
			
			pnl:AddControl( "Header", {
				Text = "Change door description.",
				Description	= "Change door description.\nIf you are change to 'Blank' does it change to default value."
			} )
		elseif ( mode == 4 ) then
			pnl:AddControl( "Header", {
				Text = "Change door status.",
				Description	= "Change door status (ownable / unownable)."
			} )
		elseif ( mode == 5 ) then
			pnl:AddControl( "Header", {
				Text = "Change door active.",
				Description	= "Change door active (show / hide)."
			} )
		end
	end

	concommand.Add( "cat_door_changemode", function( pl, cmd, args )
		if ( pl:GetInfoNum( "cat_door_mode", 0 ) != args[ 1 ] ) then
			RunConsoleCommand( "cat_door_mode", args[ 1 ] )
			
			timer.Simple( 0, function( )
				RunConsoleCommand( "cat_door_updatepanel" )
			end )
		end
	end )

	concommand.Add( "cat_door_updatepanel", function( )
		local pnl = controlpanel.Get( "cat_door" )
		
		if ( pnl ) then
			UpdateControlPanel( pnl )
		end
	end )
	
	function TOOL.BuildCPanel( pnl )
		UpdateControlPanel( pnl )
	end
end

catherine.tool.Register( TOOL )