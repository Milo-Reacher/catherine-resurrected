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

catherine.menu = catherine.menu or {
	activePanel = nil,
	activePanelName = nil,
	activePanelUniqueID = nil
}
catherine.menu.lists = { }
CAT_MENU_STATUS_SAMEMENU = 1
CAT_MENU_STATUS_SAMEMENU_NO = 2
CAT_MENU_STATUS_NOTSAMEMENU = 3
CAT_MENU_STATUS_NOTSAMEMENU_NO = 4

function catherine.menu.Register( name, uniqueID, func, canLook )
	catherine.menu.lists[ #catherine.menu.lists + 1 ] = {
		name = name,
		uniqueID = uniqueID,
		func = func,
		canLook = canLook
	}
end

function catherine.menu.Override( uniqueID, name, func, canLook )
	for k, v in pairs( catherine.menu.lists ) do
		if ( v.uniqueID == uniqueID ) then
			local data = catherine.menu.lists[ k ]
			
			if ( name ) then
				data.name = name
			end
			
			if ( func ) then
				data.func = func
			end
			
			if ( canLook ) then
				data.canLook = canLook
			end
			
			break
		end
	end
end

function catherine.menu.GetAll( )
	return catherine.menu.lists
end

function catherine.menu.GetPanel( )
	return catherine.vgui.menu
end

function catherine.menu.GetActivePanel( )
	return catherine.menu.activePanel
end

function catherine.menu.GetActivePanelName( )
	return catherine.menu.activePanelName
end

function catherine.menu.GetActivePanelUniqueID( )
	return catherine.menu.activePanelUniqueID
end

function catherine.menu.SetActivePanel( pnl )
	catherine.menu.activePanel = pnl
end

function catherine.menu.SetActivePanelName( name )
	catherine.menu.activePanelName = name
end

function catherine.menu.SetActivePanelUniqueID( uniqueID )
	catherine.menu.activePanelUniqueID = uniqueID
end

function catherine.menu.RecoverLastActivePanel( menuPanel )
	local activePanel = catherine.menu.GetActivePanel( )
	local pl = catherine.pl
	
	if ( IsValid( activePanel ) and type( activePanel ) == "Panel" and activePanel:IsHiding( ) ) then
		for k, v in pairs( catherine.menu.GetAll( ) ) do
			if ( v.uniqueID == catherine.menu.GetActivePanelUniqueID( ) ) then
				if ( v.canLook and v.canLook( pl ) == false ) then
					catherine.menu.SetActivePanel( nil )
					catherine.menu.SetActivePanelName( nil )
					catherine.menu.SetActivePanelUniqueID( nil )
					
					return
				end
			end
		end
		
		activePanel:Show( )
		activePanel:OnMenuRecovered( )
	end
end

function catherine.menu.Rebuild( )
	if ( IsValid( catherine.vgui.menu ) ) then
		if ( catherine.vgui.menu:IsVisible( ) ) then
			catherine.vgui.menu:Remove( )
			
			timer.Simple( 0, function( )
				catherine.vgui.menu = vgui.Create( "catherine.vgui.menu" )
			end )
		else
			catherine.vgui.menu:Remove( )
		end
	end
end

function catherine.menu.VGUIMousePressed( pnl, code )
	local menuPanel = catherine.menu.GetPanel( )
	local activePanel = catherine.menu.GetActivePanel( )
	
	if ( IsValid( menuPanel ) and IsValid( activePanel ) and menuPanel == pnl ) then
		activePanel:Close( )
		catherine.menu.SetActivePanel( nil )
		catherine.menu.SetActivePanelName( nil )
		catherine.menu.SetActivePanelUniqueID( nil )
	end
end

hook.Add( "VGUIMousePressed", "catherine.menu.VGUIMousePressed", catherine.menu.VGUIMousePressed )

concommand.Add( "cat_menu_rebuild", function( )
	catherine.menu.Rebuild( )
end )