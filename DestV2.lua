-- Chờ game tải xong hoàn toàn
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Cấu hình hệ thống v3.6.2 (Chỉ giữ lại các chức năng ESP cốt lõi)
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
    -- [TỐI ƯU HÓA ESP THEO YÊU CẦU]
    TeamCheck = true,    -- Mặc định BẬT để lọc đồng đội
    Tracers = true,      -- Mặc định BẬT đường kẻ hướng
    Distance = true,     -- Mặc định BẬT hiển thị khoảng cách
    Names = true,        -- Mặc định BẬT tên ID
    HealthBar = true,    -- Mặc định BẬT thanh máu
    Active = true,
    MaxDistance = 600
}

local ESP_Connections = {}
local ESP_Objects = {}

-- KHỞI TẠO VÒNG FOV CORE GRAPHICS
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.0
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 0.6
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

-- BYPASS ANTI-CHEAT & TỐI ƯU BỘ NHỚ CHẠY NGẦM
task.spawn(function()
    while task.wait(15) do
        if not Settings.Active then break end
        collectgarbage("collect")
        setfflag("RbxCrashUploadToBacktraceEnabled", "False")
        setfflag("D3D11UseD3D11C", "False")
    end
end)

-- QUẢN LÝ GIAO DIỆN (UI)
local GUI_PARENT = nil
pcall(function() GUI_PARENT = gethui and gethui() end)
if not GUI_PARENT then
    pcall(function() GUI_PARENT = game:GetService("CoreGui") end)
end
if not GUI_PARENT or (not pcall(function() local _ = GUI_PARENT.Name end)) then
    GUI_PARENT = LocalPlayer:WaitForChild("PlayerGui")
end

-- Dọn dẹp tất cả các phiên bản cũ để tránh xung đột cấu trúc
for _, child in ipairs(GUI_PARENT:GetChildren()) do
    if child.Name:match("^DeltaX_v") then
        child:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaX_v362_LIGHT"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = GUI_PARENT

-- HÀM KÉO THẢ MENU MƯỢT MÀ
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

-- NÚT BẬT/TẮT MENU GỌN NHẸ CHO MOBILE
local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Name = "MobileToggle"
MobileToggleBtn.Size = UDim2.new(0, 42, 0, 42)
MobileToggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
MobileToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MobileToggleBtn.Text = "Δ"
MobileToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
MobileToggleBtn.TextSize = 15
MobileToggleBtn.Font = Enum.Font.GothamBold
MobileToggleBtn.ZIndex = 99999
MobileToggleBtn.Parent = ScreenGui

local MobileStroke = Instance.new("UIStroke") MobileStroke.Color = Color3.fromRGB(0, 255, 150) MobileStroke.Thickness = 1.5 MobileStroke.Parent = MobileToggleBtn
local MobileCorner = Instance.new("UICorner") MobileCorner.CornerRadius = UDim.new(0, 8) MobileCorner.Parent = MobileToggleBtn

MakeDraggable(MobileToggleBtn, MobileToggleBtn)

-- MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ZIndex = 500
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MenuStroke = Instance.new("UIStroke") MenuStroke.Color = Color3.fromRGB(0, 255, 150) MenuStroke.Thickness = 1.5 MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border MenuStroke.Parent = MainFrame
local MenuCorner = Instance.new("UICorner") MenuCorner.CornerRadius = UDim.new(0, 8) MenuCorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(4, 4, 5)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 501
TitleBar.Parent = MainFrame
local TitleBarCorner = Instance.new("UICorner") TitleBarCorner.CornerRadius = UDim.new(0, 8) TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 12)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DELTA X v3.6.2 [LIGHT]"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 12
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

local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0, 22, 0, 22) CloseBtn.Position = UDim2.new(1, -30, 0, 9) CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25) CloseBtn.Text = "×" CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60) CloseBtn.TextSize = 16 CloseBtn.Font = Enum.Font.GothamBold CloseBtn.ZIndex = 503 CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    Settings.Active = false
    for _, Con in ipairs(ESP_Connections) do if Con then Con:Disconnect() end end
    for _, Obj in ipairs(ESP_Objects) do if Obj then pcall(function() Obj.Visible = false Obj:Remove() end) end end
    ScreenGui:Destroy()
end)

-- THANH TAB ĐIỀU HƯỚNG GIAO DIỆN
local TabSelector = Instance.new("Frame") TabSelector.Size = UDim2.new(1, 0, 0, 30) TabSelector.Position = UDim2.new(0, 0, 0, 40) TabSelector.BackgroundColor3 = Color3.fromRGB(6, 6, 8) TabSelector.BorderSizePixel = 0 TabSelector.ZIndex = 501 TabSelector.Parent = MainFrame
local Tab1Btn = Instance.new("TextButton") Tab1Btn.Size = UDim2.new(0, 125, 1, 0) Tab1Btn.BackgroundTransparency = 1 Tab1Btn.Text = "AIMBOT" Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab1Btn.TextSize = 10 Tab1Btn.Font = Enum.Font.GothamBold Tab1Btn.ZIndex = 502 Tab1Btn.Parent = TabSelector
local Tab2Btn = Instance.new("TextButton") Tab2Btn.Size = UDim2.new(0, 125, 1, 0) Tab2Btn.Position = UDim2.new(0, 125, 0, 0) Tab2Btn.BackgroundTransparency = 1 Tab2Btn.Text = "VISUALS (ESP)" Tab2Btn.TextColor3 = Color3.fromRGB(140, 140, 145) Tab2Btn.TextSize = 10 Tab2Btn.Font = Enum.Font.GothamBold Tab2Btn.ZIndex = 502 Tab2Btn.Parent = TabSelector
local TabIndicator = Instance.new("Frame") TabIndicator.Size = UDim2.new(0, 113, 0, 2) TabIndicator.Position = UDim2.new(0, 6, 1, -2) TabIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 150) TabIndicator.BorderSizePixel = 0 TabIndicator.ZIndex = 503 TabIndicator.Parent = TabSelector

local AimContainer = Instance.new("ScrollingFrame") AimContainer.Size = UDim2.new(1, -6, 1, -75) AimContainer.Position = UDim2.new(0, 3, 0, 72) AimContainer.BackgroundTransparency = 1 AimContainer.BorderSizePixel = 0 AimContainer.CanvasSize = UDim2.new(0, 0, 0, 360) AimContainer.ScrollBarThickness = 1 AimContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) AimContainer.ZIndex = 501 AimContainer.Parent = MainFrame
local VisualsContainer = Instance.new("ScrollingFrame") VisualsContainer.Size = UDim2.new(1, -6, 1, -75) VisualsContainer.Position = UDim2.new(0, 3, 0, 72) VisualsContainer.BackgroundTransparency = 1 VisualsContainer.BorderSizePixel = 0 VisualsContainer.CanvasSize = UDim2.new(0, 0, 0, 240) VisualsContainer.ScrollBarThickness = 1 VisualsContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150) VisualsContainer.Visible = false VisualsContainer.ZIndex = 501 VisualsContainer.Parent = MainFrame

local L1 = Instance.new("UIListLayout") L1.Parent = AimContainer L1.SortOrder = Enum.SortOrder.LayoutOrder L1.Padding = UDim.new(0, 5) L1.HorizontalAlignment = Enum.HorizontalAlignment.Center
local L2 = Instance.new("UIListLayout") L2.Parent = VisualsContainer L2.SortOrder = Enum.SortOrder.LayoutOrder L2.Padding = UDim.new(0, 5) L2.HorizontalAlignment = Enum.HorizontalAlignment.Center

Tab1Btn.MouseButton1Click:Connect(function()
    AimContainer.Visible = true VisualsContainer.Visible = false Tab1Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab2Btn.TextColor3 = Color3.fromRGB(140, 140, 145)
    TabIndicator:TweenPosition(UDim2.new(0, 6, 1, -2), "Out", "Quad", 0.15, true)
end)
Tab2Btn.MouseButton1Click:Connect(function()
    AimContainer.Visible = false VisualsContainer.Visible = true Tab2Btn.TextColor3 = Color3.fromRGB(0, 255, 150) Tab1Btn.TextColor3 = Color3.fromRGB(140, 140, 145)
    TabIndicator:TweenPosition(UDim2.new(0, 131, 1, -2), "Out", "Quad", 0.15, true)
end)

local function CreateMenuButton(text, settingKey, startState, targetContainer)
    local Button = Instance.new("TextButton") 
    Button.Size = UDim2.new(0.94, 0, 0, 32) 
    Button.BackgroundColor3 = startState and Color3.fromRGB(15, 30, 20) or Color3.fromRGB(14, 14, 18) 
    Button.Text = text .. (startState and " • BẬT" or " • TẮT") 
    Button.TextColor3 = startState and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(160, 160, 165) 
    Button.TextSize = 10.5 
    Button.Font = Enum.Font.GothamBold 
    Button.BorderSizePixel = 0 
    Button.ZIndex = 502
    Button.Parent = targetContainer

    local ButtonCorner = Instance.new("UICorner") ButtonCorner.CornerRadius = UDim.new(0, 5) ButtonCorner.Parent = Button
    local ButtonStroke = Instance.new("UIStroke") ButtonStroke.Color = startState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(30, 30, 35) ButtonStroke.Thickness = 1.0 ButtonStroke.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if not Settings.Active then return end
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            Button.Text = text .. " • BẬT" Button.TextColor3 = Color3.fromRGB(100, 255, 180) Button.BackgroundColor3 = Color3.fromRGB(15, 30, 20) ButtonStroke.Color = Color3.fromRGB(0, 255, 150)
        else
            Button.Text = text .. " • TẮT" Button.TextColor3 = Color3.fromRGB(160, 160, 165) Button.BackgroundColor3 = Color3.fromRGB(14, 14, 18) ButtonStroke.Color = Color3.fromRGB(30, 30, 35)
        end
        UpdateFOV()
    end)
end

-- KHỞI TẠO NÚT BẤM TAB AIMBOT
CreateMenuButton("Khóa Tâm (Aimbot)", "Aimbot", true, AimContainer)
CreateMenuButton("Tự Động Ghim (Auto-Lock)", "AutoLock", true, AimContainer)
CreateMenuButton("Tự Động Bắn (Trigger)", "Triggerbot", false, AimContainer)
CreateMenuButton("Đón Đầu Băng Thông", "Prediction", true, AimContainer)
CreateMenuButton("Kiểm Tra Tường Chắn", "WallCheck", false, AimContainer)
CreateMenuButton("Vòng Giới Hạn FOV", "UseFOV", true, AimContainer)

-- NÚT CHUYỂN BỘ PHẬN GHIM CHUẨN
local TargetParts = {"Head", "UpperTorso", "HumanoidRootPart"}
local PartLabels = {Head = "ĐẦU", UpperTorso = "THÂN", HumanoidRootPart = "TRỌNG TÂM (ROOT)"}
local CurrentPartIdx = 1

local PartBtn = Instance.new("TextButton") PartBtn.Size = UDim2.new(0.94, 0, 0, 32) PartBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18) PartBtn.Text = "Vị Trí Ghim: ĐẦU" PartBtn.TextColor3 = Color3.fromRGB(210, 210, 215) PartBtn.TextSize = 10.5 PartBtn.Font = Enum.Font.GothamBold PartBtn.ZIndex = 502 PartBtn.Parent = AimContainer
local PartCorner = Instance.new("UICorner") PartCorner.CornerRadius = UDim.new(0, 5) PartCorner.Parent = PartBtn
local PartStroke = Instance.new("UIStroke") PartStroke.Color = Color3.fromRGB(30, 30, 35) PartStroke.Thickness = 1.0 PartStroke.Parent = PartBtn

PartBtn.MouseButton1Click:Connect(function()
    CurrentPartIdx = CurrentPartIdx % #TargetParts + 1
    local ChosenPart = TargetParts[CurrentPartIdx]
    Settings.AimPart = ChosenPart
    PartBtn.Text = "Vị Trí Ghim: " .. PartLabels[ChosenPart]
end)

-- THANH ĐIỀU CHỈNH KÍCH THƯỚC FOV
local FovFrame = Instance.new("Frame") FovFrame.Size = UDim2.new(0.94, 0, 0, 50) FovFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18) FovFrame.ZIndex = 502 FovFrame.Parent = AimContainer
local FovCornerUI = Instance.new("UICorner") FovCornerUI.CornerRadius = UDim.new(0, 5) FovCornerUI.Parent = FovFrame
local FovStrokeUI = Instance.new("UIStroke") FovStrokeUI.Color = Color3.fromRGB(30, 30, 35) FovStrokeUI.Thickness = 1.0 FovStrokeUI.Parent = FovFrame
local FovLabel = Instance.new("TextLabel") FovLabel.Size = UDim2.new(1, 0, 0, 22) FovLabel.BackgroundTransparency = 1 FovLabel.Text = "Tầm FOV: " .. Settings.FOVRadius .. "px" FovLabel.TextColor3 = Color3.fromRGB(210, 210, 215) FovLabel.TextSize = 10.5 FovLabel.Font = Enum.Font.GothamBold FovLabel.ZIndex = 503 FovLabel.Parent = FovFrame

local DecFovBtn = Instance.new("TextButton") DecFovBtn.Size = UDim2.new(0.44, 0, 0, 20) DecFovBtn.Position = UDim2.new(0.04, 0, 0.48, 0) DecFovBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26) DecFovBtn.Text = "- 20px" DecFovBtn.TextColor3 = Color3.fromRGB(255, 90, 90) DecFovBtn.TextSize = 10.5 DecFovBtn.Font = Enum.Font.GothamBold DecFovBtn.ZIndex = 503 DecFovBtn.Parent = FovFrame
local IncFovBtn = Instance.new("TextButton") IncFovBtn.Size = UDim2.new(0.44, 0, 0, 20) IncFovBtn.Position = UDim2.new(0.52, 0, 0.48, 0) IncFovBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26) IncFovBtn.Text = "+ 20px" IncFovBtn.TextColor3 = Color3.fromRGB(0, 255, 150) IncFovBtn.TextSize = 10.5 IncFovBtn.Font = Enum.Font.GothamBold IncFovBtn.ZIndex = 503 IncFovBtn.Parent = FovFrame

local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 4) c1.Parent = DecFovBtn
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 4) c2.Parent = IncFovBtn

DecFovBtn.MouseButton1Click:Connect(function() if Settings.FOVRadius > 40 then Settings.FOVRadius = Settings.FOVRadius - 20 FovLabel.Text = "Tầm FOV: " .. Settings.FOVRadius .. "px" UpdateFOV() end end)
IncFovBtn.MouseButton1Click:Connect(function() if Settings.FOVRadius < 350 then Settings.FOVRadius = Settings.FOVRadius + 20 FovLabel.Text = "Tầm FOV: " .. Settings.FOVRadius .. "px" UpdateFOV() end end)

-- KHỞI TẠO CÁC NÚT BẤM CỦA TAB VISUALS THEO YÊU CẦU MỚI
CreateMenuButton("Lọc Đồng Đội (Team)", "TeamCheck", true, VisualsContainer)
CreateMenuButton("Đường Kẻ Hướng (Tracers)", "Tracers", true, VisualsContainer)
CreateMenuButton("Thanh Sinh Mệnh (HP)", "HealthBar", true, VisualsContainer)
CreateMenuButton("Hiển Thị Tên ID", "Names", true, VisualsContainer)
CreateMenuButton("Khoảng Cách Đo", "Distance", true, VisualsContainer)

-- ==================== ĐỘNG CƠ CORE AIMBOT ENGINE ====================
local function IsPlayerVisible(TargetPlayer)
    if not Settings.WallCheck then return true end
    local Character = TargetPlayer.Character
    if not Character then return false end
    local TargetBone = Character:FindFirstChild(Settings.AimPart) or Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
    if not TargetBone then return false end
    
    local RayOrigin = Camera.CFrame.Position
    local RayDirection = (TargetBone.Position - RayOrigin).Unit * (TargetBone.Position - RayOrigin).Magnitude
    local HitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(RayOrigin, RayDirection), {LocalPlayer.Character, Camera})
    return (HitPart and HitPart:IsDescendantOf(Character))
end

local function GetClosestPlayer()
    local ClosestTarget = nil
    local MaxMouseDistance = Settings.UseFOV and Settings.FOVRadius or math.huge
    local CenterScreen = GetViewportCenter()

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            if Player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
            
            local HumRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumRoot and (Camera.CFrame.Position - HumRoot.Position).Magnitude > Settings.MaxDistance then continue end
            if not IsPlayerVisible(Player) then continue end

            local TargetBone = Player.Character:FindFirstChild(Settings.AimPart) or Player.Character:FindFirstChild("Head") or HumRoot
            if TargetBone then
                local Pos, OnScreen = Camera:WorldToViewportPoint(TargetBone.Position)
                if OnScreen then
                    local DistanceFromCenter = (Vector2.new(Pos.X, Pos.Y) - CenterScreen).Magnitude
                    if DistanceFromCenter < MaxMouseDistance then
                        MaxMouseDistance = DistanceFromCenter
                        ClosestTarget = Player
                    end
                end
            end
        end
    end
    return ClosestTarget
end

local ManualAim = false
table.insert(ESP_Connections, UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then ManualAim = true end end))
table.insert(ESP_Connections, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then ManualAim = false end end))

local IsShooting = false
table.insert(ESP_Connections, RunService.RenderStepped:Connect(function()
    UpdateFOV() 
    
    if Settings.Active and Settings.Aimbot and (Settings.AutoLock or ManualAim) then
        local Target = GetClosestPlayer()
        if Target and Target.Character then
            local TargetBone = Target.Character:FindFirstChild(Settings.AimPart) or Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChild("HumanoidRootPart")
            local TargetRoot = Target.Character:FindFirstChild("HumanoidRootPart")
            if TargetBone and TargetRoot then
                local TargetPosition = TargetBone.Position
                if Settings.Prediction then
         
