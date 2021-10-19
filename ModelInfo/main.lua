local defaultOptions = {
    { "InfoNum", VALUE, 0, 0, 5 },
    { "Frame", BOOL, 1 },
    { "Color", COLOR, RED },
}

local fileBitmap
local fileWidth
local fileHeight

local function getInfoFileName(aNum)
    local suffix = ""
    if aNum > 0 then
        suffix = suffix .. "-" .. aNum
    end
    local modelInfo = model.getInfo()
    return "/INFO/" .. modelInfo["name"] .. "-model-info" .. suffix .. ".jpg"
end

local function loadBitmap(aNum)
    local filePath = getInfoFileName(aNum)
    fileBitmap = Bitmap.open(filePath)
    fileWidth, fileHeight = Bitmap.getSize(fileBitmap)
end

local function createWidget(aZone, aOptions)
    loadBitmap(aOptions.InfoNum)
    local lWidget = { zone=aZone, options=aOptions }
    return lWidget
end

local function updateWidget(aWidget, aOptions)
    loadBitmap(aOptions.InfoNum)
    aWidget.options = aOptions
end

local function refreshWidget(aWidget)
    local x = aWidget.zone.x
    local y = aWidget.zone.y
    local w = aWidget.zone.w
    local h = aWidget.zone.h

    if aWidget.options.Frame == 1 then
        lcd.setColor(CUSTOM_COLOR, aWidget.options.Color)
        lcd.drawRectangle(x, y, w, h, CUSTOM_COLOR)
        x = x + 1
        y = y + 1
        w = w - 2
        h = h - 2
    end

    if fileWidth > 0 and fileHeight > 0 then
        local scaleX = w / fileWidth
        local scaleY = h / fileHeight

        local scale = scaleX
        if scaleX > scaleY then
            scale = scaleY
        end

        local pW = fileWidth * scale
        local pH = fileHeight * scale

        local sW = w - pW
        if sW > 0 then
            sW = sW + 1
        end

        local sH = h - pH
        if sH > 0 then
            sH = sH + 1
        end

        local rX = math.floor(x + (sW/2))
        local rY = math.floor(y + (sH/2))

        scale = math.floor(scale * 100)
	    lcd.drawBitmap(fileBitmap, rX, rY, scale)
    else
        local fontOptions = SMLSIZE
        local filePath = getInfoFileName(aWidget.options.InfoNum)
        lcd.drawText(x+5, y+2, "File not found!", fontOptions)
        lcd.drawText(x+5, y+14, "Please, put file to", fontOptions)
        lcd.drawText(x+5, y+26, "> " .. filePath, fontOptions)
        lcd.drawText(x+5, y+38, "Recommended: " .. w .. "x" .. h .. " size", fontOptions)
    end
end

local function backgroundWidget(aWidget)

end

return { name="ModelInfo", options=defaultOptions, create=createWidget, update=updateWidget, refresh=refreshWidget, background=backgroundWidget }
