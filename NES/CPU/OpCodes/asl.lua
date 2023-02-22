local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
ASL - Arithmetic Shift Left
A,Z,C,N = M*2 or M,Z,C,N = M*2

This operation shifts all the bits of the accumulator or memory contents one bit left. Bit 0 is set to 0 and bit 7 is placed in the carry flag. 
The effect of this operation is to multiply the memory contents by 2 (ignoring 2's complement considerations), 
setting the carry if the result will not fit in 8 bits.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    -- Multiply 2 
    local result = bit.lshift(value,1)
    -- Check Rollover
    result = bit.band(result,0xFF)
    -- check if bit 7 is 1 then save it to carry
    local flag = (bit.band(value, 0x80) == 0x80) and 1 or 0
    cpuMemory.WriteFlag("carry", flag)
    cpuMemory.CheckZeroAndNegativeFlag(result)
    return result
end

local opcodes = {
    -- Accumulator
    [0x0A] = {
        opcode = "ASL",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.A
            cpuMemory.A = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ASL","ASL","0x0A", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0x06] = {
        opcode = "ASL",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ASL","ASL","0x06", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0x16] = {
        opcode = "ASL",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ASL","ASL","0x16", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x0E] = {
        opcode = "ASL",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ASL","ASL","0x0E", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0x1E] = {
        opcode = "ASL",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 7
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ASL","ASL","0x1E", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes