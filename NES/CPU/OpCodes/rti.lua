local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
RTI - Return from Interrupt
The RTI instruction is used at the end of an interrupt processing routine.
It pulls the processor flags from the stack followed by the program counter.
]]--

local opcodes = {
    -- RTI Immediate Mode
    [0x40] = {
        opcode = "RTI",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 0
            -- Get Past Flag Status
            local flagByte = addressMode.ReadFromStack()
            -- Flag must have bit 5 high
            flagByte = bit.bor(flagByte, 0x20)
            cpuMemory.statusRegister = flagByte
            -- Get Low Byte
            local lowbyte = addressMode.ReadFromStack()
            -- Get High Byte
            local highbyte = addressMode.ReadFromStack() * 256
            local targetAddress = highbyte + lowbyte
            -- Jump to Target
            cpuMemory.programCounter = targetAddress
            if false then
                addressMode.OpcodePrint("*****RTI ****","RTI","0x40", targetAddress, 0, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes