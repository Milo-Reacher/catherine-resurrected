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
PLUGIN.name = "^VED_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^VED_Plugin_Desc"
PLUGIN.randModels = { }
PLUGIN.VENDOR_SOLD_DISCOUNTPER = 2
local varsID = {
	"name",
	"desc",
	"factions",
	"classes",
	"inv",
	"cash",
	"setting",
	"status",
	"model"
}
CAT_VENDOR_ACTION_BUY = 1 // Buy from player
CAT_VENDOR_ACTION_SELL = 2 // Sell to player
CAT_VENDOR_ACTION_SETTING_CHANGE = 3
CAT_VENDOR_ACTION_ITEM_CHANGE = 4
CAT_VENDOR_ACTION_ITEM_UNCHANGE = 5

function PLUGIN:GetVendorDatas( ent )
	local data = { }

	for k, v in pairs( varsID ) do
		data[ v ] = ent:GetNetVar( v )
	end
	
	return data
end

function PLUGIN:GetVendorWorkingPlayers( index )
	local players = { }

	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( v:GetNetVar( "vendorWorkingID", 0 ) == index ) then
			players[ #players + 1 ] = v
		end
	end
	
	return players
end

catherine.language.Merge( "english", {
	[ "VED_Plugin_Name" ] = "Vendor NPC",
	[ "VED_Plugin_Desc" ] = "Adding the Vendor NPC.",
	
	[ "Vendor_Notify_Buy" ] = "You are brought '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_Sell" ] = "You are sold '%s' at '%s' from this vendor!",
	[ "Vendor_Notify_VendorNoHasCash" ] = "This vendor has not enough %s!",
	[ "Vendor_Notify_ItemDataUpdate" ] = "Item data updated.",
	[ "Vendor_Notify_NoHasStock" ] = "This vendor don't have this kind of item anymore!",
	[ "Vendor_Notify_NotValid" ] = "This is not vendor!",
	[ "Vendor_Notify_Add" ] = "You are added vendor.",
	[ "Vendor_Notify_Remove" ] = "You are removed this vendor.",
	[ "Vendor_Message_CantUse" ] = "You don't have permission using this vendor!",
	[ "Vendor_NameQ" ] = "What are you want vendor name?",
	
	[ "Vendor_UI_BuyFromVendorStr" ] = "Buy Item",
	[ "Vendor_UI_SellToVendorStr" ] = "Sell Item",
	[ "Vendor_UI_SettingStr" ] = "Vendor Setting",
	[ "Vendor_UI_ItemStr" ] = "Vendor Item",
	[ "Vendor_UI_ItemSettingStr" ] = "Item Setting",
	[ "Vendor_UI_ItemSetting_RegisterStr" ] = "Register",
	[ "Vendor_UI_ItemSetting_UNRegisterStr" ] = "UNRegister",
	[ "Vendor_UI_ItemSetting_CostTitleStr" ] = "Item Cost",
	[ "Vendor_UI_ItemSetting_StockTitleStr" ] = "Item Stock",
	[ "Vendor_UI_ItemSettingNoneTypeStr" ] = "Mode : None",
	[ "Vendor_UI_ItemSettingBuyOnlyTypeStr" ] = "Mode : Buy Only",
	[ "Vendor_UI_ItemSettingSellOnlyTypeStr" ] = "Mode : Sell Only",
	[ "Vendor_UI_ItemSettingBothTypeStr" ] = "Mode : Buy and Sell",
	[ "Vendor_UI_ItemSettingBuyOnlyTypeOptionStr" ] = "Buy Only",
	[ "Vendor_UI_ItemSettingSellOnlyTypeOptionStr" ] = "Sell Only",
	[ "Vendor_UI_ItemSettingBothTypeOptionStr" ] = "Buy and Sell",
	
	[ "Vendor_UI_StockStr" ] = "%s's Stock",
	[ "Vendor_UI_CantBuyStr" ] = "You can not buy anything.",
	[ "Vendor_UI_CantSellStr" ] = "You can not sell anything.",
	[ "Vendor_UI_VendorNameStr" ] = "Vendor Name",
	[ "Vendor_UI_VendorDescriptionStr" ] = "Vendor Description",
	[ "Vendor_UI_VendorModelStr" ] = "Vendor Model",
	[ "Vendor_UI_VendorAllowFactionStr" ] = "Allowed Factions",
	[ "Vendor_UI_VendorAllowClassStr" ] = "Allowed Classes",
	[ "Vendor_UI_VendorAllowFaction_AllowedStr" ] = "Allowed",
	[ "Vendor_UI_VendorAllowFaction_AllowOptionStr" ] = "Allow",
	[ "Vendor_UI_VendorAllowFaction_DenyOptionStr" ] = "Deny",
	[ "Vendor_UI_VendorAllowClass_AllowedStr" ] = "Allowed",
	[ "Vendor_UI_VendorAllowClass_AllowOptionStr" ] = "Allow",
	[ "Vendor_UI_VendorAllowClass_DenyOptionStr" ] = "Deny",
	[ "Vendor_UI_VendorItemNoneTypeStr" ] = "None",
	[ "Vendor_UI_VendorItemBuyOnlyTypeStr" ] = "Buy Only",
	[ "Vendor_UI_VendorItemSellOnlyTypeStr" ] = "Sell Only",
	[ "Vendor_UI_VendorItemBothTypeStr" ] = "Buy and Sell",
	[ "Vendor_UI_HasCash" ] = "This vendor has %s."
} )

