local tau = math.pi * 2
local samplerate = 44100 -- Hz
local bits = 16 -- 8 bits results in very low quality sound
local channels = 2 -- löve only supports mono or stereo
local buffercount = 2 -- don't need too many buffers
local qsource = love.audio.newQueueableSource(samplerate, bits, channels, buffercount)
local samplepoints = samplerate -- how many numbers does one buffer hold
local buffer = love.sound.newSoundData(samplepoints, samplerate, bits, channels)
local phase = 0
local amplitude = 0.5 -- 50%

-- twinkle twinkle 
local notes = {
    { note = 261.63, duration = 0.5 }, -- C4
    { note = 261.63, duration = 0.5 }, -- C4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 440.00, duration = 0.5 }, -- A4
    { note = 440.00, duration = 0.5 }, -- A4
    { note = 392.00, duration = 1 },   -- G4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 293.66, duration = 0.5 }, -- D4
    { note = 293.66, duration = 0.5 }, -- D4
    { note = 261.63, duration = 1 },   -- C4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 293.66, duration = 1 },   -- D4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 329.63, duration = 0.5 }, -- E4
    { note = 293.66, duration = 1 },   -- D4
    { note = 261.63, duration = 0.5 }, -- C4
    { note = 261.63, duration = 0.5 }, -- C4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 392.00, duration = 0.5 }, -- G4
    { note = 440.00, duration = 0.5 }, -- A4
    { note = 440.00, duration = 0.5 }, -- A4
    { note = 392.00, duration = 1 },   -- G4
    { note = 349.23, duration = 0.5 }, -- F4
    { note = 349.23, duration = 0.5 }, -- F4
}
-- smb
local notes1 = {
    { note = 659.3, duration = 0.1 }, -- E5
    { note = 659.3, duration = 0.3 }, -- E5
    { note = 659.3, duration = 0.3 }, -- E5
    { note = 523.3, duration = 0.3 }, -- C5
    { note = 659.3, duration = 0.3 }, -- E5
    { note = 784.0, duration = 0.5 }, -- G5
    { note = 392.0, duration = 0.5 }, -- G4
    { note = 523.3, duration = 0.3 }, -- C5
    { note = 392.0, duration = 0.3 }, -- G4
    { note = 329.6, duration = 0.3 }, -- E4
    { note = 523.3, duration = 0.3 }, -- C5
    { note = 659.3, duration = 0.3 }, -- E5
    { note = 784.0, duration = 0.3 }, -- G5
    { note = 880.0, duration = 0.15 }, -- A5
    { note = 1046.5, duration = 0.15 }, -- C6
    { note = 880.0, duration = 0.15 }, -- A5
    { note = 784.0, duration = 0.15 }, -- G5
    { note = 659.3, duration = 0.3 }, -- E5
    { note = 523.3, duration = 0.3 }, -- C5
}
local function getFrequency(note)
    return math.pow(2, (note - 49) / 12) * 440
end

local function synth2(frequency)
    phase = phase + (tau * frequency / samplerate)
    local pulse = (math.sin(phase) > 0) and 1 or -1
    return math.sin(phase) * pulse * amplitude
end

local function generateSamples()
    local samples = {}
    for i, note in ipairs(notes) do
        local noteDuration = note.duration
        local noteFrequency = getFrequency(note.note)
        local samplesPerNote = noteDuration * samplerate / 1000
        for j = 1, samplesPerNote do
            samples[#samples + 1] = synth2(noteFrequency)
        end
    end
    return samples
end

local function synthSin(frequency)
    phase = phase + (tau * frequency / samplerate)
    return math.sin(phase) * amplitude
end

local function synthTriangle(frequency)
    phase = phase + (tau * frequency / samplerate)
    local value = 2 * (phase % (2 * math.pi)) / (2 * math.pi)
    return (value > 1 and 2 - value or value) * amplitude*4
end
local function synthPulse(frequency, duty)
    phase = phase + (tau * frequency / samplerate)
    local value = (phase % (2 * math.pi)) / (2 * math.pi)
    return (value < duty) and amplitude or -amplitude
end
local function synthNoise(frequency)
    return math.sin(frequency) * 100 * love.math.random(5)/100
end
  
local timer = 0
function love.update1(dt)
    timer = dt + timer
    while qsource:getFreeBufferCount() > 0 do
        for i = 0, samplepoints - 1 do
            local sample1 = 0--synthTriangle(notes[r].note, 0.5)*2
            local sample2 = 0--synthPulse(notes1[r].note, .5)*3
            local sample3 = synthPulse(notes1[r].note, .5)*3
            local sample4 = 0--synthNoise(50)/5
            local sample = (sample1 + sample2 + sample3 + sample4)
            buffer:setSample(i, sample)
        end
        qsource:queue(buffer)
        qsource:play()
    end
    if timer >= notes1[r].duration then
        timer = 0
        r=r+1
        if r >= #notes1 then
            r = 1
        end
    end
end
r = 1
function love.keypressed(key)
    if key == 'k' then
        r=r+1
    elseif key == 'j' then
        r=r-1
    end
end