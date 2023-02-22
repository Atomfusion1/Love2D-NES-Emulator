local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    AND - Logical AND
    A,Z,N = A&M

    A logical AND is performed, bit by bit, on the accumulator contents using the contents of a byte of memory.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    local results = bit.band(cpuMemory.A, value)
    cpuMemory.CheckZeroAndNegativeFlag(results)
    cpuMemory.A = results
end

local opcodes = {
    -- Immediate Mode
    [0x29] = {
        opcode = "AND",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x29", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0x25] = {
        opcode = "AND",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x25", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0x35] = {
        opcode = "AND",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x35", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0x2D] = {
        opcode = "AND",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x2D", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute X Mode
    [0x3D] = {
        opcode = "AND",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x3D", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0x39] = {
        opcode = "AND",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x39", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indexed X Mode
    [0x21] = {
        opcode = "AND",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x21", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect Y Mode
    [0x31] = {
        opcode = "AND",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("AND","AND","0x31", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes