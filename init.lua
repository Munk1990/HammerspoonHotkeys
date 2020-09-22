local hyper = {"cmd", "alt", "ctrl"}
local screensnaps = {0.30, 0.5,0.70}
local CountDown = hs.loadSpoon('ProductivityTracker')
----------------------------------------------------------
-------------------------Functions------------------------
----------------------------------------------------------

function arrange_windows( mainwindow, newwindow, partition, split)
	local mainframe = mainwindow:frame()
	local max_x = mainframe.x
	local max_y = mainframe.y
	local max_w = mainframe.w
	local max_h = mainframe.h

	mainframe.x = max_x
	mainframe.y = max_y
	if split == 'v' then
		mainframe.w = max_w
		mainframe.h = max_h * partition
	else
		mainframe.w = max_w * partition
		mainframe.h = max_h
    end
	mainwindow:setFrame(mainframe)


	app = mainwindow:application()
	pre_windows = app:allWindows()


    post_windows = app:allWindows()


    local appWindowFilter = hs.window.filter.new(false):setAppFilter(app:title())
    local function size_watcher(a,b,c)
    	local main_win = mainwindow
    	local width = max_w
    	local height = max_h
    	local mainframe = main_win:frame()
    	mainframe.w = max_w
    	mainframe.h = max_h
    	main_win:setFrame(mainframe)
    end

	appWindowFilter:subscribe(hs.window.filter.windowDestroyed, size_watcher)

    local new_frame = newwindow:frame()

    new_frame.x = mainframe.x + mainframe.w
    new_frame.y = mainframe.y
    new_frame.h = mainframe.h
    new_frame.w = max_w * (1 - partition)

	if split == 'v' then
		new_frame.x = mainframe.x
		new_frame.y = mainframe.y + mainframe.h
		new_frame.w = mainframe.w
		new_frame.h = max_h * (1 - partition)
	else
		new_frame.x = mainframe.x + mainframe.w
		new_frame.y = mainframe.y
		new_frame.h = mainframe.h
		new_frame.w = max_w * (1 - partition)
    end
    newwindow:setFrame(new_frame)
end


function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end




function diff_windows( arr, sub_arr )
	local res = {}
	for pos, item in pairs(arr) do
		local matched = false
		for pos_2, sub_item in pairs(sub_arr) do
			if item == sub_item then
				matched = true
			end
		end
		if matched == false then
			table.insert(res,item)
		end
	end
	return res
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function insidethreshold(num1, num2, threshold)
  if (num2 > num1 * (1+threshold)) then
    return false
  end
  if (num1 < num1 * (1-threshold)) then
    return false
  end
  return true
end





----------------------------------------------------------
-------------------------Bindings-------------------------
----------------------------------------------------------



hs.hotkey.bind(hyper, '/', function()
  local screens = hs.screen.allScreens()
  local screencount = tablelength(screens)

  local win = hs.window.focusedWindow()
  win_screen = win:screen()
  new_screens = diff_windows(screens, {win_screen})
  if tablelength(new_screens) > 0 then
    win:moveToScreen(new_screens[1])
  end
end)


hs.hotkey.bind(hyper, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)


hs.hotkey.bind(hyper, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + max.h / 2
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end)

hs.hotkey.bind(hyper, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  for k,v in pairs(screensnaps) do
    if f.w < max.w * v * 0.98 then
			 f.x = max.x
			 f.y = max.y
			 f.w = max.w * v
			 f.h = max.h
			 win:setFrame(f)
			return
    end
  end
  f.x = max.x
  f.y = max.y
  f.w = max.w * screensnaps[1]
  f.h = max.h
  win:setFrame(f)
end)


hs.hotkey.bind(hyper , "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  for k,v in pairs(screensnaps) do
    if f.x > max.x + max.w * (1 - v) * 1.01 then
			 f.x = max.x + (max.w * (1-v))
			 f.y = max.y
			 f.w = max.w * v
			 f.h = max.h
			 win:setFrame(f)
			return
    end
  end
  f.x = max.x + (max.w * (1 - screensnaps[1]))
  f.y = max.y
  f.w = max.w * screensnaps[1]
  f.h = max.h
  win:setFrame(f)
end)

local function launchCountdown() 
	key, time = hs.dialog.textPrompt('Daily Productivity Tracker'
                        , CountDown:getProgress() 
                            .. '\n\nEnter minutes to start the countdown for', "40", 'Start/Stop', 'Cancel')
	if key == 'Start/Stop' then
		CountDown:startFor(tonumber(time))
		countdownrunning = true
    end
end


hs.hotkey.bind({}, 'F10', 
function()
  long_press = true 
  press_timer = hs.timer.delayed.new(0.5, function()
        if long_press == true then
            print("long press")
            long_press = false
            launchCountdown()
        end 
    end)
  press_timer:start()
end, 
function()
  if long_press == true then
    print("Short press")
    long_press = false
    if CountDown:isTimer() then CountDown:pauseOrResume() else launchCountdown() end
  end  
end)

expose_app = hs.expose.new(nil,{onlyActiveApplication=true}) -- show windows for the current application

hs.hotkey.bind(hyper,'e','App Expose',function()expose_app:toggleShow()end)

hs.hotkey.bind(hyper, 'm', function()
  app = hs.application.frontmostApplication()
  wins = app:allWindows()
  for k,v in pairs(wins) do
    if not v:isVisible() then
      v:unminimize()
    end
  end
  app:activate(true)
end)


hs.hotkey.bind(hyper,'return', function()
  local win = hs.window.focusedWindow()
  if win == nil then
    return
  end
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  print(string.format('comparing width: %s to %s', f.w, max.w))
  print(string.format('comparing height: %s to %s', f.h, max.h))
  if insidethreshold(f.w, max.w, 0.05) and insidethreshold(f.h, max.h, 0.05) then
    print("fullscreen detected")
    win:minimize()
  end
  f.x = max.x
  print("Method run")
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind(hyper , "n", function()
	--[[Sets the current app as the main app, create a new window, and align in beside]]
	local partition = 0.5

	local mainwin = hs.window.focusedWindow()

	app = mainwin:application()
	pre_windows = app:allWindows()

	hs.eventtap.keyStroke({},'f6')
	hs.eventtap.keyStroke({'shift'},'return')
    hs.timer.usleep(2000000)
    post_windows = app:allWindows()

    print(string.format("Count before: %d, count after: %d", tablelength(pre_windows), tablelength(post_windows)))

    newwin = diff_windows(post_windows,pre_windows)[1]

	arrange_windows(mainwin, newwin, 0.5, 'h')


end)



--Send Time to input
hs.hotkey.bind(hyper, 't', function()
    hs.eventtap.keyStrokes(os.date("%I:%M %p"))
end)

-- Send Date to input
hs.hotkey.bind(hyper, 'd', function()
    hs.eventtap.keyStrokes(os.date("%b %d, %Y"))
end)




----------------------------------------------------------
-------------------------Initiations----------------------
----------------------------------------------------------

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  print(hs.inspect(event:getRawEventData()))
end)
--tap:start()
-----------------------------------------------------------





hs.alert.show("Config loaded")
