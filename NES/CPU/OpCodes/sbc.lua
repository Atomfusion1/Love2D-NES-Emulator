local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
SBC - Subtract with Carry
A,Z,C,N = A-M-(1-C)

This instruction subtracts the contents of a memory location to the accumulator together with the not of the carry bit. 
If overflow occurs the carry bit is clear, this enables multiple byte subtraction to be performed.
]]--

-- one day i may figure out how this works but today is not that day 
local function CheckOverflowFlag( result, operand1, operand2)
    -- Check for Overflow
    local overflow = (bit.band(bit.bxor(operand1, operand2), 0x80) ~= 0) and (bit.band(bit.bxor(operand1, result), 0x80) ~= 0)
        cpuMemory.WriteFlag("overflow",(overflow == true) and 1 or 0)
end

-- update flags for SBC
local function CheckSBCResults(result, operand1, operand2)
    if result < 0x00 then 
        cpuMemory.WriteFlag("carry",0)
        result = bit.band(result,0xFF)
    else
        cpuMemory.WriteFlag("carry",1)
    end
    result = bit.band(result,0xFF)
    cpuMemory.CheckZeroAndNegativeFlag(result)
    CheckOverflowFlag(result, operand1, operand2)
    return result
end

-- SBC function 
local function SBCFunction(value)
    local result = cpuMemory.A - value - (1-cpuMemory.ReadFlag("carry"))
    cpuMemory.A = CheckSBCResults(result, cpuMemory.A ,value)
end

local opcodes = {
    -- Immediate Mode
    [0xE9] = {
        opcode = "SBC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xE9", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0xE5] = {
        opcode = "SBC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xE5", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0xF5] = {
        opcode = "SBC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xF5", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xED] = {
        opcode = "SBC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xED", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0xFD] = {
        opcode = "SBC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xFD", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0xF9] = {
        opcode = "SBC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xF9", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indexed X Mode
    [0xE1] = {
        opcode = "SBC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xE1", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect Y Mode
    [0xF1] = {
        opcode = "SBC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            SBCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("SBC","SBC","0xF1", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes