Brick = Class{}

function Brick:init(x, y, width, height, color)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = color
end

function Brick:render()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end