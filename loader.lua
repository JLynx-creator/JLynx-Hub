-- JLynx Hub Loader by Yağız
print("JLynx Hub Yükleniyor...")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/JLynx-creator/JLynx-Hub/main/main.lua"))()

Rayfield:Notify({
    Title = "JLynx Hub",
    Content = "Yüklendi! Insert ile aç/kapa kanka",
    Duration = 5
})