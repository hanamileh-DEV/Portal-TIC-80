-- This file was originally created to prototype the compression that parts of the game use,
-- and is now kept around as a useful reference or standalone compression tool (requires some simple tweaks).

local function bitwriter()
    return {
        cur = 0,
        bits = 0,
        output = {},

        write = function(self, val, bits)
            self.cur = self.cur | (val << self.bits)
            self.bits = self.bits + bits
            self:flush()
        end,
        flush = function(self)
            while self.bits >= 8 do
                self.output[#self.output + 1] = string.char(self.cur & 0xFF)
                self.bits = self.bits - 8
                self.cur = self.cur >> 8
            end
        end,
        finish = function(self)
            self.output[#self.output + 1] = string.char(self.cur)
            self.bits = 0
            self.cur = 0
            return table.concat(self.output)
        end,
    }
end

local function bitreader(data)
    return {
        data = data,
        pos = 1,
        bits = 0,

        read = function(self, bits)
            local value = 0
            local cur = 0

            if self.bits > 0 then
                if bits >= (8 - self.bits) then
                    value = self:byte() >> self.bits
                    cur = 8 - self.bits
                    self.bits = 0
                    self.pos = self.pos + 1
                else
                    value = (self:byte() >> self.bits) & ((1 << bits) - 1)
                    self.bits = self.bits + bits
                    return value
                end
            end

            while (cur + 8) <= bits do
                value = value | (self:byte() << cur)
                cur = cur + 8
                self.pos = self.pos + 1
            end

            if cur < bits then
                value = value | (self:byte() & ((1 << bits - cur) - 1)) << cur
                self.bits = bits - cur
            end

            return value
        end,
        byte = function(self)
            return string.byte(self.data, self.pos, self.pos)
        end,
    }
end

local function compress(str)
    local writer = bitwriter()

    local codes = {}
    for i = 1, 256 do
        codes[string.char(i - 1)] = i
    end
    local count = 256
    local bits = 9
    local inc = 512

    local start = 1

    while start <= #str do
        for i = start, #str do
            local cur = str:sub(start, i)
            if i == #str then
                writer:write(codes[cur], bits)
                start = i + 1
                break
            end

            local nxt = str:sub(start, i + 1)
            if not codes[nxt] then
                writer:write(codes[cur], bits)
                count = count + 1
                codes[nxt] = count
                start = i + 1
                break
            end
        end

        if count == inc then
            inc = inc * 2
            bits = bits + 1
        end
    end

    writer:write(0, bits)
    return writer:finish()
end

local function decompress(str)
    local reader = bitreader(str)

    local codes = {}
    for i = 1, 256 do
        codes[i] = string.char(i - 1)
    end
    local bits = 9
    local inc = 512

    local result = {}
    local prev

    while true do
        local code = reader:read(bits)
        if code == 0 then
            return table.concat(result)
        end

        if codes[code] then
            result[#result + 1] = codes[code]
            if prev then
                codes[#codes + 1] = prev .. codes[code]:sub(1, 1)
            end
            prev = codes[code]
        else
            local new = prev .. prev:sub(1, 1)
            result[#result + 1] = new
            codes[#codes + 1] = new
            prev = new
        end

        if #codes == inc - 1 then
            inc = inc * 2
            bits = bits + 1
        end
    end
end

local function tohex(str)
    return ({str:gsub('.', function(c) return string.format('%02x', string.byte(c)) end)})[1]
end

local function fromhex(str)
    return ({str:gsub('..', function(c) return string.char(tonumber(c, 16)) end)})[1]
end

local data = io.read('a')
print(#data .. ' bytes uncompressed')
local compressed = compress(data)
print(#compressed .. ' bytes compressed')
print(string.format('Space saved: %.2f%%', 100 - #compressed / #data * 100))
print('Data correct: ' .. (data == decompress(compressed) and 'yes' or 'no'))

