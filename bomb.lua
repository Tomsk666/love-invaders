Bomb = Object:extend()

function Bomb:new(x, y)
    self.image = love.graphics.newImage("sprites/bomb.png")
    self.x = x
    self.y = y
    self.speed = 700
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Bomb:update(dt)
    --move bomb down
    self.y = self.y + self.speed * dt

    if self.y > love.graphics.getHeight() then
        --destroy the bullet
        self.offScreen = true
    end
end


function Bomb:checkCollision(obj)
    local self_left=self.x
    local self_right=self.x + self.width
    local self_top=self.y
    local self_bottom=self.y + self.height

    local obj_left=obj.x
    local obj_right=obj.x + obj.width
    local obj_top=obj.y
    local obj_bottom=obj.y + obj.height

    if self_right > obj_left
    and self_left < obj_right
    and self_bottom >obj_top
    and self_top < obj_bottom then
        self.dead=true
    end
end

function Bomb:draw()
    love.graphics.draw(self.image, self.x, self.y)
end