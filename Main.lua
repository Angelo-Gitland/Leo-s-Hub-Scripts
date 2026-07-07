local allowedUsers = {
    [3673634114] = "permanent",
    [4256101131] = "permanent",
    [AspringSmellybum2] = "permanent",
    [4321575771] = "permanent",
    [2235731985] = "permanent",
    [10242250083] = "permanent",
    [8081233261] = os.time({
        year = 2026,
        month = 7,
        day = 22,
        hour = 13
    }),
    [7190258814] = os.time({
        year = 2026,
        month = 7,
        day = 22,
        hour = 11
    }),
    [10512592607] = os.time({
        year = 2026,
        month = 7,
        day = 22,
        hour = 3
    }),
    [2630870376] = os.time({
        year = 2026,
        month = 7,
        day = 22,
        hour = 14
    }),
    [9622514065] = os.time({
        year = 2026,
        month = 7,
        day = 6,
        hour = 15
    }),
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local isAllowed = false

if allowedUsers[localPlayer.UserId] then
    local exp = allowedUsers[localPlayer.UserId]
    if exp == "permanent" or os.time() < exp then
        isAllowed = true
    end
end

if not isAllowed then
    localPlayer:Kick("Not whitelisted for Premium Hub")
    return
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera
local trackEnabled = false
local teamCheckEnabled = true
local trackDropOpen = false
local hopDropOpen = false
local tSettingsOn = false
local hSettingsOn = false
local guiLocked = false
local minimized = false
local hubVisible = true
local hopEnabled = false
local debounce = false
local WALL_DIST = 1
local FLICK_ANGLE = 35
local controlMode = "jump"
local jumpOnFlick = false
local infJump = false
local pcMode = false
local flickKey = Enum.KeyCode.F
local listeningForKey = nil
local backOn = false
local trigOn = false
local backExpanded = false
local trigExpanded = false
local jumpExpanded = false
local flickExpanded = false
local tSettings = { stopDistance=0.5, backDistance=5, triggerTime=2.5 }
local saveFile = "leoshub_v22.json"

local function save()
    pcall(function()
        writefile(saveFile, game:GetService("HttpService"):JSONEncode(tSettings))
    end)
end

local function load()
    pcall(function()
        if isfile and isfile(saveFile) then
            local d = game:GetService("HttpService"):JSONDecode(readfile(saveFile))
            for k,v in pairs(d) do
                if tSettings[k]~=nil then tSettings[k]=v end
            end
        end
    end)
end
load()

local ARROW_DOWN = "rbxassetid://98764963621439"
local ARROW_UP = "rbxassetid://89282378235317"
local GREEN_BG = Color3.fromRGB(18,66,36)
local GREEN_TC = Color3.fromRGB(172,222,192)
local RED_BG = Color3.fromRGB(66,18,18)
local RED_TC = Color3.fromRGB(228,158,158)
local OFF_BG = Color3.fromRGB(19,19,30)
local OFF_TC = Color3.fromRGB(132,132,152)
local ON_BG = Color3.fromRGB(42,125,68)
local ON_TC = Color3.fromRGB(255,255,255)
local DARK_BG = Color3.fromRGB(42,22,22)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeosHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local MAIN_W = 230
local DRAG_H = 30
local SEP_H = 1
local LABEL_H = 12
local ROW_H = 26
local GAP = 4
local PAD = 6
local ARROW_W = 30
local ITEM_H = 24
local ITEM_G = 4
local HDR_H = 18
local HEAD_H = ROW_H + 4

local function mkC(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end

local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0,62,0,62)
iconBtn.Position = UDim2.new(0,14,0.5,60)
iconBtn.BackgroundTransparency = 1
iconBtn.BorderSizePixel = 0
iconBtn.AutoButtonColor = false
iconBtn.Image = "rbxassetid://139836959126766"
iconBtn.ZIndex = 20
iconBtn.Active = true
iconBtn.Parent = screenGui
mkC(31,iconBtn)

local iDrag,iDragStart,iStartPos,iMoved = false,nil,nil,false
iconBtn.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        iDrag=true; iDragStart=input.Position; iStartPos=iconBtn.Position; iMoved=false
    end
end)
iconBtn.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        iDrag=false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not iDrag then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
    local d=input.Position-iDragStart
    if d.Magnitude>5 then iMoved=true end
    iconBtn.Position=UDim2.new(iStartPos.X.Scale,iStartPos.X.Offset+d.X, iStartPos.Y.Scale,iStartPos.Y.Offset+d.Y)
end)
iconBtn.MouseButton1Click:Connect(function()
    if iMoved then iMoved=false; return end
    hubVisible=not hubVisible
    local mf=screenGui:FindFirstChild("MainHub")
    if mf then mf.Visible=hubVisible end
end)

local flickFrame = Instance.new("Frame")
flickFrame.Size = UDim2.new(0,80,0,36)
flickFrame.Position = UDim2.new(0.5,-40,0.8,0)
flickFrame.BackgroundColor3 = Color3.fromRGB(44,44,148)
flickFrame.BorderSizePixel = 0; flickFrame.ZIndex = 10
flickFrame.Visible = false; flickFrame.Active = true
flickFrame.Parent = screenGui
mkC(10,flickFrame)

local flickBtnMain = Instance.new("TextButton")
flickBtnMain.Size = UDim2.new(1,-22,1,0)
flickBtnMain.BackgroundTransparency = 1
flickBtnMain.TextColor3 = Color3.fromRGB(255,255,255)
flickBtnMain.Text = "FLICK"; flickBtnMain.Font = Enum.Font.GothamBold
flickBtnMain.TextSize = 13; flickBtnMain.BorderSizePixel = 0
flickBtnMain.ZIndex = 11; flickBtnMain.Parent = flickFrame

local flickPinBtn = Instance.new("ImageButton")
flickPinBtn.Size = UDim2.new(0,14,0,14)
flickPinBtn.Position = UDim2.new(1,-18,0.5,-7)
flickPinBtn.BackgroundTransparency = 1
flickPinBtn.Image = "rbxassetid://120978111007514"
flickPinBtn.ImageColor3 = Color3.fromRGB(138,138,158)
flickPinBtn.BorderSizePixel = 0; flickPinBtn.ZIndex = 12
flickPinBtn.Parent = flickFrame

local flickLockBtn = Instance.new("ImageButton")
flickLockBtn.Size = UDim2.new(0,14,0,14)
flickLockBtn.Position = UDim2.new(1,-18,0.5,-7)
flickLockBtn.BackgroundTransparency = 1
flickLockBtn.Image = "rbxassetid://78672912777756"
flickLockBtn.ImageColor3 = Color3.fromRGB(252,185,42)
flickLockBtn.BorderSizePixel = 0; flickLockBtn.ZIndex = 12
flickLockBtn.Visible = false; flickLockBtn.Parent = flickFrame

local flickPinned = false
flickPinBtn.MouseButton1Click:Connect(function()
    flickPinned=true; flickPinBtn.Visible=false; flickLockBtn.Visible=true
end)
flickLockBtn.MouseButton1Click:Connect(function()
    flickPinned=false; flickLockBtn.Visible=false; flickPinBtn.Visible=true
end)

local ffDrag,ffDragStart,ffStartPos,ffMoved = false,nil,nil,false
local function ffBegan(input)
    if flickPinned then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        ffDrag=true; ffDragStart=input.Position; ffStartPos=flickFrame.Position; ffMoved=false
    end
end
local function ffEnded(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        ffDrag=false
    end
end
flickFrame.InputBegan:Connect(ffBegan)
flickFrame.InputEnded:Connect(ffEnded)
flickBtnMain.InputBegan:Connect(ffBegan)
flickBtnMain.InputEnded:Connect(ffEnded)
UserInputService.InputChanged:Connect(function(input)
    if not ffDrag then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
    local d=input.Position-ffDragStart
    if d.Magnitude>2 then ffMoved=true end
    flickFrame.Position=UDim2.new(ffStartPos.X.Scale,ffStartPos.X.Offset+d.X, ffStartPos.Y.Scale,ffStartPos.Y.Offset+d.Y)
end)

local TRACK_LABEL_Y = DRAG_H + SEP_H
local TRACK_ROW_Y = TRACK_LABEL_Y + LABEL_H
local TRACK_BTM = TRACK_ROW_Y + ROW_H
local HOP_LABEL_Y = TRACK_BTM + GAP
local HOP_ROW_Y = HOP_LABEL_Y + LABEL_H
local HOP_BTM = HOP_ROW_Y + ROW_H
local HEAD_LABEL_Y = HOP_BTM + GAP
local HEAD_ROW_Y = HEAD_LABEL_Y + LABEL_H
local HEAD_BTM = HEAD_ROW_Y + HEAD_H
local BASE_H = HEAD_BTM + PAD

local main = Instance.new("Frame")
main.Name = "MainHub"
main.Size = UDim2.new(0,MAIN_W,0,BASE_H)
main.Position = UDim2.new(0,30,0.4,0)
main.BackgroundColor3 = Color3.fromRGB(13,13,19)
main.BorderSizePixel = 0; main.Active = true
main.ClipsDescendants = true; main.ZIndex = 3
main.Parent = screenGui
mkC(10,main)

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1,0,0,DRAG_H)
dragBar.BackgroundColor3 = Color3.fromRGB(9,9,14)
dragBar.BorderSizePixel = 0; dragBar.Active = true
dragBar.ZIndex = 4; dragBar.Parent = main; mkC(10,dragBar)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0,75,1,0); titleLbl.Position = UDim2.new(0,10,0,0)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "Leo's Hub"
titleLbl.TextColor3 = Color3.fromRGB(168,168,192); titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 12; titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 5; titleLbl.Parent = dragBar

local function hIcon(img,xOff,col)
    local b = Instance.new("ImageButton")
    b.Size=UDim2.new(0,13,0,13); b.Position=UDim2.new(1,xOff,0.5,-6)
    b.BackgroundTransparency=1; b.Image=img
    b.ImageColor3=col or Color3.fromRGB(138,138,158)
    b.BorderSizePixel=0; b.ZIndex=5; b.Parent=dragBar; return b
end

local closeBtn = hIcon("rbxassetid://110786993356448",-15,Color3.fromRGB(205,48,48))
local minBtn = hIcon("rbxassetid://116269596042539",-32)
local pinBtn = hIcon("rbxassetid://120978111007514",-49)
local lockBtn = hIcon("rbxassetid://78672912777756", -49,Color3.fromRGB(252,185,42))
lockBtn.Visible = false

local sep = Instance.new("Frame")
sep.Size=UDim2.new(1,0,0,SEP_H); sep.Position=UDim2.new(0,0,0,DRAG_H)
sep.BackgroundColor3=Color3.fromRGB(20,20,32); sep.BorderSizePixel=0
sep.ZIndex=4; sep.Parent=main

local function splitRow(yPos, text)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1,-10,0,ROW_H)
    wrap.Position = UDim2.new(0,5,0,yPos)
    wrap.BackgroundColor3 = OFF_BG; wrap.BorderSizePixel = 0
    wrap.ZIndex = 4; wrap.ClipsDescendants = true; wrap.Parent = main
    mkC(6,wrap)

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(1,-ARROW_W-1,1,0)
    tog.BackgroundTransparency = 1; tog.TextColor3 = OFF_TC; tog.Text = text
    tog.Font = Enum.Font.GothamBold; tog.TextSize = 12
    tog.BorderSizePixel = 0; tog.ZIndex = 5; tog.Parent = wrap

    local divL = Instance.new("Frame")
    divL.Size = UDim2.new(0,1,1,0); divL.Position = UDim2.new(1,-ARROW_W-1,0,0)
    divL.BackgroundColor3 = Color3.fromRGB(44,44,62)
    divL.BorderSizePixel = 0; divL.ZIndex = 5; divL.Parent = wrap

    local arrBtn = Instance.new("TextButton")
    arrBtn.Size = UDim2.new(0,ARROW_W,1,0); arrBtn.Position = UDim2.new(1,-ARROW_W,0,0)
    arrBtn.BackgroundTransparency = 1; arrBtn.Text = ""
    arrBtn.BorderSizePixel = 0; arrBtn.ZIndex = 5; arrBtn.Parent = wrap

    local arrImg = Instance.new("ImageLabel")
    arrImg.Size = UDim2.new(0,13,0,13); arrImg.Position = UDim2.new(0.5,-6,0.5,-6)
    arrImg.BackgroundTransparency = 1; arrImg.Image = ARROW_DOWN
    arrImg.ImageColor3 = Color3.fromRGB(105,105,128)
    arrImg.ZIndex = 6; arrImg.Parent = arrBtn

    return wrap, tog, arrBtn, arrImg, divL
