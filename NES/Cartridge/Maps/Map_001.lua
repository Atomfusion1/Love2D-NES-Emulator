local cart = require("NES.Cartridge.Cartridge")

local mapper = {}
mapper.version = 0x01
local loadRegister = 0x00
local targetRegister = 0x00
local nCHRBankSelect4Lo = 0x00
local nCHRBankSelect4Hi = 0x00
local nCHRBankSelect8 = 0x00
local nLoadRegister = 0x00
local nLoadRegisterCount = 0x00
local nControlRegister = 0x00


function mapper.CPURead(addr)
    -- Cartridge ROM Memory
    if cart.header[0x04] == 1 and addr >= 0xC000 and addr <= 0xFFFF then
        return cart.ROM[addr - 0xC000 + 0x0010] -- offset for header added back on 
    elseif addr >= 0x8000 and addr <= 0xFFFF then
        return cart.ROM[addr - 0x8000 + 0x0010] -- offset for header added back on 
    else
        return addr
    end
end

function mapper.CPUWrite(addr, value)

end

function mapper.PPURead(addr)
    -- Character Memory 
    local CHRoffset   = cart.header[0x04]*0x4000
    return cart.ROM[addr + CHRoffset + 0x0010] -- offset for header added back on 
end

function mapper.PPUWrite(addr, value)

end

function mapper.INI()

end

return mapper