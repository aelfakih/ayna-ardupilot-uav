-- Loiter Mode Switch Script for ArduPilot Copter (4.6.1+)
-- Listens to RC Channel 8 (three-position switch)
-- Pos 1 (Low): Cinematic (smooth, slow)
-- Pos 2 (Mid): Agile (faster, more responsive)
-- Pos 3 (High): Sports (aggressive, high performance)
-- Includes altitude control parameters for consistent behavior

local last_pos = 0
local MSG_SEVERITY_INFO = 6  -- MAV_SEVERITY_INFO for gcs:send_text

local function set_param(name, value)
    if param:set(name, value) then
        return true
    else
        gcs:send_text(MSG_SEVERITY_INFO, string.format("Failed to set %s to %d", name, value))
        return false
    end
end

local function update()
    local rc8 = rc:get_pwm(8)
    if not rc8 then
        gcs:send_text(MSG_SEVERITY_INFO, "Failed to read RC Channel 8")
        return update, 200
    end

    local pos = 0
    -- Determine switch position based on PWM value
    -- Assuming standard servo ranges: ~1000 (low), ~1500 (mid), ~2000 (high)
    if rc8 < 1250 then
        pos = 1  -- Low: Cinematic
    elseif rc8 < 1750 then
        pos = 2  -- Mid: Agile
    else
        pos = 3  -- High: Sports
    end

    if pos ~= last_pos then
        local mode_name = ""
        local success = true
        if pos == 1 then
            -- Cinematic settings (smooth loiter and altitude control)
            success = success and set_param("LOIT_SPEED", 500)      -- cm/s
            success = success and set_param("LOIT_ACC_MAX", 180)    -- cm/s^2
            success = success and set_param("LOIT_ANG_MAX", 15)     -- degrees
            success = success and set_param("LOIT_BRK_ACCEL", 180)  -- cm/s^2
            success = success and set_param("LOIT_BRK_DELAY", 1.3)  -- seconds
            success = success and set_param("LOIT_BRK_JERK", 400)   -- cm/s^3
            success = success and set_param("PILOT_ACCEL_Z", 250)   -- cm/s^2
            success = success and set_param("PILOT_SPEED_DN", 350)  -- cm/s
            success = success and set_param("PILOT_SPEED_UP", 300)  -- cm/s
            success = success and set_param("PILOT_Y_RATE", 202.5)  -- deg/s
            success = success and set_param("PILOT_Y_EXPO", 0)      -- linear yaw
            mode_name = "Cinematic"
        elseif pos == 2 then
            -- Agile settings (balanced speed and responsiveness)
            success = success and set_param("LOIT_SPEED", 800)      -- cm/s
            success = success and set_param("LOIT_ACC_MAX", 300)    -- cm/s^2
            success = success and set_param("LOIT_ANG_MAX", 25)     -- degrees
            success = success and set_param("LOIT_BRK_ACCEL", 300)  -- cm/s^2
            success = success and set_param("LOIT_BRK_DELAY", 1.0)  -- seconds
            success = success and set_param("LOIT_BRK_JERK", 600)   -- cm/s^3
            success = success and set_param("PILOT_ACCEL_Z", 400)   -- cm/s^2
            success = success and set_param("PILOT_SPEED_DN", 500)  -- cm/s
            success = success and set_param("PILOT_SPEED_UP", 450)  -- cm/s
            success = success and set_param("PILOT_Y_RATE", 300)    -- deg/s
            success = success and set_param("PILOT_Y_EXPO", 0.2)    -- slight expo
            mode_name = "Agile"
        else
            -- Sports settings (high speed, aggressive maneuvers)
            success = success and set_param("LOIT_SPEED", 1200)     -- cm/s
            success = success and set_param("LOIT_ACC_MAX", 500)    -- cm/s^2
            success = success and set_param("LOIT_ANG_MAX", 45)     -- degrees
            success = success and set_param("LOIT_BRK_ACCEL", 500)  -- cm/s^2
            success = success and set_param("LOIT_BRK_DELAY", 0.5)  -- seconds
            success = success and set_param("LOIT_BRK_JERK", 1000)  -- cm/s^3
            success = success and set_param("PILOT_ACCEL_Z", 600)   -- cm/s^2
            success = success and set_param("PILOT_SPEED_DN", 750)  -- cm/s
            success = success and set_param("PILOT_SPEED_UP", 600)  -- cm/s
            success = success and set_param("PILOT_Y_RATE", 450)    -- deg/s
            success = success and set_param("PILOT_Y_EXPO", 0.4)    -- pronounced expo
            mode_name = "Sports"
        end

        if success then
            last_pos = pos
            gcs:send_text(MSG_SEVERITY_INFO, string.format("Loiter mode switched to %s", mode_name))
        else
            gcs:send_text(MSG_SEVERITY_INFO, string.format("Error setting %s mode parameters", mode_name))
        end
    end

    return update, 200  -- Run every 200ms
end

-- Check if param and rc libraries are available
if not param or not rc then
    gcs:send_text(MSG_SEVERITY_INFO, "Script error: param or rc library not available")
    return update, 1000  -- Retry slower if initialization fails
end

gcs:send_text(MSG_SEVERITY_INFO, "Loiter mode switch script loaded")
return update, 200