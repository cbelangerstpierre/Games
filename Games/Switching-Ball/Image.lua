Image = Class{}

function Image:init(file, x, y, width, height, orientation, state, color)
    self.image = love.graphics.newImage(file)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.orientation = orientation
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
    self.state = state
    self.color = color
end

function Image:render()
    love.graphics.setColor(self.color)
    love.graphics.draw(self.image, self.x, self.y, self.orientation, self.widthRatio, self.heightRatio)
end