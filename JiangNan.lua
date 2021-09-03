local Yingtian =0;
local Suzhou =1;
local sleepTime=1200;

function closeAllApp()
    jobs();
    sleep(1000);
    click(1072,935);
end

-- 选择4 档工作模式
function selectLevel(n)
    local x=-1;
    local y=-1;
    if n==1 then
        x=725;
        y=280
      else if n==2 then
            x = 1270;
            y = 280
          else if n==3 then
                x= 725;
                y=580;
              else if n==4 then
                    x=1270;
                    y=580
                  else
                end
            end
        end
    end
    myClick(x,y);
end

-- 点击后延时
function myClick(x,y)
    click(x,y);
    sleep(sleepTime)
end

-- 拖动后延迟
function mySlid(x1,y1,x2,y2)
    slid(x1,y1,x2,y2,2000);
    sleep(2000);
end

-- 地区名
function clickArea()
    myClick(272,961);
end

-- 开始菜单
function clickStartMenu()
    myClick(117,904);
end

-- 大地图
function clickTotalMap()
    myClick(211,516);
end

-- 基地
function clickFundation()
    myClick(470,514);
end
-- 建筑工作
function jinWork(x,y)

    print("井开始工作,坐标\t x="..x .."\ty="..y);

    myClick(x,y);

    local title = getText(459,119,600,339);
    print(title);
    if string.find(title,"井") then --水井

        selectLevel(1); --1档
        local title2 = getText(865,193,1116,273);
        print(title2);
        if string.find(title2,"直接") then --直接开始
            myClick(1288,255);
        end
      else

        if findBoard() then
            crackBoard();
        end
        toMainPage();
    end
end

-- 识别区域的文字
function getText(x1,y1,x2,y2)
    a,b=ocr(x1,y1,x2,y2);

    if a then
        return a;
      else
        return "";
    end
end

function waitForMainPage()
    while true do
        clearMessage();
        a= getText(20,756,196,940);
        print("wait:"..a);

        -- print(a);
        local ret = string.find(a,"应天");
        if ret then
            -- print("now yingtian");
            break;
        end
        local ret = string.find(a,"苏州");
        if ret then
            -- print("now suzhou");
            break;
        end

        local ret = string.find(a,"杭州");
        if ret then
            -- print("now hangzhou");
            break;
        end

        sleep(1000);
    end

end

function clearMessage()
    text = getText(915,851,1243,937);
    if text then
        if text=="知道了" then
            print("clear 知道了")
            myClick(1086,883);
        end
    end
end

-- 回到主页
function toMainPage()
    while true do

        local text = getText(172,405,256,603);
        print(text);
        if string.find(text,"大") then --大地图
            break;
        end
        clickStartMenu();
    end
    clickStartMenu();
end
-- 获取当前城市
function getCurrentCity()
    -- toast("请保持手机横屏显示");
    toMainPage();
    a= getText(20,756,196,940);
    if(a) then
        -- print(a);
        local ret = string.find(a,"应天");
        if ret then
            print("now yingtian")
            return Yingtian
        end
        local ret = string.find(a,"苏州");
        if ret then
            print("now suzhou");
            return Suzhou;
        end
    end
end



function openBigMap()
    while true do
        local text = getText(172,405,256,603);
        print(text);
        if string.find(text,"大") then --大地图
            break;
        end
        clickStartMenu();
    end
    clickTotalMap();

    text = getText(679,656,812,727);
    if string.find(text,"应天府") then
        return true;
      else
        return false;
    end
end

-- 切换城市
function switchCity(cityIndex)

    city = getCurrentCity();

    if (cityIndex == Yingtian) then
        print("to yingtian");

        if(Yingtian ~= city) then
            openBigMap();
            myClick(743,679); --大地图上应天所在位置

            waitForMainPage();
            clearMessage();
        end



      else if(cityIndex == Suzhou) then
            print("to suzhou");

            if city~=Suzhou then
                openBigMap();
                slid(1134,624,670,168);
                sleep(1000);
                myClick(1526,934);
                sleep(2000);
                waitForMainPage();
                clearMessage();
            end
        end
    end
end

-- 切换到地基模式
function switchFoundationMode()
    while true do

        local text = getText(172,405,256,603);
        print("switchFoundationMode--"..text);
        if string.find(text,"大") then --大地图
            break;
        end
        clickStartMenu();
    end
    -- clickStartMenu();
    clickFundation();
    clickStartMenu();
end

function regionContainText(x1,y1,x2,y2,text)

    local t = getText(x1,y1,x2,y2);
    print("regionContainText begin --"..t);
    if string.find(t,text) then
        return true;
      else
        return false;
    end
end


-- 应天20#采集
function yingtian20Jin()
    while true do
        switchCity(Suzhou);
        switchCity(Yingtian);

        switchFoundationMode();


        mySlid(310,90,1515,757); --滑动时间会影响相对位置

        if regionContainText(142,4,218,75,"闺") then --云锦里
            break;
        end
    end
    clickArea();


    -- 定义四个顶点坐标
    local x1 =545; local y1=647;
    local x2 =x1+608; local y2=y1-300;
    local x3 =x1+608; local y3 =y1+300;
    local x4 =x1+608*2; local y4=y1;

    -- 没有井(路)的坐标
    local nullRow={2,2,3,4,5}
    local nullCol={2,3,3,4,2}

    local unitWidth = (x2-x1)/5;
    local unitHeight = (y1-y2)/5;

    -- print("unitwidth:".. unitWidth.."\t unitHeight:".. unitHeight);

    local x = x1;
    local y = y1;
    for row=1,5,1 do
        local startX = x1 + (row-1)*unitWidth;
        local startY = y1 + (row-1)*unitHeight;
        for col=1,5,1 do
            -- 实现跳过非井类对象
            if (col == nullCol[1] and row == nullRow[1]) or
                (col == nullCol[2] and row == nullRow[2]) or
                (col == nullCol[3] and row == nullRow[3]) or
                (col == nullCol[4] and row == nullRow[4]) or
                (col == nullCol[5] and row == nullRow[5]) then

                print("("..row..","..col..")".. " null object");
              else
                x = startX + (col-1) * unitWidth +40;
                y = startY - (col-1) * unitHeight;
                jinWork(x,y)

            end

        end

    end
end
-- 应天8#采集
function yingtian8Jin()
    while true do
        switchCity(Suzhou);
        switchCity(Yingtian);

        clickStartMenu();
        clickFundation();

        clickStartMenu();

        slid(895,184,2119,843,2000); --滑动时间会影响相对位置
        sleep(2000);
        local areaName = getText(161,0,231,176);
        print("agrea:"..areaName);
        if areaName then
            if string.find(areaName,"云") then --云锦里
                break;
            end
        end
    end
    clickArea();

    -- 定义四个顶点坐标
    local x1 =564; local y1=636;
    local x2 =x1+608; local y2=y1-300;
    local x3 =x1+608; local y3 =y1+300;
    local x4 =x1+608*2; local y4=y1;

    -- 没有井(路)的坐标
    local nullRow={2,2,3,4,5}
    local nullCol={2,3,3,4,2}

    local unitWidth = (x2-x1)/5;
    local unitHeight = (y1-y2)/5;

    -- print("unitwidth:".. unitWidth.."\t unitHeight:".. unitHeight);

    local x = x1;
    local y = y1;
    for row=1,5,1 do
        local startX = x1 + (row-1)*unitWidth;
        local startY = y1 + (row-1)*unitHeight;
        for col=1,5,1 do
            -- 实现跳过非井类对象
            if (col == nullCol[1] and row == nullRow[1]) or
                (col == nullCol[2] and row == nullRow[2]) or
                (col == nullCol[3] and row == nullRow[3]) or
                (col == nullCol[4] and row == nullRow[4]) or
                (col == nullCol[5] and row == nullRow[5]) then

                print("("..row..","..col..")".. " null object");
              else
                x = startX + (col-1) * unitWidth +40;
                y = startY - (col-1) * unitHeight;

                print("x:"..x .."\ty:"..y);

                myClick(x,y);

                local title = getText(459,119,600,339);
                local title3 = getText(946,234,1207,313);
                print(title);
                if string.find(title,"水") then --水井
                    --myClick(1262,581); --45分钟坐标点
                    myClick(728,264); --1分30s坐标

                    local title2 = getText(865,193,1116,273);
                    print(title2);
                    if string.find(title2,"直接") then --直接开始
                        myClick(1288,255);
                    end
                  else
                    toMainPage();
                end
            end

        end

    end
end
-- 应天画室采集
function yingtianHS()
end

function onlySuzhou40Jin()
    -- 定义四个顶点坐标
    local x1 =230; local y1=480;
    local x2 =x1+850; local y2=y1-420;
    local x3 =x1+850; local y3 =y1+420;
    local x4 =x1+850*2; local y4=y1;

    -- 没有井(路)的坐标
    local nullRow={2,2,3,4,4,5,5,6,6}
    local nullCol={3,6,5,2,4,3,6,2,4}

    local unitWidth = (x2-x1)/7;
    local unitHeight = (y1-y2)/7;

    -- print("unitwidth:".. unitWidth.."\t unitHeight:".. unitHeight);

    local x = x1;
    local y = y1;
    for row=1,7,1 do
        local startX = x1 + (row-1)*unitWidth;
        local startY = y1 + (row-1)*unitHeight;
        for col=1,7,1 do
            -- 实现跳过非井类对象
            if (col == nullCol[1] and row == nullRow[1]) or
                (col == nullCol[2] and row == nullRow[2]) or
                (col == nullCol[3] and row == nullRow[3]) or
                (col == nullCol[4] and row == nullRow[4]) or
                (col == nullCol[5] and row == nullRow[5]) or
                (col == nullCol[6] and row == nullRow[6]) or
                (col == nullCol[7] and row == nullRow[7]) or
                (col == nullCol[8] and row == nullRow[8]) or
                (col == nullCol[9] and row == nullRow[9]) then

                print("("..row..","..col..")".. " null object");
              else
                x = startX + (col-1) * unitWidth +40;
                y = startY - (col-1) * unitHeight;
                jinWork(x,y);
            end
        end
    end
end

-- 苏州40#采集(45min)
function suzhou40Jin()
    while true do
        switchCity(Yingtian);
        switchCity(Suzhou);
        switchFoundationMode();
        mySlid(376,93,943,1000); --滑动时间会影响相对位置

        if regionContainText(70,624,139,736,"萝") then --青萝坞
            break;
        end
    end
    clickArea();

    -- 定义四个顶点坐标
    local x1 =230; local y1=480;
    local x2 =x1+850; local y2=y1-420;
    local x3 =x1+850; local y3 =y1+420;
    local x4 =x1+850*2; local y4=y1;

    -- 没有井(路)的坐标
    local nullRow={2,2,3,4,4,5,5,6,6}
    local nullCol={3,6,5,2,4,3,6,2,4}

    local unitWidth = (x2-x1)/7;
    local unitHeight = (y1-y2)/7;

    -- print("unitwidth:".. unitWidth.."\t unitHeight:".. unitHeight);

    local x = x1;
    local y = y1;
    for row=1,7,1 do
        local startX = x1 + (row-1)*unitWidth;
        local startY = y1 + (row-1)*unitHeight;
        for col=1,7,1 do
            -- 实现跳过非井类对象
            if (col == nullCol[1] and row == nullRow[1]) or
                (col == nullCol[2] and row == nullRow[2]) or
                (col == nullCol[3] and row == nullRow[3]) or
                (col == nullCol[4] and row == nullRow[4]) or
                (col == nullCol[5] and row == nullRow[5]) or
                (col == nullCol[6] and row == nullRow[6]) or
                (col == nullCol[7] and row == nullRow[7]) or
                (col == nullCol[8] and row == nullRow[8]) or
                (col == nullCol[9] and row == nullRow[9]) then

                print("("..row..","..col..")".. " null object");
              else
                x = startX + (col-1) * unitWidth +40;
                y = startY - (col-1) * unitHeight;
                jinWork(x,y);
            end
        end
    end
end

function runJiangNan()
    runApp("com.cis.jiangnan.coconut");
    waitForMainPage();
end

function findBoard()
    if regionContainText(891,270,1288,346,"机关术") then
        print("find board!!!!!!!!!!!!!!!!!!");
        return true;
      else
        return false;
    end
end


local param1 = {'#342323-95','[{"a":-0.283,"d":3.475,"id":"1","r":324.0}]',0.85};
local param2 = {'#606051-95','[{"a":0.504,"d":1.733,"id":"1","r":156.0}]',0.85};
local param7 = {'#BCC3BC-95','[{"a":-0.602,"d":3.184,"id":"1","r":156.0},{"a":-0.107,"d":6.575,"id":"2","r":110.0},{"a":0.329,"d":1.478,"id":"3","r":745.0}]',0.85}

local param8 = {'#E1D9D0-95','[{"a":0.061,"d":3.303,"id":"1","r":194.0},{"a":-0.639,"d":1.365,"id":"2","r":117.0},{"a":-0.136,"d":1.782,"id":"3","r":238.0},{"a":-0.124,"d":1.896,"id":"4","r":747.0}]',0.85}
local param5 = {'#2E2E2A-95','[{"a":-0.015,"d":3.181,"id":"1","r":428.0}]',0.85};
local param6 = {'#AEAE9D-95','[{"a":-0.094,"d":2.95,"id":"1","r":107.0}]',0.85};
local param3 = {'#595947-95','[{"a":-0.622,"d":2.177,"id":"1","r":115.0}]',0.85};
local param4 = {'#2A2A2A-95','[{"a":-0.288,"d":2.543,"id":"3","r":249.0}]',0.85}
local param9 = {'#E7DFD3-95','[{"a":-0.448,"d":1.48,"id":"1","r":848.0},{"a":-0.505,"d":2.585,"id":"2","r":608.0},{"a":0.042,"d":1.451,"id":"3","r":295.0},{"a":0.138,"d":2.14,"id":"4","r":125.0}]',0.85}
local param10 = {'#A0B0A8-95','[{"a":-0.004,"d":1.193,"id":"1","r":418.0}]',0.85};
local param11 = {'#CAC6BE-95','[{"a":-0.692,"d":1.646,"id":"1","r":141.0},{"a":0.193,"d":1.496,"id":"2","r":1334.0},{"a":0.674,"d":1.164,"id":"3","r":104.0},{"a":0.703,"d":2.712,"id":"4","r":170.0}]',0.85}
local param12 = {'#B8C0B3-95','[{"a":-0.464,"d":1.479,"id":"1","r":108.0},{"a":0.727,"d":2.369,"id":"2","r":546.0},{"a":-0.159,"d":1.375,"id":"3","r":444.0}]',0.85}

local pictureParam = {
    param1,
    param2,
    param3,
    param4,
    param5,
    param6,
    param7,
    param8,
    param9,
    param10,
    param11,
    param12,
};
function crackBoard()

    local left = 710;
    local right = 1450;
    local top = 445;
    local bottom = 710;

    local unitWidth = (right - left)/6;
    local unitHeight = (bottom- top)/2;

    local moveTimes = 0;

    for i=1,12,1 do

        if (false == findBoard()) then
            return 0;
        end

        local row = 0;
        local col = 0;


        if i<=6 then
            row = 1;
            col = i;
          else
            row =2;
            col = i-6;
        end

        local unitLeft = left + (col-1) *unitWidth;
        local unitRight = unitLeft + unitWidth;
        local unitTop = top + (row -1)*unitHeight;
        local unitBottom = unitTop + unitHeight;

        local centerX =unitLeft + unitWidth/2;
        local centerY =unitTop + unitHeight/2;

        local ret = findShape(pictureParam[i]);
        if ret == nil then
            return 0;
        end

        print("--"..i.."--\t"..ret[1].x.."\t"..ret[1].y);
        local x = ret[1].x;
        local y = ret[1].y;

        if x < left or x> right or y<top or y > bottom then
            print("crackBoard exception 1" );
        end;

        if x < unitLeft or x >unitRight or y <unitTop or y >unitBottom then
            myMove(x, y, centerX, centerY);
            moveTimes = moveTimes +1;
            print("crack-----------------------"..moveTimes.."from:("..x..","..y..") to ("..centerX..","..centerY..")");
        end
    end
end

function myMove(x1,y1,x2,y2)
    paths ={
        { --模拟第一根手指滑动
            {x=math.floor(x1),y=math.floor(y1)}, --将手指移动到屏幕200，200坐标
            {x=math.floor( x2),y= math.floor(y2)}
        }
    }
    gesture(paths,500)
end


-- 程序开始
print("start");


while true do
    switchCity(Yingtian);
    switchCity(Suzhou);
    switchFoundationMode();
    mySlid(376,93,943,1000); --滑动时间会影响相对位置

    if regionContainText(70,624,139,736,"萝") then --青萝坞
        break;
    end
end
clickArea();
while true do
    onlySuzhou40Jin();
end
-- crackBoard();




-- local 结果 =  findShape(param8)
-- for k,v in pairs(结果) do
--     print(v.id); -- 图形id
--     print(v.sim); -- 图形相似度
--     print(v.scale); -- 图形的缩放倍数
--     print(v.x); -- 图形重心 x坐标
--     print(v.y); -- 图形重心 y坐标
-- end

-- crackBoard();



-- while true do
--     -- toMainPage();
--     -- yingtian20Jin();
--     toMainPage();

--     suzhou40Jin();

--     sleep(1000*60*45);
-- end
-- suzhou40Jin();
-- yingtian20Jin();
-- switchCity(Suzhou);
-- switchCity(Yingtian);
-- slid(1567,353,1567-1000,353,2000); --滑动时间会影响相对位置

-- p= catchClick();
-- print(p.x);print(p.y);

-- sleep(5000);
-- p= catchClick();
-- print(p.x);print(p.y);
