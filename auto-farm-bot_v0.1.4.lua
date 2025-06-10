-- Настройки
Settings:set("MinSimilarity", 0.6)

local reward_chest = "reward-chest.png"
local get_chest_reward = "get-reward-chest.png"
local start = "start.png"
local start2 = "start2.png"
local settings = "settings.png"
local sleep = "sleep.png"
local win = "win.png"
local defeat = "defeat.png"
local fight = "fight.png"
local end_slime = "end-slime.png"
local end_game = "end-game.png"
local anti_clicker = "anti-clicker.png"
local brown_chest = "brown-chest.png"
local anti_clicker_reward = "anti-clicker-reward.png"

-- Тап по изображению обязательный
function tapButton(imgPath, timeout)
    -- вызываем опциональный тап, но если кнопка не была нажата выбрасываем ошибку
    if not tapOptionalButton(imgPath, timeout) then
        error("!!! ОБРАТИ ВНИМАНИЕ!!!! кнопка {" .. imgPath .. "} не найдена на экране")
    end
end

-- опциональный тап на изображение (т.е. если не нашел кнопку - ниче страшного)
-- timeout - время для проги на подумать
-- возвращаем статус true (логическая переменная), если кнопка нажата
function tapOptionalButton(imgPath, timeout)
    timeout = timeout or 3
    -- если кнопка найдена
    if exists(imgPath, timeout) then
        click(imgPath)
        return true
    end
    return false
end


-- конец раунда
function gameEnd(winPath, defeatPath, fightPath, end_slimePath, end_gamePath)
    local found = false
    local targetRegion = Region(200, 700, 700, 400)
    while not found do
        -- ищем победу или поражение
        if targetRegion:exists(winPath) or targetRegion:exists(defeatPath) then
            print("найдена надпись win или борьба")
            -- проверяем, не спутал ли он с Борьбой
            if targetRegion:exists(fightPath) and targetRegion:exists("fight-bor.png") and targetRegion:exists("fight-points.png") then
                print("Упс, это борьба")
            else
                found = true
                wait(1)
                break
            end
        end
        wait(5)
    end

    --находим кнопочку слайма
    local xy_slime = find(end_slimePath)
    --print(xy_slime.x .. " ".. xy_slime.y)
    -- перетаскиваем её вправо на 1000
    local r1 = Region(xy_slime.x + 100, xy_slime.y + 100, 5, 5)
    local r2 = Region(xy_slime.x + 1100, xy_slime.y + 100, 5, 5)
    setDragDropStepInterval(100)
    dragDrop(r1, r2)
    wait(1)
    tapButton(end_gamePath)
end

-- прохождение антикликера (Поиск сокровищ)
function antiClickerPass(antiClickerPath, brownChestPath, anti_clicker_rewardPath)
    -- ищем диалоговое окно с сундучками
    if exists(antiClickerPath) then
        print("Появился анти-кликер")
        -- находим все сундучки
        local spots = findAll(brownChestPath, 0.8)

        -- тут мы проходимся по всем сундучкам
        for i, spot in pairs(spots) do
            -- тут мы отсеиваем все черно-белые сундуки (у них цвет в формате rgb должен совпадать по каждой характеристике (к примеру 175,175,175))
            local r, g, b = getColor(spot)
            -- эта формула для оптимизации - суммарная разница между красным и зеленым + между красным и синим не должна превышать 15
            if not (math.abs(r - g) + math.abs(r - b) <= 15) then
                click(spot)
                wait(0.5)
            end
        end
        --print("Колличество ящиков: " .. #spots)  
        tapOptionalButton(anti_clicker_rewardPath)
    end
end

--Основной цикл
while true do
    --сбор наград с сундука, если он появился
    if tapOptionalButton(reward_chest) then
        tapButton(get_chest_reward)
     end
    -- кнопки старт два раза
    tapButton(start)
    tapButton(start2)
    wait(2)
    -- заходим в настройки
     tapButton(settings)
    -- включаем дремоту
     tapButton(sleep)

    -- выходим из сна
    gameEnd(win, defeat, fight, end_slime, end_game)

    wait(3)
    -- собираем сундучки, если есть
    antiClickerPass(anti_clicker, brown_chest, anti_clicker_reward)

end