if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
  end
-- This file is for Loading and storing the Rom in MemoryThis is needed to use Love Launcher
-- relative file location
filestring            = love.filesystem.getSourceBaseDirectory() .. "\\" .. love.filesystem.getIdentity() .. "\\"
-- Order Matters .. Cart First for setup  
local cart          = require("NES.Cartridge.Cartridge")
cart.Initialize(filestring .. "Roms\\contra.nes")
local mapper        = require("NES.Cartridge.Mappers")
local keyboard      = require("Includes.keyboard")
local cpu           = require("NES.CPU.cpumain")
local ppu           = require("NES.PPU.ppu")
local testing       = require("UI.Debug.testing")
local frontend      = require("UI.Emulator.frontend")
local nesTestromLog = require("nestestrom.testromlogs")
local profile       = require("Library.profile.profile")
local nameTable     = require("NES.PPU.ppunametable")
local ppuReg        = require("NES.PPU.ppuIO")
local apu           = require("NES.Audio.apu")
-- Set FPS
local target_fps = 60
-- create a global array to store the last 10 opcodes
last10Opcodes = {}
-- enable disable sound .. 
UseSound = true
-- enable Debug 
local EnableDebug = true
-- global Testing in Main
step                  = 2
local time            = 0
local executePerFrame = 0
local cyclesPerFrame  = 29780--29780/2.5 -- 29780 cpu cycle s per frame 1/60s
y = 0

-- Run 1 Time and Load Sections
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Global Cartridge
    cart.Initialize(filestring .. "Roms\\smb.nes")
    mapper[cart.mapper].mapper.INI()
    cpu.Initialize()
end

-- Main Loop
function love.update(dt)
    --profile.start()
    local storage = love.timer.getTime()
    keyboard.KeyboardIsDown()
    if step == 2 then
        cpu.ExecuteCycles(cyclesPerFrame)
        --nesTestromLog.PrintOutput(0)
    elseif step == 1 then
        cpu.ExecuteCycles(1)
        --nesTestromLog.PrintOutput(0)
        step = 0
    end
    ppu.StartCharacterTiles()
    ppu.StartGameWindow()
    time = .95 * time + .05 * (love.timer.getTime() - storage)
    apu.TimerCheck(dt)
    --profile.stop()
    --print(profile.report(20))
    --profile.reset()

end

-- Output To Screen
function love.draw()
    local msTime        = time * 1000 * 1000
    local execute_f_c_e = executePerFrame * cyclesPerFrame / executePerFrame
    if EnableDebug then testing.DisplayUI() end
    love.graphics.print(
        "16700 micro/frame " ..
        string.format("(%.3f)", msTime) .. " Comm Frame:" .. string.format("(%.0fk)", (16600 / msTime * execute_f_c_e / 1000)),
        500, 770)
    love.graphics.print("6502 Emulator FPS: " .. string.format("(%.2f)", 1 / love.timer.getDelta()), 300, 770)
    love.graphics.print("Garbage: " .. string.format("(%.2f)", collectgarbage("count")), 30, 770)
    ppu.DrawCharacterTiles()
    ppu.GameWindow()
    --ppu.ScreenToNumbers()-- HACK 
    -- 60 fps limit 

end

-- Get Keyboard Interactions
function love.keypressed(key)
    keyboard.KeyboardIsPressed(key)
end
-- calculate the time it takes to process one frame
local frame_time = 1 / target_fps

function love.run()
    
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    -- Main loop time.
    return function()
        local start_time = love.timer.getTime()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then dt = love.timer.step() end

        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then love.draw() end

            love.graphics.present()
        end

        -- limit the fps to 60
        local end_time = love.timer.getTime()
        local elapsed_time = end_time - start_time
        
        if elapsed_time < frame_time then
            love.timer.sleep(frame_time - elapsed_time)
        end
    end
end

--[[
    6502 Lua Emulator
    General information Sites:
    http://www.6502.org/users/obelisk/


.







]]
--
