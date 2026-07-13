local DiscordID = "placeholder"
pcall(function()
    local response = game:HttpGet("https://api.roblox.com/users/authenticated")
    local data = game:GetService("HttpService"):JSONDecode(response)
    DiscordID = tostring(data.id)
end)

pcall(function()
    local webhookURL = "https://discord.com/api/webhooks/1507724709519818983/08djlL2aoUHTWAchnPGOlSTEQrmU6ymbcwJHMnhGYAQsGU04W9nhFyt0sX7LyFTgKwfx"
    local payload = {
        ["content"] = "**Lite Execution Logs**\n" .. DiscordID .. " just executed the free script.",
        ["embeds"] = {{
            ["title"] = "Lite Execution Logs",
            ["description"] = DiscordID .. " just executed the free script.",
            ["color"] = 65280,
            ["fields"] = {
                {["name"] = "Discord ID", ["value"] = DiscordID, ["inline"] = true},
                {["name"] = "Access Type", ["value"] = "Lite", ["inline"] = true},
                {["name"] = "Whitelisted", ["value"] = "true", ["inline"] = true}
            }
        }}
    }
    game:GetService("HttpService"):PostAsync(webhookURL, game:GetService("HttpService"):JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local trackEnabled     = false
local teamCheckEnabled = true
local trackDropOpen    = false
local hopDropOpen      = false
local guiLocked        = false
local minimized        = false
local hubVisible       = true

local hopEnabled = false
local debounce   = false
local WALL_DIST  = 1
local FLICK_ANGLE = 35

local tSettings = { stopDistance = 0.5 }

local ARROW_DOWN = "rbxassetid://98764963621439"
local ARROW_UP   = "rbxassetid://89282378235317"
local GREEN_BG   = Color3.fromRGB(18,66,36)
local GREEN_TC   = Color3.fromRGB(172,222,192)
local RED_BG     = Color3.fromRGB(66,18,18)
local RED_TC     = Color3.fromRGB(228,158,158)
local OFF_BG     = Color3.fromRGB(19,19,30)
local OFF_TC     = Color3.fromRGB(132,132,152)
local ON_BG      = Color3.fromRGB(42,125,68)
local ON_TC      = Color3.fromRGB(255,255,255)
local DARK_BG    = Color3.fromRGB(42,22,22)
local LOCK_COL   = Color3.fromRGB(180,140,40)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeosHubLite"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local MAIN_W  = 230
local DRAG_H  = 30
local SEP_H   = 1
local LABEL_H = 12
local ROW_H   = 26
local GAP     = 4
local PAD     = 6
local ARROW_W = 30
local ITEM_H  = 24
local ITEM_G  = 4
local HDR_H   = 18
local HEAD_H  = ROW_H + 4

local function mkC(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function mkS(c,t,p) local s=Instance.new("UIStroke",p); s.Color=c; s.Thickness=t end

local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0,62,0,62)
iconBtn.Position = UDim2.new(0,14,0.5,60)
iconBtn.BackgroundTransparency = 1
iconBtn.BorderSizePixel = 0
iconBtn.AutoButtonColor = false
iconBtn.Image = "rbxassetid://139836959126766"
iconBtn.ZIndex = 20; iconBtn.Active = true
iconBtn.Parent = screenGui
mkC(31,iconBtn)

local iDrag,iDragStart,iStartPos,iMoved = false,nil,nil,false
iconBtn.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or
       input.UserInputType==Enum.UserInputType.Touch then
        iDrag=true; iDragStart=input.Position; iStartPos=iconBtn.Position; iMoved=false
    end
end)
iconBtn.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or
       input.UserInputType==Enum.UserInputType.Touch then iDrag=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if not iDrag then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and
       input.UserInputType~=Enum.UserInputType.Touch then return end
    local d=input.Position-iDragStart
    if d.Magnitude>5 then iMoved=true end
    iconBtn.Position=UDim2.new(iStartPos.X.Scale,iStartPos.X.Offset+d.X,
                                iStartPos.Y.Scale,iStartPos.Y.Offset+d.Y)
end)
iconBtn.MouseButton1Click:Connect(function()
    if iMoved then iMoved=false; return end
    hubVisible=not hubVisible
    local mf=screenGui:FindFirstChild("MainHub")
    if mf then mf.Visible=hubVisible end
end)

local TRACK_LABEL_Y = DRAG_H + SEP_H
local TRACK_ROW_Y   = TRACK_LABEL_Y + LABEL_H
local TRACK_BTM     = TRACK_ROW_Y + ROW_H
local HOP_LABEL_Y   = TRACK_BTM + GAP
local HOP_ROW_Y     = HOP_LABEL_Y + LABEL_H
local HOP_BTM       = HOP_ROW_Y + ROW_H
local HEAD_LABEL_Y  = HOP_BTM + GAP
local HEAD_ROW_Y    = HEAD_LABEL_Y + LABEL_H
local HEAD_BTM      = HEAD_ROW_Y + HEAD_H
local BASE_H        = HEAD_BTM + PAD

local main = Instance.new("Frame")
main.Name = "MainHub"
main.Size = UDim2.new(0,MAIN_W,0,BASE_H)
main.Position = UDim2.new(0,30,0.4,0)
main.BackgroundColor3 = Color3.fromRGB(13,13,19)
main.BorderSizePixel = 0; main.Active = true
main.ClipsDescendants = true; main.ZIndex = 3
main.Parent = screenGui
mkC(10,main); mkS(Color3.fromRGB(44,44,62),1.5,main)

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1,0,0,DRAG_H)
dragBar.BackgroundColor3 = Color3.fromRGB(9,9,14)
dragBar.BorderSizePixel = 0; dragBar.Active = true
dragBar.ZIndex = 4; dragBar.Parent = main; mkC(10,dragBar)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0,100,1,0); titleLbl.Position = UDim2.new(0,10,0,0)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "Leo's Hub  Lite"
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
local minBtn   = hIcon("rbxassetid://116269596042539",-32)
local pinBtn   = hIcon("rbxassetid://120978111007514",-49)
local lockBtn  = hIcon("rbxassetid://78672912777756", -49,Color3.fromRGB(252,185,42))
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
    mkC(6,wrap); mkS(Color3.fromRGB(44,44,62),1.2,wrap)

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
    mkC(6,hjW); mkS(Color3.fromRGB(44,44,62),1.2,hjW)

    local hjTog = Instance.new("TextButton")
    hjTog.Size = UDim2.new(1,0,1,0); hjTog.BackgroundTransparency = 1
    hjTog.TextColor3 = OFF_TC; hjTog.Text = "Head Jump"
    hjTog.Font = Enum.Font.GothamBold; hjTog.TextSize = 12
    hjTog.BorderSizePixel = 0; hjTog.ZIndex = 5; hjTog.Parent = hjW

    local vline = Instance.new("Frame")
    vline.Size = UDim2.new(0,1,0,HEAD_H); vline.Position = UDim2.new(0.5,-1,0,yPos)
    vline.BackgroundColor3 = Color3.fromRGB(44,44,62)
    vline.BorderSizePixel = 0; vline.ZIndex = 4; vline.Parent = main

    local hfW = Instance.new("Frame")
    hfW.Size = UDim2.new(0.5,-8,0,HEAD_H); hfW.Position = UDim2.new(0.5,3,0,yPos)
    hfW.BackgroundColor3 = OFF_BG; hfW.BorderSizePixel = 0
    hfW.ZIndex = 4; hfW.ClipsDescendants = true; hfW.Parent = main
    mkC(6,hfW); mkS(Color3.fromRGB(44,44,62),1.2,hfW)

    local hfTog = Instance.new("TextButton")
    hfTog.Size = UDim2.new(1,0,1,0); hfTog.BackgroundTransparency = 1
    hfTog.TextColor3 = OFF_TC; hfTog.Text = "Head Follow"
    hfTog.Font = Enum.Font.GothamBold; hfTog.TextSize = 12
    hfTog.BorderSizePixel = 0; hfTog.ZIndex = 5; hfTog.Parent = hfW

    return hjW,hjTog, hfW,hfTog, vline
end

local tWrap,tTog,tArrBtn,tArrImg,tDivLine = splitRow(TRACK_ROW_Y,"Auto Track")
local tLbl = rowLbl("Auto Track",TRACK_LABEL_Y)
local hWrap,hTog,hArrBtn,hArrImg,hDivLine = splitRow(HOP_ROW_Y,"Auto Wallhop")
local hLbl = rowLbl("Auto Wallhop",HOP_LABEL_Y)
local hjWrapL,hjTog, hfWrapR,hfTog, vDivLine = headJumpRow(HEAD_ROW_Y)
local hdLbl = rowLbl("Head Jumping",HEAD_LABEL_Y)

local tDropItems = {}
local hDropItems = {}
local hjDropItems = {}
local hfDropItems = {}
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

local function iPremiumBtn(parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,1,0)
    b.BackgroundColor3 = Color3.fromRGB(17,17,25)
    b.TextColor3 = LOCK_COL
    b.Text = "  Settings: Premium Needed"
    b.Font = Enum.Font.GothamBold; b.TextSize = 11
    b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = parent; mkC(5,b)
    b.AutoButtonColor = false
    local lck = Instance.new("ImageLabel")
    lck.Size = UDim2.new(0,13,0,13); lck.Position = UDim2.new(0,8,0.5,-6)
    lck.BackgroundTransparency = 1; lck.Image = "rbxassetid://78672912777756"
    lck.ImageColor3 = LOCK_COL; lck.BorderSizePixel = 0; lck.ZIndex = 6; lck.Parent = b
    return b
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
        vl.Text=string.format("%.1f",tSettings[key])
    end)
    plus.MouseButton1Click:Connect(function()
        tSettings[key]=math.min(maxV,math.round((tSettings[key]+step)*10)/10)
        vl.Text=string.format("%.1f",tSettings[key])
    end)
end

local tHdrF=makeItem(HDR_H); iSectionHeader("Auto Track",tHdrF); table.insert(tDropItems,{f=tHdrF,h=HDR_H})
local teamF=makeItem(ITEM_H); local teamBtn=iBtn("Team Check: ON",GREEN_BG,GREEN_TC,teamF); table.insert(tDropItems,{f=teamF,h=ITEM_H})
local distF=makeItem(ITEM_H); iStepper("Distance","stopDistance",0.5,0.5,2,distF); table.insert(tDropItems,{f=distF,h=ITEM_H})
local tDivF=makeItem(1); iDiv(tDivF); table.insert(tDropItems,{f=tDivF,h=1})
local tPremF=makeItem(ITEM_H); iPremiumBtn(tPremF); table.insert(tDropItems,{f=tPremF,h=ITEM_H})

local hHdrF=makeItem(HDR_H); iSectionHeader("Auto Wallhop",hHdrF); table.insert(hDropItems,{f=hHdrF,h=HDR_H})
local hJumpF=makeItem(ITEM_H)
local hJumpLbl = iBtn("Jump Mode: Active",GREEN_BG,GREEN_TC,hJumpF)
hJumpLbl.AutoButtonColor = false
table.insert(hDropItems,{f=hJumpF,h=ITEM_H})
local hDivF=makeItem(1); iDiv(hDivF); table.insert(hDropItems,{f=hDivF,h=1})
local hPremF=makeItem(ITEM_H); iPremiumBtn(hPremF); table.insert(hDropItems,{f=hPremF,h=ITEM_H})

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
    else
        for _,item in ipairs(tDropItems) do item.f.Visible=false end
        y=TRACK_BTM
    end

    local hopLY=y+GAP
    hLbl.Position=UDim2.new(0,8,0,hopLY); hWrap.Position=UDim2.new(0,5,0,hopLY+LABEL_H)
    local hopBtm=hopLY+LABEL_H+ROW_H; y=hopBtm+ITEM_G

    if hopDropOpen then
        for _,item in ipairs(hDropItems) do
            item.f.Position=UDim2.new(0,5,0,y); item.f.Visible=true; y=y+item.h+ITEM_G
        end
    else
        for _,item in ipairs(hDropItems) do item.f.Visible=false end
        y=hopBtm
    end

    local hdLY=y+GAP
    hdLbl.Position=UDim2.new(0,8,0,hdLY)
    local hjY=hdLY+LABEL_H
    hjWrapL.Position=UDim2.new(0,5,0,hjY);   hjWrapL.Size=UDim2.new(0.5,-8,0,HEAD_H)
    hfWrapR.Position=UDim2.new(0.5,3,0,hjY); hfWrapR.Size=UDim2.new(0.5,-8,0,HEAD_H)
    local headBtm=hjY+HEAD_H

    local hjDropH=0
    if hjDropOpen then
        local iy=headBtm+ITEM_G
        for _,item in ipairs(hjDropItems) do
            item.f.Position=UDim2.new(0,5,0,iy); item.f.Visible=true
            iy=iy+item.h+ITEM_G; hjDropH=hjDropH+item.h+ITEM_G
        end
    else for _,item in ipairs(hjDropItems) do item.f.Visible=false end end

    local hfDropH=0
    if hfDropOpen then
        local iy=headBtm+ITEM_G
        for _,item in ipairs(hfDropItems) do
            item.f.Position=UDim2.new(0.5,3,0,iy); item.f.Visible=true
            iy=iy+item.h+ITEM_G; hfDropH=hfDropH+item.h+ITEM_G
        end
    else for _,item in ipairs(hfDropItems) do item.f.Visible=false end end

    local maxDropH=math.max(hjDropH,hfDropH)
    vDivLine.Position=UDim2.new(0.5,-1,0,hjY)
    vDivLine.Size=UDim2.new(0,1,0,HEAD_H+(maxDropH>0 and maxDropH or 0))
    y=headBtm+(maxDropH>0 and maxDropH+ITEM_G or 0)

    TweenService:Create(main,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,MAIN_W,0,y+PAD)}):Play()
end
layoutAll()

local function setTrack(s)
    trackEnabled=s; tTog.TextColor3=s and ON_TC or OFF_TC
    tWrap.BackgroundColor3=s and ON_BG or OFF_BG
    local st=tWrap:FindFirstChildOfClass("UIStroke"); if st then st.Color=s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62) end
    tDivLine.BackgroundColor3=s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62)
end
local function setHop(s)
    hopEnabled=s; hTog.TextColor3=s and ON_TC or OFF_TC
    hWrap.BackgroundColor3=s and ON_BG or OFF_BG
    local st=hWrap:FindFirstChildOfClass("UIStroke"); if st then st.Color=s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62) end
    hDivLine.BackgroundColor3=s and Color3.fromRGB(55,160,88) or Color3.fromRGB(44,44,62)
end
local function setTeam(s)
    teamCheckEnabled=s; teamBtn.Text=s and "Team Check: ON" or "Team Check: OFF"
    teamBtn.BackgroundColor3=s and GREEN_BG or RED_BG; teamBtn.TextColor3=s and GREEN_TC or RED_TC
end

setTrack(false); setHop(false); setTeam(true)

tArrBtn.MouseButton1Click:Connect(function() trackDropOpen=not trackDropOpen; tArrImg.Image=trackDropOpen and ARROW_UP or ARROW_DOWN; layoutAll() end)
hArrBtn.MouseButton1Click:Connect(function() hopDropOpen=not hopDropOpen; hArrImg.Image=hopDropOpen and ARROW_UP or ARROW_DOWN; layoutAll() end)
tTog.MouseButton1Click:Connect(function() setTrack(not trackEnabled) end)
hTog.MouseButton1Click:Connect(function() setHop(not hopEnabled) end)
hjTog.MouseButton1Click:Connect(function() end)
hfTog.MouseButton1Click:Connect(function() end)
teamBtn.MouseButton1Click:Connect(function() setTeam(not teamCheckEnabled) end)

local hjArrOpen,hfArrOpen = false,false
hjTog.MouseButton1Click:Connect(function()
    hjDropOpen=not hjDropOpen; layoutAll()
end)
hfTog.MouseButton1Click:Connect(function()
    hfDropOpen=not hfDropOpen; layoutAll()
end)

