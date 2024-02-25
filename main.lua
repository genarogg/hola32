-- Variables
local love= require('love')
local player = { x = 400, y = 300, img = nil }
local bullets = {}
local enemies = {}
local enemyTimer = 15
local enemyInterval = 50
local enemyBullets = {}
local FireInterval = 6
local enemyFireInterval=30
local maxEnemyBullets =3 
-- Imágenes
local background = love.graphics.newImage("Imagen.png")
local playerImg = love.graphics.newImage("player.png")
local bulletImg = love.graphics.newImage("bala2.png")
local enemyImg = love.graphics.newImage("enemigo.png")
local enemyBulletImg = love.graphics.newImage("bala.png")

-- Tiempo de recarga en segundos
local reloadTime = 0.4
-- Tiempo hasta el próximo disparo
local timeToNextShot = 0



function love.load()
    player.img = playerImg
end

function love.update(dt)
    -- Mover jugador
    if love.keyboard.isDown("up") then
        player.y = player.y - 200 * dt
    end
    if love.keyboard.isDown("down") then
        player.y = player.y + 200 * dt
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - 200 * dt
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + 200 * dt
    end

    -- Disminuir el tiempo hasta el próximo disparo
    if timeToNextShot > 0 then
        timeToNextShot = timeToNextShot - dt
    end
    
    -- Disparar balas
    if love.keyboard.isDown("space") and timeToNextShot <= 0 then
        table.insert(bullets, { x = player.x, y = player.y })
        -- Reiniciar el tiempo hasta el próximo disparo
        timeToNextShot = reloadTime
    end

    -- Mover balas
    for _, bullet in ipairs(bullets) do
        bullet.y = bullet.y - 400 * dt

        -- Eliminar balas fuera de pantalla
        if bullet.y < 0 then
            table.remove(bullets, _)
        end
    end

    -- Crear enemigos
    if math.random(100) < 2 then
        table.insert(enemies, { x = math.random(800),
         y = 0 })
    end
    for _, enemy in ipairs(enemies) do
        enemy.fireTimer = (enemy.fireTimer or 0) + dt

        -- Disparar si ha pasado el intervalo de tiempo y el límite de balas no se ha alcanzado
        if enemy.fireTimer > enemyFireInterval and #enemyBullets < maxEnemyBullets then
            local newBullet = {
                x = enemy.x + enemyImg:getWidth() / 2,
                y = enemy.y + enemyImg:getHeight(),
                speed = 300
            }
            table.insert(enemyBullets, newBullet)
            enemy.fireTimer = 0  -- Reiniciar el temporizador de disparo
            break  -- Salir del bucle para que solo un enemigo dispare a la vez
        end
    end


    -- Actualizar enemigos y sus balas
    for _, enemy in ipairs(enemies) do
        local angle = math.atan(player.y - enemy.y, player.x - enemy.x)
        enemy.dx = math.cos(angle) * 100
        enemy.dy = math.sin(angle) * 100
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt

        -- Eliminar enemigos fuera de pantalla
        if enemy.y > love.graphics.getHeight() then
            table.remove(enemies, _)
        end

        -- Disparar al jugador
        if math.random(50) < 30 then
            table.insert(bullets, { x = enemy.x, y = enemy.y, isEnemyBullet = true })
        end

        -- Mover balas del enemigo
        for _, bullet in ipairs(bullets) do
            if bullet.isEnemyBullet then
                bullet.y = bullet.y + 200 * dt

                -- Eliminar balas del enemigo fuera de pantalla
                if bullet.y > love.graphics.getHeight() then
                    table.remove(bullets, _)
                end
            end
        end
        -- Actualizar el temporizador de los enemigos
    enemyTimer = enemyTimer + dt

    -- Generar nuevos enemigos si ha pasado el intervalo de tiempo
    if enemyTimer > enemyInterval then
        local newEnemy = {
            x = math.random(0, love.graphics.getWidth() - enemyImg:getWidth()),
            y = -enemyImg:getHeight(),
            speed = 20
        }
        table.insert(enemies, newEnemy)
        
        -- Reiniciar el temporizador
        enemyTimer = 0
    end

    -- ... (código de colisiones)
end

    
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        for j, bullet in ipairs(bullets) do
            if not bullet.isEnemyBullet and love.checkCollision(enemy.x, enemy.y, enemyImg:getWidth(), enemyImg:getHeight(), bullet.x, bullet.y, bulletImg:getWidth(), bulletImg:getHeight()) then
                table.remove(enemies, i)
                table.remove(bullets, j)
                break
            end
        end
    end
end
    

function love.checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

function love.checkPlayerEnemyCollision()
    local playerWidth, playerHeight = playerImg:getWidth(), playerImg:getHeight()
    
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        local enemyWidth, enemyHeight = enemyImg:getWidth(), enemyImg:getHeight()
        
        if love.checkCollision(player.x, player.y, playerWidth, playerHeight, enemy.x, enemy.y, enemyWidth, enemyHeight) then
            -- Reiniciar la posición del jugador
            player.x = 400
            player.y = 300
            
            -- Eliminar al enemigo
            table.remove(enemies, i)
        end
    end
end
function love.draw()
    -- Dibujar fondo
    
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local imageWidth, imageHeight = background:getWidth(), background:getHeight()
    local scaleX = windowWidth / imageWidth
    local scaleY = windowHeight / imageHeight

    love.graphics.draw(background, 0, 0, 0, scaleX, scaleY)



    -- Dibujar jugador
    love.graphics.draw(player.img, player.x, player.y)

    -- Dibujar balas del jugador
    for _, bullet in ipairs(bullets) do
        love.graphics.draw(bulletImg, bullet.x, bullet.y)
    end

    -- Dibujar enemigos y sus balas
    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemyImg, enemy.x, enemy.y)

        -- Dibujar balas del enemigo
        for _, bullet in ipairs(bullets) do
            if bullet.isEnemyBullet then
                love.graphics.draw(enemyBulletImg, bullet.x, bullet.y)
            end
        end
    end
end
