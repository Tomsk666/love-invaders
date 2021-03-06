utilFuncs = require "funcs"
Bullet = Object:extend()

function Bullet:new(x, y)
    self.image = love.graphics.newImage("sprites/bullet.png")
    self.x = x
    self.y = y
    self.speed = 700
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Bullet:update(dt)
    --move bullet up
    self.y = self.y - self.speed * dt

    if self.y < 20 then
        self.offScreen = true
        --love.load()
    end
end

function Bullet:checkCollision(obj)
    if utilFuncs.collided(self, obj)  then
        self.dead = true
    end

end

function Bullet:draw()
    love.graphics.draw(self.image, self.x, self.y)
end