end

local function rowLbl(text, yPos)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-10,0,LABEL_H); l.Position = UDim2.new(0,8,0,yPos)
    l.BackgroundTransparency = 1; l.Text = text
    l.TextColor3 = Color3.fromRGB(68,68,90)
    l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 4; l.Parent = main; return l
end

local function headJumpRow(yPos)
    local hjW = Instance.new("Frame")
    hjW.Size = UDim2.new(0.5,-8,0,HEAD_H); hjW.Position = UDim2.new(0,5,0,yPos)
    hjW.BackgroundColor3 = OFF_BG; hjW.BorderSizePixel = 0
    hjW.ZIndex = 4; hjW.ClipsDescendants = true; hjW.Parent = main
    mkC(6,hjW)

    local hjTog = Instance.new("TextButton")
    hjTog.Size = UDim2.new(1,-ARROW_W,1,0); hjTog.BackgroundTransparency = 1
    hjTog.TextColor3 = OFF_TC; hjTog.Text = "Head Jump"
    hjTog.Font = Enum.Font.GothamBold; hjTog.TextSize = 12
    hjTog.BorderSizePixel = 0; hjTog.ZIndex = 5; hjTog.Parent = hjW

    local hjArr = Instance.new("TextButton")
    hjArr.Size = UDim2.new(0,ARROW_W,1,0); hjArr.Position = UDim2.new(1,-ARROW_W,0,0)
    hjArr.BackgroundTransparency = 1; hjArr.Text = ""
    hjArr.BorderSizePixel = 0; hjArr.ZIndex = 5; hjArr.Parent = hjW

    local hjArrImg = Instance.new("ImageLabel")
    hjArrImg.Size = UDim2.new(0,13,0,13); hjArrImg.Position = UDim2.new(0.5,-6,0.5,-6)
    hjArrImg.BackgroundTransparency = 1; hjArrImg.Image = ARROW_DOWN
    hjArrImg.ImageColor3 = Color3.fromRGB(105,105,128)
    hjArrImg.ZIndex = 6; hjArrImg.Parent = hjArr

    local vline = Instance.new("Frame")
    vline.Size = UDim2.new(0,1,0,HEAD_H); vline.Position = UDim2.new(0.5,-1,0,yPos)
    vline.BackgroundColor3 = Color3.fromRGB(44,44,62)
    vline.BorderSizePixel = 0; vline.ZIndex = 4; vline.Parent = main

    local hfW = Instance.new("Frame")
    hfW.Size = UDim2.new(0.5,-8,0,HEAD_H); hfW.Position = UDim2.new(0.5,3,0,yPos)
    hfW.BackgroundColor3 = OFF_BG; hfW.BorderSizePixel = 0
    hfW.ZIndex = 4; hfW.ClipsDescendants = true; hfW.Parent = main
    mkC(6,hfW)

    local hfTog = Instance.new("TextButton")
    hfTog.Size = UDim2.new(1,-ARROW_W,1,0); hfTog.BackgroundTransparency = 1
    hfTog.TextColor3 = OFF_TC; hfTog.Text = "Head Follow"
    hfTog.Font = Enum.Font.GothamBold; hfTog.TextSize = 12
    hfTog.BorderSizePixel = 0; hfTog.ZIndex = 5; hfTog.Parent = hfW

    local hfArr = Instance.new("TextButton")
    hfArr.Size = UDim2.new(0,ARROW_W,1,0); hfArr.Position = UDim2.new(1,-ARROW_W,0,0)
    hfArr.BackgroundTransparency = 1; hfArr.Text = ""
    hfArr.BorderSizePixel = 0; hfArr.ZIndex = 5; hfArr.Parent = hfW

    local hfArrImg = Instance.new("ImageLabel")
    hfArrImg.Size = UDim2.new(0,13,0,13); hfArrImg.Position = UDim2.new(0.5,-6,0.5,-6)
    hfArrImg.BackgroundTransparency = 1; hfArrImg.Image = ARROW_DOWN
    hfArrImg.ImageColor3 = Color3.fromRGB(105,105,128)
    hfArrImg.ZIndex = 6; hfArrImg.Parent = hfArr

    return hjW,hjTog,hjArr,hjArrImg, hfW,hfTog,hfArr,hfArrImg, vline
end

local tWrap,tTog,tArrBtn,tArrImg,tDivLine = splitRow(TRACK_ROW_Y,"Auto Track")
local tLbl = rowLbl("Auto Track",TRACK_LABEL_Y)
local hWrap,hTog,hArrBtn,hArrImg,hDivLine = splitRow(HOP_ROW_Y,"Auto Wallhop")
local hLbl = rowLbl("Auto Wallhop",HOP_LABEL_Y)
local hjWrapL,hjTog,hjArrBtn,hjArrImg, hfWrapR,hfTog,hfArrBtn,hfArrImg,vDivLine = headJumpRow(HEAD_ROW_Y)
local hdLbl = rowLbl("Head Jumping",HEAD_LABEL_Y)

local tDropItems,hDropItems,hjDropItems,hfDropItems,tSubItems,hSubItems = {},{},{},{},{},{}
local hjDropOpen,hfDropOpen = false,false

local function makeItem(h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-10,0,h); f.BackgroundTransparency = 1
    f.BorderSizePixel = 0; f.ZIndex = 4; f.Visible = false; f.Parent = main
    return f
end

local function makeHalfItem(h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.5,-8,0,h); f.BackgroundTransparency = 1
    f.BorderSizePixel = 0; f.ZIndex = 4; f.Visible = false; f.Parent = main
    return f
end

local function iBtn(text,bg,tc,parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundColor3 = bg or OFF_BG; b.TextColor3 = tc or OFF_TC
    b.Text = text; b.Font = Enum.Font.GothamBold; b.TextSize = 11
    b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = parent
    mkC(5,b); return b
end

local function iSectionHeader(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,LABEL_H); lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(108,108,132); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = parent
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,0,LABEL_H+2)
    line.BackgroundColor3 = Color3.fromRGB(44,44,62)
    line.BorderSizePixel = 0; line.ZIndex = 5; line.Parent = parent
end

local function iSettBtn(parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0); b.BackgroundColor3 = Color3.fromRGB(17,17,25)
    b.TextColor3 = Color3.fromRGB(105,105,128); b.Text = "Settings: OFF"
    b.Font = Enum.Font.GothamBold; b.TextSize = 11
    b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = parent; mkC(5,b)
    local gear = Instance.new("ImageLabel")
    gear.Size = UDim2.new(0,13,0,13); gear.Position = UDim2.new(1,-18,0.5,-6)
    gear.BackgroundTransparency = 1; gear.Image = "rbxassetid://80758916183665"
    gear.ImageColor3 = Color3.fromRGB(100,100,122)
    gear.BorderSizePixel = 0; gear.ZIndex = 6; gear.Parent = b
    return b, gear
end

local function iDiv(parent)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(24,24,36)
    f.BorderSizePixel = 0; f.ZIndex = 5; f.Parent = parent
end

local function iStepper(lText, key, step, minV, maxV, parent)
    local row = Instance.new("Frame"); row.Size = UDim2.new(1,0,1,0)
    row.BackgroundColor3 = Color3.fromRGB(14,14,22)
    row.BorderSizePixel = 0; row.ZIndex = 5; row.Parent = parent; mkC(5,row)
    local ll = Instance.new("TextLabel"); ll.Size = UDim2.new(0,72,1,0)
    ll.Position = UDim2.new(0,6,0,0); ll.BackgroundTransparency = 1; ll.Text = lText
    ll.TextColor3 = Color3.fromRGB(122,122,142); ll.Font = Enum.Font.GothamBold
    ll.TextSize = 10; ll.TextXAlignment = Enum.TextXAlignment.Left; ll.ZIndex = 6; ll.Parent = row
    local minus = Instance.new("TextButton"); minus.Size = UDim2.new(0,16,0,16)
    minus.Position = UDim2.new(1,-80,0.5,-8); minus.BackgroundColor3 = Color3.fromRGB(105,22,22)
    minus.Text = "-"; minus.Font = Enum.Font.GothamBold; minus.TextSize = 13
    minus.TextColor3 = Color3.fromRGB(255,255,255); minus.BorderSizePixel = 0
    minus.ZIndex = 6; minus.Parent = row; mkC(4,minus)
    local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0,34,0,16)
    vl.Position = UDim2.new(1,-60,0.5,-8); vl.BackgroundColor3 = Color3.fromRGB(18,18,28)
    vl.TextColor3 = Color3.fromRGB(192,192,208); vl.Font = Enum.Font.GothamBold; vl.TextSize = 10
    vl.BorderSizePixel = 0; vl.ZIndex = 6; vl.Text = string.format("%.1f",tSettings[key])
    vl.Parent = row; mkC(4,vl)
    local plus = Instance.new("TextButton"); plus.Size = UDim2.new(0,16,0,16)
    plus.Position = UDim2.new(1,-20,0.5,-8); plus.BackgroundColor3 = Color3.fromRGB(15,68,30)
    plus.Text = "+"; plus.Font = Enum.Font.GothamBold; plus.TextSize = 13
    plus.TextColor3 = Color3.fromRGB(255,255,255); plus.BorderSizePixel = 0
    plus.ZIndex = 6; plus.Parent = row; mkC(4,plus)
    minus.MouseButton1Click:Connect(function()
        tSettings[key]=math.max(minV,math.round((tSettings[key]-step)*10)/10)
        vl.Text=string.format("%.1f",tSettings[key]); save()
    end)
    plus.MouseButton1Click:Connect(function()
        tSettings[key]=math.min(maxV,math.round((tSettings[key]+step)*10)/10)
        vl.Text=string.format("%.1f",tSettings[key]); save()
    end)
end

local tHdrF=makeItem(HDR_H); iSectionHeader("Auto Track",tHdrF); table.insert(tDropItems,{f=tHdrF,h=HDR_H})
local teamF=makeItem(ITEM_H); local teamBtn=iBtn("Team Check: ON",GREEN_BG,GREEN_TC,teamF); table.insert(tDropItems,{f=teamF,h=ITEM_H})
local distF=makeItem(ITEM_H); iStepper("Distance","stopDistance",0.5,0.5,2,distF); table.insert(tDropItems,{f=distF,h=ITEM_H})
local tDivF=makeItem(1); iDiv(tDivF); table.insert(tDropItems,{f=tDivF,h=1})
local tSetF=makeItem(ITEM_H); local tSetBtn,tGear=iSettBtn(tSetF); table.insert(tDropItems,{f=tSetF,h=ITEM_H})
local backBtnF=makeItem(ITEM_H); local backBtn=iBtn("Back Away: OFF",DARK_BG,OFF_TC,backBtnF); table.insert(tSubItems,{f=backBtnF,h=ITEM_H,id="back"})
local backStepF=makeItem(ITEM_H); iStepper("Back Dist","backDistance",1,1,20,backStepF); table.insert(tSubItems,{f=backStepF,h=ITEM_H,id="backStep"})
local trigBtnF=makeItem(ITEM_H); local trigBtn=iBtn("Trigger Time: OFF",DARK_BG,OFF_TC,trigBtnF); table.insert(tSubItems,{f=trigBtnF,h=ITEM_H,id="trig"})
local trigStepF=makeItem(ITEM_H); iStepper("Trigger T","triggerTime",0.5,0.5,9.5,trigStepF); table.insert(tSubItems,{f=trigStepF,h=ITEM_H,id="trigStep"})

local hHdrF=makeItem(HDR_H); iSectionHeader("Auto Wallhop",hHdrF); table.insert(hDropItems,{f=hHdrF,h=HDR_H})
local hDivF=makeItem(1); iDiv(hDivF); table.insert(hDropItems,{f=hDivF,h=1})
local hSetF=makeItem(ITEM_H); local hSetBtn,hGear=iSettBtn(hSetF); table.insert(hDropItems,{f=hSetF,h=ITEM_H})
local jumpSecF=makeItem(HDR_H); iSectionHeader("Jump Mode",jumpSecF); table.insert(hSubItems,{f=jumpSecF,h=HDR_H,always=true})
local jumpModeBtnF=makeItem(ITEM_H); local jumpModeBtn=iBtn("Jump Button: ON",GREEN_BG,GREEN_TC,jumpModeBtnF); table.insert(hSubItems,{f=jumpModeBtnF,h=ITEM_H,always=true,id="jumpMode"})
local infJF=makeItem(ITEM_H); local infJumpBtn=iBtn("Inf Jump: OFF",DARK_BG,OFF_TC,infJF); table.insert(hSubItems,{f=infJF,h=ITEM_H,always=false,id="infJ"})
local flickSecF=makeItem(HDR_H); iSectionHeader("Flick Mode",flickSecF); table.insert(hSubItems,{f=flickSecF,h=HDR_H,always=true})
local flickModeBtnF=makeItem(ITEM_H); local flickModeBtn=iBtn("Flick Button: OFF",DARK_BG,OFF_TC,flickModeBtnF); table.insert(hSubItems,{f=flickModeBtnF,h=ITEM_H,always=true,id="flickMode"})
local jofF=makeItem(ITEM_H); local jumpOnFlickBtn=iBtn("Jump On Flick: OFF",DARK_BG,OFF_TC,jofF); table.insert(hSubItems,{f=jofF,h=ITEM_H,always=false,id="jof"})
local pcF=makeItem(ITEM_H); local pcModeBtn=iBtn("PC Mode: OFF",DARK_BG,OFF_TC,pcF); table.insert(hSubItems,{f=pcF,h=ITEM_H,always=false,id="pc"})

local kbF=makeItem(ITEM_H); kbF.BackgroundColor3=Color3.fromRGB(14,14,22); kbF.BackgroundTransparency=0; mkC(5,kbF)
local kbL=Instance.new("TextLabel"); kbL.Size=UDim2.new(0.5,0,1,0); kbL.Position=UDim2.new(0,6,0,0); kbL.BackgroundTransparency=1; kbL.Text="Flick Key"; kbL.TextColor3=Color3.fromRGB(122,122,142); kbL.Font=Enum.Font.GothamBold; kbL.TextSize=10; kbL.TextXAlignment=Enum.TextXAlignment.Left; kbL.ZIndex=5; kbL.Parent=kbF
local fkBtn=Instance.new("TextButton"); fkBtn.Size=UDim2.new(0,48,0,15); fkBtn.Position=UDim2.new(1,-54,0.5,-7); fkBtn.BackgroundColor3=Color3.fromRGB(44,44,148); fkBtn.TextColor3=Color3.fromRGB(255,255,255); fkBtn.Text=flickKey.Name; fkBtn.Font=Enum.Font.GothamBold; fkBtn.TextSize=10; fkBtn.BorderSizePixel=0; fkBtn.ZIndex=5; fkBtn.Parent=kbF; mkC(4,fkBtn)
table.insert(hSubItems,{f=kbF,h=ITEM_H,always=false,id="kb"})

local DEV_H = 28
local hjDevF = makeHalfItem(DEV_H)
local hjDevLbl = Instance.new("TextLabel")
hjDevLbl.Size=UDim2.new(1,0,1,0); hjDevLbl.BackgroundTransparency=1
hjDevLbl.Text="In Development"; hjDevLbl.TextColor3=Color3.fromRGB(148,112,0)
hjDevLbl.Font=Enum.Font.GothamBold; hjDevLbl.TextSize=10
hjDevLbl.TextXAlignment=Enum.TextXAlignment.Center
hjDevLbl.ZIndex=5; hjDevLbl.Parent=hjDevF
table.insert(hjDropItems,{f=hjDevF,h=DEV_H})

local hfDevF = makeHalfItem(DEV_H)
local hfDevLbl = Instance.new("TextLabel")
hfDevLbl.Size=UDim2.new(1,0,1,0); hfDevLbl.BackgroundTransparency=1
hfDevLbl.Text="In Development"; hfDevLbl.TextColor3=Color3.fromRGB(148,112,0)
hfDevLbl.Font=Enum.Font.GothamBold; hfDevLbl.TextSize=10
hfDevLbl.TextXAlignment=Enum.TextXAlignment.Center
hfDevLbl.ZIndex=5; hfDevLbl.Parent=hfDevF
table.insert(hfDropItems,{f=hfDevF,h=DEV_H})

local function layoutAll()
    local y = TRACK_BTM + ITEM_G
    if trackDropOpen then
        for _,item in ipairs(tDropItems) do
            item.f.Position=UDim2.new(0,5,0,y); item.f.Visible=true; y=y+item.h+ITEM_G
        end
        if tSettingsOn then
            for _,item in ipairs(tSubItems) do
                local show=false
                if item.id=="back" or item.id=="trig" then show=true
                elseif item.id=="backStep" then show=backOn and backExpanded
                elseif item.id=="trigStep" then show=trigOn and trigExpanded end
                if show then item.f.Position=UDim2.new(0,5,0,y); item.f.Visible=true; y=y+item.h+ITEM_G
                else item.f.Visible=false end
            end
        else
            for _,item in ipairs(tSubItems) do item.f.Visible=false end
        end
    else
        for _,item in ipairs(tDropItems) do item.f.Visible=false end
        for _,item in ipairs(tSubItems) do item.f.Visible=false end
        y=TRACK_BTM
    end

    local hopLY=y+GAP
    hLbl.Position=UDim2.new(0,8,0,hopLY); hWrap.Position=UDim2.new(0,5,0,hopLY+LABEL_H)
    local hopBtm=hopLY+LABEL_H+ROW_H; y=hopBtm+ITEM_G

    if hopDropOpen then
        for _,item in ipairs(hDropItems) do
            item.f.Position=UDim2.new(0,5,0,y); item.f.Visible=true; y=y+item.h+ITEM_G
        end
        if hSettingsOn then
            for _,item in ipairs(hSubItems) do
                local show=false
                if item.always then show=true
                elseif item.id=="infJ" then show=jumpExpanded
                elseif item.id=="jof" or item.id=="pc" then show=flickExpanded
                elseif item.id=="kb" then show=flickExpanded and pcMode end
                if show then item.f.Position=UDim2.new(0,5,0,y); item.f.Visible=true; y=y+item.h+ITEM_G
                else item.f.Visible=false end
            end
        else
            for _,item in ipairs(hSubItems) do item.f.Visible=false end
        end
    else
        for _,item in ipairs(hDropItems) do item.f.Visible=false end
        for _,item in ipairs(hSubItems) do item.f.Visible=false end
        y=hopBtm
    end

    local hdLY=y+GAP
    hdLbl.Position=UDim2.new(0,8,0,hdLY)
    local hjY=hdLY+LABEL_H
    hjWrapL.Position=UDim2.new(0,5,0,hjY); hjWrapL.Size=UDim2.new(0.5,-8,0,HEAD_H)
    hfWrapR.Position=UDim2.new(0.5,3,0,hjY); hfWrapR.Size=UDim2.new(0.5,-8,0,HEAD_H)
    local headBtm=hjY+HEAD_H

    local hjDropH=0
    if hjDropOpen then
        local iy=headBtm+ITEM_G
        for _,item in ipairs(hjDropItems) do
            item.f.Position=UDim2.new(0,5,0,iy); item.f.Visible=true
            iy=iy+item.h+ITEM_G; hjDropH=hjDropH+item.h+ITEM_G
        end
    else
        for _,item in ipairs(hjDropItems) do item.f.Visible=false end
    end

    local hfDropH=0
    if hfDropOpen then
        local iy=headBtm+ITEM_G
        for _,item in ipairs(hfDropItems) do
            item.f.Position=UDim2.new(0.5,3,0,iy); item.f.Visible=true
            iy=iy+item.h+ITEM_G; hfDropH=hfDropH+item.h+ITEM_G
        end
    else
        for _,item in ipairs(hfDropItems) do item.f.Visible=false end
    end

    local maxDropH=math.max(hjDropH,hfDropH)
    vDivLine.Position=UDim2.new(0.5,-1,0,hjY)
    vDivLine.Size=UDim2.new(0,1,0,HEAD_H+(maxDropH>0 and maxDropH or 0))

    y=headBtm+(maxDropH>0 and maxDropH+ITEM_G or 0)
    TweenService:Create(main,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out), {Size=UDim2.new(0,MAIN_W,0,y+PAD)}):Play()
