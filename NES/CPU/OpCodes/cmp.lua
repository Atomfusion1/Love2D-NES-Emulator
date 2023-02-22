local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    CMP - Compare
    Z,C,N = A-M

    This instruction compares the contents of the accumulator with another memory held value and sets the zero and carry flags as appropriate.
]]--

-- Opcode function 
local function OpcodeFunction(operand2)
    local operand1 = cpuMemory.A
    local result = operand1 - operand2
    result = bit.band(result, 0xFF)
    -- Check Carry flag
    if operand1 >= operand2 then
        cpuMemory.WriteFlag("carry", 1)
    else
        cpuMemory.WriteFlag("carry", 0)
    end
    -- Check if A and Value are equal
    if operand1 == operand2 then
        cpuMemory.WriteFlag("zero", 1)
    else
        cpuMemory.WriteFlag("zero", 0)
    end
    -- Check for Negative Flag
    cpuMemory.CheckNegativeFlag(result)
end

local opcodes = {
    -- Immediate Mode
    [0xC9] = {
        opcode = "CMP",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xC9", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0xC5] = {
        opcode = "CMP",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xC5", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0xD5] = {
        opcode = "CMP",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xD5", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xCD] = {
        opcode = "CMP",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xCD", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0xDD] = {
        opcode = "CMP",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xDD", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0xD9] = {
        opcode = "CMP",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xD9", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect X Mode
    [0xC1] = {
        opcode = "CMP",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0xC1", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect Y Mode
    [0xD1] = {
        opcode = "CMP",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CMP","CMP","0x00", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes