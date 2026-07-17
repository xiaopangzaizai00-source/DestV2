-- DEST V2 - FULL SOURCE MASTER
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Anti-Crash & Clean Reset
if PlayerGui:FindFirstChild("DestV2") then PlayerGui.DestV2:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "DestV2"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 320); Main.Position = UDim2.new(0.05, 0, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true

-- 2. Hệ thống Trạng thái (States)
local States = {Noclip = false, InfJump = false, Fly = false}
local FlyingSpeed = 50

-- 3. Header
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "DEST V2 | Hội đồng FLY"
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0); Title.TextColor3 = Color3.new(1, 1, 1)

-- 4. Hàm tạo nút bấm (Clean Button)
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, 40 + (#Main:GetChildren() * 40))
    btn.Text = text; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 5. Logic chức năng (Gán vào nút)
CreateButton("Xuyên tường", function() States.Noclip = not States.Noclip end)
CreateButton("Nhảy vô hạn", function() States.InfJump = not States.InfJump end)
CreateButton("Bay (Fly)", function() States.Fly = not States.Fly end)
CreateButton("Ẩn Menu", function() Main.Visible = false end)
CreateButton("Tắt Menu", function() ScreenGui:Destroy() end)

-- 6. Vòng lặp Core (Xử lý tất cả trong 1 lần duy nhất)
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        -- Noclip
        if States.Noclip then
            for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
        
        -- Nhảy vô hạn
        if States.InfJump then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Landed then hum:ChangeState("Jumping") end
        end
        
        -- Bay
        if States.Fly then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then 
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame = hrp.CFrame + (workspace.CurrentCamera.CFrame.LookVector * 1.5)
            end
        end
    end)
end)

print("Dest V2 đã khởi chạy ổn định!")