catherine.language.Merge( "korean", {
	[ "VED_Plugin_Name" ] = "상인 NPC",
	[ "VED_Plugin_Desc" ] = "상인 NPC 를 추가합니다.",
	
	[ "Vendor_Notify_Buy" ] = "당신은 '%s' 를 '%s' 에 구입하였습니다.",
	[ "Vendor_Notify_Sell" ] = "당신은 '%s' 를 '%s' 에 파셨습니다.",
	[ "Vendor_Notify_VendorNoHasCash" ] = "이 상인은 %s 가 없습니다!",
	[ "Vendor_Notify_ItemDataUpdate" ] = "아이템 데이터를 업데이트 하였습니다.",
	[ "Vendor_Notify_NoHasStock" ] = "이 상인은 재고가 없습니다!",
	[ "Vendor_Notify_NotValid" ] = "이것은 상인이 아닙니다!",
	[ "Vendor_Notify_Add" ] = "상인을 추가했습니다.",
	[ "Vendor_Notify_Remove" ] = "상인을 제거했습니다.",
	[ "Vendor_Message_CantUse" ] = "이 상인을 사용할 권한이 없습니다!",
	[ "Vendor_NameQ" ] = "상인의 이름을 무엇으로 하시겠습니까?",
	
	[ "Vendor_UI_BuyFromVendorStr" ] = "물건 구매",
	[ "Vendor_UI_SellToVendorStr" ] = "물건 판매",
	[ "Vendor_UI_SettingStr" ] = "상인 설정",
	[ "Vendor_UI_ItemStr" ] = "상인 아이템",
	[ "Vendor_UI_ItemSettingStr" ] = "물건 설정",
	[ "Vendor_UI_ItemSetting_RegisterStr" ] = "등록",
	[ "Vendor_UI_ItemSetting_UNRegisterStr" ] = "등록 해제",
	[ "Vendor_UI_ItemSetting_CostTitleStr" ] = "물건 가격",
	[ "Vendor_UI_ItemSetting_StockTitleStr" ] = "물건 재고",
	[ "Vendor_UI_ItemSettingNoneTypeStr" ] = "모드 : 설정되지 않음",
	[ "Vendor_UI_ItemSettingBuyOnlyTypeStr" ] = "모드 : 구매만 가능",
	[ "Vendor_UI_ItemSettingSellOnlyTypeStr" ] = "모드 : 판매만 가능",
	[ "Vendor_UI_ItemSettingBothTypeStr" ] = "모드 : 구매, 판매 가능",
	[ "Vendor_UI_ItemSettingBuyOnlyTypeOptionStr" ] = "구매만 가능",
	[ "Vendor_UI_ItemSettingSellOnlyTypeOptionStr" ] = "판매만 가능",
	[ "Vendor_UI_ItemSettingBothTypeOptionStr" ] = "구매, 판매 가능",
	
	[ "Vendor_UI_StockStr" ] = "%s 개의 재고",
	[ "Vendor_UI_CantBuyStr" ] = "당신이 구매할 수 있는 물건이 없습니다.",
	[ "Vendor_UI_CantSellStr" ] = "당신이 판매할 수 있는 물건이 없습니다.",
	[ "Vendor_UI_VendorNameStr" ] = "상인 이름",
	[ "Vendor_UI_VendorDescriptionStr" ] = "상인 설명",
	[ "Vendor_UI_VendorModelStr" ] = "상인 모델",
	[ "Vendor_UI_VendorAllowFactionStr" ] = "접근 가능한 팩션",
	[ "Vendor_UI_VendorAllowClassStr" ] = "접근 가능한 클래스",
	[ "Vendor_UI_VendorAllowFaction_AllowedStr" ] = "접근 가능",
	[ "Vendor_UI_VendorAllowFaction_AllowOptionStr" ] = "접근 허용",
	[ "Vendor_UI_VendorAllowFaction_DenyOptionStr" ] = "접근 거부",
	[ "Vendor_UI_VendorAllowClass_AllowedStr" ] = "접근 가능",
	[ "Vendor_UI_VendorAllowClass_AllowOptionStr" ] = "접근 허용",
	[ "Vendor_UI_VendorAllowClass_DenyOptionStr" ] = "접근 거부",
	[ "Vendor_UI_VendorItemNoneTypeStr" ] = "설정되지 않음",
	[ "Vendor_UI_VendorItemBuyOnlyTypeStr" ] = "구매만 가능",
	[ "Vendor_UI_VendorItemSellOnlyTypeStr" ] = "판매만 가능",
	[ "Vendor_UI_VendorItemBothTypeStr" ] = "구매, 판매 가능",
	[ "Vendor_UI_HasCash" ] = "이 상인은 %s 를 가지고 있습니다."
} )

