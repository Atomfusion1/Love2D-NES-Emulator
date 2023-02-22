
local apu = {}
apu.notes = {}
apu.length = {}

-- Linear length values ms -- I hardcoded this NOT TRUE 
apu.length[0x1F] = 30   * .0025
apu.length[0x1D] = 28   * .0025
apu.length[0x1B] = 26   * .0025
apu.length[0x19] = 24   * .0025
apu.length[0x17] = 22   * .0025
apu.length[0x15] = 20   * .0025
apu.length[0x13] = 18   * .0025
apu.length[0x11] = 16   * .0025
apu.length[0x0F] = 14   * .0025
apu.length[0x0D] = 12   * .0025
apu.length[0x0B] = 10   * .0025
apu.length[0x09] = 8    * .0025
apu.length[0x07] = 6    * .0025
apu.length[0x05] = 4    * .0025
apu.length[0x03] = 2    * .0025
apu.length[0x01] = 80  * .0015

-- Notes with base 1000 * 12 (4/4 at 75 bpm) ms
apu.length[0x1E] = 10 * 32 * 3 / (4 * 75)
apu.length[0x1C] = 10 * 16 * 3 / (4 * 75)
apu.length[0x1A] = 10 * 72 * 3 / (4 * 75)
apu.length[0x18] = 10 * 192 * 3 / (4 * 75)
apu.length[0x16] = 10 * 96 * 3 / (4 * 75)
apu.length[0x14] = 10 * 48 * 3 / (4 * 75)
apu.length[0x12] = 10 * 24 * 3 / (4 * 75)
apu.length[0x10] = 10 * 12 * 3 / (4 * 75)

-- Notes with base 1000 * 10 (4/4 at 90 bpm) ms
apu.length[0x0E] = 10 * 26 * 3 / (4 * 90)
apu.length[0x0C] = 10 * 14 * 3 / (4 * 90)
apu.length[0x0A] = 10 * 60 * 3 / (4 * 90)
apu.length[0x08] = 10 * 160 * 3 / (4 * 90)
apu.length[0x06] = 10 * 80 * 3 / (4 * 90)
apu.length[0x04] = 10 * 40 * 3 / (4 * 90)
apu.length[0x02] = 10 * 20 * 3 / (4 * 90)
apu.length[0x00] = 10 * 10 * 3 / (4 * 90)


local A4 = 440.00
for n = 1, 181 do -- From C0 to B9
  table.insert(apu.notes, A4 * 2^((n-69)/12))
end

local sampleRate = 44100
local duration = 20
local amplitude = 0.2
local sin = math.sin
local floor = math.floor
local samplePoints = sampleRate * duration
local soundData = love.sound.newSoundData(samplePoints, sampleRate, 16, 1)

-- sin Waves
for i = 0, samplePoints - 1 do
    local time = i / sampleRate
    local value = amplitude * math.sin(2 * math.pi * apu.notes[69] * time)
    soundData:setSample(i, value)
end

-- square wave
for i = 0, samplePoints - 1 do
    local time = i / sampleRate
    local value = (floor(time * apu.notes[69] * 2) % 2 == 0) and amplitude or -amplitude
    soundData:setSample(i, value*.5)
end
Pulsesources1 = {}
for i, note in ipairs(apu.notes) do
    Pulsesources1[i] = love.audio.newSource(soundData)
    Pulsesources1[i]:setPitch(note / apu.notes[69])
    Pulsesources1[i]:setLooping(true)
end
Pulsesources2 = {}
for i, note in ipairs(apu.notes) do
    Pulsesources2[i] = love.audio.newSource(soundData)
    Pulsesources2[i]:setPitch(note / apu.notes[69])
    Pulsesources2[i]:setLooping(true)
end

local lastnote1 = 69
function apu.PlayPulse1(note, volume)
    if volume ~= 0 then
        Pulsesources1[note]:play()
    end
    Pulsesources1[lastnote1]:stop()
    lastnote1 = note
end

local lastnote2 = 69
function apu.PlayPulse2(note, volume)
    Pulsesources2[lastnote2]:stop()
    if volume ~= 0 then
        Pulsesources2[note]:setVolume(.01)
        Pulsesources2[note]:play()
    end
    lastnote2 = note
end

-- Triangle Wave
for i = 0, samplePoints - 1 do
    local time = i / sampleRate
    local value = ((time * apu.notes[69]) % 1) * 4 - 2
    if value > 1 then
        value = 2 - value
    elseif value < -1 then
        value = -2 - value
    end
    value = value * amplitude
    soundData:setSample(i, value)
end

Trianglesource = {}
for i, note in ipairs(apu.notes) do
    Trianglesource[i] = love.audio.newSource(soundData)
    Trianglesource[i]:setPitch(note / apu.notes[69])
    Trianglesource[i]:setLooping(true)
end

local lastnote3 = 69
function apu.PlayTriangle(note, volume)
    -- Stop the previous note and reset the ramp timer
    for i = 0, 25 do
        Trianglesource[lastnote3]:setVolume((25-i)/25*.3) -- avoid Poping 
        love.timer.sleep(0.0001)  -- Avoid hogging the CPU
    end
    Trianglesource[lastnote3]:stop()
    -- Play the new note and set its volume to zero
    Trianglesource[note]:play()
    Trianglesource[note]:setVolume(volume)
    lastnote3 = note
end

local eightbit1 = 0
local frequency1 = 0
local notePlaying1 = 58
local volume1 = 0
local pulseTimer1 = 0;
local pulseHaltTimer1 = false
function apu.HandlePulse1(addr, data)
    if addr == 0x4000 then
        volume1 = bit.band(data, 0x0F)
        if volume1 ~= 0 then
            volume1 = volume1/0x08
            if not Pulsesources1[notePlaying1]:isPlaying() then Pulsesources1[notePlaying1]:play() end
        else
            if Pulsesources1[notePlaying1]:isPlaying() then Pulsesources1[notePlaying1]:pause() end
        end
        Pulsesources1[notePlaying1]:setVolume(volume1)
        if bit.band(data, 0x20) ~= 0 then
            pulseHaltTimer1 = true
        else
            pulseHaltTimer1 = false
        end
    end
    if addr == 0x4002 then
        eightbit1 = data
    end
    if addr == 0x4003 then
        local holder = bit.lshift(bit.band(data, 0x07),8)
        local elevinbit = holder + eightbit1
        frequency1 = 1789773/(16*(elevinbit+1))
        local note = 12 * (math.log(frequency1 / A4) / math.log(2)) + 69
        note = math.floor(note + 0.5) -- round to nearest integer
        apu.PlayPulse1(notePlaying1, 1)
        pulseTimer1 = apu.length[bit.rshift(bit.band(data,0xF8),3)]notePlaying1 = note
    end
end

local eightbit2 = 0
local frequency2 = 0
local notePlaying2 = 58
local volume2 = 0
local pulseTimer2 = 0;
local pulseHaltTimer2 = false
function apu.HandlePulse2(addr, data)
    if addr == 0x4004 then
        volume2 = bit.band(data, 0x0F)
        if volume2 ~= 0 then
            volume2 = volume2/0x08
            if not Pulsesources2[notePlaying2]:isPlaying() then Pulsesources2[notePlaying2]:play() end
        else
            if Pulsesources2[notePlaying2]:isPlaying() then Pulsesources2[notePlaying2]:pause() end
        end
        Pulsesources2[notePlaying2]:setVolume(volume2)
        if bit.band(data, 0x20) ~= 0 then
            pulseHaltTimer2 = true
        else
            pulseHaltTimer2 = false
        end
    end
    if addr == 0x4006 then
        eightbit2 = data
    end
    if addr == 0x4007 then
        local holder = bit.lshift(bit.band(data, 0x07),8)
        local elevinbit = holder + eightbit2
        frequency2 = 1789773/(16*(elevinbit+1))
        local note = 12 * (math.log(frequency2 / A4) / math.log(2)) + 69
        note = math.floor(note + 0.5) -- round to nearest integer
        apu.PlayPulse2(notePlaying2, volume2)
        pulseTimer2 = apu.length[bit.rshift(bit.band(data,0xF8),3)]
        notePlaying2 = note
    end
end

local eightbit3 = 0
local frequency3 = 0
local notePlaying3 = 58
local volume3 = .8
local triangleTimer = 0;
local triangleHaltTimer = false
function apu.HandleTriangle(addr, data)
    if addr == 0x4008 then
        triangleTimer = apu.length[bit.band(data,0x7f)] or 0
        if bit.band(data,0x80) ~= 0 then
            triangleHaltTimer = true
        else
            triangleHaltTimer = false
        end
    end
    if addr == 0x400A then
        eightbit3 = data
    end
    if addr == 0x400B then
        Trianglesource[lastnote3]:setVolume(.2)
        local holder = bit.lshift(bit.band(data, 0x07),8)
        local elevinbit = holder + eightbit3
        frequency3 = 1789773/(16*(elevinbit+1))
        local note = 12 * (math.log(frequency3 / A4) / math.log(2)) + 69 - 12 -- subtract 12 to shift frequency as its set to cpu 
        note = math.floor(note + 0.5) -- round to nearest integer
        apu.PlayTriangle(note, volume3)
        notePlaying3 = note
    end
end

-- Sound data for noise channel
local noiseTimer = 0;
local noiseFrequency = 85
-- set up noise wave parameters
local noiseVolume = .5

-- set up envelope parameters for shaping the noise wave
local attackTime = 0.02 -- time for the sound to reach peak volume
local decayTime = 0.001 -- time for the sound to decay to sustain volume
local sustainTime = 0.0005 -- duration of the sustain phase
local releaseTime = 0.003 -- time for the sound to decay from sustain to zero
local sustainVolume = 0.5 -- volume during the sustain phase

-- create the noise wave sample
for i = 0, samplePoints - 1 do
    local time = i / sampleRate
    local value = .5*love.math.random() * 5 - 1 -- generate a random value between -1 and 1
    -- apply the envelope shaping to the noise wave
    if time < attackTime then
        value = value * (time / attackTime) -- linearly increase amplitude during attack phase
    elseif time < attackTime + decayTime then
        value = value * ((sustainVolume - 1) * ((time - attackTime) / decayTime) + 1) -- exponential decay during decay phase
    elseif time < attackTime + decayTime + sustainTime then
        value = value * sustainVolume -- sustain phase (constant amplitude)
    else
        value = value * (1 - (time - (attackTime + decayTime + sustainTime)) / releaseTime) -- exponential decay during release phase
    end
    soundData:setSample(i, value * noiseVolume)
end

local Noisesource = {}
-- Create noise sources for each note
for i, note in ipairs(apu.notes) do
    Noisesource[i] = love.audio.newSource(soundData)
    Noisesource[i]:setPitch(note / apu.notes[69])
    Noisesource[i]:setLooping(true)
end

local lastnote4 = 69
function apu.PlayNoise(note, volume)
    --print("play noise ".. note.." "..volume)
    Noisesource[lastnote4]:stop()
    if volume ~= 0 then
        Noisesource[note]:setVolume(.2)
        Noisesource[note]:play()
        noiseTimer = .1
    end
    lastnote4 = note
end

local notePlaying4 = 48
local noiseHaltTimer = false
-- Function to handle the noise channel
function apu.HandleNoise(addr, data)
    if addr == 0x400C then
        noiseVolume = bit.band(data, 0x0F) / 0x0F
        if bit.band(data, 0x10) ~= 0 then
            -- TODO: handle changing noise frequency mode
        end
        if bit.band(data, 0x20) ~= 0 then
            noiseHaltTimer = true
        else
            noiseHaltTimer = false
        end
    elseif addr == 0x400E then
        --noiseFrequency = bit.band(data, 0x0F)
        --local period = math.floor((noiseFrequency + 1) * 2)
        --local waveform = {}
        --for i=1, period do
        --    table.insert(waveform, math.random() * 2 - 1)
        --end
        --apu.SetNoiseWaveform(waveform)
        apu.PlayNoise(notePlaying4, noiseVolume)
    end
end

function apu.StatusHandle(addr, data)
    --print(string.format("Status %04x %03x", addr, data))
end

function apu.TimerCheck(dt)
    if not pulseHaltTimer1 then
        pulseTimer1 = pulseTimer1 - dt/2
        if pulseTimer1 <= 0 then
            apu.PlayPulse1(lastnote3, 0)
            apu.PlayPulse1(notePlaying1, 0)
        end
    end
    if not pulseHaltTimer2 then
        pulseTimer2 = pulseTimer2 - dt/2
        if pulseTimer2 <= 0 then
            apu.PlayPulse2(lastnote3, 0)
            apu.PlayPulse2(notePlaying2, 0)
        end
    end
    if not triangleHaltTimer then
        triangleTimer = triangleTimer - dt/4
        if triangleTimer <= 0 then
            Trianglesource[lastnote3]:stop()
            Trianglesource[notePlaying3]:stop()
        end
    end
    if not noiseHaltTimer then
        noiseTimer = noiseTimer - dt
        if noiseTimer <= 0 then
            Noisesource[lastnote4]:stop()
            Noisesource[notePlaying4]:stop()
        end
    end

end

function apu.APUSound(addr, data)
    -- Pulse 1
    if addr >= 0x4000 and addr <= 0x4003 then
    apu.HandlePulse1(addr, data)
    end
    -- Pulse 2
    if addr >= 0x4004 and addr <= 0x4007 then
    apu.HandlePulse2(addr, data)
    end
    -- Triangle
    if addr >= 0x4008 and addr <= 0x400B then
    apu.HandleTriangle(addr, data)
    end
    -- Noise
    if addr >= 0x400C and addr <= 0x400F then
        apu.HandleNoise(addr, data)
    end
end

return apu