Enemy = Object:extend()

function Enemy:new()
    self.image = love.graphics.newImage("snake.png")
    self.x = 325
    self.y = 450
    self.speed = 100
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Enemy:update(dt)
    --move enemy
    self.x = self.x + self.speed * dt

    --check if we hit edge of window
    local window_width = love.graphics.getWidth()

    if self.x < 0 then
        self.x=0
        self.speed = -self.speed --reverse direction
    elseif self.x + self.width > window_width then
        self.x = window_width-self.width
        self.speed = -self.speed --reverse direction
    end
end

function Enemy:draw()
    love.graphics.draw(self.image, self.x, self.y)
end