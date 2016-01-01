local r=require("robot")
local component=require("component")
local c=require("computer")
local g = component.generator
local ic = component.inventory_controller
local nStart=4
local greeting = "Тебя приветствует Копатель для Братишки (КДБ)\n\nОтвечай на мой ответ:"
local gFuel =("minecraft:coal")
local tDumpster ={
"minecraft:cobblestone",
"minecraft:dirt",
"minecraft:gravel",
"chisel:granite",
"chisel:limestone",
"chisel:andesite",
"chisel:diorite"
                 }
print(greeting)
print("\nСколько хуячить в ДАЛЬ?")
local xLength=io.read()
print("\nА сколько хуячить в ШЫРЬ?")
local yLength=io.read()
print("\nА в ГЛУБИНОШКУ?")
local zDepth=io.read()
local dLayer=1
print("\nЩа все заебеню!")

if component.isAvailable("chunkloader")
    then
    component.chunkloader.setActive(true)
end
-- Добыча 1 столба
local function prey()
while not r.forward() do r.swing() os.sleep(0,5) end
while r.swingUp() do os.sleep(0,5) end
r.swingDown()
end
-- Спуск на заданную глубину
local function preyDown(dLL)
for dLLL=1,dLL do
while not r.down() do r.swingDown() end
end
end
-- Добыча 1 траншеи
local function trench(ll)
for lll=1,ll do
prey() 
-- while r.durability()*1000000<100 do os.sleep(180) end 
end
end
-- Перемещение на заданное расстояние
local function moveLine(ll)
while ll>1 do while not r.forward() do r.swing() os.sleep(0,5) end ll=ll-1 end
end
-- 1 слот - кирка
local nKir=1
-- 2 слот - топливо
local nFue=2
-- 3 слот - сундуки
local nChe=3
local function goForward()
while not r.forward() do r.swing() os.sleep(0,5) end
r.suck()
return true
end
local function goUp()
while not r.up() do r.swingUp() end
end
local function goDown()
while not r.down() do r.swingDown() end
end
local function goBack()
if not r.back() then r.turnAround() goForward() r.turnAround() end
end
local function doPlace(nSlot)
r.select(nSlot)
while not r.place() do r.select(nStart) goForward() goBack() r.select(nSlot) end
r.select(nStart)
end

-- Проверка на мусор
local function dumpster(sNN)
local log=false
local i,j=1,#tDumpster
repeat 
if sNN==tDumpster[i] then log=true end
i=i+1
until log or i>j 
return log
end

-- Выгрузка инвентаря в указанную сторону. Если нет сундука, то выброс мусора и уплотнение. 
-- Слоты до указанного не трогаются.
local function drop()
  if ic.getInventorySize(3) ~= nil then
    for i = r.inventorySize(), nStart, -1 do
    r.select(i)
	while r.count()>0 do r.drop() end
	end
  else
	local i,j=nStart, r.inventorySize()
    while i ~= j do
    r.select(j)
    local t = ic.getStackInInternalSlot(j)
    if t ~= nil then 
	local sN = t.name
	  if dumpster(sN)	then r.drop() j=j-1
	  else r.transferTo(i) i=i+1
      end
	else
	  j=j-1
	end
    end
  end
end

-- Проверка на наличие угля
local function fueler(sNN)
local log=false
--local #gFuel
--repeat 
if sNN==gFuel then log=true end
--until log or i>j 
return log
end

-- Загрузка угля в слот nFue
local function refuel()
	local i,j=nStart, r.inventorySize()
    while i ~= j do
    r.select(j)
    local t = ic.getStackInInternalSlot(j)
    if t ~= nil then 
	local sN = t.name
	  if fueler(sN) then r.transferTo(nFue) j=j-1
	  else r.transferTo(i) i=i+1
      end
	else
	  j=j-1
	end
    end
end

local function zaryad()
refuel() r.select(nFue) g.insert(8) r.select(nStart) drop()
end

local function servicing()
-- Если инвентарь заполнился, то выброс мусора. 
-- Свободного места до переполнения, должно хватить от проверки до проверки. Оставляем 5 слотов.
-- Для добычи в ваниле, можно оставить 2.
local robEn=c.energy()/c.maxEnergy()
-- Если разрядился робот, бур или заполнился инвентарь, то проводим обслуживание.
if (r.count(r.inventorySize()-3)>0) or (robEn<0.5) then zaryad() end
end

-- Тело программы
-- Текущая глубина копания
local zD=zDepth
-- Текущая толщина слоя копания
local dL=dLayer
repeat
--print(zD,dL)  
xL=xLength
yL=yLength-1
repeat
trench(xL)
xL=xL-1
servicing()
r.turnRight()
trench(yL)
yL=yL-1
servicing()
r.turnRight()
until xL<1 or yL<0
-- Очищаемся от мусора перед возвратом в исходную позицию.
-- drop()
-- Вычисление длины "обратного" хода
local xyBack=math.ceil((math.min(xLength, yLength)-1)/2)+1
if math.min(xLength, yLength)%2 == 0 then
yBack=xyBack
xBack=yBack
else
r.turnAround()
if xLength-yLength<=0 then
yBack=yLength-xyBack+1
xBack=xyBack+1
else
xBack=xLength-xyBack+2
yBack=xyBack
end
end
r.turnLeft()
moveLine(yBack)
r.turnLeft()
moveLine(xBack)
r.turnAround()

zD=zD-dL
dL=math.min(zD,dL)
preyDown(dL)
until dL<1
for k=1,zDepth do goUp() end
zaryad()
print("Дело сделано!")