end
layoutAll()

local function setRowColor(wrap,div,bg,sc)
    wrap.BackgroundColor3=bg
    div.BackgroundColor3=sc
end

local function setTrack(s)
    trackEnabled=s; tTog.TextColor3=s and ON_TC or OFF_TC
    setRowColor(tWrap,tDivLine,s and ON_BG or OFF_BG,s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62))
end

local function setHop(s)
    hopEnabled=s; hTog.TextColor3=s and ON_TC or OFF_TC
    setRowColor(hWrap,hDivLine,s and ON_BG or OFF_BG,s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62))
end

local function setTeam(s)
    teamCheckEnabled=s; teamBtn.Text=s and "Team Check: ON" or "Team Check: OFF"
    teamBtn.BackgroundColor3=s and GREEN_BG or RED_BG; teamBtn.TextColor3=s and GREEN_TC or RED_TC
end

local function rBack()
    backBtn.Text=backOn and "Back Away: ON" or "Back Away: OFF"
    backBtn.BackgroundColor3=backOn and GREEN_BG or DARK_BG; backBtn.TextColor3=backOn and GREEN_TC or OFF_TC
end

local function rTrig()
    trigBtn.Text=trigOn and "Trigger Time: ON" or "Trigger Time: OFF"
    trigBtn.BackgroundColor3=trigOn and GREEN_BG or DARK_BG; trigBtn.TextColor3=trigOn and GREEN_TC or OFF_TC
end

local function setTSettings(s)
    tSettingsOn=s; tSetBtn.Text=s and "Settings: ON" or "Settings: OFF"
    tSetBtn.BackgroundColor3=s and Color3.fromRGB(24,72,42) or Color3.fromRGB(17,17,25)
    tSetBtn.TextColor3=s and GREEN_TC or Color3.fromRGB(105,105,128)
    tGear.ImageColor3=s and Color3.fromRGB(252,185,42) or Color3.fromRGB(100,100,122)
    if not s then backOn=false;trigOn=false;backExpanded=false;trigExpanded=false;rBack();rTrig() end
    layoutAll()
end

local function setHSettings(s)
    hSettingsOn=s; hSetBtn.Text=s and "Settings: ON" or "Settings: OFF"
    hSetBtn.BackgroundColor3=s and Color3.fromRGB(24,72,42) or Color3.fromRGB(17,17,25)
    hSetBtn.TextColor3=s and GREEN_TC or Color3.fromRGB(105,105,128)
    hGear.ImageColor3=s and Color3.fromRGB(252,185,42) or Color3.fromRGB(100,100,122)
    if not s then jumpExpanded=false; flickExpanded=false end; layoutAll()
end

local function uFlickVisible() flickFrame.Visible=(controlMode=="button" and not pcMode) end

local function uJumpMode()
    jumpModeBtn.Text=controlMode=="jump" and "Jump Button: ON" or "Jump Button: OFF"
    jumpModeBtn.BackgroundColor3=controlMode=="jump" and GREEN_BG or DARK_BG
    jumpModeBtn.TextColor3=controlMode=="jump" and GREEN_TC or OFF_TC
end

local function uFlickMode()
    flickModeBtn.Text=controlMode=="button" and "Flick Button: ON" or "Flick Button: OFF"
    flickModeBtn.BackgroundColor3=controlMode=="button" and GREEN_BG or DARK_BG
    flickModeBtn.TextColor3=controlMode=="button" and GREEN_TC or OFF_TC; uFlickVisible()
end

local function uJOF()
    jumpOnFlickBtn.Text=jumpOnFlick and "Jump On Flick: ON" or "Jump On Flick: OFF"
    jumpOnFlickBtn.BackgroundColor3=jumpOnFlick and GREEN_BG or DARK_BG
    jumpOnFlickBtn.TextColor3=jumpOnFlick and GREEN_TC or OFF_TC
end

local function uInfJ()
    infJumpBtn.Text=infJump and "Inf Jump: ON" or "Inf Jump: OFF"
    infJumpBtn.BackgroundColor3=infJump and GREEN_BG or DARK_BG
    infJumpBtn.TextColor3=infJump and GREEN_TC or OFF_TC
end

local function uPc()
    pcModeBtn.Text=pcMode and "PC Mode: ON" or "PC Mode: OFF"
    pcModeBtn.BackgroundColor3=pcMode and GREEN_BG or DARK_BG
    pcModeBtn.TextColor3=pcMode and GREEN_TC or OFF_TC
    uFlickVisible(); layoutAll()
end

uJumpMode(); uFlickMode(); uJOF(); uInfJ(); uPc(); rBack(); rTrig()

tArrBtn.MouseButton1Click:Connect(function()
    trackDropOpen=not trackDropOpen; tArrImg.Image=trackDropOpen and ARROW_UP or ARROW_DOWN; layoutAll()
end)
hArrBtn.MouseButton1Click:Connect(function()
    hopDropOpen=not hopDropOpen; hArrImg.Image=hopDropOpen and ARROW_UP or ARROW_DOWN; layoutAll()
end)
hjArrBtn.MouseButton1Click:Connect(function()
    hjDropOpen=not hjDropOpen; hjArrImg.Image=hjDropOpen and ARROW_UP or ARROW_DOWN; layoutAll()
end)
hfArrBtn.MouseButton1Click:Connect(function()
    hfDropOpen=not hfDropOpen; hfArrImg.Image=hfDropOpen and ARROW_UP or ARROW_DOWN; layoutAll()
end)

tTog.MouseButton1Click:Connect(function() setTrack(not trackEnabled) end)
hTog.MouseButton1Click:Connect(function() setHop(not hopEnabled) end)
hjTog.MouseButton1Click:Connect(function() end)
hfTog.MouseButton1Click:Connect(function() end)
teamBtn.MouseButton1Click:Connect(function() setTeam(not teamCheckEnabled) end)
tSetBtn.MouseButton1Click:Connect(function() setTSettings(not tSettingsOn) end)
hSetBtn.MouseButton1Click:Connect(function() setHSettings(not hSettingsOn) end)

backBtn.MouseButton1Click:Connect(function()
    if not tSettingsOn then return end
    if not backOn then backOn=true; backExpanded=true else backOn=false; backExpanded=false end
    rBack(); layoutAll()
end)
trigBtn.MouseButton1Click:Connect(function()
    if not tSettingsOn then return end
    if not trigOn then trigOn=true; trigExpanded=true else trigOn=false; trigExpanded=false end
    rTrig(); layoutAll()
end)
jumpModeBtn.MouseButton1Click:Connect(function()
    if controlMode~="jump" then flickExpanded=false; controlMode="jump"; jumpExpanded=true
    else jumpExpanded=not jumpExpanded end; uJumpMode(); uFlickMode(); layoutAll()
end)
flickModeBtn.MouseButton1Click:Connect(function()
    if controlMode~="button" then jumpExpanded=false; controlMode="button"; flickExpanded=true
    else flickExpanded=not flickExpanded end; uJumpMode(); uFlickMode(); layoutAll()
end)
jumpOnFlickBtn.MouseButton1Click:Connect(function() jumpOnFlick=not jumpOnFlick; uJOF() end)
infJumpBtn.MouseButton1Click:Connect(function() infJump=not infJump; uInfJ() end)
pcModeBtn.MouseButton1Click:Connect(function() pcMode=not pcMode; uPc() end)

fkBtn.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey=true; fkBtn.Text="..."; fkBtn.BackgroundColor3=Color3.fromRGB(148,112,0)
    local conn; conn=UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Keyboard then
            conn:Disconnect(); listeningForKey=nil; flickKey=input.KeyCode
            fkBtn.Text=input.KeyCode.Name; fkBtn.BackgroundColor3=Color3.fromRGB(44,44,148)
        end
    end)
end)

flickBtnMain.MouseButton1Click:Connect(function()
    if ffMoved then ffMoved=false; return end; doFlick(false)
end)

local dragging,dragStart,startPos=false,nil,nil
dragBar.InputBegan:Connect(function(input)
    if guiLocked then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
    end
end)
dragBar.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging or guiLocked then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and input.UserInputType~=Enum.UserInputType.Touch then return end
    local d=input.Position-dragStart
    main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        trackDropOpen=false; hopDropOpen=false; hjDropOpen=false; hfDropOpen=false
        tArrImg.Image=ARROW_DOWN; hArrImg.Image=ARROW_DOWN; hjArrImg.Image=ARROW_DOWN; hfArrImg.Image=ARROW_DOWN
        sep.Visible=false; tWrap.Visible=false; tLbl.Visible=false; hWrap.Visible=false; hLbl.Visible=false
        hjWrapL.Visible=false; hfWrapR.Visible=false; hdLbl.Visible=false; vDivLine.Visible=false
        for _,t in ipairs({tDropItems,tSubItems,hDropItems,hSubItems,hjDropItems,hfDropItems}) do
            for _,item in ipairs(t) do item.f.Visible=false end
        end
        main.Size=UDim2.new(0,MAIN_W,0,DRAG_H)
    else
        sep.Visible=true; tWrap.Visible=true; tLbl.Visible=true; hWrap.Visible=true; hLbl.Visible=true
        hjWrapL.Visible=true; hfWrapR.Visible=true; hdLbl.Visible=true; vDivLine.Visible=true
        tLbl.Position=UDim2.new(0,8,0,TRACK_LABEL_Y); tWrap.Position=UDim2.new(0,5,0,TRACK_ROW_Y)
        layoutAll()
    end
    minBtn.ImageColor3=minimized and Color3.fromRGB(78,78,98) or Color3.fromRGB(138,138,158)
end)

pinBtn.MouseButton1Click:Connect(function()
    guiLocked=true; pinBtn.Visible=false; lockBtn.Visible=true
end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked=false; lockBtn.Visible=false; pinBtn.Visible=true
end)

local function getChar()
    local c=localPlayer.Character or localPlayer.CharacterAdded:Wait()
    return c,c:WaitForChild("Humanoid"),c:WaitForChild("HumanoidRootPart")
end

local function nearWall(hrp)
    local p=RaycastParams.new(); p.FilterDescendantsInstances={hrp.Parent}; p.FilterType=Enum.RaycastFilterType.Blacklist
    local dirs={hrp.CFrame.RightVector,-hrp.CFrame.RightVector,hrp.CFrame.LookVector,-hrp.CFrame.LookVector}
    for i=1,4 do
        local r=workspace:Raycast(hrp.Position,dirs[i]*WALL_DIST,p)
        if r then
            local h=r.Instance; local n=h.Name:lower()
            if not h:IsA("TrussPart") and not n:find("ladder") and not n:find("truss") and not n:find("climb") then return true end
        end
    end; return false
