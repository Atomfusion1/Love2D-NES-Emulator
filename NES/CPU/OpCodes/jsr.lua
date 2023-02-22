local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
JSR - Jump to Subroutine
The JSR instruction pushes the address (minus one) of the return point on to the stack
and then sets the program counter to the target memory address.
]]--

local opcodes = {
    -- JSR Immediate Mode
    [0x20] = {
        opcode = "JSR",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 0
            -- Store Highbyte

            addressMode.WriteToStack(math.floor(bit.band(cpuMemory.programCounter + 2,0xFF00)/0x100))
            -- Store Lowbyte
            addressMode.WriteToStack(bit.band(cpuMemory.programCounter + 2,0xFF))
            local lowbyte = bus.CPURead(bit.band(cpuMemory.programCounter + 1,0xFFFF))
            local highbyte = bus.CPURead(math.floor(bit.band(cpuMemory.programCounter + 2,0xFFFF))) * 256
            local targetAddress = highbyte+lowbyte
            -- Jump to Target
            cpuMemory.programCounter = targetAddress
            if addressMode.debug.trace then addressMode.OpcodePrint("JSR","JSR","0x20", targetAddress, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes