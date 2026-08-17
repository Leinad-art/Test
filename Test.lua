local __nn_meta={1,14,15,27,42,14,56,4,60,11,71,27,98,24,122,7,129,13,142,4,146,7,153,8,161,36,197,187,384,139,523,1,524,3,527,277,804,15,819,9,828,17,845,35,880,7,887,33,920,5,925,247,1172,145,1317,49,1366,20,1386,128,1514,19,1533,65,1598,12,1610,8,1618,14,1632,13,1645,119,1764,11,1775,9,1784,16,1800,7,1807,32,1839,8,1847,13,1860,12,1872,16,1888,46,1934,7,1941,12,1953,21,1974,10,1984,17,2001,10,2011,13,2024,36,2060,242,2302,18,2320,22,2342,40,2382,6,2388,136,2524,31,2555,104,2659,34,2693,32,2725,4,2729,220,2949,2,2951,27,2978,14,2992,20,3012,9,3021,3,3024,7,3031,8,3039,0,3039,221,3260,8,3268,37,3305,32,3337,49,3386,13,3399,12,3411,5,3416,121,3537,268,3805,7,3812,28,3840,230,4070,16,4086,4,4090,27,4117,3,4120,24,4144,137,4281,9,4290,55,4345,8,4353,16,4369,4,4373,12,4385,2,4387,59,4446,24,4470,375,4845,8,4853,5,4858,257,5115,2,5117,12,5129,8,5137,1,5138,1,5139,36,5175,9,5184,26,5210,7,5217,5}
local __nn_cache={}
local __nn_seed=150073
local function __NNSTR(i)
 local v=__nn_cache[i]
 if v~=nil then return v end
 local o=__nn_meta[i*2-1]
 local l=__nn_meta[i*2]
 local t={}
 for j=1,l do
  local p=o+j-1
  local k=(__nn_seed+p*67+i*43+(p%13)*17)%256
  t[j]=string.char(__nn_b32.bxor(string.byte(__nn_blob,p),k))
 end
 v=table.concat(t)
 __nn_cache[i]=v
 return v