end

local function flickDir(hum)
    local md=hum.MoveDirection
    if md.Magnitude<0.1 then return math.random(0,1)==1 and 1 or -1 end
    return md:Dot(camera.CFrame.RightVector)>0 and -1 or 1
end

local function doFlick(rw)
    if debounce then return end; debounce=true
    local _,hum,hrp=getChar()
    if rw and not nearWall(hrp) then debounce=false; return end
    if jumpOnFlick then
        local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,hum.JumpPower,v.Z); hum.Jump=true
    end
    hum.AutoRotate=false
    local d=flickDir(hum)
    hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(d*FLICK_ANGLE),0); task.wait(0.08)
    hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(-d*FLICK_ANGLE),0)
    hum.AutoRotate=true; debounce=false
end

UserInputService.JumpRequest:Connect(function()
    if not hopEnabled or pcMode then return end
    if infJump and controlMode=="jump" then
        local _,hum,hrp=getChar(); local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,hum.JumpPower,v.Z); hum.Jump=true
    end
    if controlMode=="jump" then doFlick(true) end
end)

UserInputService.InputBegan:Connect(function(input,processed)
    if processed or not pcMode or listeningForKey then return end
    if input.UserInputType~=Enum.UserInputType.Keyboard or input.KeyCode~=flickKey then return end
    local _,hum,hrp=getChar(); if not hum or not hrp then return end
    if jumpOnFlick then
        local v=hrp.AssemblyLinearVelocity; hrp.AssemblyLinearVelocity=Vector3.new(v.X,hum.JumpPower,v.Z); hum.Jump=true
    end
    doFlick(false)
end)

local function blockedByGlass(from, to, ignoreList)
    local dir = to - from
    local dist = dir.Magnitude
    if dist < 0.1 then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local current = from
    local remaining = dist
    local maxBounces = 6
    for _ = 1, maxBounces do
        local result = workspace:Raycast(current, dir.Unit * remaining, params)
        if not result then return false end
        local hit = result.Instance
        local name = hit.Name:lower()
        local isGlassy = name:find("glass") or name:find("window") or name:find("transparent")
        local isTrans = false
        if hit:IsA("BasePart") then isTrans = hit.Transparency > 0.5 end
        if isGlassy or isTrans then
            return true
        end
        return false
    end
    return false
end

local function isGreen(other)
    local char=other.Character; if not char then return false end
    local function g(c) return c.G>0.4 and c.G>c.R*1.5 and c.G>c.B*1.5 end
    local h=char:FindFirstChildOfClass("Highlight")
    if h and (g(h.FillColor) or g(h.OutlineColor)) then return true end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("Highlight") and g(v.FillColor) then return true end
        if v:IsA("SelectionBox") and g(v.Color3) then return true end
        if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
            local c=v.Color; if c.G>0.5 and c.G>c.R*2 and c.G>c.B*2 then return true end
        end
    end; return false
end

local function isEnemy(p)
    if not teamCheckEnabled then return true end; return not isGreen(p)
end

local function closestEnemyTrack(myRoot)
    local cl,cd=nil,math.huge
    local char=localPlayer.Character
    local ignoreList = {myRoot.Parent}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=localPlayer and isEnemy(p) then
            local pChar=p.Character
            if pChar then
                local r=pChar:FindFirstChild("HumanoidRootPart"); local hum=pChar:FindFirstChild("Humanoid")
                if r and hum and hum.Health>0 then
                    local d=(myRoot.Position-r.Position).Magnitude
                    if d<cd then
                        local ignore = {myRoot.Parent, pChar}
                        if not blockedByGlass(myRoot.Position, r.Position, ignore) then
                            cd=d; cl={root=r,player=p}
                        end
                    end
                end
            end
        end
    end; return cl
end

local function getToolTimer(tool)
    if not tool then return nil end
    for _,v in ipairs(tool:GetDescendants()) do
        if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("time") or v.Name:lower():find("count")) then
            return tonumber(v.Value)
        end
    end
    for _,v in ipairs(tool:GetDescendants()) do
        if v:IsA("TextLabel") then
            local n=tonumber(v.Text); if n then return n end
        end
    end
    return nil
end

local function bombHolder(myRoot)
    local cl,cd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==localPlayer then continue end
        local char=p.Character; if not char then continue end
        local tool=char:FindFirstChildOfClass("Tool"); local root=char:FindFirstChild("HumanoidRootPart")
        if tool and root then
            local d=(myRoot.Position-root.Position).Magnitude
            if d<cd then cd=d; cl={player=p,root=root} end
        end
    end
    if cl then return cl.player,cl.root end; return nil,nil
end

local hadTool=false; local backingUp=false
RunService.Heartbeat:Connect(function()
    local char=localPlayer.Character; if not char then return end
    local hum=char:FindFirstChild("Humanoid"); local myRoot=char:FindFirstChild("HumanoidRootPart")
    if not hum or not myRoot then return end
    local myTool=char:FindFirstChildOfClass("Tool"); local holding=myTool~=nil
    if hadTool and not holding then backingUp=true end
    if holding then backingUp=false end; hadTool=holding

    if not trackEnabled then
        hum:MoveTo(myRoot.Position); backingUp=false; return
    end

    if backingUp and tSettingsOn and backOn then
        local bp,br=bombHolder(myRoot)
        if br then
            local dist=(myRoot.Position-br.Position).Magnitude
            if dist<tSettings.backDistance then
                hum:MoveTo(myRoot.Position+(myRoot.Position-br.Position).Unit*tSettings.backDistance)
            else
                backingUp=false
            end
        else
            backingUp=false
        end; return
    elseif backingUp then
        backingUp=false
    end

    if not holding then hum:MoveTo(myRoot.Position); return end

    if tSettingsOn and trigOn then
        local tv=getToolTimer(myTool); if tv~=nil and tv>tSettings.triggerTime then
            hum:MoveTo(myRoot.Position); return
        end
    end

    local ed=closestEnemyTrack(myRoot)
    if ed then
        local dist=(myRoot.Position-ed.root.Position).Magnitude
        if dist>tSettings.stopDistance then
            hum:MoveTo(ed.root.Position)
        else
            hum:MoveTo(myRoot.Position)
        end
    end
end)
