--Invaders game by Tom Millichamp March 2022

function love.load()
    --uses 'classic' library that emulates object classes from https://github.com/rxi/classic
    Object=require "libs/classic"

    require "player"
    require "enemy"
    require "bullet"
    require "bomb"

    player = Player()
    enemy = Enemy()
    listOfBullets = {} -- create a table (array) to store bullet objects
    listOfBombs = {} -- for alien bombs
    score = 0
end

function love.update(dt)
    player:update(dt)
    enemy:update(dt)

    --update bullets player fires
    for i, v in ipairs (listOfBullets) do
        v:update(dt)
        v:checkCollision(enemy)
        if v.dead then
            table.remove(listOfBullets,i)
            score = score + 1
            enemy.image=love.graphics.newImage("sprites/explosion.png")
        end
        if v.offScreen then
            table.remove(listOfBullets,i)
        end
    end

    --update bombs aliens drop
    for i, v in ipairs (listOfBombs) do
        v:update(dt)
        v:checkCollision(player)
        if v.dead then
            table.remove(listOfBombs,i)
            score = score - 1
            player.image=love.graphics.newImage("sprites/bang.png")
        end
        if v.offScreen then
            table.remove(listOfBombs,i)
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
    for i, v in ipairs (listOfBombs) do
        v:draw(dt)
    end
end

--check if player fires missile
function love.keypressed(key)
    player:keyPressed(key)
end

