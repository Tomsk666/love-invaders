--uses 'classic' library that emulates object classes from https://github.com/rxi/classic

function love.load()
    Object=require "libs/classic"

    require "player"
    require "enemy"
    require "bullet"

    player = Player()
    enemy = Enemy()
    listOfBullets = {} -- create a table (array) to store bullet objects

    score = 0
end

function love.update(dt)
    player:update(dt)
    enemy:update(dt)
    for i, v in ipairs (listOfBullets) do
        v:update(dt)
        v:checkCollision(enemy)
        if v.dead then
            table.remove(listOfBullets,i)
            score = score + 1
        end
    end
end

function love.draw()
    love.graphics.print("Score: " .. score, 10, 20) -- .. is string concatenation!
    player:draw()
    enemy:draw()
    for i, v in ipairs (listOfBullets) do
        v:draw(dt)
    end
end

function love.keypressed(key)
    player:keyPressed(key)
end

