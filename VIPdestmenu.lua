-- Chờ game tải xong hoàn toàn
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Cấu hình hệ thống v3.7.4
local Settings = {
    Aimbot = true,        
    AutoLock = true,      
    Triggerbot = false, 
    Prediction = true,   
    PredictionFactor = 0.165,
    WallCheck = false,    
    AimSmooth = 0.15,     
    AimPart = "Head", 
    UseFOV = true,
    FOVRadius = 120,      
    TeamCheck = true,    
    Tracers = true,      
    Distance = true,     
    Names = true,        
    HealthBar = true,    
    SpecialChams = true,  -- TÍNH NĂNG ĐẶC BIỆT MỚI
    Active = true,
    MaxDistance = 600
}

local ESP_Connections = {}
local ESP_Objects = {}

-- KHỞI TẠO VÒNG FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
table.insert(ESP_Objects, FOVCircle)

local function GetViewportCenter()
    local ViewportSize = Camera.ViewportSize
    local Inset = GuiService:GetGuiInset()
    return Vector2.new(ViewportSize.X / 2, (ViewportSize.Y - Inset.Y) / 2)
end

local function UpdateFOV()
    if Settings.Active and Settings.UseFOV and Settings.Aimbot then
        FOVCircle.Position = GetViewportCenter()
        FOVCircle.Radius = Settings.FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

-- QUẢN LÝ GIAO DIỆN
local GUI_PARENT = nil
pcall(function() GUI_PARENT = gethui and gethui() end)
if not GUI_PARENT then pcall(function() GUI_PARENT = game:GetService("CoreGui") end) end
if not GUI_PARENT or (not pcall(function() local _ = GUI_PARENT.Name end)) then
    GUI_PARENT = LocalPlayer:WaitForChild("PlayerGui")
end

-- Dọn phiên bản cũ
for _, child in ipairs(GUI_PARENT:GetChildren()) do
    if child.Name:match("^DeltaX_v") then child:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_v374_Special"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GUI_PARENT

-- HÀM KÉO THẢ
local function MakeDraggable(Frame, DragArea)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    DragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    DragArea.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
end

-- NÚT MINI TOGGLE TRÊN MOBILE
local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Name = "MobileToggle"
MobileToggleBtn.Size = UDim2.new(0, 46, 0, 46)
MobileToggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
MobileToggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MobileToggleBtn.Text = "⚡"
MobileToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
MobileToggleBtn.TextSize = 18
MobileToggleBtn.Font = Enum.Font.GothamBold
MobileToggleBtn.ZIndex = 99999
MobileToggleBtn.Parent = ScreenGui

local MobileStroke = Instance.new("UIStroke") MobileStroke.Color = Color3.fromRGB(0, 255, 150) MobileStroke.Thickness = 2.0 MobileStroke.Parent = MobileToggleBtn
local MobileCorner = Instance.new("UICorner") MobileCorner.CornerRadius = UDim.new(0, 10) MobileCorner.Parent = MobileToggleBtn

MakeDraggable(MobileToggleBtn, MobileToggleBtn)

-- MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 440)
MainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ZIndex = 500
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MenuStroke = Instance.new("UIStroke") MenuStroke.Color = Color3.fromRGB(0, 255, 150) MenuStroke.Thickness = 1.8 MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border MenuStroke.Parent = MainFrame
local MenuCorner = Instance.new("UICorner") MenuCorner.CornerRadius = UDim.new(0, 10) MenuCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 501
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner") TitleBarCorner.CornerRadius = UDim.new(0, 10) TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 14)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DELTA X v3.7.4 [CYBER-PULSE]"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 502
TitleText.Parent = TitleBar

MakeDraggable(MainFrame, TitleBar)

local startTouchPos
MobileToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startTouchPos = MobileToggleBtn.Position end
end)

MobileToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local endPos = MobileToggleBtn.Position
        if startTouchPos then
            local distance = math.sqrt((endPos.X.Offset - startTouchPos.X.Offset)^2 + (endPos.Y.Offset - startTouchPos.Y.Offset)^2)
            if distance < 8 then MainFrame.Visible = not MainFrame.Visible end
        end
    end
end)

local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0, 24, 0, 24) CloseBtn.Position = UDim2.new(1, -34, 0, 10) CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 22) CloseBtn.Text = "×" CloseBtn.TextColor3 = Color3.fromRGB(255, 42, 95) CloseBtn.TextSize = 18 CloseBtn.Font = Enum.Font.GothamBold CloseBtn.ZIndex = 503 CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner") CloseCorner.CornerRadius = UDim.new(0, 6) CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    Settings.Active = false
    for _, Con in ipairs(ESP_Connections) do if Con then Con:Disconnect() end end
    for _, Obj in ipairs(ESP_Objects) do if Obj then pcall(function() Obj.Visible = false Obj:Remove() end) end end
    for _, child in ipairs(game:GetService("CoreGui"):GetChildren()) do if child:IsA("Highlight") and child.Name:match("_Chams$") then child:Destroy() end end
    ScreenGui:Destroy()
end)

-- THANH TAB
local TabSelector = Instance.new("Frame") TabSelector.Size = UDim2.new(1, 0, 0, 35) TabSelector.Position = UDim2.new(0, 0, 0, 45) TabSelector.BackgroundColor3 = Color3.fromRGB(7, 7, 10) TabSelector.BorderSizePixel = 0 TabSelector.ZIndex = 505 TabSelector.Parent = MainFrame
local Tab1Btn = Instance.new("TextButton") Tab1Btn.Size = UDim2.new(0, 135, 1, 0) Tab1Btn.BackgroundTransparency = 1 Tab1Btn.Text = "🎯 AIM ENGINE" Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab1Btn.TextSize = 11 Tab1Btn.Font = Enum.Font.GothamBold Tab1Btn.ZIndex = 506 Tab1Btn.Parent = TabSelector
local Tab2Btn = Instance.new("TextButton") Tab2Btn.Size = UDim2.new(0, 135, 1, 0) Tab2Btn.Position = UDim2.new(0, 135, 0, 0) Tab2Btn.BackgroundTransparency = 1 Tab2Btn.Text = "👁️ CYBER VISUALS" Tab2Btn.TextColor3 = Color3.fromRGB(130, 130, 135) Tab2Btn.TextSize = 11 Tab2Btn.Font = Enum.Font.GothamBold Tab2Btn.ZIndex = 506 Tab2Btn.Parent = TabSelector
local TabIndicator = Instance.new("Frame") TabIndicator.Size = UDim2.new(0, 123, 0, 2.5) TabIndicator.Position = UDim2.new(0, 6, 1, -2.5) TabIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150) TabIndicator.BorderSizePixel = 0 TabIndicator.ZIndex = 507 TabIndicator.Parent = TabSelector

-- CONTAINERS (CanvasSize nâng lên để chứa vừa tính năng đặc biệt)
local AimContainer = Instance.new("ScrollingFrame") AimContainer.Size = UDim2.new(1, -6, 1, -96) AimContainer.Position = UDim2.new(0, 3, 0, 86) AimContainer.BackgroundTransparency = 1 AimContainer.BorderSizePixel = 0 AimContainer.CanvasSize = UDim2.new(0, 0, 0, 460) AimContainer.ScrollBarThickness = 3 AimContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) AimContainer.ZIndex = 501 AimContainer.Parent = MainFrame
local VisualsContainer = Instance.new("ScrollingFrame") VisualsContainer.Size = UDim2.new(1, -6, 1, -96) VisualsContainer.Position = UDim2.new(0, 3, 0, 86) VisualsContainer.BackgroundTransparency = 1 VisualsContainer.BorderSizePixel = 0 VisualsContainer.CanvasSize = UDim2.new(0, 0, 0, 360) VisualsContainer.ScrollBarThickness = 3 VisualsContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) VisualsContainer.Visible = false VisualsContainer.ZIndex = 501 VisualsContainer.Parent = MainFrame

