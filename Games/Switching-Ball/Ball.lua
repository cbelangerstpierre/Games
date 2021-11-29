local Ball = Class{}

function Ball:init(x, y, radius, orientation, speed)
    self.x = x
    self.y = y
    self.radius = radius
    self.orientation = orientation
    self.border_adjuster = 0 -- ou CIRCLE_BORDER
    self.state = "outside" --ou inside
    self.speed = speed
end

function Ball:update(dt)
    self.x = MID_CIRCLE_X+(CIRCLE_RADIUS+BALL_RADIUS-self.border_adjuster*2)*math.sin(math.rad(self.orientation))
    self.y = MID_CIRCLE_Y-(CIRCLE_RADIUS+BALL_RADIUS-self.border_adjuster*2)*math.cos(math.rad(self.orientation))
    self.orientation = (self.orientation + self.speed*dt) % 360
end

function Ball:render()
    love.graphics.setColor({0,1,1})
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Ball:touchRectangle(rectangles)

    ballPoint1x = self.x - self.radius * math.cos(math.rad(self.orientation))
    ballPoint1y = self.y - self.radius * math.sin(math.rad(self.orientation))
    ballPoint2x = self.x + self.radius * math.cos(math.rad(self.orientation))
    ballPoint2y = self.y + self.radius * math.sin(math.rad(self.orientation))
    ballPoint3x = self.x + self.radius * math.sin(math.rad(self.orientation))
    ballPoint3y = self.y - self.radius * math.cos(math.rad(self.orientation))
    ballPoint4x = self.x - self.radius * math.sin(math.rad(self.orientation))
    ballPoint4y = self.y + self.radius * math.cos(math.rad(self.orientation))

    for i = 1,tablelength(rectangles),1
    do
        if rectangles[i].state == "inside" then
            border_adjuster = CIRCLE_BORDER
        else
            border_adjuster = 0
        end
        rectPoint1x = rectangles[i].x + (BALL_RADIUS - border_adjuster) * math.sin(rectangles[i].orientation)
        rectPoint1y = rectangles[i].y - (BALL_RADIUS - border_adjuster) * math.cos(rectangles[i].orientation)
        rectPoint2x = rectPoint1x + RECTANGLE_WIDTH * math.cos(rectangles[i].orientation)
        rectPoint2y = rectPoint1y + RECTANGLE_WIDTH * math.sin(rectangles[i].orientation)

        if (((
            not xor(rectPoint1x >= ballPoint1x, rectPoint1x <= ballPoint2x)) and 
            (not xor(rectPoint1y >= ballPoint3y, rectPoint1y <= ballPoint4y))) or 
            ((not xor(rectPoint1x >= ballPoint3x, rectPoint1x <= ballPoint4x)) and 
            (not xor(rectPoint1y >= ballPoint1y, rectPoint1y <= ballPoint2y)))) or 
            (((not xor(rectPoint2x >= ballPoint1x, rectPoint2x <= ballPoint2x)) and 
            (not xor(rectPoint2y >= ballPoint3y, rectPoint2y <= ballPoint4y))) or 
            ((not xor(rectPoint2x >= ballPoint3x, rectPoint2x <= ballPoint4x)) and 
            (not xor(rectPoint2y >= ballPoint1y, rectPoint2y <= ballPoint2y)))) then
            return true
        end
    end

    return false
end

return Ball