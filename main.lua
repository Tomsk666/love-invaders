--Invaders game by Tom Millichamp March 2022

--set window size
view_w = 800
view_h = 600
local background = {}


alien_dead_snd = love.audio.newSource("snd/alien_dead.ogg", "static")
bonus_ship_snd = love.audio.newSource("snd/bonus_ship.ogg", "static")
player_dead_snd = love.audio.newSource("snd/player_dead.ogg", "static")
player_shoot_snd = love.audio.newSource("snd/player_shoot.ogg", "static")

arkham_font = "fonts/Arkham_bold.TTF"

--for high scores saving
highscore = require "libs/sick"

function love.load()
    --set window size, title & background
    love.window.setMode (view_w, view_h,{resizable=false,vsync=false})
    love.window.setTitle("Alien Invaders by Tom Millichamp")
    background.image = love.graphics.newImage("sprites/background.png")
    background.x = 0
    background.y = 0

    --play our intr music
    intro= love.audio.newSource("snd/intro.ogg", "stream")
    intro:setLooping(true)
    love.audio.play(intro)

    --uses 'classic' library that emulates object classes from https://github.com/rxi/classic
    Object = require "libs/classic"

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

    --create 1 alien & our player
    --when we create an enemy, we pass in the Y co-ordinate for how far down the screen it appears
    table.insert(listOfEnemies, Enemy(45))
    player = Player()

    --set up the high scores file
    highscore.set("scores")

    --go to the start screen
    startScreen = true
end

function love.update(dt)
    --only update if in play
    if gamePaused or playerDead or startScreen then
        return
    end

    --update scrolling background
    if background.y > -600 then
        background.y = background.y - (dt * 15)
    else
        background.y = 0
    end

    --update player
    player:update(dt)

    --update the bonus alien (red alien) if it is on-screen
    if bonusInPlay then
        bonus:update(dt)
    else
        --if it isn't then create one at random, but only from level 3 onwards
        bonus = nil
        if love.math.random(1,2500) == 73 and level > 2 then
            --create a new bonus alien
            bonus = Bonus()
            bonusInPlay = true
            love.audio.play(bonus_ship_snd)
        end
    end

    --update our table of alien enemies
    --on each iteration, check if we hit one with our bullets
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
                love.audio.play(alien_dead_snd)
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
                    love.audio.play(alien_dead_snd)
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
    --and check if they hit the player
    for i, v in ipairs (listOfBombs) do
        v:update(dt)
        v:checkCollision(player)
        if v.dead then
            love.audio.play(player_dead_snd)
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
        love.graphics.setNewFont(arkham_font, 24)
        love.graphics.printf("Alien Invaders!!!", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
        love.graphics.printf("Arrow keys - Left & Right", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Space bar - Shooot", 0, 280, love.graphics.getWidth(), "center")
        love.graphics.printf("Escape - Quit", 0, 310, love.graphics.getWidth(), "center")
        love.graphics.printf("Click Off/On Screen to Pause", 0, 340, love.graphics.getWidth(), "center")
        love.graphics.printf("Press ENTER to Start...", 0, 400, love.graphics.getWidth(), "center")
        return
    elseif gamePaused then
        love.graphics.printf("PAUSED", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
        return
    elseif playerDead then
        --save the high scores 
        highscore.save("Bob", score)
        love.graphics.setNewFont(arkham_font, 24)
        love.graphics.printf("GAME OVER!!", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
        love.graphics.printf("You Scored : " .. score .. "  Level : " .. level, 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Press 's' to play again", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("or 'escape' to Quit", 0, 330, love.graphics.getWidth(), "center")
        --display highest scorer
        local h_scores = highscore.load()
        love.graphics.printf("HIGH SCORE", 0, 430, love.graphics.getWidth(), "center")
        love.graphics.printf(h_scores[1] .. "   " .. h_scores[2], 0, 430, love.graphics.getWidth(), "center")
        
        return
    end

    --draw background
    love.graphics.draw(background.image, background.x, background.y)

    love.graphics.print("Score: " .. score, 20, 20)
    --set the params for printf as below to center text on-screen
    love.graphics.printf("Level: " .. level, 0, 20, love.graphics.getWidth(), "center")
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth()-70, 20)

    player:draw()
    if bonusInPlay then
        bonus:draw()
    end
    for n, e in ipairs (listOfEnemies) do
        e:draw()
    end
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
        love.event.quit("Thank you for Playing!")
    elseif key == "s" then 
        --restart game
        love.load()
    elseif key == "return" then 
        --start game
        startScreen = false
        --stop the intro music
        love.audio.stop()
    end
end

--check if player has moved to another application window
--if so, pause the game
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
    love.graphics.setNewFont(18) -- the number denotes the font size

    love.graphics.printf("LEVEL : " .. level, 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    love.graphics.present()
    local start = os.time()
    repeat until os.time() > start + 1.5
    love.graphics.setNewFont(12) 
end

