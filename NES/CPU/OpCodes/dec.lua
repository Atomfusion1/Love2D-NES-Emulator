local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
DEC - Decrement Memory
M,Z,N = M-1

Subtracts one from the value held at a specified memory location setting the zero and negative flags as appropriate.
NOTE: DEC, DEX, DEY are in this file 
]]--

-- Opcode function 
local function OpcodeFunction(value)
    value = bit.band(value - 1, 0xFF)
    cpuMemory.CheckZeroAndNegativeFlag(value)
    return value
end

local opcodes = {

    -- Zero Page Mode
    [0xC6] = {
        opcode = "DEC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEC","0xC6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0xD6] = {
        opcode = "DEC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEC","0xD6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xCE] = {
        opcode = "DEC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEC","0xCE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0xDE] = {
        opcode = "DEC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 7
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEC","0xDE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },

    -- EXTRA DEX and DEY
    -- DEX 
    [0xCA] = {
        opcode = "DEX",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.X
            cpuMemory.X = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEX","0xCA", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- DEY
    [0x88] = {
        opcode = "DEY",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.Y
            cpuMemory.Y = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("DEC","DEY","0x88", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes