local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
BIT - Bit Test
A & M, N = M7, V = M6

This instructions is used to test if one or more bits are set in a target memory location. 
The mask pattern in A is ANDed with the value in memory to set or clear the zero flag, but the result is not kept. 
Bits 7 and 6 of the value from memory are copied into the N and V flags.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    local result = bit.band(cpuMemory.A, value)
    cpuMemory.CheckZeroFlag(result)
    cpuMemory.CheckNegativeFlag(value)
    local overflow = (bit.band(value, 0x40) == 0x40) and 1 or 0
    cpuMemory.WriteFlag("overflow", overflow)
    return
end

local opcodes = {
    -- Zero Page Mode
    [0x24] = {
        opcode = "BIT",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BIT","BIT","0x24", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x2C] = {
        opcode = "BIT",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BIT","BIT","0x2C", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes