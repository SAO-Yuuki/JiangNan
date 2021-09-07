local Yingtian = 0;
local Suzhou =1;
local sleepTime=1500;
local citys ={"应天","苏州","杭州"}

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

    -- print("jinWork x="..x .."\ty="..y);

    myClick(x,y);

    if regionContainText(459,119,600,339,"井") then --水井
        selectLevel(1); --1档
        if regionContainText(865,193,1116,273,"直接") then --直接开始
            myClick(1288,255);
        end
      else
        if findBoard() then
            if false == crackBoard() then
                return false;
            end
        end
        toMainPage();
    end
    return true;
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
    sleep(500);
    local isFindCity =false;
    while true do
        clearMessage();
        a= getText(20,756,196,940);
        for i, v in pairs(citys) do
            if regionContainText(20,756,196,940,v) then
                isFindCity = true;
                break;
            end
        end
        if isFindCity then
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
    local times = 0;
    while true do
        if times >5 then
            print("to mainPage timeout");
            return false;
        end
        if regionContainText(172,405,256,603, "大") then --大地图
            clickStartMenu();
            return true;
        end
        clickStartMenu();
        times = times +1;
    end
end
-- 获取当前城市
function getCurrentCity()
    toMainPage();
    if regionContainText(20,756,196,940,"应天") then
        print("now yingtian");
        return Yingtian;
      else
        if regionContainText(20,756,196,940,"苏州") then
            print("now suzhou");
            return Suzhou;

          else
            print("can not find any city");
            return -1
        end
    end
end



function openBigMap()
    local times =0;
    while true do
        if times >5 then
            print("openBigMap timeout");
        end
        if regionContainText(172,405,256,603,"大") then --大地图
            clickTotalMap();

            if regionContainText(679,656,812,727,"应天") then
                sleep(2000);
                return true;
              else
                print("can not find 应天府 in bigMap");
                return false;
            end

            break;
        end
        clickStartMenu();
        times = times +1;
    end
end

-- 切换城市
function switchCity(cityIndex)
    city = getCurrentCity();
    if (cityIndex == Yingtian) then
        print("to yingtian");
        if(Yingtian ~= city) then
            if false == openBigMap() then

                print("openbigmap return false");
                return false;
            end
            myClick(743,679); --大地图上应天所在位置
            waitForMainPage();
            clearMessage();
        end
      else if(cityIndex == Suzhou) then
            print("to suzhou");

            if city~=Suzhou then
                if false == openBigMap() then

                    print("openbigmap return false");
                    return false;
                end
                slid(1134,624,670,168);
                sleep(1000);
                myClick(1526,934);
                sleep(2000);
                waitForMainPage();
                clearMessage();
            end
        end
    end
    return true;
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
    if string.find(t,text) then
        return true;
      else
        print("can not find text ["..text.."] in ["..t.."]");

        return false;
    end
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
                if false == jinWork(x,y) then
                    return false;
                end

            end
        end
    end
    return true;
end

function runJiangNan()
    runApp("com.cis.jiangnan.coconut");
    waitForMainPage();
end

function findBoard()
    if regionContainText(891,270,1288,346,"机关术") then
        print("find board true");
        return true;
      else
        print("find board false");
        return false;
    end
end


local param1 = {'#515149-95','[{"a":0.005,"d":2.675,"id":"1","r":120.0},{"a":-0.267,"d":1.151,"id":"2","r":317.0}]',0.85}
local param2 = {'#4C4E3B-95','[{"a":0.67,"d":1.208,"id":"1","r":121.0}]',0.85}
local param7 = {'#B2BAB2-95','[{"a":0.249,"d":6.47,"id":"1","r":1227.0}]',0.85}
local param8 = {'#D3CBC3-95','[{"a":-0.346,"d":4.741,"id":"1","r":189.0}]',0.85}
local param5 = {'#E1E16A-95','[{"a":-0.092,"d":7.314,"id":"1","r":116.0}]',0.85}
local param6 = {'#D7CF63-95','[{"a":0.089,"d":3.332,"id":"1","r":104.0},{"a":0.323,"d":2.476,"id":"2","r":382.0},{"a":0.104,"d":3.018,"id":"3","r":127.0}]',0.85}
local param3 = {'#585850-95','[{"a":0.371,"d":3.754,"id":"1","r":193.0}]',0.85}
local param4 = {'#323232-95','[{"a":-0.258,"d":2.009,"id":"1","r":180.0}]',0.85}
local param9 = {'#8C8C84-95','[{"a":-0.695,"d":3.035,"id":"1","r":106.0}]',0.85}
local param10 = {'#C7C7BF-95','[{"a":0.764,"d":1.547,"id":"1","r":175.0},{"a":-0.452,"d":2.797,"id":"2","r":155.0},{"a":-0.085,"d":1.554,"id":"3","r":243.0}]',0.85}
local param11 = {'#987F77-95','[{"a":-0.161,"d":2.378,"id":"1","r":150.0}]',0.85}
local param12 = {'#8D8D85-95','[{"a":0.28,"d":1.665,"id":"1","r":130.0}]',0.85}

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
        repeat
            if (false == findBoard()) then
                return true;
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
                print("can not find board picture");
                break;
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
                print("cracking..................."..moveTimes.."from:("..x..","..y..") to ("..centerX..","..centerY..")");
            end
        until true
    end
    if (true == findBoard()) then
        return false;
    end
end

function myMove(x1,y1,x2,y2)
    paths ={
        { --模拟第一根手指滑动
            {x=math.floor(x1),y=math.floor(y1)}, --将手指移动到屏幕200，200坐标
            {x=math.floor( x2),y= math.floor(y2)}
        }
    }
    gesture(paths,1000)
end

function gotoSuzhouJin()
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
end

function rerunJNan()
    compile("tingzhi:1.0.31")
    关闭APP("com.cis.jiangnan.coconut");
    sleep(5000);
    runApp("com.cis.jiangnan.coconut");
    sleep(50000);
end

function viewPath()

    config = {
        -- 触控轨迹的颜色
        color ="#FD0017";
        --触控轨迹的大小(单位：dp)
        size = 30;
        --触控轨迹的背景色
        bgcolor = "#F00367FD";
    }
    pathTip(config)
end;

function runStart()
    while true do

        rerunJNan();
        gotoSuzhouJin();

        while true do
            if onlySuzhou40Jin() == false then

                break;
            end

        end
    end
end

runStart();
-- gotoSuzhouJin();
-- clickStartMenu();

-- exec("am force-stop com.cis.jiangnan.coconut");


-- a = getAppinfo('com.cis.jiangnan.coconut')
-- print(a.versionCode); -- 版本号
-- print(a.versionName); -- 版本名称
-- print(a.name); -- 应用名称
-- rerunJNan();
-- 程序开始

-- exec("am force-stop com.cis.jiangnan.coconut");


-- local uri = luajava.bind( "www.baidu.com");
-- intent = luajava.newInstance(android.content.Internet)
-- gotoSuzhouJin();
-- while true do
--     onlySuzhou40Jin();
-- end

-- openBigMap();
-- local x =  getText(23,754,193,945);
-- print("txt"..x);
-- local co =   {'#8D8D85-95','[{"a":0.28,"d":1.665,"id":"1","r":130.0}]',0.85}

-- local 结果 = findShape(co)
-- for k,v in pairs(结果) do
--     print(v.id); -- 图形id
--     print(v.sim); -- 图形相似度
--     print(v.scale); -- 图形的缩放倍数
--     print(v.x); -- 图形重心 x坐标
--     print(v.y); -- 图形重心 y坐标
-- end

-- for i=1,12,1 do

--     local co = pictureParam[i];

--     local num=0;

--     local 结果 = findShape(co)
--     for k,v in pairs(结果) do

--         print(i..".................."..num);
--     end
--     num = 0;
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
