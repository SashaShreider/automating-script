-- Настройки
Settings:set("MinSimilarity", 0.6)
setImmersiveMode(true)
--------- Картинки -------------
kirk = "kirk.png"
additional_slimes = {"veinley.png"}
mini_games = "mini-games.png"
grind_in = "grind-in.png"
grind_out = "grind-out.png"
mini_games_out = "mini-games-out.png"
-- Счетчики
wave_count = 0
cycle_count = 0
anti_clicker_counter = 0
-- Список ошибок
error_list = {}
-- Время начала работы
start_time = os.time()

slime = "slime1.png"

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
        table.insert(error_list, "[" .. wave_count+1  .. "] : " ..  imgPath)
    end

    return false
end

--Основной цикл
function grinding()
    setDragDropTiming(20, 4)
    setDragDropStepInterval(90)
    if exists(kirk) then
        spots = findAll(kirk, 0.6)
        for i, spot in pairs(spots) do
            --print(spot)
            l1 = Location(spot:getX() + 50, spot:getY())
            r = Region(spot:getX() , spot:getY(),2,2):highlight()
            l1 = Location(spot.x-50, spot.y+15)
            l2 = Location(spot.x-50, spot.y+250)
            dragDrop(l1, l2)
        end
    end
    for i, slime in pairs(additional_slimes) do
        if exists(slime) then
            l2 = Pattern(slime):targetOffset(0, 200)
            dragDrop(find(slime), find(l2))
        end
    end
end

function autoGrind()
    while true do
        grinding()
        wait(30)
    end
end

autoGrind()
