

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Timer"
obj.version = "1.0"
obj.author = "Munk <mayank.kr@protonmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.canvas = nil
obj.timer = nil
obj.countdown = nil
obj.filepath = "~/.hammerspoon/Spoons/Timer/"

function obj:init()
    self.countdown = hs.loadSpoon('CountDown')
    self.canvas = hs.canvas.new({x=0, y=0, w=0, h=0}):show()
    self.canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    self.canvas:level(hs.canvas.windowLevels.status)
    self.canvas:alpha(0.20)
    self.canvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = hs.drawing.color.osx_green,
        frame = {x="0%", y="0%", w="0%", h="100%"}
    }
    self.canvas[2] = {
        type = "rectangle",
        action = "fill",
        fillColor = hs.drawing.color.osx_red,
        frame = {x="0%", y="0%", w="0%", h="100%"}
    }
end


function getwritefile()
    local curdate = os.date("*t")
    local curfilename = string.format(obj.filepath + "%s-%s-%s.timer" , curdate.year, curdate.month, curdate.day)
    --Todo: Should be using 2 digits for month and day for better formatting
    if ~file_exists(curfilename)
        then create_file(curfilename)
    end
    return curfilename 
end

function file_exists(name)
   local f=io.open(name,"w")
   if f~=nil then io.close(f) return true 
   else 
       return false 
   end
end

function create_file(name)
   local f = io.open(name, "w")
   f:write("")
   f:close()
end