end
local API = __NNSTR(71)
local LOADER_VERSION = __NNSTR(118)
local Players = game:GetService(__NNSTR(8))
local HttpService = game:GetService(__NNSTR(5))
local CoreGui = game:GetService(__NNSTR(74))
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
repeat task.wait() until Players.LocalPlayer
LocalPlayer = Players.LocalPlayer
end
local function uiParent()
local ok, h = pcall(function()
if type(gethui) == __NNSTR(75) then
return gethui()
end
end)
if ok and h then return h end
return CoreGui
end
local parent = uiParent()
local old = parent:FindFirstChild(__NNSTR(44))
if old then old:Destroy() end
local function resolveRequest()
local env = (type(getgenv) == __NNSTR(75) and getgenv()) or _G
local candidates = {
env.request,
env.http_request,
(env.syn and env.syn.request) or nil,
(env.http and env.http.request) or nil,
(env.fluxus and env.fluxus.request) or nil,
}
for _, fn in ipairs(candidates) do
if type(fn) == __NNSTR(75) then
return fn
end
end
error(__NNSTR(81))
end
local httpRequest = resolveRequest()
local function jsonDecode(body)
local ok, data = pcall(HttpService.JSONDecode, HttpService, body or __NNSTR(76))
if ok then return data end
return nil
end
local function apiRequest(method, path, body, session, raw)
local headers = {
[__NNSTR(60)] = raw and __NNSTR(7) or __NNSTR(40),
[__NNSTR(51)] = __NNSTR(1) .. LOADER_VERSION,
[__NNSTR(54)] = __NNSTR(106),
}
local payload
if body ~= nil then
headers[__NNSTR(49)] = __NNSTR(40)
payload = HttpService:JSONEncode(body)
end
if session then
headers[__NNSTR(9)] = __NNSTR(23) .. session
end
local ok, response = pcall(httpRequest, {
Url = API .. path,
Method = method,
Headers = headers,
Body = payload,
})
if not ok then
return nil, 0, tostring(response)
end
local code = tonumber(response.StatusCode or response.Status or response.status_code or 0) or 0
local responseBody = response.Body or response.body or __NNSTR(76)
if code < 200 or code >= 300 then
local decoded = jsonDecode(responseBody)
local detail = decoded and decoded.detail or responseBody
if type(detail) == __NNSTR(84) then
detail = detail.reason or detail.code or HttpService:JSONEncode(detail)
end
return nil, code, tostring(detail or (__NNSTR(107) .. code))
end
if raw then
return responseBody, code, nil
end
return jsonDecode(responseBody), code, nil
end
local bit = bit32
local MOD = 4294967296
local K = {
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
}
local function u32(x)
return x % MOD
end
local function sha256(message)
local H = {
0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19,
}
local bitLen = #message * 8
local high = math.floor(bitLen / MOD)
local low = bitLen % MOD
message = message .. string.char(0x80)
local pad = (56 - (#message % 64)) % 64
message = message .. string.rep(__NNSTR(16), pad)
local function b(n, shift)
return bit.band(bit.rshift(n, shift), 0xff)
end
message = message .. string.char(
b(high,24), b(high,16), b(high,8), b(high,0),
b(low,24), b(low,16), b(low,8), b(low,0)
)
for chunk = 1, #message, 64 do
local W = {}
for i = 0, 15 do
local p = chunk + i * 4
local a, c, d, e = string.byte(message, p, p + 3)
W[i] = u32(bit.bor(bit.lshift(a,24), bit.lshift(c,16), bit.lshift(d,8), e))
end
for i = 16, 63 do
local x = W[i - 15]
local y = W[i - 2]
local s0 = bit.bxor(bit.rrotate(x,7), bit.rrotate(x,18), bit.rshift(x,3))
local s1 = bit.bxor(bit.rrotate(y,17), bit.rrotate(y,19), bit.rshift(y,10))
W[i] = u32(W[i - 16] + s0 + W[i - 7] + s1)
end
local a,bv,c,d,e,f,g,h = H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]
for i = 0, 63 do
local S1 = bit.bxor(bit.rrotate(e,6), bit.rrotate(e,11), bit.rrotate(e,25))
local ch = bit.bxor(bit.band(e,f), bit.band(bit.bnot(e),g))
local t1 = u32(h + S1 + ch + K[i + 1] + W[i])
local S0 = bit.bxor(bit.rrotate(a,2), bit.rrotate(a,13), bit.rrotate(a,22))
local maj = bit.bxor(bit.band(a,bv), bit.band(a,c), bit.band(bv,c))
local t2 = u32(S0 + maj)
h = g
g = f
f = e
e = u32(d + t1)
d = c
c = bv
bv = a
a = u32(t1 + t2)
end
H[1] = u32(H[1] + a)
H[2] = u32(H[2] + bv)
H[3] = u32(H[3] + c)
H[4] = u32(H[4] + d)
H[5] = u32(H[5] + e)
H[6] = u32(H[6] + f)
H[7] = u32(H[7] + g)
H[8] = u32(H[8] + h)
end
return string.format(__NNSTR(65),
H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8])
end
local TweenService = game:GetService(__NNSTR(101))
local UserInputService = game:GetService(__NNSTR(99))
local Workspace = game:GetService(__NNSTR(96))
local gui = Instance.new(__NNSTR(39))
gui.Name = __NNSTR(44)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100000
gui.Parent = parent
local function addCorner(obj, radius)
local c = Instance.new(__NNSTR(78))
c.CornerRadius = UDim.new(0, radius or 10)
c.Parent = obj
return c
end
local function addStroke(obj, color, thickness, transparency)
local s = Instance.new(__NNSTR(43))
s.Color = color
s.Thickness = thickness or 1
s.Transparency = transparency or 0
s.Parent = obj
return s
end
local function tween(obj, t, props, style, dir)
local tw = TweenService:Create(
obj,
TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
props
)
tw:Play()
return tw
end
local C = {
bg = Color3.fromRGB(12, 13, 17),
panel = Color3.fromRGB(17, 18, 23),
panel2 = Color3.fromRGB(22, 24, 30),
card = Color3.fromRGB(24, 26, 33),
cardHover = Color3.fromRGB(28, 30, 39),
border = Color3.fromRGB(44, 47, 58),
text = Color3.fromRGB(241, 242, 246),
muted = Color3.fromRGB(145, 150, 162),
dim = Color3.fromRGB(100, 105, 117),
accent = Color3.fromRGB(126, 112, 255),
accent2 = Color3.fromRGB(155, 143, 255),
warning = Color3.fromRGB(255, 184, 78),
warningBg = Color3.fromRGB(41, 31, 18),
warningBorder = Color3.fromRGB(113, 79, 34),
good = Color3.fromRGB(116, 210, 145),
bad = Color3.fromRGB(232, 112, 112),
}
local frame = Instance.new(__NNSTR(25))
frame.Name = __NNSTR(12)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Size = UDim2.fromOffset(430, 300)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(14, 15, 18)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
addCorner(frame, 14)
addStroke(frame, Color3.fromRGB(47, 50, 58), 1)
local frameScale = Instance.new(__NNSTR(117))
frameScale.Parent = frame
local function updateResponsiveScale()
local cam = Workspace.CurrentCamera
if not cam then return end
local vp = cam.ViewportSize
local scale = math.clamp(math.min(vp.X / 1280, vp.Y / 720), 0.72, 1.05)
frameScale.Scale = scale
end
updateResponsiveScale()
if Workspace.CurrentCamera then
Workspace.CurrentCamera:GetPropertyChangedSignal(__NNSTR(33)):Connect(updateResponsiveScale)
end
local title = Instance.new(__NNSTR(72))
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(24, 18)
title.Size = UDim2.new(1, -48, 0, 36)
title.Font = Enum.Font.GothamBold
title.Text = __NNSTR(87)
title.TextColor3 = Color3.fromRGB(245,245,248)
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame
local subtitle = Instance.new(__NNSTR(72))
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(24, 54)
subtitle.Size = UDim2.new(1, -48, 0, 22)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = __NNSTR(34) .. LOADER_VERSION
subtitle.TextColor3 = Color3.fromRGB(130,134,145)
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame
local info = Instance.new(__NNSTR(72))
info.BackgroundTransparency = 1
info.Position = UDim2.fromOffset(24, 88)
info.Size = UDim2.new(1, -48, 0, 54)
info.Font = Enum.Font.Gotham
info.RichText = true
info.Text = string.format(__NNSTR(59), LocalPlayer.Name, LocalPlayer.UserId)
info.TextColor3 = Color3.fromRGB(215,218,225)
info.TextSize = 15
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = frame
local status = Instance.new(__NNSTR(72))
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(24, 147)
status.Size = UDim2.new(1, -48, 0, 24)
status.Font = Enum.Font.Gotham
status.Text = __NNSTR(55)
status.TextColor3 = Color3.fromRGB(148,152,164)
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame
local function button(textValue, x, y, w)
local b = Instance.new(__NNSTR(53))
b.Position = UDim2.fromOffset(x,y)
b.Size = UDim2.fromOffset(w,44)
b.BackgroundColor3 = Color3.fromRGB(34,37,44)
b.BorderSizePixel = 0
b.AutoButtonColor = false
b.Font = Enum.Font.GothamSemibold
b.Text = textValue
b.TextColor3 = Color3.fromRGB(240,241,244)
b.TextSize = 14
b.Parent = frame
addCorner(b, 10)
b.MouseEnter:Connect(function()
if b.Active then tween(b, 0.12, {BackgroundColor3 = Color3.fromRGB(41,44,53)}) end
end)
b.MouseLeave:Connect(function()
tween(b, 0.12, {BackgroundColor3 = Color3.fromRGB(34,37,44)})
end)
return b
end
local launchFree = button(__NNSTR(110), 24, 184, 185)
local launchBeta = button(__NNSTR(21), 221, 184, 185)
launchFree.Active = false
launchBeta.Active = false
local keyBox = Instance.new(__NNSTR(41))
keyBox.Position = UDim2.fromOffset(24, 238)
keyBox.Size = UDim2.fromOffset(250, 38)
keyBox.BackgroundColor3 = Color3.fromRGB(23,25,30)
keyBox.BorderSizePixel = 0
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = __NNSTR(38)
keyBox.Text = __NNSTR(76)
keyBox.Font = Enum.Font.Gotham
keyBox.TextColor3 = Color3.fromRGB(235,237,242)
keyBox.PlaceholderColor3 = Color3.fromRGB(100,104,115)
keyBox.TextSize = 13
keyBox.Visible = false
keyBox.Parent = frame
addCorner(keyBox, 9)
local activate = button(__NNSTR(94), 286, 238, 120)
activate.Size = UDim2.fromOffset(120,38)
activate.Visible = false
local manual = Instance.new(__NNSTR(25))
manual.Name = __NNSTR(45)
manual.AnchorPoint = Vector2.new(0.5, 0.5)
manual.Position = UDim2.fromScale(0.5, 0.5)
manual.Size = UDim2.fromOffset(740, 560)
manual.BackgroundColor3 = C.panel
manual.BorderSizePixel = 0
manual.Parent = gui
addCorner(manual, 18)
local manualStroke = addStroke(manual, C.border, 1)
local manualScale = Instance.new(__NNSTR(117))
manualScale.Parent = manual
local function updateManualScale()
local cam = Workspace.CurrentCamera
if not cam then return end
local vp = cam.ViewportSize
manualScale.Scale = math.clamp(math.min((vp.X - 24) / 740, (vp.Y - 24) / 560), 0.68, 1)
end
updateManualScale()
if Workspace.CurrentCamera then
Workspace.CurrentCamera:GetPropertyChangedSignal(__NNSTR(33)):Connect(updateManualScale)
end
local topGlow = Instance.new(__NNSTR(25))
topGlow.Size = UDim2.new(1, 0, 0, 122)
topGlow.BackgroundColor3 = Color3.fromRGB(30, 27, 59)
topGlow.BorderSizePixel = 0
topGlow.Parent = manual
addCorner(topGlow, 18)
local topMask = Instance.new(__NNSTR(25))
topMask.Position = UDim2.new(0,0,1,-18)
topMask.Size = UDim2.new(1,0,0,18)
topMask.BackgroundColor3 = topGlow.BackgroundColor3
topMask.BorderSizePixel = 0
topMask.Parent = topGlow
local brand = Instance.new(__NNSTR(72))
brand.BackgroundTransparency = 1
brand.Position = UDim2.fromOffset(26, 19)
brand.Size = UDim2.fromOffset(230, 30)
brand.Font = Enum.Font.GothamBold
brand.Text = __NNSTR(87)
brand.TextColor3 = C.text
brand.TextSize = 24
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = manual
local manualBadge = Instance.new(__NNSTR(72))
manualBadge.Position = UDim2.fromOffset(26, 54)
manualBadge.Size = UDim2.fromOffset(118, 24)
manualBadge.BackgroundColor3 = Color3.fromRGB(44, 39, 87)
manualBadge.BorderSizePixel = 0
manualBadge.Font = Enum.Font.GothamSemibold
manualBadge.Text = __NNSTR(82)
manualBadge.TextColor3 = C.accent2
manualBadge.TextSize = 11
manualBadge.Parent = manual
addCorner(manualBadge, 7)
addStroke(manualBadge, Color3.fromRGB(72, 64, 139), 1)
local intro = Instance.new(__NNSTR(72))
intro.BackgroundTransparency = 1
intro.Position = UDim2.fromOffset(158, 54)
intro.Size = UDim2.new(1, -184, 0, 24)
intro.Font = Enum.Font.Gotham
intro.Text = __NNSTR(69)
intro.TextColor3 = C.muted
intro.TextSize = 12
intro.TextXAlignment = Enum.TextXAlignment.Left
intro.Parent = manual
local langHolder = Instance.new(__NNSTR(25))
langHolder.AnchorPoint = Vector2.new(1,0)
langHolder.Position = UDim2.new(1,-26,0,20)
langHolder.Size = UDim2.fromOffset(230, 42)
langHolder.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
langHolder.BorderSizePixel = 0
langHolder.Parent = manual
addCorner(langHolder, 10)
addStroke(langHolder, Color3.fromRGB(48, 50, 62), 1)
local function langButton(textValue, x)
local b = Instance.new(__NNSTR(53))
b.Position = UDim2.fromOffset(x, 4)
b.Size = UDim2.fromOffset(109, 34)
b.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
b.BorderSizePixel = 0
b.AutoButtonColor = false
b.Font = Enum.Font.GothamSemibold
b.Text = textValue
b.TextColor3 = C.muted
b.TextSize = 12
b.Parent = langHolder
addCorner(b, 8)
return b
end
local ruBtn = langButton(__NNSTR(70), 4)
local enBtn = langButton(__NNSTR(48), 117)
local content = Instance.new(__NNSTR(25))
content.Position = UDim2.fromOffset(26, 138)
content.Size = UDim2.new(1, -52, 1, -216)
content.BackgroundTransparency = 1
content.Visible = false
content.Parent = manual
local warningCard = Instance.new(__NNSTR(25))
warningCard.Size = UDim2.new(1, 0, 0, 66)
warningCard.BackgroundColor3 = C.warningBg
warningCard.BorderSizePixel = 0
warningCard.Parent = content
addCorner(warningCard, 10)
addStroke(warningCard, C.warningBorder, 1)
local warnIcon = Instance.new(__NNSTR(72))
warnIcon.BackgroundTransparency = 1
warnIcon.Position = UDim2.fromOffset(14, 0)
warnIcon.Size = UDim2.fromOffset(30, 66)
warnIcon.Font = Enum.Font.GothamBold
warnIcon.Text = __NNSTR(112)
warnIcon.TextColor3 = C.warning
warnIcon.TextSize = 20
warnIcon.Parent = warningCard
local warnTitle = Instance.new(__NNSTR(72))
warnTitle.BackgroundTransparency = 1
warnTitle.Position = UDim2.fromOffset(48, 10)
warnTitle.Size = UDim2.new(1, -64, 0, 20)
warnTitle.Font = Enum.Font.GothamSemibold
warnTitle.TextColor3 = C.warning
warnTitle.TextSize = 13
warnTitle.TextXAlignment = Enum.TextXAlignment.Left
warnTitle.Parent = warningCard
local warnSub = Instance.new(__NNSTR(72))
warnSub.BackgroundTransparency = 1
warnSub.Position = UDim2.fromOffset(48, 31)
warnSub.Size = UDim2.new(1, -64, 0, 25)
warnSub.Font = Enum.Font.Gotham
warnSub.TextColor3 = Color3.fromRGB(198, 171, 128)
warnSub.TextSize = 11
warnSub.TextXAlignment = Enum.TextXAlignment.Left
warnSub.TextWrapped = true
warnSub.Parent = warningCard
local scroll = Instance.new(__NNSTR(3))
scroll.Position = UDim2.fromOffset(0, 80)
scroll.Size = UDim2.new(1, 0, 1, -80)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(69, 64, 118)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = content
local layout = Instance.new(__NNSTR(83))
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll
local pad = Instance.new(__NNSTR(115))
pad.PaddingRight = UDim.new(0, 7)
pad.PaddingBottom = UDim.new(0, 4)
pad.Parent = scroll
local itemLabels = {}
local function makeTip(index)
local card = Instance.new(__NNSTR(25))
card.Name = __NNSTR(73) .. tostring(index)
card.Size = UDim2.new(1, -7, 0, 76)
card.BackgroundColor3 = C.card
card.BorderSizePixel = 0
card.LayoutOrder = index
card.Parent = scroll
addCorner(card, 10)
addStroke(card, Color3.fromRGB(41, 44, 54), 1)
local number = Instance.new(__NNSTR(72))
number.Position = UDim2.fromOffset(12, 20)
number.Size = UDim2.fromOffset(34, 34)
number.BackgroundColor3 = Color3.fromRGB(44, 40, 84)
number.BorderSizePixel = 0
number.Font = Enum.Font.GothamBold
number.Text = tostring(index)
number.TextColor3 = C.accent2
number.TextSize = 12
number.Parent = card
addCorner(number, 8)
local txt = Instance.new(__NNSTR(72))
txt.BackgroundTransparency = 1
txt.Position = UDim2.fromOffset(58, 10)
txt.Size = UDim2.new(1, -72, 1, -20)
txt.Font = Enum.Font.Gotham
txt.TextColor3 = Color3.fromRGB(209, 212, 220)
txt.TextSize = 13
txt.TextWrapped = true
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.TextYAlignment = Enum.TextYAlignment.Center
txt.LineHeight = 1.12
txt.Parent = card
itemLabels[index] = txt
card.MouseEnter:Connect(function()
tween(card, 0.12, {BackgroundColor3 = C.cardHover})
end)
card.MouseLeave:Connect(function()
tween(card, 0.12, {BackgroundColor3 = C.card})
end)
end
for i = 1, 7 do makeTip(i) end
local footer = Instance.new(__NNSTR(25))
footer.Position = UDim2.new(0,0,1,-68)
footer.Size = UDim2.new(1,0,0,68)
footer.BackgroundColor3 = Color3.fromRGB(15,16,21)
footer.BorderSizePixel = 0
footer.Parent = manual
local footerLine = Instance.new(__NNSTR(25))
footerLine.Size = UDim2.new(1,0,0,1)
footerLine.BackgroundColor3 = Color3.fromRGB(39,42,50)
footerLine.BorderSizePixel = 0
footerLine.Parent = footer
local footerText = Instance.new(__NNSTR(72))
footerText.BackgroundTransparency = 1
footerText.Position = UDim2.fromOffset(26, 9)
footerText.Size = UDim2.new(1, -236, 0, 48)
footerText.Font = Enum.Font.Gotham
footerText.TextColor3 = C.dim
footerText.TextSize = 10
footerText.TextWrapped = true
footerText.TextXAlignment = Enum.TextXAlignment.Left
footerText.TextYAlignment = Enum.TextYAlignment.Center
footerText.Parent = footer
local continueBtn = Instance.new(__NNSTR(53))
continueBtn.AnchorPoint = Vector2.new(1,0.5)
continueBtn.Position = UDim2.new(1,-26,.5,0)
continueBtn.Size = UDim2.fromOffset(176, 40)
continueBtn.BackgroundColor3 = Color3.fromRGB(29,31,38)
continueBtn.BorderSizePixel = 0
continueBtn.AutoButtonColor = false
continueBtn.Active = false
continueBtn.Font = Enum.Font.GothamSemibold
continueBtn.Text = __NNSTR(19)
continueBtn.TextColor3 = Color3.fromRGB(105,109,120)
continueBtn.TextSize = 12
continueBtn.Parent = footer
addCorner(continueBtn, 9)
local continueStroke = addStroke(continueBtn, Color3.fromRGB(48,51,61), 1)
local TEXT = {
ru = {
intro = __NNSTR(92),
warnTitle = __NNSTR(32),
warnSub = __NNSTR(26),
footer = __NNSTR(77),
wait = __NNSTR(58),
go = __NNSTR(29),
tips = {
__NNSTR(105),
__NNSTR(86),
__NNSTR(18),
__NNSTR(56),
__NNSTR(67),
__NNSTR(89),
__NNSTR(108),
}
},
en = {
intro = __NNSTR(46),
warnTitle = __NNSTR(64),
warnSub = __NNSTR(61),
footer = __NNSTR(63),
wait = __NNSTR(111),
go = __NNSTR(98),
tips = {
__NNSTR(14),
__NNSTR(30),
__NNSTR(27),
__NNSTR(15),
__NNSTR(37),
__NNSTR(85),
__NNSTR(95),
}
}
}
local selectedLang = nil
local countdownToken = 0
local function setLangVisual(active, inactive)
tween(active, 0.14, {BackgroundColor3 = Color3.fromRGB(50, 44, 98)})
tween(inactive, 0.14, {BackgroundColor3 = Color3.fromRGB(20, 21, 28)})
active.TextColor3 = C.text
inactive.TextColor3 = C.muted
end
local function startCountdown(lang)
countdownToken += 1
local token = countdownToken
continueBtn.Active = false
continueBtn.BackgroundColor3 = Color3.fromRGB(29,31,38)
continueBtn.TextColor3 = Color3.fromRGB(105,109,120)
continueStroke.Color = Color3.fromRGB(48,51,61)
task.spawn(function()
for sec = 5, 1, -1 do
if token ~= countdownToken or not manual.Parent then return end
continueBtn.Text = string.format(TEXT[lang].wait, sec)
task.wait(1)
end
if token ~= countdownToken or not manual.Parent then return end
continueBtn.Active = true
continueBtn.Text = TEXT[lang].go
continueBtn.BackgroundColor3 = C.accent
continueBtn.TextColor3 = Color3.fromRGB(255,255,255)
continueStroke.Color = C.accent2
end)
end
local function selectLanguage(lang)
selectedLang = lang
local t = TEXT[lang]
intro.Text = t.intro
warnTitle.Text = t.warnTitle
warnSub.Text = t.warnSub
footerText.Text = t.footer
for i = 1, 7 do
itemLabels[i].Text = t.tips[i]
end
content.Visible = true
if lang == __NNSTR(109) then
setLangVisual(ruBtn, enBtn)
else
setLangVisual(enBtn, ruBtn)
end
startCountdown(lang)
end
ruBtn.MouseButton1Click:Connect(function() selectLanguage(__NNSTR(109)) end)
enBtn.MouseButton1Click:Connect(function() selectLanguage(__NNSTR(102)) end)
continueBtn.MouseEnter:Connect(function()
if continueBtn.Active then
tween(continueBtn, .12, {BackgroundColor3 = Color3.fromRGB(140,126,255)})
end
end)
continueBtn.MouseLeave:Connect(function()
if continueBtn.Active then
tween(continueBtn, .12, {BackgroundColor3 = C.accent})
end
end)
continueBtn.MouseButton1Click:Connect(function()
if not continueBtn.Active or not selectedLang then return end
continueBtn.Active = false
tween(manualScale, .18, {Scale = manualScale.Scale * 0.97}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
tween(manual, .18, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
for _, obj in ipairs(manual:GetDescendants()) do
if obj:IsA(__NNSTR(72)) or obj:IsA(__NNSTR(53)) then
tween(obj, .16, {TextTransparency = 1})
elseif obj:IsA(__NNSTR(25)) then
tween(obj, .16, {BackgroundTransparency = 1})
elseif obj:IsA(__NNSTR(43)) then
tween(obj, .16, {Transparency = 1})
end
end
task.wait(.18)
manual:Destroy()
frame.Visible = true
frameScale.Scale = frameScale.Scale * 0.97
tween(frameScale, .20, {Scale = frameScale.Scale / 0.97}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)
local session = nil
local tier = __NNSTR(10)
local busy = false
local function setStatus(text, good)
status.Text = text
status.TextColor3 = good == true and Color3.fromRGB(116,210,145)
or good == false and Color3.fromRGB(232,112,112)
or Color3.fromRGB(148,152,164)
end
local function refreshInfo()
info.Text = string.format(__NNSTR(13), LocalPlayer.Name, LocalPlayer.UserId, string.upper(tier))
end
local function setButtons(enabled)
launchFree.Active = enabled
launchBeta.Active = enabled
launchFree.AutoButtonColor = enabled
launchBeta.AutoButtonColor = enabled
end
local function bootstrap()
setButtons(false)
local data, _, err = apiRequest(__NNSTR(100), __NNSTR(52), {
roblox_user_id = LocalPlayer.UserId,
roblox_username = LocalPlayer.Name,
loader_version = LOADER_VERSION,
})
if not data or not data.ok then
setStatus(__NNSTR(79) .. tostring(err or __NNSTR(11)), false)
return false
end
session = data.session
tier = (data.user and data.user.tier) or __NNSTR(10)
refreshInfo()
setStatus(__NNSTR(116), true)
setButtons(true)
return true
end
local function executeRelease(channel)
if busy or not session then return end
busy = true
setButtons(false)
setStatus(__NNSTR(31) .. string.upper(channel) .. __NNSTR(90), nil)
local latest, _, err = apiRequest(__NNSTR(17), __NNSTR(42) .. channel, nil, session)
if not latest or not latest.ok then
setStatus(__NNSTR(24) .. tostring(err or __NNSTR(11)), false)
busy = false
setButtons(true)
return
end
local rel = latest.release
setStatus(__NNSTR(57) .. tostring(rel.version) .. __NNSTR(93), nil)
local source, _, downloadErr = apiRequest(__NNSTR(17), rel.download_path, nil, session, true)
if not source then
setStatus(__NNSTR(62) .. tostring(downloadErr or __NNSTR(11)), false)
busy = false
setButtons(true)
return
end
setStatus(__NNSTR(6), nil)
local actual = sha256(source)
local expected = string.lower(tostring(rel.sha256 or __NNSTR(76)))
if actual ~= expected then
setStatus(__NNSTR(97), false)
busy = false
setButtons(true)
return
end
local compiler = loadstring or load
if type(compiler) ~= __NNSTR(75) then
setStatus(__NNSTR(114), false)
busy = false
setButtons(true)
return
end
local fn, compileErr = compiler(source, __NNSTR(20) .. channel .. __NNSTR(113) .. tostring(rel.version))
if not fn then
setStatus(__NNSTR(47), false)
warn(__NNSTR(104), compileErr)
busy = false
setButtons(true)
return
end
setStatus(__NNSTR(36) .. string.upper(channel) .. __NNSTR(68) .. tostring(rel.version), true)
task.wait(0.12)
gui:Destroy()
task.spawn(function()
local ok, runErr = pcall(fn)
if not ok then
warn(__NNSTR(80), runErr)
end
end)
end
launchFree.MouseButton1Click:Connect(function()
executeRelease(__NNSTR(10))
end)
launchBeta.MouseButton1Click:Connect(function()
if busy then return end
if tier == __NNSTR(4) then
executeRelease(__NNSTR(4))
return
end
keyBox.Visible = true
activate.Visible = true
setStatus(__NNSTR(88), nil)
keyBox:CaptureFocus()
end)
activate.MouseButton1Click:Connect(function()
if busy or not session then return end
local key = keyBox.Text:gsub(__NNSTR(66), __NNSTR(76)):gsub(__NNSTR(91), __NNSTR(76))
if #key < 10 then
setStatus(__NNSTR(28), false)
return
end
busy = true
activate.Active = false
setStatus(__NNSTR(22), nil)
local result, _, err = apiRequest(__NNSTR(100), __NNSTR(50), {key = key}, session)
if not result or not result.ok then
setStatus(__NNSTR(2) .. tostring(err or __NNSTR(11)), false)
activate.Active = true
busy = false
return
end
tier = __NNSTR(4)
refreshInfo()
keyBox.Visible = false
activate.Visible = false
activate.Active = true
busy = false
setStatus(__NNSTR(103), true)
task.wait(0.15)
executeRelease(__NNSTR(4))
end)
task.spawn(function()
local ok, err = pcall(bootstrap)
if not ok then
setStatus(__NNSTR(35) .. tostring(err), false)
end
end)
