Fireball = Class{}

function Fireball:init(file, x, y, width, height, orientation, speed)
    self.image = love.graphics.newImage(file)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
    self.orientation = orientation
    self.speed = speed
end

function Fireball:render()
    love.graphics.setColor({1, 1, 1})
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.orientation), self.widthRatio, self.heightRatio)
end

function Fireball:update(dt)
    self.x = self.x + self.speed * dt * math.cos(math.rad(self.orientation))
    self.y = self.y + self.speed * dt * math.sin(math.rad(self.orientation))
end