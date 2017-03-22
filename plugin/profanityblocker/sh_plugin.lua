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
PLUGIN.name = "^Profanity_Blocker_Plugin_Name"
PLUGIN.author = "L7D"
PLUGIN.desc = "^Profanity_Blocker_Plugin_Desc"

catherine.language.Merge( "english", {
	[ "Profanity_Blocker_Plugin_Name" ] = "Profanity Blocker",
	[ "Profanity_Blocker_Plugin_Desc" ] = "Adding the Profanity Blocker.",
	[ "Profanity_Blocker_Warning" ] = "Do not use Profanity."
} )

catherine.language.Merge( "korean", {
	[ "Profanity_Blocker_Plugin_Name" ] = "욕설 차단",
	[ "Profanity_Blocker_Plugin_Desc" ] = "욕설 차단 시스템을 추가합니다.",
	[ "Profanity_Blocker_Warning" ] = "비속어를 사용하지 마십시오."
} )

if ( SERVER ) then
	PLUGIN.storedProfanityCount = PLUGIN.storedProfanityCount or { }
	PLUGIN.storedKickCount = PLUGIN.storedKickCount or { }
	local blockClasses = { "ooc", "looc" }
	local profanityList = { }
	
	function PLUGIN:RegisterProfanity( text, additive, smartIgnore )
		profanityList[ #profanityList + 1 ] = {
			text = text,
			textLowered = text:lower( ),
			additive = additive,
			smartIgnore = smartIgnore
		}
	end
	
	PLUGIN:RegisterProfanity( "시발", {
		"시1발",
		"시!발"
	}, {
		"시발점"
	} )
	
	function PLUGIN:IsProfanity( text )
		text = text:lower( )
		
		for k, v in pairs( profanityList ) do
			local startPos, endPos = text:find( v.textLowered )
			
			if ( startPos and endPos ) then
				if ( v.smartIgnore ) then
					for k1, v1 in pairs( v.smartIgnore ) do
						local startPos1, endPos1 = text:find( v1:lower( ) )
						
						if ( startPos == startPos1 ) then
							return false
						end
					end
				end
				
				return true
			end
			
			if ( v.additive ) then
				for k1, v1 in pairs( v.additive ) do
					if ( text:find( v1:lower( ) ) ) then
						return true
					end
				end
			end
		end
		
		return false
	end
	
	function PLUGIN:PlayerCharacterLoaded( pl )
		if ( self.storedProfanityCount[ pl:SteamID( ) ] and !pl.CAT_profanityCount ) then
			self.storedProfanityCount[ pl:SteamID( ) ] = pl.CAT_profanityCount
		end
	end
	
	function PLUGIN:PlayerDisconnected( pl )
		if ( pl.CAT_profanityCount ) then
			self.storedProfanityCount[ pl:SteamID( ) ] = pl.CAT_profanityCount
		end
	end
	
	function PLUGIN:OnChatControl( chatInformation )
		local pl = chatInformation.pl
		local uniqueID = chatInformation.uniqueID
		
		if ( table.HasValue( blockClasses, uniqueID ) and self:IsProfanity( chatInformation.text ) ) then
			pl.CAT_profanityCount = pl.CAT_profanityCount or 0
			
			if ( pl.CAT_profanityCount <= 3 ) then
				local timerID = "Catherine.plugin.timer.RemoveProfanityCount." .. pl:SteamID( )
				
				pl.CAT_profanityCount = pl.CAT_profanityCount + 1
				
				catherine.util.NotifyLang( pl, "Profanity_Blocker_Warning" )
				
				timer.Remove( timerID )
				timer.Create( timerID, 300, pl.CAT_profanityCount, function( )
					if ( IsValid( pl ) ) then
						if ( pl.CAT_profanityCount ) then
							if ( pl.CAT_profanityCount <= 0 ) then
								timer.Remove( timerID )
							else
								pl.CAT_profanityCount = pl.CAT_profanityCount - 1
							end
						else
							timer.Remove( timerID )
						end
					else
						timer.Remove( timerID )
					end
				end )
				
				return false
			else
				timer.Simple( 0, function( )
					local count = self.storedKickCount[ pl:SteamID( ) ]
					
					if ( count ) then
						if ( count >= 2 ) then
							self.storedKickCount[ pl:SteamID( ) ] = 0
							
							pl:Ban( 10, LANG( pl, "Profanity_Blocker_Warning" ) )
						else
							self.storedKickCount[ pl:SteamID( ) ] = count + 1
							
							pl:Kick( LANG( pl, "Profanity_Blocker_Warning" ) )
						end
					else
						self.storedKickCount[ pl:SteamID( ) ] = 1
						
						pl:Kick( LANG( pl, "Profanity_Blocker_Warning" ) )
					end
				end )
				
				return false
			end
		end
	end
end