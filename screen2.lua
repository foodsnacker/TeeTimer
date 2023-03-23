module(..., package.seeall)

-- positionen verbessern

function zeige_info( datei )
	if teebild then
		display.remove ( teebild )
		teebild = nil
	end
	teebild = display.newImage( "teetassen/" .. datei ..".png", 0, 40)
	teebild.alpha = 0

	titelziehzeit.text = ziehzeit .. ": " .. SekundenInUhrzeit ( getraenktab[id].ziehzeit ) .. "\n" .. temperatur .. ": " .. tostring ( getraenktab[id].temperatur ) .. "°C"
	if config.diesprache == "de" then
		titelBox.text = getraenktab[id].name
		beschreibung.text = getraenktab[id].beschreibungde
	else
		titelBox.text = getraenktab[id].nameen
		beschreibung.text = getraenktab[id].beschreibungen
	end

	titelBox:setReferencePoint ( display.TopLeftReferencePoint )
	titelziehzeit:setReferencePoint ( display.TopLeftReferencePoint ) 
	beschreibung:setReferencePoint ( display.TopLeftReferencePoint )
	titelBox.x = 160
	titelBox.y = 50
	titelziehzeit.x = 160
	beschreibung.x = 5
	beschreibung.y = 5
	transition.to(teebild, {time=400, alpha=1 })
end

--setup functions to execute on touch of the list view items
function onRowTouch( event )
	local row = event.target
	local rowGroup = event.view
	id = event.index
	 
	if event.phase == "press" then
		if not row.isCategory then rowGroup.alpha = 0.5; end
		
 	elseif event.phase == "release" then                                        
		if not row.isCategory then

			hintergrund = display.newImage ( "hintergrund/teehtml.jpg", 0, 0)
			hintergrund.alpha = 0
		
			navBar:toFront ( )
			navHeader:toFront ( )

			--Setup the buttons
--			backBtn = widget.newButton { id="back", style = "backSmall",label=zuruck, onEvent=backBtnRelease, top=10, left=10, width=100, height=20, cornerRadius=1, labelColor={ default={ 255, 255, 255, 255 }, over={ 0, 0, 0, 0 } }, defaultColor={ 0, 0, 0, 128 }, overColor={ 0, 0, 0, 64 }, emboss=true }
--			useBtn = widget.newButton  { id="brew", label=bruehen, onEvent=useBtnRelease, top=10, left=screenW - 110, width=100, height=20, cornerRadius=1, labelColor={ default={ 255, 255, 255, 255 }, over={ 0, 0, 0, 0 } }, defaultColor={ 0, 0, 0, 128 }, overColor={ 0, 0, 0, 64 }, emboss=true }
			backBtn = widget.newButton { id="back", style = "backLarge", label=zuruck, onEvent=backBtnRelease, top=5, left=10, width=100, height=28, emboss=true }
			useBtn = widget.newButton  { id="brew", style = "blue2Large", label=bruehen, onEvent=useBtnRelease, top=5, left=screenW - 110, width=100, height=28, emboss=true }

			backBtn.alpha = 0
			useBtn.alpha = 0

			titelBox = display.newText( "", 160, 50, 156, 120, "Georgia-BoldItalic", 22 )
			titelBox:setTextColor ( 0, 0, 0 )
			titelBox.alpha = 0
			titelBox:toFront ( )
			titelBox:setReferencePoint ( display.TopLeftReferencePoint ) 

			titelziehzeit = display.newText( "", 160, 160, 160, 52, "Georgia", 16 )
			titelziehzeit:setTextColor ( 0, 0, 0 )
			titelziehzeit.alpha = 0
			titelziehzeit:setReferencePoint ( display.TopLeftReferencePoint ) 

			beschreibungwidget = widget.newScrollView { height=280, maskFile="mask-300.png", left=0, top=240 }
			beschreibungwidget[1].isVisible=false
			beschreibung = display.newText( "", 5, 245, 312, 490, "Georgia", 14 )
			beschreibung:setTextColor ( 0, 0, 0 )
			beschreibung.alpha = 0
			beschreibung:setReferencePoint ( display.TopLeftReferencePoint ) 
			beschreibungwidget:insert ( beschreibung ) 
			
			row.reRender = true
		
			navHeader.text = teeinfo
			zeige_info( getraenktab[id].datei )
 
			transition.to(list,			{time=400, x=screenW*-1, transition=easing.outExpo })
			transition.to(backBtn, 		{time=400, x=60, transition=easing.outExpo, alpha=1 })
			transition.to(tabBar,		{time=400, y=screenH + tabBar.height, transition=easing.outExpo })
			transition.to(useBtn,		{time=400, x=screenW - 60, transition=easing.outExpo, alpha=1 })
			transition.to(titelziehzeit,{time=400, alpha=1 })
			transition.to(titelBox, 	{time=400, alpha=1 })
			transition.to(beschreibung,	{time=400, alpha=1 })
			transition.to(hintergrund,	{time=400, alpha=1 })
		end
    end
 
	return true
end

