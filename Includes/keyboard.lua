local addressMode = require("NES.CPU.OpCodes.addressmodes")
local cpumain = require("NES.CPU.cpumain")
local controller = require("NES.Controller.controller")

local keyboard = {}

local function getAddressFromUser()
    -- set up the dialog box properties
    local dialogWidth = 400
    local dialogHeight = 100
    local dialogX = (love.graphics.getWidth() - dialogWidth) / 2
    local dialogY = (love.graphics.getHeight() - dialogHeight) / 2
    local prompt = "Enter a hexadecimal address:"
    local userInput = ""

    -- define a function to handle text input events
    local function handleTextinputEvent(text)
        -- check if userInput is empty and the entered text is "b"
        if userInput == "" and text == "b" then
            userInput = "0x"
        elseif text:match("[0-9a-fA-FxX]") then
            userInput = userInput .. text
        elseif text == "\b" then
            userInput = userInput:sub(1, -2)
        end
    end

    -- run the main loop until the user enters an address
    while true do
        -- process events
        love.event.pump()
        for event, arg1, arg2, arg3 in love.event.poll() do
            if event == "textinput" then
                handleTextinputEvent(arg1)
            elseif event == "keypressed" then
                if arg1 == "return" or arg1 == "kpenter" then
                    -- convert the user input to a number and return it
                    if userInput ~= "" then return tonumber(userInput) else 
                        UseBreakPoint = false
                        return 0xffff 
                    end
                elseif arg1 == "backspace" then
                    userInput = userInput:sub(1, -2)
                end
            end
        end


        -- check for escape event
        if love.keyboard.isDown("escape") then
            UseBreakPoint = false
            return 0xFFFF
        end
        -- draw the dialog box
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", dialogX+5, dialogY+5, dialogWidth-10, dialogHeight-10, 5, 5)
        love.graphics.setColor(.4, .4, .4)
        love.graphics.rectangle("fill", dialogX+5, dialogY+5, dialogWidth-10, dialogHeight-10, 5, 5)
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf(prompt, dialogX, dialogY + 10, dialogWidth, "center")
        love.graphics.setColor(.6, .4, .6)
        love.graphics.rectangle("fill", dialogX + 80, dialogY + 45, dialogWidth - 160, 30, 5, 5)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", dialogX + 80, dialogY + 45, dialogWidth - 160, 30, 5, 5)
        love.graphics.printf(userInput, dialogX + 25, dialogY + 50, dialogWidth - 50, "center")
        love.graphics.present()
    end
end

function keyboard.KeyboardIsPressed(key)
    if key == 'b' then
        UseBreakPoint = true
        local value = getAddressFromUser()
        if value and UseBreakPoint then print("Breakpoint Set at "..value) end
        
        BreakPointValue = value
    end
    if key == '.' then
        step = 2
    end
    if key == ',' then
        step = 0
    end
    if key == 'y' then
        y = y + 1 -- Palette Color Changing 
    end
    if key == 't' then
        t = t + 1 -- Testing PPU vs CPU memory 
        if t > 3 then
            t=0
        end
    end
    if key == '/' then
        step = 1
    end
    if key == 'r' then
        r = not r
    end
    if key == 'd' then
        addressMode.debug.print = not addressMode.debug.print
    end
    if key == '[' then
        debug.viewMemory = bit.band(debug.viewMemory - 0x100, 0xffff)
    end
    if key == ']' then
        debug.viewMemory = bit.band(debug.viewMemory + 0x100, 0xffff)
    end
    if key == 'space' then
        --mainCPU.Initialize()
        cpumain.Initialize()
    end
    if key == 'escape' then
        love.event.quit()
    end
end

function keyboard.KeyboardIsDown()
    controller.Controller1State = 0x00
    if love.keyboard.isDown('/') then
        --step = 1
    end
    if love.keyboard.isDown("up") then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 3)
    end
    if love.keyboard.isDown("down")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 2)
    end
    if love.keyboard.isDown("left")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 1)
    end
    if love.keyboard.isDown("right")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 0)
    end
    if love.keyboard.isDown("z")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 4)
    end
    if love.keyboard.isDown("x")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 5)
    end
    if love.keyboard.isDown("s")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 6)
    end
    if love.keyboard.isDown("a")  then
        controller.Controller1State = controller.Controller1State + bit.lshift(1, 7)
    end
end

return keyboard