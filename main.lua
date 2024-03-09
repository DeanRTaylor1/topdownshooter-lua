function love.load()
    math.randomseed(os.time())
    Sprites            = {}
    Sprites.background = love.graphics.newImage('sprites/background.png')
    Sprites.bullet     = love.graphics.newImage('sprites/bullet.png')
    Sprites.player     = love.graphics.newImage('sprites/player.png')
    Sprites.zombie     = love.graphics.newImage('sprites/zombie.png')

    Player             = {}
    Player.x           = love.graphics.getWidth() / 2
    Player.y           = love.graphics.getHeight() / 2
    Player.speed       = 5
    Player.rotation    = math.pi / 2
    Player.getSpeed    = function(self)
        return self.speed * 60
    end

    MyFont             = love.graphics.newFont(30)

    Zombies            = {}
    Bullets            = {}

    GameState          = 1
    MaxTime            = 2
    Timer              = MaxTime
    Score              = 0
end

function love.update(dt)
    if GameState == 2 then
        local speed = Player:getSpeed() * dt
        if love.keyboard.isDown("d") and Player.x < love.graphics.getWidth() then
            Player.x = Player.x + speed
        end
        if love.keyboard.isDown("a") and Player.x > 0 then
            Player.x = Player.x - speed
        end
        if love.keyboard.isDown("w") and Player.y > 0 then
            Player.y = Player.y - speed
        end
        if love.keyboard.isDown("s") and Player.y < love.graphics.getHeight() then
            Player.y = Player.y + speed
        end
    end

    for i, z in ipairs(Zombies) do
        local speedMultiplier = z.speed * dt
        z.x = z.x + math.cos(ZombieFacePlayerAngle(z)) * speedMultiplier
        z.y = z.y + math.sin(ZombieFacePlayerAngle(z)) * speedMultiplier

        if DistanceBetween(z.x, z.y, Player.x, Player.y) < 20 then
            for j, _ in ipairs(Zombies) do
                Zombies[j] = nil
                GameState = 1
                Player.x = love.graphics.getWidth() / 2
                Player.y = love.graphics.getHeight() / 2
            end
        end
    end

    for _, b in ipairs(Bullets) do
        local speedMultiplier = b.speed * dt
        b.x = b.x + (math.cos(b.direction) * speedMultiplier)
        b.y = b.y + (math.sin(b.direction) * speedMultiplier)
    end

    for i = #Bullets, 1, -1 do
        local b = Bullets[i]

        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(Bullets, i)
        end
    end

    for _, zombie in ipairs(Zombies) do
        for j, bullet in ipairs(Bullets) do
            if DistanceBetween(zombie.x, zombie.y, bullet.x, bullet.y) < 20 then
                zombie.dead = true
                bullet.dead = true
                Score = Score + 1
            end
        end
    end

    for i = #Zombies, 1, -1 do
        local z = Zombies[i]
        if z.dead == true then
            table.remove(Zombies, i)
        end
    end

    for i = #Bullets, 1, -1 do
        local b = Bullets[i]
        if b.dead == true then
            table.remove(Bullets, i)
        end
    end

    if GameState == 2 then
        Timer = Timer - dt
        if Timer <= 0 then
            SpawnZombie()
            MaxTime = 0.95 * MaxTime
            Timer = MaxTime
        end
    end
end

function love.draw()
    love.graphics.draw(Sprites.background, 0, 0)

    if GameState == 1 then
        love.graphics.setFont(MyFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end
    love.graphics.printf("Score: " .. Score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

    love.graphics.draw(Sprites.player, Player.x, Player.y, PlayerMouseAngle(), nil, nil, Sprites.player:getWidth() / 2,
        Sprites.player:getHeight() / 2)

    for i, z in ipairs(Zombies) do
        love.graphics.draw(Sprites.zombie, z.x, z.y, ZombieFacePlayerAngle(z), nil, nil, Sprites.zombie:getWidth() / 2,
            Sprites.zombie:getHeight() / 2)
    end

    for i, b in ipairs(Bullets) do
        love.graphics.draw(Sprites.bullet, b.x, b.y, nil, 0.5, nil, Sprites.bullet:getWidth() / 2,
            Sprites.bullet:getHeight() / 2)
    end
end

function love.keypressed(key)
    if key == "space" then
        SpawnZombie()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if GameState == 2 then
            SpawnBullet()
        elseif GameState == 1 then
            GameState = 2
            MaxTime = 2
            Timer = MaxTime
            Score = 0
        end
    end
end

function SpawnZombie()
    local zombie = {}

    zombie.x = 0
    zombie.y = 0
    zombie.speed = math.random(100, 300)
    zombie.dead = false

    local side = math.random(1, 4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 2 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end
    table.insert(Zombies, zombie)
end

function SpawnBullet()
    local bullet = {}
    bullet.x = Player.x
    bullet.y = Player.y
    bullet.speed = 500
    bullet.direction = PlayerMouseAngle()
    bullet.dead = false

    table.insert(Bullets, bullet)
end

function PlayerMouseAngle()
    local turn = 0
    if love.mouse.getX() < Player.x then
        turn = math.pi
    end
    return math.atan((love.mouse.getY() - Player.y) / (love.mouse.getX() - Player.x)) + turn
end

function ZombieFacePlayerAngle(zombie)
    local turn = 0
    if Player.x < zombie.x then
        turn = math.pi
    end
    return math.atan((Player.y - zombie.y) / (Player.x - zombie.x)) + turn
end

function DistanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end
