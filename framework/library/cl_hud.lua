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

catherine.hud = catherine.hud or {
	welcomeIntroWorkingData = nil,
	progressBar = nil,
	topNotify = nil,
	welcomeIntro = nil,
	vAlpha = 0,
	vAlphaTarget = 255,
	sAlpha = 0,
	sAlphaTarget = 255
}
catherine.hud.welcomeIntroAnimations = { }
local blockedModules = { }

--[[ Function Optimize :> ]]--
local gradient_center = Material( "gui/center_gradient" )
local vignetteMat = Material( "CAT/vignette.png" )
local animationApproach = math.Approach
local setColor = surface.SetDrawColor
local setMat = surface.SetMaterial
local drawMat = surface.DrawTexturedRect
local drawText = draw.SimpleText
local drawBox = draw.RoundedBox
local drawCircle = catherine.geometry.DrawCircle
local noTex = draw.NoTexture
local timeFrac = math.TimeFraction
local mathR = math.Round
local traceLine = util.TraceLine

function catherine.hud.RegisterBlockModule( name )
	blockedModules[ #blockedModules + 1 ] = name
end

function catherine.hud.GetBlockModules( )
	return blockedModules
end

function catherine.hud.Draw( pl )
	if ( GetConVarString( "cat_convar_hud" ) == "0" ) then return end
	local w, h = ScrW( ), ScrH( )
	
	catherine.hud.ZipTie( pl, w, h )
	catherine.hud.Vignette( pl, w, h )
	catherine.hud.ScreenDamage( pl, w, h )
	catherine.hud.Ammo( pl, w, h )
	catherine.hud.DeathScreen( pl, w, h )
	catherine.hud.ProgressBar( pl, w, h )
	catherine.hud.TopNotify( pl, w, h )
	catherine.hud.WelcomeIntro( pl, w, h )
end

function catherine.hud.ZipTie( pl, w, h )
	if ( !pl:IsTied( ) ) then return end
	
	setColor( 70, 70, 70, 100 )
	setMat( gradient_center )
	drawMat( w / 2 - w / 2 / 2, 0, w / 2, 40 )
	
	drawText( LANG( "Item_Message03_ZT" ), "catherine_normal20", w / 2, 20, Color( 255, 255, 255, 255 ), 1, 1 )
end

function catherine.hud.DeathScreen( pl, w, h )
	if ( !IsValid( pl ) or !pl:IsCharacterLoaded( ) ) then return end
	local deathTime = pl:GetNetVar( "deathTime", 0 )
	local nextSpawnTime = pl:GetNetVar( "nextSpawnTime", 0 )
	
	if ( deathTime == 0 or nextSpawnTime == 0 ) then return end
	
	drawBox( 0, 0, 0, w, h, Color( 20, 20, 20, timeFrac( deathTime, nextSpawnTime, CurTime( ) ) * 255 ) )
end

timer.Create( "catherine.hud.VignetteCheck", 2, 0, function( )
	if ( !vignetteMat or vignetteMat:IsError( ) ) then return end
	local pl = catherine.pl
	
	if ( !IsValid( pl ) ) then return end
	if ( hook.Run( "ShouldCheckVignette", pl ) == false ) then return end
	
	local data = { start = pl:GetPos( ) }
	data.endpos = data.start + Vector( 0, 0, 2000 )
	local tr = traceLine( data )
	
	catherine.hud.vAlphaTarget = ( !tr.Hit or tr.HitSky ) and 125 or 255
end )

function catherine.hud.Vignette( pl, w, h )
	if ( !vignetteMat or vignetteMat:IsError( ) ) then return end
	if ( hook.Run( "ShouldDrawVignette", pl ) == false ) then return end
	
	catherine.hud.vAlpha = animationApproach( catherine.hud.vAlpha, catherine.hud.vAlphaTarget, FrameTime( ) * 90 )
	
	setColor( 0, 0, 0, catherine.hud.vAlpha )
	setMat( vignetteMat )
	drawMat( 0, 0, w, h )
end

function catherine.hud.ScreenDamage( pl, w, h )
	if ( hook.Run( "ShouldDrawScreenDamage", pl ) == false ) then return end
	
	if ( pl:Alive( ) and pl:Health( ) <= 35 ) then
		catherine.hud.sAlphaTarget = 150 * ( 1 - ( pl:Health( ) / 35 ) )
	else
		catherine.hud.sAlphaTarget = 0
	end
	
	catherine.hud.sAlpha = animationApproach( catherine.hud.sAlpha, catherine.hud.sAlphaTarget, FrameTime( ) * 90 )
	
	if ( math.Round( catherine.hud.sAlpha ) > 0 ) then
		setColor( 255, 0, 0, catherine.hud.sAlpha )
		setMat( Material( "cat/4.png") )
		drawMat( 0, 0, w, h )
	end
end

function catherine.hud.Ammo( pl, w, h )
	local wep = pl:GetActiveWeapon( )
	if ( !IsValid( wep ) or wep.DrawHUD == false ) then return end
	if ( hook.Run( "ShouldDrawAmmo", pl ) == false ) then return end
	local clip1 = wep:Clip1( )
	local pre = pl:GetAmmoCount( wep:GetPrimaryAmmoType( ) )
	local sec = pl:GetAmmoCount( wep:GetSecondaryAmmoType( ) )
	
	if ( clip1 > 0 or pre > 0 ) then
		clip1 = mathR( clip1 )
		pre = mathR( pre )
		
		surface.SetFont( "catherine_normal20" )
		
		local clip1MaxW, clip1MaxH = surface.GetTextSize( wep:GetMaxClip1( ) )
		local circleSize = math.max( clip1MaxW, 15 )
		
		noTex( )
		setColor( 255, 255, 255, 255 )
		drawCircle( w - 80 - ( circleSize / 2 ), h - 20 - ( circleSize / 2 ), circleSize, 3, 90, 360, 100 )
		
		noTex( )
		setColor( 255, 50, 50, 255 )
		drawCircle( w - 80 - ( circleSize / 2 ), h - 20 - ( circleSize / 2 ), circleSize, 3, 90, clip1 / wep:GetMaxClip1( ) * 360, 100 )
		
		drawText( clip1, "catherine_normal20", w - 80 - ( circleSize / 2 ), h - 20 - ( circleSize / 2 ), Color( 255, 255, 255, 255 ), 1, 1 )
		drawText( pre, "catherine_normal25", w - 20, h - 30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
		
		if ( sec > 0 ) then
			drawText( "★" .. mathR( sec ), "catherine_normal35", w - 20, h - 70, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, 1 )
		end
	end
end

function catherine.hud.WelcomeIntroInitialize( noRun )
	local scrW, scrH = ScrW( ), ScrH( )
	local gm_information = hook.Run( "GetFrameworkInformation" )
	local schema_information = hook.Run( "GetSchemaInformation" )
	
	catherine.hud.RegisterWelcomeIntroAnimation( function( )
		return schema_information.title
	end, "catherine_outline35", 8, nil, scrW * 0.8, scrH / 2, TEXT_ALIGN_RIGHT )
	
	catherine.hud.RegisterWelcomeIntroAnimation( function( )
		return gm_information.author
	end, "catherine_outline20", 8, nil, scrW * 0.15, scrH * 0.8, TEXT_ALIGN_LEFT )
	
	catherine.hud.RegisterWelcomeIntroAnimation( function( )
		return schema_information.author
	end, "catherine_outline20", 8, nil, scrW * 0.85, scrH * 0.8, TEXT_ALIGN_RIGHT )
	
	if ( !noRun ) then
		catherine.hud.welcomeIntroWorkingData = { initStartTime = CurTime( ), runID = 1 }
	end
end

function catherine.hud.RegisterWelcomeIntroAnimation( text, font, showingTime, col, startX, startY, xAlign, yAlign )
	catherine.hud.welcomeIntroAnimations[ #catherine.hud.welcomeIntroAnimations + 1 ] = {
		text = "",
		font = font,
		targetText = text,
		startX = startX,
		startY = startY,
		startTime = CurTime( ),
		showingTime = showingTime,
		a = 0,
		xAlign = xAlign,
		yAlign = yAlign,
		textSubCount = 1,
		textTime = CurTime( ),
		textTimeDelay = 0.09,
	}
end

function catherine.hud.WelcomeIntro( pl, w, h )
	if ( !catherine.hud.welcomeIntroWorkingData or !catherine.hud.welcomeIntroAnimations ) then return end
	if ( hook.Run( "ShouldDrawWelcomeIntro", pl ) == false ) then return end
	local data = catherine.hud.welcomeIntroWorkingData
	local runningData = catherine.hud.welcomeIntroAnimations[ data.runID ]
	
	if ( !runningData ) then
		return
	end
	
	local curTime = CurTime( )
		
	if ( runningData.startTime + runningData.showingTime - 1 <= curTime ) then
		if ( math.Round( runningData.a ) <= 0 ) then
			data.runID = data.runID + 1
			runningData = catherine.hud.welcomeIntroAnimations[ data.runID ]
			
			if ( !runningData ) then
				catherine.hud.welcomeIntroWorkingData = nil
				return
			end
			runningData.startTime = curTime
		else
			runningData.a = Lerp( 0.03, runningData.a, 0 )
		end
	else
		runningData.a = Lerp( 0.03, runningData.a, 255 )
	end
	
	local targetText = type( runningData.targetText ) == "function" and runningData.targetText( ) or runningData.targetText
	
	if ( runningData.textTime <= curTime and runningData.text:utf8len( ) < targetText:utf8len( ) ) then
		local text = targetText:utf8sub( runningData.textSubCount, runningData.textSubCount )
		
		runningData.text = runningData.text .. text
		runningData.textSubCount = runningData.textSubCount + 1
		runningData.textTime = curTime + runningData.textTimeDelay
		
		surface.PlaySound( "common/talk.wav" )
	end
	
	local col = runningData.col or Color( 255, 255, 255 )
	
	drawText( runningData.text, runningData.font, runningData.startX, runningData.startY, Color( col.r, col.g, col.b, runningData.a ), runningData.xAlign or 1, runningData.yAlign or 1 )
end

function catherine.hud.ProgressBarAdd( message, endTime )
	catherine.hud.progressBar = {
		message = message,
		startTime = CurTime( ),
		endTime = CurTime( ) + endTime
	}
end

function catherine.hud.TopNotifyAdd( message )
	catherine.hud.topNotify = { message = message }
end

function catherine.hud.TopNotify( pl, w, h )
	if ( !catherine.hud.topNotify ) then return end
	if ( hook.Run( "ShouldDrawTopNotify", pl ) == false ) then return end
	
	setColor( 50, 50, 50, 150 )
	setMat( gradient_center )
	drawMat( 0, h / 2 - 80, w, 110 )
	
	drawText( catherine.hud.topNotify.message or "", "catherine_normal25", w / 2, h / 2 - 30, Color( 255, 255, 255, 255 ), 1, 1 )
end

function catherine.hud.ProgressBar( pl, w, h )
	if ( !catherine.hud.progressBar ) then return end
	if ( hook.Run( "ShouldDrawProgressBar", pl ) == false ) then return end
	local data = catherine.hud.progressBar
	
	if ( data.endTime <= CurTime( ) ) then
		catherine.hud.progressBar = nil
		return
	end
	
	local frac = 1 - timeFrac( data.startTime, data.endTime, CurTime( ) )
	
	setColor( 50, 50, 50, 150 )
	setMat( gradient_center )
	drawMat( 0, h / 2 - 80, w, 110 )
	
	noTex( )
	setColor( 90, 90, 90, 255 )
	drawCircle( w / 2, h / 2 - 40, 15, 5, 90, 360, 100 )
	
	noTex( )
	setColor( 255, 255, 255, 255 )
	drawCircle( w / 2, h / 2 - 40, 15, 5, 90, 360 * frac, 100 )
	
	drawText( data.message or "", "catherine_normal25", w / 2, h / 2, Color( 255, 255, 255, 255 ), 1, 1 )
end

local modules = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudCrosshair",
	"CHudDamageIndicator",
	"CHudCloseCaption",
	"CHudGeiger",
	"CHudHintDisplay",
	"CHudMessage",
	"CHudPoisonDamageIndicator",
	"CHudGameMessage",
	"CHudDeathNotice",
	"CHudSquadStatus",
	"CHudVoiceStatus"
}

for i = 1, #modules do
	catherine.hud.RegisterBlockModule( modules[ i ] )
end

netstream.Hook( "catherine.hud.WelcomeIntroStart", function( )
	catherine.hud.WelcomeIntroInitialize( )
end )