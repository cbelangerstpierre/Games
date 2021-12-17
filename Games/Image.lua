local Image = Class{}

function Image:init(file, width, height, x, y, orientation)
    self.image = love.graphics.newImage(file)
    self.width = width
    self.height = height
    self.x = x
    self.y = y
    self.orientation = orientation
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
end

function Image:render()
    love.graphics.setColor({1,1,1})
    love.graphics.draw(self.image, self.x, self.y, self.orientation, self.widthRatio, self.heightRatio)
end

function Image:lineRender()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return Image