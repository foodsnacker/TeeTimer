module(..., package.seeall)

local function blinktext ( )
	if (blinkend == true) then
		transition.to( digitalzeit, { time=500, alpha=1.0 } )
		blinkend = false
	else
		transition.to( digitalzeit, { time=500, alpha=0 } )
		blinkend = true
	end
end

-- Analoguhr: Zeiger bewegen
local function uhr_update(e)
	local timeTable		 = os.date("*t")
	hourHand.rotation	 = timeTable.hour * 30 + (timeTable.min * 0.5)
	minuteHand.rotation = timeTable.min * 6
	secondHand.rotation = timeTable.sec * 6
	digitalzeit.text = string.format( "%02.f", timeTable.hour ) .. ":" .. string.format( "%02.f", timeTable.min )
	timeTable = nil
end

-- Ton stoppen und Alarm & Timer entfernen
function WegMitDemAlarm()
	audio.fadeOut ( meinton, 500 )
	audio.pause( meinton )
	if ( meinalarm ) then native.cancelAlert( meinalarm ) end
	if ( meintimer ) then timer.cancel( meintimer ) end
	if ( anzeigentimer ) then timer.cancel( anzeigentimer ) end
	timing = false
	analoguhr = timer.performWithDelay(1000, moveHands, 0)
end

-- Vergleich des Timers mit der aktuell verstrichenen Zeit
local function Uhrenvergleich()
	if	(timing == true ) then
		anzeigezeit = biswann - system.getTimer()
		digitalzeit.text = SekundenInUhrzeit ( anzeigezeit ) --:setText( SekundenInUhrzeit ( anzeigezeit ) )
		secondHand.rotation = anzeigezeit / 1000 * 6
		minuteHand.rotation = anzeigezeit / 1000 * 6 / 60
		if ( anzeigezeit > 5000 ) and ( anzeigezeit < 5750 ) then
			if ( config.countdown == 1 ) then audio.play		( countton, { channel = 2, loops = 5, fadein = 500 } ) end
			if ( config.sectick	 == 1 ) then audio.fadeOut ( { channel = 1, time = 500 } ) end
		end
		if ( anzeigezeit <= 0 ) then
			if ( config.sectick	  == 1 ) then audio.stop ( 1 ) end
			if ( config.countdown == 1 ) then audio.stop ( 2 ) end
			if ( config.vibration == 1 ) then system.vibrate( ) end
			timing = false
			digitalzeit.text = getraenk .. " " .. istfertig -- :setText( getraenk .. " " .. istfertig )
			transition.to( digitalzeit, { time=500, alpha=1.0 } )
			audio.play( meinton, { fadein=500 } )
			meinalarm = native.showAlert( "TeaTimer", getraenk .. " " .. istfertig, { danke }, WegMitDemAlarm )
		end
	end
end

local function pause ( event)
	if (abgelaufen == 0) then
		timing = false
		pausean = system.getTimer()
		abgelaufen = biswann
		blinktimer = timer.performWithDelay( 500, blinktext, 0 )
		if (blinktimer) then timer.cancel ( anzeigentimer ) end
		system.setIdleTimer( true )
	else
		timing = true
		biswann = system.getTimer() + biswann - pausean
		abgelaufen = 0
		uhrlaeuft = 1
		if (blinktimer) then timer.cancel ( blinktimer ) end
		anzeigentimer = timer.performWithDelay( 100, Uhrenvergleich, 0 )
		transition.to( digitalzeit, { time=500, alpha=1.0 } )
		system.setIdleTimer( false )
	end
end

local function infotextausblenden ( )
	transition.to( infotext, { time=500, alpha=0.0 } )
end

local function startstop ( event )
	if (event.phase == "ended") then
	if (uhrlaeuft == 1) then		-- Pausieren / Stoppen
		if ( config.sectick	 == 1 ) then audio.stop ( 1 ) end
		if ( config.countdown == 1 ) then audio.stop ( 2 ) end
		infotext.text = uhrantippen		 --setText ( uhrantippen )
		infotext.x = screenW / 2		-- - infotext.width / 2
		transition.to( ausgewaehlt, { time=500, alpha=1.0, y=370 } )
		transition.to( produktname, { time=500, y=400 } )
		transition.to( infotext,	{ time=500, alpha=1.0 } )
		transition.to( digitalzeit, { time=500, alpha=1.0 } )
		transition.to( hourHand,	{ time=500, alpha=1.0 } )
		transition.to( tabBar,		{ time=500, y=screenH - tabBar.height / 2 + 1 } )
		if (abgelaufen == nil) then return end
		if (anzeigentimer) then timer.cancel ( anzeigentimer ) end
		if ((timing == true) or (abgelaufen > 0)) then if (blinktimer ) then timer.cancel ( blinktimer ) end end
		timing = false
		if ( config.sectick == 1 ) then audio.stop( 1 ) end
		system.setIdleTimer( true)
		uhr_update ( )
		analoguhr = timer.performWithDelay(1000, uhr_update, 0)
		uhrlaeuft = 0
		transition.to( digitalzeit, { time=500, alpha=1.0 } )
		return
	end
	-- ansonsten starten...
	infotext.text = tippstop -- infotext:setText ( tippstop )
	infotext.x = screenW / 2 -- - infotext.width / 2
	timer.performWithDelay( 1000, infotextausblenden, 1 )
	transition.to( digitalzeit, { time=500, alpha=0.0 } )
	transition.to( ausgewaehlt, { time=500, alpha=0.0, y=screenH - 70 } )
	transition.to( produktname, { time=500, y=screenH - 40 } )
	transition.to( tabBar, { time=500, y=screenH + tabBar.height / 2 + 1  } )
	if (analoguhr)	then timer.cancel ( analoguhr )	end
	if (blinktimer) then timer.cancel ( blinktimer ) end
	abjetzt = system.getTimer()
	biswann = abjetzt + timerzeit
