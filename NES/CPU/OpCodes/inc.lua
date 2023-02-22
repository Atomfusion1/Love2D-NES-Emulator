local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
INC - Increment Memory
M,Z,N = M+1

Adds one to the value held at a specified memory location setting the zero and negative flags as appropriate.
NOTE: INC, INX, INY are in this file 
]]--

-- Opcode function 
local function OpcodeFunction(value)
    value = bit.band(value + 1, 0xFF)
    cpuMemory.CheckZeroAndNegativeFlag(value)
    return value
end

local opcodes = {

    -- Zero Page Mode
    [0xE6] = {
        opcode = "INC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INC","0xE6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0xF6] = {
        opcode = "INC",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INC","0xF6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xEE] = {
        opcode = "INC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INC","0xEE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0xFE] = {
        opcode = "INC",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 7
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            bus.CPUWrite(address, OpcodeFunction(value))
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INC","0xFE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },

    -- EXTRA INX and INY
    -- INX 
    [0xE8] = {
        opcode = "INX",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.X
            cpuMemory.X = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INX","0xE8", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- INY
    [0xC8] = {
        opcode = "INY",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 1
            local value = cpuMemory.Y
            cpuMemory.Y = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("INC","INY","0xC8", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes