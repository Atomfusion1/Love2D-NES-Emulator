local cpuMemory   = require("NES.CPU.cpumemory")
local cpu         = require("NES.CPU.cpuram")
local bus         = require("NES.BUS.bus")
local ppuBus      = require("NES.PPU.ppuBus")
local opcode      = require("NES.CPU.OpCodes.TABLEOFOPCODE")
local memory      = require("NES.CPU.cpuram")
local ppu         = require("NES.PPU.ppu")
local oam         = require("NES.PPU.ppuOAM")

local testing = {}

local Y = 15
t = 0
-- text, x, r, g, b, a
local function PrintText(text, x, r, g, b, a)
    love.graphics.setColor(r, g, b, a)
    love.graphics.print(text, x, Y)
    Y = Y + 15
end

local function CPUParamaters()
    local X = 550;
    Y = 15
    PrintText(string.format("STATUS: N:%i  V:%i  -  B:%i  D:%i  I:%i  Z:%i  C:%i", cpuMemory.ReadFlag("negative"),
        cpuMemory.ReadFlag("overflow"), cpuMemory.ReadFlag("breakflow"), cpuMemory.ReadFlag("decimal"),
        cpuMemory.ReadFlag("interrupt"), cpuMemory.ReadFlag("zero"), cpuMemory.ReadFlag("carry")), X, 1, 1, 1, 1)
    PrintText(string.upper(string.format("A:  $%04x    [%3i]", cpuMemory.A, cpuMemory.A)), X, 1, 1, 1, 1)
    PrintText(string.upper(string.format("X:  $%04x    [%3i]", cpuMemory.X, cpuMemory.X)), X, 1, 1, 1, 1)
    PrintText(string.upper(string.format("Y:  $%04x    [%3i]", cpuMemory.Y, cpuMemory.Y)), X + 2, 1, 1, 1, 1) -- Offset for the Fucking Y .. Stupid Variable Width Font
    PrintText(string.upper(string.format("PC: $%04x ", cpuMemory.programCounter)), X, 1, 1, 1, 1)
    local stack = 0x0100 + cpuMemory.stackPointer
    PrintText(string.upper(string.format("Stack P: $%04x   [%02x]  [%02x]  [%02x]  [%02x]", stack, cpu.cpuRAM[stack - 1],
        cpu.cpuRAM[stack + 0], cpu.cpuRAM[stack + 1], cpu.cpuRAM[stack + 2])), X, 1, 1, 1, 1)
    PrintText(string.upper(string.format("PPU ScanLine:$%06i     VBlank %3s", ppu.scanLines, tostring(ppu.vBlank))), X, 1,
        1, 1, 1)
end

local previousTrace = "Old Trace"

local function DebugTrace()
    local X = 550;
    Y = 130
    local cpuCounter = cpuMemory.programCounter
    local i = 0
    local t = 0
    -- Print Previous Value
    PrintText(previousTrace, X, 1, 1, 1, 1)

    love.graphics.rectangle("line", 545, 145, 200, 16)
    while t < 15 do
        local instruction = bus.CPURead(cpuCounter + i)
        if opcode[instruction] then
            local command1 = ""
            local command2 = ""
            local command3 = ""
            local programCounts = opcode[instruction].pcCounts
            if programCounts >= 2 then
                if bus.CPURead(cpuCounter + i + 1) then command1 = string.upper(string.format("%02x",
                            bus.CPURead(cpuCounter + i + 1))) end
            end
            if programCounts >= 3 then
                if bus.CPURead(cpuCounter + i + 2) then command2 = string.upper(string.format("%02x",
                            bus.CPURead(cpuCounter + i + 2))) end
            end
            if programCounts >= 4 then
                command3 = string.upper(string.format("%02x", bus.CPURead(cpuCounter + i + 3)))
            end

            if programCounts == 1 then
                PrintText(
                    string.upper(string.format("%04x %02x %03s %02s %02s %02s", cpuCounter + i, instruction,
                        opcode[instruction].opcode, command1, command2, command3)), X, 1, 1, 1, 1)
            elseif programCounts == 2 then
                PrintText(
                    string.upper(string.format("%04x %02x %03s [$%02s] %02s %02s", cpuCounter + i, instruction,
                        opcode[instruction].opcode, command1, command2, command3)), X, 1, 1, 1, 1)
            elseif programCounts == 3 then
                PrintText(
                    string.upper(string.format("%04x %02x %03s [$%02s%02s] %02s", cpuCounter + i, instruction,
                        opcode[instruction].opcode, command2, command1, command3)), X, 1, 1, 1, 1)
            elseif programCounts == 4 then
                PrintText(
                    string.upper(string.format("%04x %02x %03s [$%02] [s%02s%02s]", cpuCounter + i, instruction,
                        opcode[instruction].opcode, command2, command1, command3)), X, 1, 1, 1, 1)
                --if t == 0 then previousTrace = string.upper(string.format("%04x %02x %03s [$%02s%02s] %02s", programCount+i, instruction, opcode[instruction].opcode,command2,command1,command3)) end
            else
                PrintText(string.upper(string.format("%04x %02x %03s", cpuCounter + i, instruction, "UNK")), X, 1, 0, 0,
                    .8)
                i = i + 1
            end

            i = i + programCounts
        else

        end
        t = t + 1
    end