function allesweg ( event )
	display.remove ( beschreibungwidget ) 
	display.remove ( titelBox )
	display.remove ( titelziehzeit )
	display.remove ( hintergrund )
	display.remove ( backBtn )
	display.remove ( useBtn )
	display.remove ( teebild )

	beschreibungwidget = nil
	titelBox = nil
	titelziehzeit = nil
	hintergrund = nil
	backBtn = nil
	useBtn = nil
	teebild = nil
end
	
function backBtnRelease( event )
	if event.phase == "release" then
		transition.to(list,			{time=400, x=0, transition=easing.outExpo,onComplete=allesweg })
		transition.to(backBtn,		{time=400, x=0, transition=easing.outExpo, alpha=0 })
		transition.to(useBtn,		{time=400, x=screenW, transition=easing.outExpo, alpha=0 })
		transition.to(tabBar,		{time=400, x=screenW / 2, y=screenH - tabBar.height / 2 + 1, transition=easing.outExpo })
		transition.to(hintergrund,	{time=400, alpha=0, transition=easing.outExpo })
		transition.to(titelBox,		{time=400, alpha=0 })
		transition.to(beschreibung, {time=200, alpha=0 })
		transition.to(titelziehzeit,{time=200, alpha=0 })
		transition.to(teebild, 		{time=200, alpha=0 })
		
		navHeader.text = teeauswahl
	end
end

function useBtnRelease( event )
	if event.phase == "release" then
		sortenwahl ( id )
		transition.to(g, {time=400, alpha=0, onComplete=allesweg })
		timer.performWithDelay( 400, goback, 1 )
	end
end

function new()

-- onRender listener for the tableView
local function onRowRender( event )
	local row = event.target
	local rowGroup = event.view
	
    if not row.isCategory then
		local beschreibung = getraenktab[event.index].name
		if sprache == "English" then beschreibung = getraenktab[event.index].nameen end
	    local titeltext = display.newText ( beschreibung, 0, 0, "Helvetica-Bold", 16 )
	    titeltext:setReferencePoint( display.CenterLeftReferencePoint )
	    titeltext.y = row.height * 0.2
		titeltext.x = 60
		titeltext:setTextColor ( 0, 0, 0 )
		
		beschreibung = getraenktab[event.index].kurzde
		if sprache == "English" then beschreibung = getraenktab[event.index].kurzen end

		local subtext = display.newText ( beschreibung, 0, 0, "Helvetica-Bold", 12 )
		subtext:setReferencePoint( display.CenterLeftReferencePoint )
		subtext.y = row.height * 0.7
		subtext.x = 60
		subtext:setTextColor ( 0, 0, 0 )
    
		local titelimg = display.newImage ( "teetassen/" .. getraenktab[event.index].datei .. ".png", 0, 0 )
		titelimg:setReferencePoint( display.TopLeftReferencePoint )
		titelimg.xScale = 0.25
		titelimg.yScale = 0.25
		titelimg.x = 5
		titelimg.y = 5

		beschreibung = nil

		rowGroup:insert( titelimg )
		rowGroup:insert( subtext )
		rowGroup:insert( titeltext )
	else
	    local titeltext = display.newText ( getraenktab[event.index].name, 0, 0, "Helvetica-Bold", 14 )
	    titeltext:setReferencePoint( display.CenterLeftReferencePoint )
	    titeltext.y = row.height * 0.5
		titeltext.x = 10
		titeltext:setTextColor ( 0, 0, 0 )
		rowGroup:insert( titeltext )
    end
end

	ads.hide()
	g = display.newGroup()

	--Setup the nav bar 
	navBar = display.newImage("gui/navBar.png", 0, 0, true)
	navBar.x = screenW*.5
	navBar.y = navBar.height * 0.5

	navHeader = display.newText ( teeauswahl, 0, 0, native.systemFontBold, schrift2)
	navHeader:setReferencePoint ( display.CenterReferencePoint )	
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = screenW*.5
	navHeader.y = navBar.y

-- , maskFile="hintergrund/tee.jpg" und farbe 255,255,255,127
	local listOptions = { top=navBar.height - 2, bottomPadding=45, height=screenH - navBar.height }
	list = widget.newTableView( listOptions )
	listOptions = nil
 
 	-- Liste erstellen
	for i=1,#getraenktab do
        local rowColor, lineColor, isCategory
		local rowHeight = 52
 		if getraenktab[i].ziehzeit == 0 then
	        isCategory = true
	        rowHeight = 24
	        rowColor={ 70, 70, 130, 255 }
	        lineColor={0,0,0,255}
	    end 
    
        list:insertRow{ onEvent=onRowTouch, onRender=onRowRender, height=rowHeight, isCategory=isCategory, rowColor=rowColor, lineColor=lineColor }
	end

	g:insert(list)
	
	function g:cleanUp()
		display.remove ( list )
		display.remove ( navBar )
		display.remove ( navHeader )
		display.remove ( g )
	
		list = nil
		navBar = nil
		navHeader = nil
		g = nil
		
		id = nil
	end
		
	return g
end
