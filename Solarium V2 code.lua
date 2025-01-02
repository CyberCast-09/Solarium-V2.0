local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables pour le rectangle
local guiEnabled = true
local rectangle = Instance.new("Frame")
rectangle.Size = UDim2.new(0, 500, 0, 200)  -- Taille du rectangle
rectangle.Position = UDim2.new(0.5, -250, 0.5, -100)  -- Position au centre
rectangle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Couleur noire
rectangle.BackgroundTransparency = 0  -- Opacité complète
rectangle.BorderRadius = UDim.new(0.1, 0)  -- Coins arrondis
rectangle.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

-- Détecter la touche RightShift pour activer/désactiver le rectangle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed then
        guiEnabled = not guiEnabled
        rectangle.Visible = guiEnabled
    end
end)

-- Fonction pour créer une ligne entre le joueur local et un autre joueur
local function createLineToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Attachement de la ligne au joueur local (curseur)
        local attachment0 = Instance.new("Attachment")
        attachment0.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        -- Attachement de la ligne au joueur cible
        local attachment1 = Instance.new("Attachment", player.Character:FindFirstChild("HumanoidRootPart"))

        -- Création de la ligne (Beam)
        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(Color3.new(1, 0, 0)) -- Rouge
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = LocalPlayer.Character
        return beam -- Renvoie la ligne pour pouvoir la supprimer plus tard
    end
end

-- Fonction pour ajouter un surlignage et une étiquette de nom autour des joueurs
local function highlightPlayer(player)
    if player ~= LocalPlayer and player.Character then
        -- Surlignage (Highlight)
        if not player.Character:FindFirstChild("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 0, 0)
            highlight.OutlineTransparency = 0
            highlight.FillTransparency = 0.5
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = player.Character
        end

        -- Création d'une étiquette de nom (BillboardGui)
        if not player.Character:FindFirstChild("NameTag") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameTag"
            billboard.Adornee = player.Character:WaitForChild("Head")
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            textLabel.TextScaled = false
            textLabel.TextSize = 14
            textLabel.Parent = billboard
            billboard.Parent = player.Character

            -- Mise à jour de l'étiquette avec la distance entre les joueurs
            RunService.RenderStepped:Connect(function()
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = player.Name .. " - " .. math.floor(distance) .. " m"
            end)
        end
    end
end

-- Fonction pour gérer la barre de santé des joueurs
local function createHealthBar(player)
    if player.Character then
        if not player.Character:FindFirstChild("HealthBar") then
            -- Création de la barre de santé
            local healthBillboard = Instance.new("BillboardGui")
            healthBillboard.Name = "HealthBar"
            healthBillboard.Adornee = player.Character:WaitForChild("Head")
            healthBillboard.Size = UDim2.new(0, 10, 0, 100)  -- Taille de la barre verticale
            healthBillboard.StudsOffset = Vector3.new(-2, 0, 0)  -- Décalage à gauche du joueur
            healthBillboard.AlwaysOnTop = true

            local backgroundFrame = Instance.new("Frame")
            backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
            backgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)  -- Fond sombre
            backgroundFrame.BackgroundTransparency = 0.5
            backgroundFrame.BorderSizePixel = 0
            backgroundFrame.Parent = healthBillboard

            local healthFrame = Instance.new("Frame")
            healthFrame.Size = UDim2.new(1, 0, 0, 100)  -- La hauteur sera ajustée
            healthFrame.BackgroundColor3 = Color3.new(0, 1, 0)  -- Vert pour la barre de santé
            healthFrame.BorderSizePixel = 0
            healthFrame.Parent = backgroundFrame

            healthBillboard.Parent = player.Character

            -- Mettre à jour la barre de santé en temps réel
            local humanoid = player.Character:WaitForChild("Humanoid")
            humanoid.HealthChanged:Connect(function()
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                healthFrame.Size = UDim2.new(1, 0, healthPercentage, 0)  -- Ajuste la hauteur de la barre
            end)
        end
    end
end

-- Fonction principale pour appliquer les effets aux joueurs
local function updatePlayerEffects()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                -- Vérifier la distance et ne créer les effets que si le joueur est dans un rayon de 800 mètres
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 800 then
                    -- Créer la ligne, la barre de vie et le surlignage
                    createLineToPlayer(player)
                    createHealthBar(player)
                    highlightPlayer(player)
                end
            end
        end
    end
end

-- Appliquer les effets aux joueurs existants
updatePlayerEffects()

-- Appliquer l'effet aux nouveaux joueurs
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updatePlayerEffects()
    end)
end)
