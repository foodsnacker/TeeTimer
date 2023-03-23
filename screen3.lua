module(..., package.seeall)

local deBtn,enBtn

local function auswahlfunc ( event )
	if ( event.phase == "ended") then
		funktionwahl ( event.id, event.value )
	end
end

function neueknoepfe ( event )
	display.remove ( deBtn )
	display.remove ( enBtn )
	deBtn = nil
	enBtn = nil
		
	collectgarbage( "collect" )
	
	local style = "blue1Large"
	if sprache == "Deutsch" then style = "blue2Large" end
	deBtn = widget.newButton{ id = "de", label = "Deutsch", style = style, onEvent = sprachwahlfunc, top = 60, left = 30, height = 30, width = screenW / 2 - 40, emboss=true }

	style = "blue1Large"
	if sprache == "English" then style = "blue2Large" end
	enBtn = widget.newButton{ id = "en", label = "English", style = style, onEvent = sprachwahlfunc, top = 60, left = screenW / 2 + 10, height = 30, width = screenW / 2 - 40, emboss=true }

	style = nil

	transition.to ( deBtn, { time=100, alpha=1 } )
	transition.to ( enBtn, { time=100, alpha=1 } )

end

function sprachwahlfunc ( event )
	if event.phase == "release" and config.diesprache ~= event.target.id then
		id = event.target.id

		sprachwahl ( id )

		-- weg und neu machen der Texte
		display.remove ( sprachetext )
		display.remove ( alarmtext )
		display.remove ( weiteretext )
		display.remove ( sekundentext )
		display.remove ( countdowntext )
		display.remove ( vibriertext )
		
		sprachetext = nil
		alarmtext = nil
		weiteretext = nil
		sekundentext = nil
		countdowntext = nil
		vibriertext = nil

		sprachetext = display.newEmbossedText ( language, 20, 20, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
		alarmtext = display.newEmbossedText ( alarmname, 20, 120, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
		weiteretext = display.newEmbossedText ( weitereoptionen, 20, 210, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
		sekundentext = display.newEmbossedText ( secondstick, 20, 260, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )
		countdowntext = display.newEmbossedText ( counttick, 20, 295, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )
		vibriertext = display.newEmbossedText ( vibralarm, 20, 325, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )

		einstellung_speichern ()
		transition.to ( deBtn, { time=100, alpha=0, onComplete=neueknoepfe } )
		transition.to ( enBtn, { time=100, alpha=0 } )
	end
end

function tonauswahlfunc ( event )
	if event.phase == "release" then
		tonwahl ( event.target.id )
		einstellung_speichern ()
		if ( audio.isChannelPlaying ( 1 ) ) then audio.stop ( meinton ) end
		meinton = audio.loadSound ( toene[config.alarmton] )
		audio.setVolume( 1.00, { channel = 1 } )
		audio.play( meinton, { channel = 1, loops = 0, fadein = 200 } )

		display.remove ( ton1Btn )
		display.remove ( ton2Btn )
		display.remove ( ton3Btn )
		display.remove ( ton4Btn )
		display.remove ( ton5Btn )
		ton1Btn = nil
		ton2Btn = nil
		ton3Btn = nil
		ton4Btn = nil
		ton5Btn = nil
		
		if config.alarmton == 1 then
			ton1Btn = widget.newButton{ id = 1, default = "gui/weckericon.png", over = "gui/weckericon_grau.png", onEvent = tonauswahlfunc, top = 160, left = 20, height = 30, width = 30 }
		else
			ton1Btn = widget.newButton{ id = 1, default = "gui/weckericon_grau.png", over = "gui/weckericon.png", onEvent = tonauswahlfunc, top = 160, left = 20, height = 30, width = 30 }
		end

		if config.alarmton == 2 then
			ton2Btn = widget.newButton{ id = 2, default = "gui/hahn.png", over = "gui/hahn_grau.png", onEvent = tonauswahlfunc, top = 160, left = 70, height = 30, width = 30 }
		else
			ton2Btn = widget.newButton{ id = 2, default = "gui/hahn_grau.png", over = "gui/hahn.png", onEvent = tonauswahlfunc, top = 160, left = 70, height = 30, width = 30 }
		end
	
		if config.alarmton == 3 then
			ton3Btn = widget.newButton{ id = 3, default = "gui/electronic.png", over = "gui/electronic_grau.png", onEvent = tonauswahlfunc, top = 160, left = 120, height = 30, width = 30 }	
		else
			ton3Btn = widget.newButton{ id = 3, default = "gui/electronic_grau.png", over = "gui/electronic.png", onEvent = tonauswahlfunc, top = 160, left = 120, height = 30, width = 30 }
		end

		if config.alarmton == 4 then
			ton4Btn = widget.newButton{ id = 4, default = "gui/dampflok.png", over = "gui/dampflok_grau.png", onEvent = tonauswahlfunc, top = 160, left = 170, height = 30, width = 30 }	
		else
			ton4Btn = widget.newButton{ id = 4, default = "gui/dampflok_grau.png", over = "gui/dampflok.png", onEvent = tonauswahlfunc, top = 160, left = 170, height = 30, width = 30 }
		end

		if config.alarmton == 5 then
			ton5Btn = widget.newButton{ id = 5, default = "gui/teekessel.png", over = "gui/teekessel_grau.png", onEvent = tonauswahlfunc, top = 160, left = 220, height = 30, width = 30 }	
		else
			ton5Btn = widget.newButton{ id = 5, default = "gui/teekessel_grau.png", over = "gui/teekessel.png", onEvent = tonauswahlfunc, top = 160, left = 220, height = 30, width = 30 }
		end

	end
end

function new()

	ads.hide()

	local g = display.newGroup()
 	g.alpha = 0
 	 	
-- Hintergrund mit Ausschnitt und Slider
	hintergrund = display.newImage( "hintergrund/zahnradtrans.png", 0, 0 ) -- 171, 254)
	hintergrund.alpha = 1

	local ports = {
		port1 = { id="sec", img="gui/onoff.png",over="gui/over.png", x=250,y=274, width=70, height=20, speed=100, range=1 },
		port2 = { id="cou", img="gui/onoff.png",over="gui/over.png", x=250,y=308, width=70, height=20, speed=100, range=1 },
		port3 = { id="vib", img="gui/onoff.png",over="gui/over.png", x=250,y=342, width=70, height=20, speed=100, range=1 }
	}

	local dimensions = { slider = { width=112, height=20 }, over = { width=28, height=18 } }
	
	secslider = slider.newSlider( g, ports.port1, { onComplete=auswahlfunc }, true, true, dimensions )
	couslider = slider.newSlider( g, ports.port2, { onComplete=auswahlfunc }, true, true, dimensions )
	vibslider = slider.newSlider( g, ports.port3, { onComplete=auswahlfunc }, true, true, dimensions )

	secslider.alpha = 0
	couslider.alpha = 0
	vibslider.alpha = 0
	
	if ( config.sectick == 1 )	 then secslider:setState( "on" ) else secslider:setState( "off" ) end
	if ( config.countdown == 1 ) then couslider:setState( "on" ) else couslider:setState( "off" ) end
	if ( config.vibration == 1 ) then vibslider:setState( "on" ) else vibslider:setState( "off" ) end

	local style = "blue1Large"
	if sprache == "Deutsch" then style = "blue2Large" end
	deBtn = widget.newButton{ id = "de", label = "Deutsch", style = style, onEvent = sprachwahlfunc, top = 60, left = 30, height = 30, width = screenW / 2 - 40, emboss=true }
--	deBtn = widget.newButton{ id = "de", label = "Deutsch", onEvent = sprachwahlfunc, top = 60, left = 30, height = 30, width = screenW / 2 - 40, cornerRadius=5, strokeWidth=0, defaultColor=farbe, emboss=true }

	style = "blue1Large"
	if sprache == "English" then style = "blue2Large" end
	enBtn = widget.newButton{ id = "en", label = "English", style = style, onEvent = sprachwahlfunc, top = 60, left = screenW / 2 + 10, height = 30, width = screenW / 2 - 40, emboss=true }
--	enBtn = widget.newButton{ id = "en", label = "English", onEvent = sprachwahlfunc, top = 60, left = screenW / 2 + 10, height = 30, width = screenW / 2 - 40, cornerRadius=5, strokeWidth=0, defaultColor=farbe, emboss=true }

	style = nil

	if config.alarmton == 1 then
		ton1Btn = widget.newButton{ id = 1, default = "gui/weckericon.png", over = "gui/weckericon_grau.png", onEvent = tonauswahlfunc, top = 160, left = 20, height = 30, width = 30 }
	else
		ton1Btn = widget.newButton{ id = 1, default = "gui/weckericon_grau.png", over = "gui/weckericon.png", onEvent = tonauswahlfunc, top = 160, left = 20, height = 30, width = 30 }
	end

	if config.alarmton == 2 then
		ton2Btn = widget.newButton{ id = 2, default = "gui/hahn.png", over = "gui/hahn_grau.png", onEvent = tonauswahlfunc, top = 160, left = 70, height = 30, width = 30 }
	else
		ton2Btn = widget.newButton{ id = 2, default = "gui/hahn_grau.png", over = "gui/hahn.png", onEvent = tonauswahlfunc, top = 160, left = 70, height = 30, width = 30 }
	end
	
	if config.alarmton == 3 then
		ton3Btn = widget.newButton{ id = 3, default = "gui/electronic.png", over = "gui/electronic_grau.png", onEvent = tonauswahlfunc, top = 160, left = 120, height = 30, width = 30 }	
	else
		ton3Btn = widget.newButton{ id = 3, default = "gui/electronic_grau.png", over = "gui/electronic.png", onEvent = tonauswahlfunc, top = 160, left = 120, height = 30, width = 30 }
	end

	if config.alarmton == 4 then
		ton4Btn = widget.newButton{ id = 4, default = "gui/dampflok.png", over = "gui/dampflok_grau.png", onEvent = tonauswahlfunc, top = 160, left = 170, height = 30, width = 30 }	
	else
		ton4Btn = widget.newButton{ id = 4, default = "gui/dampflok_grau.png", over = "gui/dampflok.png", onEvent = tonauswahlfunc, top = 160, left = 170, height = 30, width = 30 }
	end

	if config.alarmton == 5 then
		ton5Btn = widget.newButton{ id = 5, default = "gui/teekessel.png", over = "gui/teekessel_grau.png", onEvent = tonauswahlfunc, top = 160, left = 220, height = 30, width = 30 }	
	else
		ton5Btn = widget.newButton{ id = 5, default = "gui/teekessel_grau.png", over = "gui/teekessel.png", onEvent = tonauswahlfunc, top = 160, left = 220, height = 30, width = 30 }
	end

	sprachetext = display.newEmbossedText ( language, 20, 20, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
	alarmtext = display.newEmbossedText ( alarmname, 20, 120, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
	weiteretext = display.newEmbossedText ( weitereoptionen, 20, 210, "AmericanTypewriter-Bold", 20, {  255, 255, 255, 255 } )
	sekundentext = display.newEmbossedText ( secondstick, 20, 260, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )
	countdowntext = display.newEmbossedText ( counttick, 20, 295, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )
	vibriertext = display.newEmbossedText ( vibralarm, 20, 325, "AmericanTypewriter-Bold", 16, {  255, 255, 255, 255 } )

	g:insert(secslider)
	g:insert(couslider)
	g:insert(vibslider)
	g:insert(hintergrund)
	g:insert(deBtn)
	g:insert(enBtn)

	local function SliderEin ( event )
		transition.to ( secslider, { time=250,alpha=1 } )
		transition.to ( couslider, { time=250,alpha=1 } )
		transition.to ( vibslider, { time=250,alpha=1 } )
	end
	
	transition.to ( g, { time=250,alpha=1,onComplete=SliderEin } )

	function g:cleanUp()
		display.remove ( hintergrund )
		display.remove ( secslider )
		display.remove ( couslider )
		display.remove ( vibslider )
		display.remove ( deBtn )
		display.remove ( enBtn )
		display.remove ( ton1Btn )
		display.remove ( ton2Btn )
		display.remove ( ton3Btn )
		display.remove ( ton4Btn )
		display.remove ( ton5Btn )
		display.remove ( sprachetext )
		display.remove ( alarmtext )
		display.remove ( weiteretext )
		display.remove ( sekundentext )
		display.remove ( countdowntext )
		display.remove ( vibriertext )
		display.remove ( g )
		
		hintergrund = nil
		secslider = nil
		couslider = nil
		vibslider = nil
		deBtn = nil
		enBtn = nil
		ton1Btn = nil
		ton2Btn = nil
		ton3Btn = nil
		ton4Btn = nil
		ton5Btn = nil
		sprachetext = nil
		alarmtext = nil
		weiteretext = nil
		sekundentext = nil
		countdowntext = nil
		vibriertext = nil
		g = nil
	end
	
	return g
end