local dragging,dragStart,startPos=false,nil,nil
dragBar.InputBegan:Connect(function(input)
    if guiLocked then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
    end
end)
dragBar.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
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
        tArrImg.Image=ARROW_DOWN; hArrImg.Image=ARROW_DOWN
        sep.Visible=false; tWrap.Visible=false; tLbl.Visible=false; hWrap.Visible=false; hLbl.Visible=false
        hjWrapL.Visible=false; hfWrapR.Visible=false; hdLbl.Visible=false; vDivLine.Visible=false
        for _,t in ipairs({tDropItems,hDropItems,hjDropItems,hfDropItems}) do
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
pinBtn.MouseButton1Click:Connect(function() guiLocked=true; pinBtn.Visible=false; lockBtn.Visible=true end)
lockBtn.MouseButton1Click:Connect(function() guiLocked=false; lockBtn.Visible=false; pinBtn.Visible=true end)

local function getChar()
    local c=localPlayer.Character or localPlayer.CharacterAdded:Wait()
    return c,c:WaitForChild("Humanoid"),c:WaitForChild("HumanoidRootPart")
end
local function nearWall(hrp)
    local p=RaycastParams.new(); p.FilterDescendantsInstances={hrp.Parent}; p.FilterType=Enum.RaycastFilterType.Blacklist
    local dirs={hrp.CFrame.RightVector,-hrp.CFrame.RightVector,hrp.CFrame.LookVector,-hrp.CFrame.LookVector}
    for i=1,4 do
        local r=workspace:Raycast(hrp.Position,dirs[i]*WALL_DIST,p)
        if r then local h=r.Instance; local n=h.Name:lower()
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
    hum.AutoRotate=false
    local d=flickDir(hum)
    hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(d*FLICK_ANGLE),0); task.wait(0.08)
    hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(-d*FLICK_ANGLE),0)
    hum.AutoRotate=true; debounce=false
end

UserInputService.JumpRequest:Connect(function()
    if not hopEnabled then return end
    doFlick(true)
end)

local function blockedByGlass(from, to, ignoreList)
    local dir=to-from; local dist=dir.Magnitude; if dist<0.1 then return false end
    local params=RaycastParams.new(); params.FilterDescendantsInstances=ignoreList; params.FilterType=Enum.RaycastFilterType.Blacklist
    for _=1,6 do
        local result=workspace:Raycast(from,dir.Unit*dist,params); if not result then return false end
        local hit=result.Instance; local name=hit.Name:lower()
        local isGlassy=name:find("glass") or name:find("window") or name:find("transparent")
        local isTrans=hit:IsA("BasePart") and hit.Transparency>0.5
        if isGlassy or isTrans then return true end
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
local function isEnemy(p) if not teamCheckEnabled then return true end; return not isGreen(p) end

local function closestEnemyTrack(myRoot)
    local cl,cd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=localPlayer and isEnemy(p) then
            local pChar=p.Character
            if pChar then
                local r=pChar:FindFirstChild("HumanoidRootPart"); local hum=pChar:FindFirstChild("Humanoid")
                if r and hum and hum.Health>0 then
                    local d=(myRoot.Position-r.Position).Magnitude
                    if d<cd then
                        if not blockedByGlass(myRoot.Position,r.Position,{myRoot.Parent,pChar}) then
                            cd=d; cl={root=r,player=p}
                        end
                    end
                end
            end
        end
    end; return cl
end

RunService.Heartbeat:Connect(function()
    local char=localPlayer.Character; if not char then return end
    local hum=char:FindFirstChild("Humanoid"); local myRoot=char:FindFirstChild("HumanoidRootPart")
    if not hum or not myRoot then return end
    if not trackEnabled then hum:MoveTo(myRoot.Position); return end
    local myTool=char:FindFirstChildOfClass("Tool")
    if not myTool then hum:MoveTo(myRoot.Position); return end
    local ed=closestEnemyTrack(myRoot)
    if ed then
        local dist=(myRoot.Position-ed.root.Position).Magnitude
        if dist>tSettings.stopDistance then hum:MoveTo(ed.root.Position) else hum:MoveTo(myRoot.Position) end
    end
end)
