local cart = require("NES.Cartridge.Cartridge")

local mapper = {}
mapper.version = 0x00
local CHRoffset = nil
local functionRead = nil
local ROM = nil

function mapper.CPURead(addr)
    return functionRead(addr)
end

function mapper.CPUWrite(addr, value)

end


    -- Character Memory 
function mapper.PPURead(addr)
    return ROM[addr + CHRoffset]
end

function mapper.PPUWrite(addr, value)

end

function mapper.INI()
    print("mapper initialized")
    CHRoffset = cart.header[0x04]*0x4000 + 0x0010 -- offset for header added back on 
    ROM = cart.ROM
    if cart.header[0x04] == 1 then
        functionRead = function(addr)
            if addr >= 0xC000 and addr <= 0xFFFF then
                return cart.ROM[addr - 0xC000 + 0x0010] -- offset for header added back on 
            elseif addr >= 0x8000 and addr <= 0xFFFF then
                return cart.ROM[addr - 0x8000 + 0x0010] -- offset for header added back on 
            end
        end
    else
        functionRead = function(addr)
            return ROM[addr - 0x7FF0]
        end
    end
end

return mapper