-- alle Zeiger zurechtrücken
	anzeigezeit = biswann - system.getTimer()
	transition.to( hourHand,		{ time=250, alpha=0.0 } )
	transition.to( secondHand,	{ time=250, rotation = anzeigezeit / 1000 * 6 } )
	transition.to( minuteHand,	{ time=250, rotation = anzeigezeit / 1000 * 6 / 60} )
	timing = true
	abgelaufen = 0
	secondHand.rotation = biswann / 1000 * 6
	minuteHand.rotation = biswann / 1000 * 6 / 60	
	anzeigentimer = timer.performWithDelay( 100, Uhrenvergleich, 0 )
	meinton = audio.loadSound ( toene[config.alarmton] )
	tictacton = audio.loadSound ( tictac[1] )
	countton = audio.loadSound ( count[1] )
	audio.setVolume( 0.45, { channel = 1 } )
	audio.setVolume( 0.85, { channel = 2 } )
	if ( config.sectick == 1 ) then audio.play( tictacton, { channel = 1, loops = -1 } ) end
	system.setIdleTimer ( false )
	uhrlaeuft = 1
	transition.to( digitalzeit, { time=500, alpha=1.0 } )
	end
end

local function daten_update ()
	timerzeit		= getraenktab[config.sorte].ziehzeit
	meineZeit		= SekundenInUhrzeit ( timerzeit )
	if config.diesprache == "de" then produktname.text = getraenktab[config.sorte].name else produktname.text = getraenktab[config.sorte].nameen end	
end

function new()

	local g = display.newGroup()
	
	hintergrund = display.newImage( "hintergrund/tee.jpg", 0, 0)

	infotext = display.newText ( uhrantippen, 0, 58, "AmericanTypewriter-Bold", 18 )
	ausgewaehlt = display.newText ( aktuellausgewaehlt, 10, 360, "AmericanTypewriter-Bold", 18 )
	produktname = display.newText ( "", 200, 400, "AmericanTypewriter-Bold", 16 )
	digitalzeit = display.newText ( "", 10, 320, "AmericanTypewriter-Bold", 30 )

	infotext:setTextColor ( 64, 51, 25, 255 )
	ausgewaehlt:setTextColor ( 64, 51, 25, 255 )
	produktname:setTextColor ( 64, 51, 25, 255 )
	digitalzeit:setTextColor ( 64, 51, 25, 255 )
	infotext.x = screenW / 2
	digitalzeit.x  = screenW / 2


-- Analoguhr erstellen & laufen lassen
	analoge_uhr = display.newGroup()
	
	wecker		= display.newImage ( "uhr/stylish/blatt.png", 60, 100 )
	hourHand	= display.newImage ( "uhr/stylish/stunde.png", 157, 150 )
	minuteHand	= display.newImage ( "uhr/stylish/minute.png", 156, 120 )
--	center			= display.newImage ( "uhr/stylish/mitte.png", 154, 214 )
	secondHand	= display.newImage ( "uhr/stylish/sekunde.png", 153, 122 )

--	center:setReferencePoint	(display.BottomCenterReferencePoint)
	hourHand:setReferencePoint	(display.BottomCenterReferencePoint)
	minuteHand:setReferencePoint(display.BottomCenterReferencePoint)
	secondHand:setReferencePoint(display.BottomCenterReferencePoint)
	secondHand.yReference = 37

	uhr_update ()

	analoge_uhr:insert( wecker )
	analoge_uhr:insert( hourHand )
	analoge_uhr:insert( minuteHand )
	analoge_uhr:insert( secondHand )
	analoge_uhr:insert( digitalzeit )

	g:insert ( hintergrund )
	g:insert ( produktname )
	g:insert ( infotext )
	g:insert ( ausgewaehlt )
	g:insert ( analoge_uhr )

	analoge_uhr:addEventListener("touch", startstop)
	analoguhr = timer.performWithDelay(1000, uhr_update, 0)

	daten_update ()

    -- following are iPhone, iPod Touch, iPad
--    if ( screenW > 960 ) then
    	ads.show( "banner", { x=0, y=0, interval=60, testMode=false } )
--	else
--    	ads.show( "banner728x90", { x=0, y=0, interval=60, testMode=false } )
--	end
	
	function g:cleanUp()
		Runtime:removeEventListener("touch", startstop )

		if ( meinalarm ) then native.cancelAlert( meinalarm ) end
		if ( meintimer ) then timer.cancel( meintimer ) end
		if ( anzeigentimer ) then timer.cancel( anzeigentimer ) end
		if ( analoguhr)	then timer.cancel ( analoguhr )	end
		if ( blinktimer) then timer.cancel ( blinktimer ) end
		
		display.remove ( hintergrund )
		display.remove ( produktname )
		display.remove ( infotext )
		display.remove ( ausgewaehlt )

		display.remove ( wecker )
		display.remove ( hourHand )
		display.remove ( minuteHand )
		display.remove ( secondHand )
		display.remove ( digitalzeit )
		display.remove ( analoge_uhr ) -- Gruppe
		display.remove ( g ) -- gruppe
		
		digitalzeit = nil
		wecker = nil
		hourHand = nil
		minuteHand = nil
		secondHand = nil
		hintergrund = nil
		produktname = nil
		infotext = nil
		ausgewaehlt = nil
		analoge_uhr = nil
		g = nil
	end

	return g
end
