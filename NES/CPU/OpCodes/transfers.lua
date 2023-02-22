local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
 TRANSFER FUNCTIONS 
 TAX TAY 
]]--

-- Opcode function 
local function OpcodeFunction(value) 
    cpuMemory.CheckZeroAndNegativeFlag(value)
    return value
end

local opcodes = {
    -- TAX Immediate Mode
    [0xAA] = {
        opcode = "TAX",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.A
            OpcodeFunction(value)
            cpuMemory.X = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TAX","TAX","0xAA", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- TAY Immediate Mode
    [0xA8] = {
        opcode = "TAY",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.A
            OpcodeFunction(value)
            cpuMemory.Y = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TAY","TAY","0xA8", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- TSX Immediate Mode
    [0xBA] = {
        opcode = "TSX",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.stackPointer
            OpcodeFunction(value)
            cpuMemory.X = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TSX","TSX","0xBA", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- TXA Immediate Mode
    [0x8A] = {
        opcode = "TXA",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.X
            OpcodeFunction(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TXA","TXA","0x8A", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- TXS Immediate Mode
    [0x9A] = {
        opcode = "TXS",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.X
            cpuMemory.stackPointer = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TXS","TXS","0x9A", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- TSX Immediate Mode
    [0x98] = {
        opcode = "TYA",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.Y
            OpcodeFunction(value)
            cpuMemory.A = value
            if addressMode.debug.trace then addressMode.OpcodePrint("TYA","TYA","0x98", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
}


return opcodes