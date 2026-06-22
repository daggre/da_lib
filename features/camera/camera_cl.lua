-- da_cam: programmatic game-camera movement built on the RDR3 CamSpline natives.
-- NOT the interactive WASD freecam (that's da_dev's mode_freecam) — this is the
-- cinematic primitive that splines a scripted camera between poses, plus the pose
-- math to frame a subject from a configured offset. See ADR-0010 for the
-- empirically-confirmed spline semantics.
--
-- A "pose" is { pos = {x,y,z}, rot = {x,y,z}, fov }. Camera rotation order is 2
-- (ZXY): rot.x = pitch, rot.y = roll, rot.z = yaw/heading.

local Cam = {}

local DEG = 180.0 / math.pi

-- Read a vector from either { x=, y=, z= } or an array { a, b, c }. The config
-- files use both styles, so both resolve here.
local function vget(t)
    if type(t) ~= "table" then return 0.0, 0.0, 0.0 end
    return (t.x or t[1] or 0.0) + 0.0, (t.y or t[2] or 0.0) + 0.0, (t.z or t[3] or 0.0) + 0.0
end

-- Camera rotation (pitch, roll, yaw) that looks from `from` toward `to`. Standard
-- GTA/RDR convention: heading 0 faces +Y, so yaw = atan2(-dx, dy); pitch from the
-- vertical rise over the horizontal run.
local function lookRot(from, to)
    local dx, dy, dz = to.x - from.x, to.y - from.y, to.z - from.z
    local horiz = math.sqrt(dx * dx + dy * dy)
    local pitch = math.atan(dz, horiz) * DEG
    local yaw = math.atan(-dx, dy) * DEG
    return { x = pitch, y = 0.0, z = yaw }
end

-- ---- low-level scripted cam ----

-- Create an inactive scripted cam at a pose.
Cam.create = function(pose)
    local p = pose.pos or pose
    local r = pose.rot or { x = 0.0, y = 0.0, z = 0.0 }
    return CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
        p.x + 0.0, p.y + 0.0, p.z + 0.0, r.x + 0.0, r.y + 0.0, r.z + 0.0,
        (pose.fov or 45.0) + 0.0, false, 2)
end

Cam.release = function(cam)
    if cam == nil then return end
    if IsCamActive(cam) then SetCamActive(cam, false) end
    DestroyCam(cam, false)
end

-- The live rendered camera pose — the natural start point for a spline.
Cam.currentPose = function()
    local c = GetFinalRenderedCamCoord()
    local r = GetFinalRenderedCamRot(2)
    return {
        pos = { x = c.x, y = c.y, z = c.z },
        rot = { x = r.x, y = r.y, z = r.z },
        fov = GetFinalRenderedCamFov(),
    }
end

-- Build and start a fresh spline cam over the given poses (>=2). Returns the cam
-- handle (active + rendering). opts: { duration=ms, smoothing=style, ease=bool,
-- easeTime=ms }. FOV is taken from the last node and set on the cam (the spline
-- interpolates position/rotation; fov is set, not splined — see ADR-0010).
Cam.spline = function(nodes, opts)
    opts = opts or {}
    -- spline nodes only run on a SPLINE camera (a SCRIPTED cam ignores them).
    local cam = CreateCam("DEFAULT_SPLINE_CAMERA", true)
    for _, n in ipairs(nodes) do
        local px, py, pz = vget(n.pos or n)
        local rr = n.rot or { x = 0.0, y = 0.0, z = 0.0 }
        -- p8=0 (no pre-node slowdown), p9=1 (honor the node's explicit rotation
        -- rather than auto-aiming along the path tangent — see ADR-0010).
        AddCamSplineNode(cam, px, py, pz, rr.x + 0.0, rr.y + 0.0, rr.z + 0.0,
            n.length or 1000, 0, 1)
    end
    local last = nodes[#nodes]
    if last.fov then SetCamFov(cam, last.fov + 0.0) end
    SetCamSplineDuration(cam, opts.duration or 1500)
    if opts.smoothing ~= nil then SetCamSplineSmoothingStyle(cam, opts.smoothing) end
    SetCamActive(cam, true)
    RenderScriptCams(true, opts.ease ~= false, opts.easeTime or 0, true, false)
    return cam
end

-- Convenience: spline from one pose to another.
Cam.splineFromTo = function(fromPose, toPose, opts)
    return Cam.spline({ fromPose, toPose }, opts)
end

-- Spline progress, 0.0 -> 1.0. Callers poll this to know when a move has landed.
Cam.phase = function(cam)
    return GetCamSplinePhase(cam) + 0.0
end

-- Block until a spline finishes. The phase reads 1.0 for the first frame before
-- the render engages (ADR-0010), so a naive `while phase < 0.99` exits instantly
-- and the move looks like a cut. First wait for the spline to actually START
-- (phase drops below 1 once rendering), then for it to COMPLETE. Returns true if
-- it reached the end before the timeout.
Cam.waitSpline = function(cam, timeoutMs)
    local startCap = GetGameTimer() + 500
    while Cam.phase(cam) >= 0.999 and GetGameTimer() < startCap do Citizen.Wait(0) end
    local deadline = GetGameTimer() + (timeoutMs or 4000)
    while Cam.phase(cam) < 0.99 and GetGameTimer() < deadline do Citizen.Wait(0) end
    return Cam.phase(cam) >= 0.99
end

-- ---- framing a subject ----

-- World pose to frame `entity` from a config offset. offset/look are in the
-- entity's LOCAL frame (x=right, y=forward, z=up) so framing is heading-agnostic.
Cam.poseFromOffset = function(entity, cfg)
    local ox, oy, oz = vget(cfg.offset)
    local lx, ly, lz = vget(cfg.look)
    local cp = GetOffsetFromEntityInWorldCoords(entity, ox, oy, oz)
    local lp = GetOffsetFromEntityInWorldCoords(entity, lx, ly, lz)
    local camPos = { x = cp.x, y = cp.y, z = cp.z }
    local lookPos = { x = lp.x, y = lp.y, z = lp.z }
    return { pos = camPos, rot = lookRot(camPos, lookPos), fov = cfg.fov or 45.0 }
end

-- Merge a camera config's `default` with a per-category override. Shallow: a
-- category replaces whole fields (offset/look/fov/…). The anim/light fields pass
-- through untouched — schema for the deferred follow-up, not applied here.
Cam.resolve = function(config, category)
    local out = {}
    for k, v in pairs(config.default or {}) do out[k] = v end
    local c = config.categories and category and config.categories[category]
    if c then for k, v in pairs(c) do out[k] = v end end
    return out
end

_ENV.da_cam = Cam
