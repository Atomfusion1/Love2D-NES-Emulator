local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    ADC - Add with Carry
    A,Z,C,N = A+M+C

    This instruction adds the contents of a memory location to the accumulator together with the carry bit. 
    If overflow occurs the carry bit is set, this enables multiple byte addition to be performed.
]]--

-- one day i may figure out how this works but today is not that day 
local function CheckOverflowFlag(operand1, operand2, result)
    -- Check for Overflow
    local overflow = (bit.band(operand1, 0x80) == bit.band(operand2, 0x80)) and (bit.band(operand1, 0x80) ~= bit.band(result, 0x80))
    cpuMemory.WriteFlag("overflow",(overflow == true) and 1 or 0)
end

-- update flags for ADC
local function CheckADCResults(result, operand1, operand2)
    --cpuMemory.WriteFlag("overflow",checkOverflow(operand2, operand1, cpuMemory.ReadFlag("carry")))
    if result > 0xFF then
        cpuMemory.WriteFlag("carry",1)
    else
        cpuMemory.WriteFlag("carry",0)
    end
    result = bit.band(result,0xFF)
    cpuMemory.CheckZeroAndNegativeFlag(result)
    CheckOverflowFlag(result, operand1, operand2)
      
    return result
end

-- ADC function 
local function ADCFunction(value)
    local result = cpuMemory.A + value + cpuMemory.ReadFlag("carry")
    cpuMemory.A = CheckADCResults(result, cpuMemory.A + cpuMemory.ReadFlag("carry"),value )
end

local opcodes = {
    -- Immediate Mode
    [0x69] = {
        opcode = "ADC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x69", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0x65] = {
        opcode = "ADC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x65", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0x75] = {
        opcode = "ADC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x75", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x6D] = {
        opcode = "ADC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x6D", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0x7D] = {
        opcode = "ADC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x7D", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0x79] = {
        opcode = "ADC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x79", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indexed X Mode
    [0x61] = {
        opcode = "ADC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x61", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect Y Mode
    [0x71] = {
        opcode = "ADC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            ADCFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("ADC","ADC","0x71", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes