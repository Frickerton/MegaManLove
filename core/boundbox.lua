local _floor = math.floor
local _ceil = math.ceil
local _clamp = math.clamp
local _min = math.min
local _max = math.max
local _round = math.round
local _dist2d = math.dist2d

function rectOverlapsRect(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
    x2 < x1 + w1 and
    y1 < y2 + h2 and
    y2 < y1 + h1
end

function pointOverlapsRect(x1, y1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
    x2 < x1 and
    y1 < y2 + h2 and
    y2 < y1
end

function pointOverlapsPoint(x1, y1, x2, y2)
  return x1 == x2 and y1 == y2
end

function circleOverlapsCircle(x1, y1, r1, x2, y2, r2)
  return _dist2d(x1, y1, x2, y2) <= r1 + r2
end

function roundCircleOverlapsCircle(x1, y1, r1, x2, y2, r2)
  return _round(_dist2d(x1, y1, x2, y2)) <= r1 + r2
end

function pointOverlapsCircle(x1, y1, x2, y2, r2)
  return _dist2d(x1, y1, x2, y2) <= r2
end

function circleOverlapsRect(x1, y1, r1, x2, y2, w2, h2)
  return (((x1 - _max(x2, _min(x1, x2 + w2))) ^ 2) + ((y1 - _max(y2, _min(y1, y2 + h2))) ^ 2)) < r1 ^ 2
end

local _pointOverlapsRect = pointOverlapsRect
local _pointOverlapsCircle = pointOverlapsCircle
local _roundCircleOverlapsCircle = roundCircleOverlapsCircle
local _rectOverlapsRect = rectOverlapsRect

function imageOverlapsRect(x, y, data, x2, y2, w2, h2)
  if _rectOverlapsRect(x, y, data:getWidth(), data:getHeight(), x2, y2, w2, h2) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x), 0, neww), _clamp(_ceil(x2-x)+w2, 0, neww) do
      for yi=_clamp(_floor(y2-y), 0, newh), _clamp(_ceil(y2-y)+h2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _rectOverlapsRect(x + xi, y + yi, 1, 1, x2, y2, w2, h2) then
          return true
        end
      end
    end
  end
  return false
end

local _circleOverlapsRect = circleOverlapsRect

function imageOverlapsCircle(x, y, data, x2, y2, r2)
  if _circleOverlapsRect(x2, y2, r2, x, y, data:getWidth(), data:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x)-r2, 0, neww), _clamp(_ceil(x2-x)+r2, 0, neww) do
      for yi=_clamp(_floor(y2-y)-r2, 0, newh), _clamp(_ceil(y2-y)+r2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _circleOverlapsRect(x2, y2, r2, x + xi, y + yi, 1, 1) then
          return true
        end
      end
    end
  end
  return false
end

function _roundImageOverlapsCircle(x, y, data, x2, y2, r2)
  if _roundCircleOverlapsRect(x2, y2, r2, x, y, data:getWidth(), data:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    
    for xi=_clamp(_floor(x2-x)-r2, 0, neww), _clamp(_ceil(x2-x)+r2, 0, neww) do
      for yi=_clamp(_floor(y2-y)-r2, 0, newh), _clamp(_ceil(y2-y)+r2, 0, newh) do
        local _, _, _, a = data:getPixel(xi, yi)
        if a > 0 and _roundCircleOverlapsRect(x2, y2, r2, x + xi, y + yi, 1, 1) then
          return true
        end
      end
    end
  end
  return false
end

local function _imageOverlapsImage(x, y, data, x2, y2, data2)
  if _rectOverlapsRect(x, y, data:getWidth(), data:getHeight(), x2, y2, data2:getWidth(), data2:getHeight()) then
    local neww, newh = data:getWidth()-1, data:getHeight()-1
    local neww2, newh2 = data2:getWidth()-1, data2:getHeight()-1
    
    for xi=_clamp(_floor(x2-x), 0, neww), _clamp(_ceil(x2-x)+w2, 0, neww) do
      for yi=_clamp(_floor(y2-y), 0, newh), _clamp(_ceil(y2-y)+h2, 0, newh) do
        for xi2=_clamp(_floor(x-x2), 0, neww2), _clamp(_ceil(x-x2)+w, 0, neww2) do
          for yi2=_clamp(_floor(y-y2), 0, newh2), _clamp(_ceil(y-y2)+h, 0, newh2) do
            local _, _, _, a = data:getPixel(xi, yi)
            local _, _, _, a2 = data2:getPixel(xi2, yi2)
            if a > 0 and a2 > 0 and _rectOverlapsRect(x + xi, y + yi, 1, 1, x2 + xi2, y2 + yi2, 1, 1) then
              return true
            end
          end
        end
      end
    end
  end
  return false
end