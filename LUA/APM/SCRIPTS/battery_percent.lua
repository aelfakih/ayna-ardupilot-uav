-- battery_status.lua
-- This program computes the % battery left before
-- battery failsafe kicks in.
local SCRIPT_NAME = 'BatteryStatus'

-- pick your "local 0%" reference
local MAH_EMPTY   = param:get("BATT_LOW_MAH") or 0   -- mAh failsafe level
local VOLT_EMPTY  = param:get("BATT_LOW_VOLT") or 0     -- voltage failsafe
local CAPACITY    = param:get("BATT_CAPACITY") or 0

-- OSD placement
local OSD_X = 20
local OSD_Y = 14

function update()
    -- Instance 0 (first battery)
    local percent   = battery:capacity_remaining_pct(0) or 0
    local consumed  = battery:consumed_mah(0) or 0
    local voltage   = battery:voltage(0) or 0
    
    -- Local sanity check:
    -- Remaining percent based on your failsafe definition
    local local_pct = 100
    if MAH_EMPTY > 0 and CAPACITY > 0 then
        local_pct = 100 * (1 - (consumed ) / (CAPACITY - MAH_EMPTY))
        if local_pct < 0 then local_pct = 0 end
--    elseif VOLT_EMPTY > 0 then
--        -- normalize voltage (rough estimate: 3.5v/cell is "empty", 4.2v full)
--        -- assumes 6S pack, adjust as needed
--        local cells = math.floor((voltage / 3.0) + 0.5)  -- rough cell count detect
--        local v_per_cell = voltage / math.max(cells,1)
--        local_pct = 100 * (v_per_cell - VOLT_EMPTY) / (4.2 - VOLT_EMPTY)
--        if local_pct > 100 then local_pct = 100 end
--        if local_pct < 0 then local_pct = 0 end
    end

    -- GCS debug messages

    if local_pct > 30 then
        gcs:send_text(6, string.format("BatteryStatus: %.2f Remaining", 
        local_pct ))
   else
        gcs:send_text(3, string.format("%.2f Battery Remaining", 
        local_pct))
   end

    return update, 60000  -- update every 60 seconds
end

gcs:send_text(6, SCRIPT_NAME .. ": Loaded")

return update, 60000
