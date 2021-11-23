Platform = Class{}

function Platform:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
end

function Platform:update(dt)
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - PLATFORM_WIDTH, self.x + self.dx * dt)
    end
end

function Platform:reset()
    self.x = (VIRTUAL_WIDTH - PLATFORM_WIDTH) / 2
    self.y = VIRTUAL_HEIGHT - PLATFORM_HEIGHT - 20
end

function Platform:render()
    love.graphics.setColor(20/255, 20/255, 255/255, 255/255)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end