local L1 = Instance.new("UIListLayout") L1.Parent = AimContainer L1.SortOrder = Enum.SortOrder.LayoutOrder L1.Padding = UDim.new(0, 7) L1.HorizontalAlignment = Enum.HorizontalAlignment.Center
local L2 = Instance.new("UIListLayout") L2.Parent = VisualsContainer L2.SortOrder = Enum.SortOrder.LayoutOrder L2.Padding = UDim.new(0, 7) L2.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TopPadding1 = Instance.new("Frame") TopPadding1.Size = UDim2.new(1,0,0,4) TopPadding1.BackgroundTransparency = 1 TopPadding1.LayoutOrder = -10 TopPadding1.Parent = AimContainer
local TopPadding2 = Instance.new("Frame") TopPadding2.Size = UDim2.new(1,0,0,4) TopPadding2.BackgroundTransparency = 1 TopPadding2.LayoutOrder = -10 TopPadding2.Parent = VisualsContainer

Tab1Btn.MouseButton1Click:Connect(function()
    AimContainer.Visible = true VisualsContainer.Visible = false Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab2Btn.TextColor3 = Color3.fromRGB(130, 130, 135)
    TabIndicator:TweenPosition(UDim2.new(0, 6, 1, -2.5), "Out", "Quad", 0.15, true)
end)
Tab2Btn.MouseButton1Click:Connect(function()
    AimContainer.Visible = false VisualsContainer.Visible = true Tab2Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab1Btn.TextColor3 = Color3.fromRGB(130, 130, 135)
    TabIndicator:TweenPosition(UDim2.new(0, 141, 1, -2.5), "Out", "Quad", 0.15, true)
end)

-- HÀM TẠO TIÊU ĐỀ
local function CreateSectionTitle(text, targetContainer)
    local Frame = Instance.new("Frame") Frame.Size = UDim2.new(0.94, 0, 0, 22) Frame.BackgroundTransparency = 1 Frame.Parent = targetContainer
    local Label = Instance.new("TextLabel", Frame) Label.Size = UDim2.new(1, 0, 1, 0) Label.BackgroundTransparency = 1 Label.Text = "——  " .. text .. "  ——" Label.TextColor3 = Color3.fromRGB(100, 100, 105) Label.TextSize = 9.5 Label.Font = Enum.Font.GothamBold Label.TextXAlignment = Enum.TextXAlignment.Center
end

-- HÀM TẠO NÚT BẤM
local function CreateMenuButton(text, settingKey, startState, targetContainer)
    local Button = Instance.new("TextButton") 
    Button.Size = UDim2.new(0.94, 0, 0, 36) 
    Button.BackgroundColor3 = startState and Color3.fromRGB(10, 25, 18) or Color3.fromRGB(15, 15, 18) 
    Button.Text = "  " .. text
    Button.TextColor3 = startState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155) 
    Button.TextSize = 11.5 
    Button.Font = Enum.Font.GothamBold 
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.BorderSizePixel = 0 
    Button.ZIndex = 502
    Button.Parent = targetContainer

    local StatusIndicator = Instance.new("Frame", Button)
    StatusIndicator.Size = UDim2.new(0, 6, 0, 6)
    StatusIndicator.Position = UDim2.new(1, -20, 0.5, -3)
    StatusIndicator.BackgroundColor3 = startState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 42, 95)
    local IndicatorCorner = Instance.new("UICorner", StatusIndicator) IndicatorCorner.CornerRadius = UDim.new(1, 0)

    local ButtonCorner = Instance.new("UICorner") ButtonCorner.CornerRadius = UDim.new(0, 6) ButtonCorner.Parent = Button
    local ButtonStroke = Instance.new("UIStroke") ButtonStroke.Color = startState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(28, 28, 33) ButtonStroke.Thickness = 1.2 ButtonStroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if not Settings.Active then return end
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            Button.TextColor3 = Color3.fromRGB(255, 255, 255) Button.BackgroundColor3 = Color3.fromRGB(10, 25, 18) ButtonStroke.Color = Color3.fromRGB(0, 255, 150) StatusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        else
            Button.TextColor3 = Color3.fromRGB(150, 150, 155) Button.BackgroundColor3 = Color3.fromRGB(15, 15, 18) ButtonStroke.Color = Color3.fromRGB(28, 28, 33) StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 42, 95)
        end
        UpdateFOV()
    end)
end

-- KHỞI TẠO TAB AIMBOT
CreateSectionTitle("HỆ THỐNG GHIM TÂM", AimContainer)
CreateMenuButton("Khóa Tâm (Aimbot)", "Aimbot", true, AimContainer)
CreateMenuButton("Tự Động Ghim (Auto-Lock)", "AutoLock", true, AimContainer)
CreateMenuButton("Tự Động Bắn (Triggerbot)", "Triggerbot", false, AimContainer)

CreateSectionTitle("BỔ TRỢ THỰC CHIẾN", AimContainer)
CreateMenuButton("Đón Đầu Băng Thông (Predict)", "Prediction", true, AimContainer)
CreateMenuButton("Kiểm Tra Tường Chắn (Wall)", "WallCheck", false, AimContainer)
CreateMenuButton("Vòng Giới Hạn FOV", "UseFOV", true, AimContainer)

local TargetParts = {"Head", "UpperTorso", "HumanoidRootPart"}
local PartLabels = {Head = "ĐẦU", UpperTorso = "THÂN", HumanoidRootPart = "TRỌNG TÂM"}
local CurrentPartIdx = 1

local PartBtn = Instance.new("TextButton") PartBtn.Size = UDim2.new(0.94, 0, 0, 36) PartBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18) PartBtn.Text = "  🎯 Vị Trí Nhắm: ĐẦU" PartBtn.TextColor3 = Color3.fromRGB(255, 255, 255) PartBtn.TextSize = 11.5 PartBtn.Font = Enum.Font.GothamBold PartBtn.TextXAlignment = Enum.TextXAlignment.Left PartBtn.ZIndex = 502 PartBtn.Parent = AimContainer
local PartCorner = Instance.new("UICorner") PartCorner.CornerRadius = UDim.new(0, 6) PartCorner.Parent = PartBtn
local PartStroke = Instance.new("UIStroke") PartStroke.Color = Color3.fromRGB(28, 28, 33) PartStroke.Thickness = 1.2 PartStroke.Parent = PartBtn

PartBtn.MouseButton1Click:Connect(function()
    CurrentPartIdx = CurrentPartIdx % #TargetParts + 1
    local ChosenPart = TargetParts[CurrentPartIdx]
    Settings.AimPart = ChosenPart
    PartBtn.Text = "  🎯 Vị Trí Nhắm: " .. PartLabels[ChosenPart]
end)

local FovFrame = Instance.new("Frame") FovFrame.Size = UDim2.new(0.94, 0, 0, 56) FovFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18) FovFrame.ZIndex = 502 FovFrame.Parent = AimContainer
local FovCornerUI = Instance.new("UICorner") FovCornerUI.CornerRadius = UDim.new(0, 6) FovCornerUI.Parent = FovFrame
local FovStrokeUI = Instance.new("UIStroke") FovStrokeUI.Color = Color3.fromRGB(28, 28, 33) FovStrokeUI.Thickness = 1.2 FovStrokeUI.Parent = FovFrame
local FovLabel = Instance.new("TextLabel") FovLabel.Size = UDim2.new(1, 0, 0, 26) FovLabel.BackgroundTransparency = 1 FovLabel.Text = "Kích Thước Vòng FOV: " .. Settings.FOVRadius .. "px" FovLabel.TextColor3 = Color3.fromRGB(210, 210, 215) FovLabel.TextSize = 11 FovLabel.Font = Enum.Font.GothamBold FovLabel.ZIndex = 503 FovLabel.Parent = FovFrame

