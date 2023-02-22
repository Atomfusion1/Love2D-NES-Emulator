local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    CPX - Compare
    Z,C,N = A-M

    This instruction compares the contents of the accumulator with another memory held value and sets the zero and carry flags as appropriate.
]]--

-- Opcode function 
local function OpcodeFunction(operand2)
    local operand1 = cpuMemory.X
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
    [0xE0] = {
        opcode = "CPX",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CPX","CPX","0xE0", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0xE4] = {
        opcode = "CPX",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CPX","CPX","0xE4", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xEC] = {
        opcode = "CPX",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("CPX","CPX","0xEC", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes