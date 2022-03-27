--Invaders game by Tom Millichamp March 2022

--set window size
view_w = 800
view_h = 600
local background = {}

function love.load()
    love.window.setMode (view_w, view_h,{resizable=false,vsync=false})
    love.window.setTitle("Alien Invaders by Tom Millichamp")
    background.image = love.graphics.newImage("sprites/background.png")
    background.x = 0
    background.y = 0

    --uses 'classic' library that emulates object classes from https://github.com/rxi/classic
    Object=require "libs/classic"

    require "player"
    require "enemy"
    require "bullet"
    require "bomb"
    require "bonus"

    score = 0
    lives = 3
    playerDead=false
    level = 1
    enemySpeed = 35
    bonusInPlay = false

    listOfBullets = {} -- create a table (array) to store bullet objects
    listOfBombs = {} -- for alien bombs
    listOfEnemies = {} -- store invaders
    table.insert(listOfEnemies, Enemy(45))
    player = Player()
    startScreen = true
end

function love.update(dt)
    if gamePaused or playerDead or startScreen then
        return
    end

    --update scrolling background
    if background.y > -600 then
        background.y = background.y - (dt * 15)
    else
        background.y = 0
    end

    player:update(dt)

    if bonusInPlay then
        bonus:update(dt)
    else
        bonus = nil
        if love.math.random(1,2000) == 73 then
            --create a new bonus alien
            bonus = Bonus()
            bonusInPlay = true
        end
    end

    for n,e in ipairs (listOfEnemies) do
        --enemy:update(dt)
        e:update(dt)

        --update bullets player fires
        for i, v in ipairs (listOfBullets) do
            --move the bullet
            v:update(dt)

            --check if bullet hit enemy
            v:checkCollision(e)
            if v.dead then
                table.remove(listOfBullets,i)
                score = score + 10

                --draw an explosion
                love.graphics.clear()
                --draw background
                love.graphics.draw(background.image, background.x, background.y)
                e.image=love.graphics.newImage("sprites/explosion.png")
                e:draw()
                love.graphics.present()
                local start = os.time()
                repeat until os.time() > start + 0.05
                e.image=love.graphics.newImage("sprites/Invader.png")
                
                --remove the enemy shot
                table.remove(listOfEnemies, n)

                --check if we killed them all
                if next(listOfEnemies) == nil then
                    -- no more enemies! so Level up!
                    levelUp()
                    return
                 end
                
            end
            --check if bullet hit bonus
            if bonusInPlay and not v.dead then
                v:checkCollision(bonus)
                if v.dead then
                    table.remove(listOfBullets,i)
                    score=score + 50
                    --draw an explosion
                    love.graphics.clear()
                    --draw background
                    love.graphics.draw(background.image, background.x, background.y)
                    bonus.image=love.graphics.newImage("sprites/explosion.png")
                    bonus:draw()
                    love.graphics.present()
                    local start = os.time()
                    repeat until os.time() > start + 0.05
                    bonus.image=love.graphics.newImage("sprites/Invader_red.png")
                    bonusInPlay=false
                end
            end

            --check if bullet has gone off-screen
            if v.offScreen then
                table.remove(listOfBullets,i)
            end
        end
    end

    --update bombs aliens drop
    for i, v in ipairs (listOfBombs) do
        v:update(dt)
        v:checkCollision(player)
        if v.dead then
            table.remove(listOfBombs,i)
            lives = lives - 1
            --draw the player dead (bang.png)
            love.graphics.clear()
            player.image=love.graphics.newImage("sprites/bang.png")
            --draw background
            love.graphics.draw(background.image, background.x, background.y)
            player:draw()
            love.graphics.present()
            local start = os.time()
            repeat until os.time() > start + 0.2
            player.image = love.graphics.newImage("sprites/canon.png")
            if lives == 0 then
                playerDead=true
            end
        end
        if v.offScreen then
            table.remove(listOfBombs,i)
        end
    end
end

function love.draw()
    if startScreen then
        -- Display Start screen with instructions
        love.graphics.print("Alien Invaders!!!", love.graphics.getWidth() / 2 -150, love.graphics.getHeight() / 3)
        love.graphics.print("Arrow keys - Left & Right", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +20)
        love.graphics.print("Space bar - Shooot", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +40)
        love.graphics.print("Escape - Quit", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +60)
        love.graphics.print("Click Off/On Screen to Pause", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +80)
        love.graphics.print("Press ENTER to Start...", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +120)
        return
    elseif gamePaused then
        love.graphics.print("PAUSED", love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 3)
        return
    elseif playerDead then
        love.graphics.print("GAME OVER!!", love.graphics.getWidth() / 2 -100, love.graphics.getHeight() / 3)
        love.graphics.print("You Scored : " .. score, love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +20)
        love.graphics.print("Press 's' to play again", love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +60)
        love.graphics.print("or 'escape' to Quit", love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +80)
        return
    end

    --draw background
    love.graphics.draw(background.image, background.x, background.y)

    love.graphics.print("Score: " .. score, 20, 20)
    love.graphics.printf("Level: " .. level, 0, 20, love.graphics.getWidth(), "center")
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth()-70, 20)
    player:draw()
    if bonusInPlay then
        bonus:draw()
    end
    for n, e in ipairs (listOfEnemies) do
        e:draw()
    end
    --enemy:draw()
    for i, v in ipairs (listOfBullets) do
        v:draw(dt)
    end
    for i, v in ipairs (listOfBombs) do
        v:draw(dt)
    end
end

--check if player presses any keys
--this gets invoked on a keypress event
function love.keypressed(key)
    if key == "space" then
        player:keyPressed(key)
    elseif key == "escape" then
        love.event.quit()
    elseif key == "s" then 
        --restart game
        love.load()
    elseif key == "return" then 
        --start game
        startScreen = false
    end
end

--check if player has moved to another application window
function love.focus(f)
    gamePaused = not f
end


--function for when you clear all aliens on a level
function levelUp()
    level = level + 1

    --lets speed them up! on levels 5 & 10
    if level == 5 or level == 10 or level == 15 then
        enemySpeed = enemySpeed + (level * 5)
    end

    --reove the bonus alien in case it is still live
    bonusInPlay=false

    --remove all existng aliens
    for k,v in pairs(listOfEnemies) do
        listOfEnemies[k] = nil
    end

      --create new ones (number of aliens depending on level)
    for i = 1, level do
        table.insert (listOfEnemies, Enemy(40 + (25 * i)))
    end

    love.graphics.clear()
    love.graphics.print("LEVEL : " .. level, love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 3)
    love.graphics.present()
    local start = os.time()
    repeat until os.time() > start + 1.5
end

