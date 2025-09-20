-- battery_status.lua
local SCRIPT_NAME = 'UsableBatteryStatus'

-- pick your "local 0%" reference
local MAH_EMPTY   = param:get("BATT_LOW_MAH") or 0   -- mAh failsafe level
local VOLT_EMPTY  = param:get("BATT_LOW_VOLT") or 0     -- voltage failsafe
local CAPACITY    = param:get("BATT_CAPACITY") or 0
local loop_count  = 60000


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
    end

    -- GCS debug messages

    if local_pct > 30 then
        gcs:send_text(6, string.format("%s: %.2f Remaining",SCRIPT_NAME, local_pct ))
   else
        gcs:send_text(3, string.format("[%.2f] Remaining",local_pct ))
   end

    return update, loop_count
end

gcs:send_text(6, SCRIPT_NAME .. ": Loaded")

return update, loop_count