end

-- get opcode string
function debug.GetOpcodeString(value)
    local opcodeString = "UNK"
    if opcode[value] then
        opcodeString = opcode[memory[cpuMemory.programCounter]].opcode
    end
    return opcodeString
end

-- Red box printed for programCounter location
function testing.displayPointerCounterLocation(x, y)
    local col = bit.band(cpuMemory.programCounter, 0x0F)
    local row = bit.band(cpuMemory.programCounter, 0xF0) / 16
    love.graphics.setColor(1, 0, 0, 1);
    love.graphics.rectangle("line", x + col * 20 + 40, y + row * 15, 20, 15)
    love.graphics.setColor(1, 1, 1, 1);
end

local chunkSize = 256
local gridSize = 16
debug.debugOpcode = false
debug.viewMemory = 0x0100
-- Col and Row of 256 memory print out on screen
function testing.displayMemoryChunk(ReadWith, startAddress, screenX, screenY)
    testing.displayPointerCounterLocation(screenX, screenY)
    for y = 0, (chunkSize / gridSize) - 1 do
        for x = 0, gridSize - 1 do
            local address = startAddress + (y * gridSize) + x
            local value = ReadWith(address) or 0
            if value > 0 then
                love.graphics.setColor(0, 1, 1, 1)
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
            if debug.debugOpcode then
                local opcode = debug.GetOpcodeString(ReadWith(address))
                love.graphics.print(string.upper(opcode), screenX + (x * 20) + 40, screenY + (y * 15), nil, .8)
            else
                love.graphics.print(string.upper(string.format("%02X", value)), screenX + (x * 20) + 40,
                    screenY + (y * 15))
            end
        end
        love.graphics.print(string.upper(string.format("%04X", startAddress + (y * gridSize))), screenX,
            screenY + (y * 15))
    end
end

function testing.DisplayUI()
    -- Main NES Screen
    love.graphics.setColor(.4, .4, .4, 1)
    love.graphics.rectangle("fill", 15, 10, 256 * 2, 240 * 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 15, 10, 256 * 2, 240 * 2)
    -- Debug Text
    love.graphics.setColor(.2, .2, .2, 1)
    love.graphics.rectangle("line", 545, 10, 350, 745)
    love.graphics.setColor(.0, .4, .6, 1)
    love.graphics.rectangle("fill", 545, 10, 350, 745)
    -- Char Rom Page 0
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 10, 500, 128 * 2, 128 * 2)
    love.graphics.setColor(.1, .4, .4, 1)
    love.graphics.rectangle("fill", 10, 500, 128 * 2, 128 * 2)
    -- Char Rom Page 1
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 276, 500, 128 * 2, 128 * 2)
    love.graphics.setColor(.1, .4, .4, 1)
    love.graphics.rectangle("fill", 276, 500, 128 * 2, 128 * 2)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("PPU Area Diagnostics", 550, 420)
    love.graphics.print("PPU Area Diagnostics", 550, 440)
    CPUParamaters()
    DebugTrace()
    --testing.displayMemoryChunk(memory,bit.band(cpuMemory.programCounter,0xFF00),20,15)
    -- CPU Memory
    love.graphics.print(string.format("PPU Area Diagnostics scanlines %d %d", ppu.scanLines, ppu.scanLinePixels), 550, 400)
    if t == 1 then
        love.graphics.print("CPU Memory", 650 , 495)
        testing.displayMemoryChunk(function(value) return bus.CPURead(value) end, debug.viewMemory, 540, 510)
    elseif t == 2 then
        love.graphics.print("PPU Memory", 650, 495)
        testing.displayMemoryChunk(function(value) return ppuBus.PPURead(value) end, debug.viewMemory+0x1F00, 540, 510)
    elseif t == 3 then
        love.graphics.print("OAM Memory", 650, 495)
        testing.displayMemoryChunk(function(value) return oam[value] end, 0x00, 540, 510)
    end

end

return testing
