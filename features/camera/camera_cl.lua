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

-- Unit forward vector for a camera rotation (order 2, ZXY): yaw = rot.z, pitch =
-- rot.x. Inverse of lookRot's convention (yaw 0 faces +Y).
local function forwardVec(rot)
    local yaw = (rot.z or 0.0) / DEG
    local pitch = (rot.x or 0.0) / DEG
    local cp = math.cos(pitch)
    return -math.sin(yaw) * cp, math.cos(yaw) * cp, math.sin(pitch)
end

local function vlen(x, y, z) return math.sqrt(x * x + y * y + z * z) end

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

-- A bowed midpoint that swings the camera AROUND the subject rather than letting a
-- straight 2-node spline chord-cut across it (which skims the head when the start
-- pose is off to the side or behind). Both the start and target cameras aim at the
-- subject, so the closest approach of their forward rays is ~the pivot to orbit.
-- The midpoint sits on the angular bisector at the average orbit radius, which
-- bows outward from the chord and clears the head. Returns a pose, or nil when the
-- swing is small enough (< `minAngle` deg) that a straight spline already reads
-- fine. nil is also returned for degenerate geometry (near-parallel rays, subject
-- behind a camera) so the caller falls back to a plain spline.
Cam.arcMidpoint = function(from, to, minAngle)
    minAngle = minAngle or 50.0
    local fp, tp = from.pos, to.pos

    local f1x, f1y, f1z = forwardVec(from.rot)
    local f2x, f2y, f2z = forwardVec(to.rot)
    local rx, ry, rz = fp.x - tp.x, fp.y - tp.y, fp.z - tp.z
    local b = f1x * f2x + f1y * f2y + f1z * f2z   -- dot of unit dirs
    local denom = 1.0 - b * b
    if denom < 1e-4 then return nil end           -- near-parallel: no stable pivot
    local d = f1x * rx + f1y * ry + f1z * rz
    local e = f2x * rx + f2y * ry + f2z * rz
    local t1 = (b * e - d) / denom
    local t2 = (e - b * d) / denom
    if t1 <= 0.0 or t2 <= 0.0 then return nil end -- subject behind a camera

    -- pivot = midpoint of the two rays' closest approach
    local pvx = (fp.x + f1x * t1 + tp.x + f2x * t2) * 0.5
    local pvy = (fp.y + f1y * t1 + tp.y + f2y * t2) * 0.5
    local pvz = (fp.z + f1z * t1 + tp.z + f2z * t2) * 0.5

    local v1x, v1y, v1z = fp.x - pvx, fp.y - pvy, fp.z - pvz
    local v2x, v2y, v2z = tp.x - pvx, tp.y - pvy, tp.z - pvz
    local r1, r2 = vlen(v1x, v1y, v1z), vlen(v2x, v2y, v2z)
    if r1 < 0.01 or r2 < 0.01 then return nil end
    local u1x, u1y, u1z = v1x / r1, v1y / r1, v1z / r1
    local u2x, u2y, u2z = v2x / r2, v2y / r2, v2z / r2

    local cosang = u1x * u2x + u1y * u2y + u1z * u2z
    if cosang > math.cos(minAngle / DEG) then return nil end  -- small swing: straight is fine

    -- angular bisector = the arc's mid direction around the pivot
    local bx, by, bz = u1x + u2x, u1y + u2y, u1z + u2z
    local bl = vlen(bx, by, bz)
    if bl < 1e-3 then
        -- ~180° (start directly behind): bisector is degenerate, so swing sideways
        -- (horizontal perpendicular to the start dir) to orbit past the side, not
        -- straight over the head.
        bx, by, bz = -u1y, u1x, 0.0
        bl = vlen(bx, by, bz)
        if bl < 1e-3 then bx, by, bz, bl = 1.0, 0.0, 0.0, 1.0 end
    end
    bx, by, bz = bx / bl, by / bl, bz / bl

    local radius = (r1 + r2) * 0.5
    local midPos = { x = pvx + bx * radius, y = pvy + by * radius, z = pvz + bz * radius }
    return { pos = midPos, rot = lookRot(midPos, { x = pvx, y = pvy, z = pvz }), fov = from.fov }
end

-- Like splineFromTo, but inserts an arc midpoint for large swings so the camera
-- curves around the subject instead of cutting across it. opts.minAngle (deg)
-- tunes the threshold.
Cam.splineArc = function(fromPose, toPose, opts)
    local mid = Cam.arcMidpoint(fromPose, toPose, opts and opts.minAngle)
    if mid then
        return Cam.spline({ fromPose, mid, toPose }, opts)
    end
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
