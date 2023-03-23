module(..., package.seeall)

function convertDegreesToRadians( degrees )
	return (math.pi * degrees) / 180
end

function rotatePoint( point, degrees )
	local x, y = point.x, point.y
	
	local theta = convertDegreesToRadians( degrees )
	
	local pt = {
		x = x * math.cos(theta) - y * math.sin(theta),
		y = x * math.sin(theta) + y * math.cos(theta)
	}

	return pt
end

--[[
	How to use:
		The image provided in the path parameter must be the same size as the viewport,
		plus the width of the tab. This is to ensure memory is kept to a minimum and the
		minimum and maximum slider positions are simply derived from the ends of the viewport,
		ie: slider will not allow a gap to be seen.
	Example:
		
		local viewport = {
			id="first",							-- unique id
			img="onoff.png",over="over.png" ,	-- slider and tab highlighter images
			x=80,y=344 ,						-- position of the centre of the slider viewport
			width=94,height=27,					-- visible area of the slider
			bleed=10,							-- distance from viewport to enable touch sensitivity
			range=70,							-- distance to use the over image within
			rotation=0							-- rotation of the viewport
		}
		local callbacks = {
			onComplete=defaultCallback,			-- called at end of slide or tap
			onMove=moveCallback					-- called at each slide move (touch event move phase)
		}
		local parts = {
			left="greenpart.png", leftwidth=20, leftheight=20,
			right="redpart.png", rightwidth=20, rightheight=20
		}
		local dimensions = {
			slider = { width=34, height=20 },
			over = { width=34, height=20 }
		}
		
		local slider = newSlider( display.getCurrentStage(), viewport, slid, false, true, dimensions, parts )
		
	parameters:
		parent: (must be nil for now) the display group to add the slider to
		viewport: location and size of the viewport, eg:
			local viewport = { x=100,y=100 , width=100,height=100 }
		isvariable: true to allow slider to sit anywhere in the viewport
		ison: boolean, true is "On" as initial value
	
	callback event:
		{
			id,			-- from viewport.id
			phase,		-- the touch/tap event.phase
			x,			-- the x position relative to the centre of the slider, 0-based
			state,		-- "on" (slider at far right), "off" (slider at far left), "value" (elsewhere)
			value		-- pixel distance of slider from the minx position (far left)
		}
	
	note:
		Speed = Distance / Time
		Time = Distance / Speed
]]--
function newSlider( parent, viewport, callbacks, isvariable, initon, dimensions, parts )
	-- create slider group
	local panel = display.newGroup()
	
	-- store image dimensions
	panel.dimensions = dimensions
	
	-- add to parent group if possible
	if (parent ~= nil) then
		parent:insert( panel )
	end
	
	-- slider
	function panel:createSliderPanel( parentpanel, img, over )
		-- create slider group
		local sliderpanel = display.newGroup()
		
		-- add slider group to parent group
		parentpanel:insert( sliderpanel )
		
		-- add slider image
		sliderpanel.img = display.newImageRect( sliderpanel, img, panel.dimensions.slider.width, panel.dimensions.slider.height )
		
		-- position slider image in centre of viewport
		sliderpanel.img.x = 0
		sliderpanel.img.y = 0
		
		-- add over image, if provided
		if (over ~= nil) then
			-- load over img
			sliderpanel.over = display.newImageRect( sliderpanel, over, panel.dimensions.over.width, panel.dimensions.over.height )
			
			-- position it
			sliderpanel.over.x = 0
			sliderpanel.over.y = 0
			
			-- hide it until touched
			sliderpanel.over.alpha = 0
		end
		
		-- shows over image if requested (coord system handled by parent object)
		-- show: true to show, false to hide
		function sliderpanel:showOver( show )
			if (sliderpanel.over ~= nil) then
				if (show) then
					transition.to( sliderpanel.over, { time=200, alpha=1 } )
				else
					transition.to( sliderpanel.over, { time=200, alpha=0 } )
				end
			end
		end
		
		-- return slider group
		return sliderpanel
	end
	
	-- touch
	function panel:createTouchPanel( parentpanel, width, height )
		-- create touch object
		local touchpanel = display.newRect( parentpanel, 0,0 , width,height )
		
		-- define stroke etc
		touchpanel.strokeWidth = 0
		touchpanel:setFillColor( 0,255,0 )
		touchpanel:setStrokeColor( 255,0,0 )
		touchpanel.alpha = 0
		touchpanel.isHitTestable = true
		
		-- position touch area in centre of slider panel
		touchpanel.x = 0
		touchpanel.y = 0
		
		-- return touch area
		return touchpanel
	end
	
	-- calls any callback functions passed in
	function panel:fireCallback( phase )
		-- only create callback object if there is a need
		if (panel.callbacks ~= nil and
			((phase == "ended" and panel.callbacks.onComplete ~= nil)
			or (phase ~= "ended" and panel.callbacks.onMove ~= nil)))
			then
			
			-- create event object
			local event = {}
			
			-- populate...
			-- slider id
			event.id = panel.viewport.id
			
			-- phase
			event.phase = phase
			
			-- position of slider from centre of viewport
			event.x = panel.sliderpanel.x
			
			-- on/off state
			if (panel.sliderpanel.x == panel.minx) then
				event.state = "off"
			elseif (panel.sliderpanel.x == panel.maxx) then
				event.state = "on"
			else
				event.state = "value"
			end
			
			-- value of slider (pixels from min position)
			event.value = panel.sliderpanel.x - panel.minx
			
			-- perform callback
			if (phase == "ended") then
				if (type(panel.callbacks.onComplete) == "function") then
					panel.callbacks.onComplete( event )
				elseif (type(panel.callbacks.onComplete) == "table") then
					panel.callbacks.onComplete:onComplete( event )
				end
			elseif (phase ~= "ended") then
				if (type(panel.callbacks.onMove) == "function") then
					panel.callbacks.onMove( event )
				elseif (type(panel.callbacks.onMove) == "table") then
					panel.callbacks.onMove:onMove( event )
				end
			end
		end
	end
	
	-- deals with firing the callback function if one was provided
	function panel:onComplete( event )
		panel:fireCallback( "ended" )
	end
	
	-- internal use only: slides the slider to a desired position
	function panel:setSliderPosition( x, callback )
		local speed = math.abs( viewport.speed/((panel.maxx-panel.minx)/(panel.sliderpanel.x-x)) )
		transition.to( panel.sliderpanel, { x=x, time=speed, onComplete=callback } )
	end
	
	-- sets the position of the slider to one end
	function panel:setState( state )
		if (state ~= nil) then
			if (tostring(state) == "on" or tostring(state) == "true") then
				panel:setSliderPosition( panel.maxx )
			else
				panel:setSliderPosition( panel.minx )
			end
		end
	end
	
	-- sets the position of the slider to a position < or > than the centre
	function panel:setXposition( x )
		if (panel.isvariable) then
			if (x >= panel.minx and x <= panel.maxx) then
				panel:setSliderPosition( x )
			elseif (x < panel.minx) then
				panel:setSliderPosition( panel.minx )
			elseif (x > panel.maxx) then
				panel:setSliderPosition( panel.maxx )
			end
		end
	end
	
	-- sets the position of the slider relative to the 0-based left end
	function panel:setValue( value )
		if (panel.isvariable) then
			panel:setXposition( tonumber( value ) + panel.minx )
		end
	end
	
	-- deals with both the end of a slide and a tap to re-use the transition of the slider code
	function panel:tap( event )
		if (event.phase == "ended") then
			if ((panel.isvariable and panel.sliderpanel.x == panel.minx and panel.sliderpanel.x == panel.startx)
				or (not panel.isvariable and panel.startx == panel.minx)) then
				-- slide to maxx
				panel:setSliderPosition( panel.maxx, panel )
			elseif ((panel.isvariable and panel.sliderpanel.x == panel.maxx and panel.sliderpanel.x == panel.startx)
				or (not panel.isvariable and panel.startx == panel.maxx)) then
				-- slide to minx
				panel:setSliderPosition( panel.minx, panel )
			else
				panel:setSliderPosition( panel.sliderpanel.x, panel )
			end
		end
	end
	
	-- touch event handler
	function panel:touch( event )
		
		-- if rotation has been used, rotate the incoming x
		if (panel.viewport.rotation ~= 0) then
			local point = rotatePoint( { x=event.x, y=event.y }, -panel.viewport.rotation )
			event.x = point.x
			event.y = point.y
		end
		
		if (event.phase == "began") then
		
			-- set this control as the focus of the current touch (multitouch friendly?)
			display.getCurrentStage():setFocus( event.target, event.id )
			panel.isFocus = true
			-- record starting offset of the touch
			panel.offsetx = (event.x-panel.x)-panel.sliderpanel.x
			-- record starting x to decide whether to and which direction the ending slide animation should go
			panel.startx = panel.sliderpanel.x
			
			-- show over image
			panel.sliderpanel:showOver( true )
			
			-- fire callback
			panel:fireCallback( "began" )
			
		-- allow other touch events if the focus is on this control
		elseif (panel.isFocus) then
			if (event.phase == "moved") then
			
				-- calc the new position, taking offset of initial touch into account
				local shiftedx = event.x-panel.offsetx
				
				-- if the touch is within the viewport, implement the move
				if (shiftedx >= panel.x+panel.minx and shiftedx <= panel.x+panel.maxx) then
					-- touch is within range of the slider's area of motion
					panel.sliderpanel.x = shiftedx-panel.x
					panel:fireCallback( "moved" ) -- fire callback
				elseif (shiftedx < panel.x+panel.minx) then
					panel.sliderpanel.x = panel.minx
					panel:fireCallback( "moved" ) -- fire callback
				elseif (shiftedx > panel.x+panel.minx) then
					panel.sliderpanel.x = panel.maxx
					panel:fireCallback( "moved" ) -- fire callback
				end
				
				-- calc half of over image width and height if it is provided
				local halfoverwidth = panel.viewport.width / 2
				local halfoverheight = panel.viewport.height / 2
				
				-- if over image was used, use its dimensions
				if (panel.sliderpanel.over ~= nil) then
					halfoverwidth = panel.sliderpanel.over.width / 2
					halfoverheight = panel.sliderpanel.over.height / 2
				end
				
				-- show over image if touch is within range
				if (event.x >= panel.x + panel.sliderpanel.x - halfoverwidth - panel.viewport.range
					and event.x <= panel.x + panel.sliderpanel.x + halfoverwidth + panel.viewport.range
					and event.y >= panel.y - halfoverheight - panel.viewport.range
					and event.y <= panel.y + halfoverheight + panel.viewport.range)
					then
					panel.sliderpanel:showOver( true )
				else
					panel.sliderpanel:showOver( false )
				end
				
			elseif (event.phase == "ended" or event.phase == "cancelled") then
			
				-- unset the current focus
				display.getCurrentStage():setFocus( event.target, nil )
				panel.isFocus = false
				panel.offsetx = nil
				
				-- complete the animation if required
				panel:tap( event )
				
				-- hide over image
				panel.sliderpanel:showOver( false )
				
			end
		end
	end
	
	-- internal only: attaches the left and right parts, makes all invisible
	function panel:attachParts()
		if (parts ~= nil) then
			-- calc number of parts to attach
			local gap = panel.viewport.width - panel.sliderpanel.img.width
			
			-- left
			if (parts.left ~= nil) then
				-- create table of image parts if only a string was provided
				if (type(parts.left) == "string") then
					parts.left = { parts.left }
				end
				
				-- create index into parts list
				local partindex = #parts.left
				
				-- distance covered
				local distance = 0
				
				-- attach
				while (distance < gap) do
					-- load image
					local img = display.newImageRect( panel.sliderpanel, parts.left[ partindex ], parts.leftdimensions[ partindex*2-1 ], parts.leftdimensions[ partindex*2 ] )
				
					-- position part
					img.x = -((panel.sliderpanel.img.width/2) + distance + (img.width/2))
					img.y = 0
					
					-- inc index
					if (partindex == 1) then partindex = #parts.left else partindex = partindex - 1 end
					
					-- accumulate distance
					distance = distance + img.width
				end
			end
			
			-- right
			if (parts.right ~= nil) then
				-- create table of image parts if only a string was provided
				if (type(parts.right) == "string") then
					parts.right = { parts.right }
				end
				
				-- create index into parts list
				local partindex = 1
				
				-- distance covered
				local distance = 0
				
				-- attach
				while (distance < gap) do
					-- load image
					local img = display.newImageRect( panel.sliderpanel, parts.right[ partindex ], parts.rightdimensions[ partindex*2-1 ], parts.rightdimensions[ partindex*2 ] )
					
					-- position part
					img.x = (panel.sliderpanel.img.width/2) + distance + (img.width/2)
					img.y = 0
					
					-- inc index
					if (partindex == #parts.right) then partindex = 1 else partindex = partindex + 1 end
					
					-- accumulate distance
					distance = distance + img.width
				end
			end
		end
	end
	
	-- hides the left/right parts which are outside the viewport
	function panel:enterFrame( event )
		for i=2, panel.sliderpanel.numChildren do
			local partedge = panel.sliderpanel[i].x - panel.sliderpanel[i].width/2
			if (
				(panel.sliderpanel.x + (panel.sliderpanel[i].x - (panel.sliderpanel[i].width/2)) > panel.viewport.halfwidth)
				or
				(panel.sliderpanel.x + (panel.sliderpanel[i].x + (panel.sliderpanel[i].width/2)) < -panel.viewport.halfwidth)
				)
				then
				panel.sliderpanel[i].isVisible = false
			else
				panel.sliderpanel[i].isVisible = true
			end
		end
	end
	
	if (viewport.rotation == nil) then viewport.rotation = 0 end
	
	-- position the panel
	panel.x = viewport.x
	panel.y = viewport.y
	panel.rotation = viewport.rotation
	
	-- keep the viewport and isvariable settings
	panel.viewport = viewport
	panel.callbacks = callbacks
	panel.isvariable = isvariable
	
	-- provide optional value defaults
	if (panel.viewport.range == nil) then panel.viewport.range = 70 end
	panel.viewport.range = math.abs( panel.viewport.range )
	
	if (panel.viewport.speed == nil) then panel.viewport.speed = 300 end
	panel.viewport.speed = math.abs( panel.viewport.speed )
	
	if (panel.viewport.bleed == nil) then panel.viewport.bleed = 0 end
	panel.viewport.bleed = math.abs( panel.viewport.bleed )
	
	-- create the slider with its over image
	panel.sliderpanel = panel:createSliderPanel( panel, viewport.img, viewport.over )
	
	-- create the viewport+bleed touch area
	panel.touchpanel = panel:createTouchPanel( panel, viewport.width+viewport.bleed, viewport.height+viewport.bleed )
	
	-- for quicker calcs later
	panel.viewport.halfwidth = panel.viewport.width / 2
	panel.viewport.halfheight = panel.viewport.height / 2
	
	-- calculate minimum and maximum slider positions (relative to centre 0,0)
	if (viewport.width < panel.sliderpanel.img.width) then
		panel.minx = -((panel.sliderpanel.img.width - viewport.width)/2)
		panel.maxx =  ((panel.sliderpanel.img.width - viewport.width)/2)
	else
		panel.minx = -(panel.viewport.halfwidth - (panel.sliderpanel.img.width/2))
		panel.maxx = panel.viewport.halfwidth - (panel.sliderpanel.img.width/2)
	end
	
	-- attach left and right parts
	panel:attachParts()
	
	-- position slider
	if (initon) then
		panel.sliderpanel.x = panel.maxx
	else
		panel.sliderpanel.x = panel.minx
	end
	
	-- add touch listeners as required...
	-- tap listener for when the slider is not variable
	if (not isvariable) then
		-- tap event handling is only required when the slider can only be at one end or the other
		panel.touchpanel:addEventListener( "tap", panel )
	end
	
	-- touch listener for any movement of the slider
	panel.touchpanel:addEventListener( "touch", panel )
	
	-- attach enter frame listener to adust visibility of the parts images
	if (parts ~= nil) then
		Runtime:addEventListener( "enterFrame", panel )
	end
	
	-- return slider panel
	return panel
end
