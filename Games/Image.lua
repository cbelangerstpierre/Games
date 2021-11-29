local Image = Class{}

function Image:init(file, width, height)
    self.image = love.graphics.newImage(file)
    self.width = width
    self.height = height
    self.x = (WINDOW_WIDTH - self.width)/2
    self.y = (WINDOW_HEIGHT - self.height)/2
    self.orientation = orientation
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
end

function Image:render()
    love.graphics.setColor({1,1,1})
    love.graphics.draw(self.image, self.x, self.y, 0, self.widthRatio, self.heightRatio)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return Image