local DecFovBtn = Instance.new("TextButton") DecFovBtn.Size = UDim2.new(0.44, 0, 0, 24) DecFovBtn.Position = UDim2.new(0.04, 0, 0.46, 0) DecFovBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 22) DecFovBtn.Text = "- 20px" DecFovBtn.TextColor3 = Color3.fromRGB(255, 42, 95) DecFovBtn.TextSize = 11 DecFovBtn.Font = Enum.Font.GothamBold DecFovBtn.ZIndex = 503 DecFovBtn.Parent = FovFrame
local IncFovBtn = Instance.new("TextButton") IncFovBtn.Size = UDim2.new(0.44, 0, 0, 24) IncFovBtn.Position = UDim2.new(0.52, 0, 0.46, 0) IncFovBtn.BackgroundColor3 = Color3.fromRGB(18, 25, 22) IncFovBtn.Text = "+ 20px" IncFovBtn.TextColor3 = Color3.fromRGB(0, 255, 150) IncFovBtn.TextSize = 11 IncFovBtn.Font = Enum.Font.GothamBold IncFovBtn.ZIndex = 503 IncFovBtn.Parent = FovFrame

local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 5) c1.Parent = DecFovBtn
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 5) c2.Parent = IncFovBtn

DecFovBtn.MouseButton1Click:Connect(function() if Settings.FOVRadius > 40 then Settings.FOVRadius = Settings.FOVRadius - 20 FovLabel.Text = "Kích Thước Vòng FOV: " .. Settings.FOVRadius .. "px" UpdateFOV() end end)
IncFovBtn.MouseButton1Click:Connect(function() if Settings.FOVRadius < 350 then Settings.FOVRadius = Settings.FOVRadius + 20 FovLabel.Text = "Kích Thước Vòng FOV: " .. Settings.FOVRadius .. "px" UpdateFOV() end end)

local BottomPadding1 = Instance.new("Frame") BottomPadding1.Size = UDim2.new(1,0,0,10) BottomPadding1.BackgroundTransparency = 1 BottomPadding1.LayoutOrder = 999 BottomPadding1.Parent = AimContainer

-- KHỞI TẠO TAB VISUALS
CreateSectionTitle("BỘ LỌC HIỂN THỊ", VisualsContainer)
CreateMenuButton("Lọc Đồng Đội (TeamCheck)", "TeamCheck", true, VisualsContainer)

CreateSectionTitle("HỆ THỐNG ĐỒ HỌA ESP", VisualsContainer)
CreateMenuButton("Đường Kẻ Hướng (Tracers)", "Tracers", true, VisualsContainer)
CreateMenuButton("Thanh Sinh Mệnh (HealthBar)", "HealthBar", true, VisualsContainer)
CreateMenuButton("Hiển Thị Tên ID (Names)", "Names", true, VisualsContainer)
CreateMenuButton("Khoảng Cách Đo (Distance)", "Distance", true, VisualsContainer)

-- MỤC ĐẶC BIỆT MỚI THÊM VÀO
CreateSectionTitle("HẠNG MỤC ĐẶC BIỆT", VisualsContainer)
CreateMenuButton("Xuyên Tường X-Ray (Chams)", "SpecialChams", true, VisualsContainer)

local BottomPadding2 = Instance.new("Frame") BottomPadding2.Size = UDim2.new(1,0,0,10) BottomPadding2.BackgroundTransparency = 1 BottomPadding2.LayoutOrder = 999 BottomPadding2.Parent = VisualsContainer

-- ==================== CORE ENGINE ====================
local function IsPlayerVisible(TargetPlayer)
    if not Settings.WallCheck then return true end
    local Character = TargetPlayer.Character
    if not Character then return false end
    local TargetBone = Character:FindFirstChild(Settings.AimPart) or Character:FindFirstChild("Head")
    if not TargetBone then return false end
    
    local RayOrigin = Camera.CFrame.Position
    local RayDirection = (TargetBone.Position - RayOrigin).Unit * (TargetBone.Position - RayOrigin).Magnitude
    local HitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(RayOrigin, RayDirection), {LocalPlayer.Character, Camera})
    return (HitPart and HitPart:IsDescendantOf(Character))
end

local function GetClosestPlayer()
    if not Settings.Active or not Settings.Aimbot then return nil end
    local ClosestTarget = nil local MaxMouseDistance = Settings.UseFOV and Settings.FOVRadius or math.huge local CenterScreen = GetViewportCenter()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            if Player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
            local HumRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumRoot and (Camer