catherine.util.Include( "sv_plugin.lua" )
catherine.util.Include( "cl_plugin.lua" )

catherine.command.Register( {
	uniqueID = "&uniqueID_vendorAdd",
	command = "vendoradd",
	desc = "Add the Vendor NPC of this position.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		catherine.util.StringReceiver( pl, "Vendor_SpawnFunc_Name", "^Vendor_NameQ", "Johnson", function( _, val )
			local pos, ang = pl:GetEyeTraceNoCursor( ).HitPos, pl:EyeAngles( )
			ang.p = 0
			ang.y = ang.y - 180
			
			local ent = ents.Create( "cat_vendor" )
			ent:SetPos( pos )
			ent:SetAngles( ang )
			ent:Spawn( )
			ent:Activate( )
			
			PLUGIN:MakeVendor( ent, {
				name = val
			} )
			PLUGIN:SaveVendors( )
			
			catherine.util.NotifyLang( pl, "Vendor_Notify_Add" )
		end )
	end
} )

catherine.command.Register( {
	uniqueID = "&uniqueID_vendorRemove",
	command = "vendorremove",
	desc = "Remove the looking Vendor NPC.",
	canRun = function( pl ) return pl:IsAdmin( ) end,
	runFunc = function( pl, args )
		local ent = pl:GetEyeTraceNoCursor( ).Entity
		
		if ( IsValid( ent ) and ent:GetClass( ) == "cat_vendor" ) then
			ent:Remove( )
			catherine.util.NotifyLang( pl, "Vendor_Notify_Remove" )
		else
			catherine.util.NotifyLang( pl, "Vendor_Notify_NotValid" )
		end
	end
} )