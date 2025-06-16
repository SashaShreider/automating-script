-- Настройки
Settings:set("MinSimilarity", 0.6)
-- Картинки
reward_chest = "reward-chest.png"
get_chest_reward = "get-reward-chest.png"
start = "start.png"
start2 = "start2.png"
settings = "settings.png"
sleep = "sleep.png"
win = "win.png"
defeat = "defeat.png"
fight = "fight.png"
fight_points = "fight-points.png"
end_slime = "end-slime.png"
end_game = "end-game.png"
anti_clicker = "anti-clicker.png"
brown_chest = "brown-chest.png"
anti_clicker_reward = "anti-clicker-reward.png"
-- Счетчики
wave_count = 0
wave_error_count = 0
cycle_count = 0
anti_clicker_counter = 0
-- Список ошибок
error_list = {}
-- Время начала работы
start_time = os.time()

-- Опциональный тап на изображение (т.е. если не нашел кнопку - ниче страшного)
-- timeout - время для проги на подумать
-- возвращаем статус true (логическая переменная), если кнопка нажата
function tapButton(imgPath, IsLog, timeout)
    timeout = timeout or 3
    IsLog = (IsLog == nil) and true or IsLog  -- Если IsLog не передан, то true
    -- если кнопка найдена
    if exists(imgPath, timeout) then
        click(imgPath)

        return true
    end
    -- Логируем ошибку только если IsLog == true
    if IsLog then
        table.insert(error_list, "[" .. wave_error_count .. "] : " .. imgPath)
    end

    return false
end

-- "Просыпание"
function wakeUp()
    local startTime = os.time() -- Запоминаем время начала выполнения
    local targetRegion = Region(200, 700, 700, 400) --  регион поиска надписи завершения
    found = false
    -- ждем конца раунда
    while true do
        if os.time() - startTime > 1500 then
            table.insert(error_list,"[" .. wave_count  .. "." ..  wave_error_count .. "] : " ..  "25+ мин ожидания")
            break -- Выходим из цикла принудительно
        end
        -- ищем победу или поражение
        if targetRegion:exists(win) or targetRegion:exists(defeat) then
            if not (targetRegion:exists(fight) and targetRegion:exists(fight_points)) then
                found = true
                break
            end
        end
        wait(5)
    end

    if found then
        --находим кнопочку слайма в дремоте
        local xy_slime = find(end_slime)
        -- перетаскиваем её вправо на 1000
        local r1 = Region(xy_slime.x + 100, xy_slime.y + 100, 5, 5)
        local r2 = Region(xy_slime.x + 1100, xy_slime.y + 100, 5, 5)
        setDragDropStepInterval(100)
        dragDrop(r1, r2)

    end
end

-- Прохождение антикликера (Поиск сокровищ)
function antiClickerPass()
    -- ищем диалоговое окно с сундучками
    if exists(anti_clicker) then
        anti_clicker_counter = anti_clicker_counter + 1
        -- print("Появился анти-кликер")
        -- находим все сундучки
        local spots = findAll(brown_chest, 0.8)

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
        tapButton(anti_clicker_reward)
    end
end

-- Вывод инфы
function printMessage ()
    os.execute("cls")
    print("--- Пройденных волн: " .. wave_count .. " ---")
    print("Время работы: " ..  os.date("!%X",os.time()-start_time))
    print("Антикликеры: " .. anti_clicker_counter)

    print("Ошибки:")
    for index, value in ipairs(error_list) do
        print(value) -- Выводим в консоль ошибку
    end
    print()
end

--Основной цикл
function App()
    while true or (cycle_count - wave_count > 5)do
        wave_error_count = 0

        --сбор наград с сундука, если он появился
        tapButton(reward_chest, false)
        tapButton(get_chest_reward, false)

        -- кнопки старт два раза
        tapButton(start)
        tapButton(start2)
        -- заходим в настройки
        tapButton(settings)
        -- включаем дремоту
        tapButton(sleep)
        -- выходим из сна
        wakeUp()
        -- собираем награды
        if tapButton(end_game, true, 6) then
            wave_count = wave_count + 1
            wait(3)
        end
        -- собираем сундучки, если есть
        antiClickerPass()
        cycle_count = cycle_count + 1
        -- выводим инфу
        printMessage()
    end
    print("Ошибка: Количество сброшенных циклов больше 5")
end

App()