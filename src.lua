repeat wait() until game:IsLoaded() -- allows the script to be placed in auto execute

wait(3)

-- Lobby check
for i, v in pairs(workspace.Enemies:GetChildren()) do
    if (v.Name == "Dummy") then
        game:GetService("ReplicatedStorage").RF:InvokeServer("Create", getgenv().client.autoplay.world, getgenv().client.autoplay.difficulty, getgenv().client.autoplay.friendsonly, getgenv().client.autoplay.hardcore)
        game:GetService("ReplicatedStorage").RF:InvokeServer("Start")
    end
end

-- Player
local Plr = game.Players.LocalPlayer
local Char = Plr.Character
local RootPart = Char.HumanoidRootPart

-- Tween service
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Body Force/No Gravity
local bv = Instance.new("BodyVelocity")
bv.Velocity = Vector3.new(0, 0, 0)
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bv.P = 9000
bv.Parent = RootPart

-- Main auto farm
RunService.Heartbeat:Connect(function()
    local Origin = RootPart.Position
    local Target, Closest = nil, math.huge
    
    for i, v in pairs(workspace.Enemies:GetChildren()) do
        repeat wait() until (v.HumanoidRootPart and RootPart ~= nil)
        
        if (v ~= nil and v.Name ~= "Dummy" and v.Enemy.Health > 0) then
            if (v:FindFirstChild("HumanoidRootPart")) then
                local dist = (Origin - v.HumanoidRootPart.Position).Magnitude
                
                if (dist < Closest) then
                    Closest = dist
                    Target = v 
                end
            end
        end
    end
    

    if (Target) then
        local Pos = Target.HumanoidRootPart.Position
        
        local TweenInfo = TweenInfo.new(math.round((Target.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude) / getgenv().client.settings.teleportspeed, Enum.EasingStyle.Linear)

        Char.Humanoid:ChangeState(10)
        
        if (Target.HumanoidRootPart and RootPart ~= nil) then
            local Tp = TweenService:Create(RootPart, TweenInfo, {
                CFrame = CFrame.new(Vector3.new(Pos.X, Pos.Y - getgenv().client.settings.offset, Pos.Z))
            })

            local Tp2 = TweenService:Create(RootPart, TweenInfo, {
                CFrame = CFrame.new(Vector3.new(Pos.X, Pos.Y + getgenv().client.settings.offset, Pos.Z))
            })
                
            if (getgenv().client.settings.below) then
                Tp:Play()
            else
                Tp2:Play()
            end
                
            if (Target:FindFirstChildOfClass("Humanoid")) then
                if (Target.Enemy.Health ~= 0) then
                    game.ReplicatedStorage.RE:FireServer("Hit", Target, Target.HumanoidRootPart.Position, Target.HumanoidRootPart.Position)
    
                    game:GetService("ReplicatedStorage").Magic:FireServer("Damage")
                    game:GetService("ReplicatedStorage").Magic:FireServer("Support")
                        
                elseif (Target.Enemy.Health == 0) then
                    Target:Destroy()
                end
            end
        end
    end
end)
