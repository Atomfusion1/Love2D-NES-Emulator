local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
LSR - Logical Shift Right
A,C,Z,N = A/2 or M,C,Z,N = M/2

Each of the bits in A or M is shift one place to the right. The bit that was in bit 0 is shifted into the carry flag. Bit 7 is set to zero.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    local result = bit.rshift(value,1)
    -- check if bit 1 is 1 then save it to carry
    local flag = (bit.band(value, 0x01) == 0x01) and 1 or 0
    cpuMemory.WriteFlag("carry", flag)
    cpuMemory.CheckZeroAndNegativeFlag(result)
    return result
end

local opcodes = {
    -- Accumulator
    [0x4A] = {
        opcode = "LSR",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.A
            cpuMemory.A = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LSR","LSR","0x4A", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0x46] = {
        opcode = "LSR",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LSR","LSR","0x46", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0x56] = {
        opcode = "LSR",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LSR","LSR","0x56", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x4E] = {
        opcode = "LSR",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LSR","LSR","0x4E", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0x5E] = {
        opcode = "LSR",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 7
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LSR","LSR","0x5E", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes