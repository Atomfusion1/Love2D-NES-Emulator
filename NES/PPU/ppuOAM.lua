local memory     = require("NES.CPU.cpuram")


local ppu = {
    OAM = {}
}

--Sprite OAM Memory PPU Internal Tables
for i = 0x00, 0xFF do
    ppu.OAM[i] = 0x00
end

function ppu.OAM.RefreshOAM(data, data1)
    local RAMAddress = bit.lshift(data,8)+data1
    -- fill OAM table with Memory location 
    for i = 0, 255 do
        ppu.OAM[i] = memory.cpuRAM[RAMAddress + i]
    end
end

return ppu.OAM