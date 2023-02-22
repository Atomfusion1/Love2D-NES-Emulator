local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
JMP - Jump
Sets the program counter to the address specified by the operand
]]--

-- Opcode function 

local opcodes = {
    -- Absolute Mode
    [0x4C] = {
        opcode = "JMP",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 0
            local address = addressMode.GetAbsoluteAddressMode()
            --local value = bus.CPURead(address]
            cpuMemory.programCounter = address

            if addressMode.debug.trace then addressMode.OpcodePrint("JMP","JMP","0x4C", address, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Indirect
    [0x6C] = {
        opcode = "JMP",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 5
            local pcCounts = 0
            local address16 = (bus.CPURead(cpuMemory.programCounter+2)*256) + bus.CPURead(cpuMemory.programCounter+1)
            -- This Is Fucking Stupid ... Why The Fuck did i spend 1 hour trying to understand this edge case Jump Vector Rolls over does not Pass Page
            local value16 = bus.CPURead(address16) + (bus.CPURead(bit.band(address16,0xFF00)+bit.band(bit.band(address16,0xFF)+1,0xFF)) * 256)
            cpuMemory.programCounter = value16
            if addressMode.debug.trace then addressMode.OpcodePrint("JMP","JMP","0x6C", address16, 0, value16, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes