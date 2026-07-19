-- Bone <-> world transform math for the prop-mode gizmo (da_dev). The gizmo speaks WORLD space;
-- AttachEntityToEntity wants a BONE-LOCAL offset. Converting between them needs the bone's world
-- frame (position + rotation as a matrix). These are the PURE helpers that do the linear algebra;
-- the caller supplies the measured bone frame (mode_prop reads it from an identity-attached probe,
-- the exact method da_test's `prop_attach` spike proves).
--
-- GATE: the rotation convention (which GetEntityRotation read-order + which matrix sequence makes
-- bone-local -> world close) is an empirical fact that must come from `testrun prop_attach`. Until
-- that ADR lands, CONV stays nil and every function returns nil + warns. Setting CONV is the single
-- switch that turns the gizmo path on. See docs/agents/redm-research.md and (pending) an ADR.
--
-- The matrix kit + the six matToEuler decompositions are validated by round-trip (machine precision,
-- all 6 Tait-Bryan orders) before shipping — the same kit da_test/features/prop/attach_cl.lua uses.

-- ===================== LOCKED CONVENTION (proven by testrun prop_attach → ADR 0016) ==========
-- Two DISTINCT Euler orders are in play, measured empirically:
--   readOrder : arg to GetEntityRotation when reading the bone/world frame — 2 (the gizmo's native
--               order; object mode proves the gizmo round-trips SetEntityRotation-default faithfully)
--   frameSeq  : intrinsic matrix order that reproduces a readOrder-2 reading — "zxy"
--   attachSeq : the order AttachEntityToEntity interprets its INPUT offset rotation in — "yzx".
--               DIFFERENT from frameSeq: a rotation matrix is representation-independent, so we build
--               frames in frameSeq (to match the gizmo's world euler) but decode/encode the attach
--               offset in attachSeq. Both position and a full 3-axis rotation round-trip to ~0 under
--               this split (da_test prop_attach: offsetRoundTrips / "MIXED frame ro2/zxy decode yzx").
local CONV = { readOrder = 2, frameSeq = "zxy", attachSeq = "yzx" }

-- ===================== tiny matrix kit (3x3 row-major, degrees) =====================

local function rotX(d) local r = math.rad(d); local c, s = math.cos(r), math.sin(r)
    return { { 1, 0, 0 }, { 0, c, -s }, { 0, s, c } } end
local function rotY(d) local r = math.rad(d); local c, s = math.cos(r), math.sin(r)
    return { { c, 0, s }, { 0, 1, 0 }, { -s, 0, c } } end
local function rotZ(d) local r = math.rad(d); local c, s = math.cos(r), math.sin(r)
    return { { c, -s, 0 }, { s, c, 0 }, { 0, 0, 1 } } end

local AXIS = { x = rotX, y = rotY, z = rotZ }

local function matMul(a, b)
    local m = {}
    for i = 1, 3 do
        m[i] = {}
        for j = 1, 3 do
            m[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j]
        end
    end
    return m
end

local function matVec(m, v)
    return vec3(
        m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z,
        m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z,
        m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z)
end

-- transpose == inverse for an orthonormal rotation matrix
local function matT(m)
    return { { m[1][1], m[2][1], m[3][1] },
             { m[1][2], m[2][2], m[3][2] },
             { m[1][3], m[2][3], m[3][3] } }
end

-- R for euler `e` (fields .x/.y/.z, degrees) composed in `seq` order: "zxy" means Rz*Rx*Ry.
local function eulerMat(e, seq)
    local m = AXIS[seq:sub(1, 1)](e[seq:sub(1, 1)])
    for i = 2, 3 do
        local ax = seq:sub(i, i)
        m = matMul(m, AXIS[ax](e[ax]))
    end
    return m
end

local function clamp1(v) if v > 1 then return 1 elseif v < -1 then return -1 else return v end end

-- Inverse of eulerMat: extract euler (.x/.y/.z, degrees) from matrix M for the given `seq`, such
-- that eulerMat(result, seq) == M. Closed forms for all 6 intrinsic Tait-Bryan orders, validated by
-- round-trip. Middle-axis gimbal (|arg| ~ 1) degrades gracefully (one angle pinned) — offsets in
-- practice sit far from it.
local function matToEuler(M, seq)
    local r = { x = 0.0, y = 0.0, z = 0.0 }
    local a2, asin, deg = math.atan, math.asin, math.deg
    if seq == "xyz" then
        r.x = deg(a2(-M[2][3], M[3][3])); r.y = deg(asin(clamp1(M[1][3])));  r.z = deg(a2(-M[1][2], M[1][1]))
    elseif seq == "xzy" then
        r.x = deg(a2(M[3][2], M[2][2]));  r.z = deg(asin(clamp1(-M[1][2]))); r.y = deg(a2(M[1][3], M[1][1]))
    elseif seq == "yxz" then
        r.y = deg(a2(M[1][3], M[3][3]));  r.x = deg(asin(clamp1(-M[2][3]))); r.z = deg(a2(M[2][1], M[2][2]))
    elseif seq == "yzx" then
        r.y = deg(a2(-M[3][1], M[1][1])); r.z = deg(asin(clamp1(M[2][1])));  r.x = deg(a2(-M[2][3], M[2][2]))
    elseif seq == "zxy" then
        r.z = deg(a2(-M[1][2], M[2][2])); r.x = deg(asin(clamp1(M[3][2])));  r.y = deg(a2(-M[3][1], M[3][3]))
    elseif seq == "zyx" then
        r.z = deg(a2(M[2][1], M[1][1]));  r.y = deg(asin(clamp1(-M[3][1]))); r.x = deg(a2(M[3][2], M[3][3]))
    end
    return vec3(r.x, r.y, r.z)
end

-- ===================== public API (attached to da_obj) =====================

-- Euler tables come in as vec3 whose .x/.y/.z are the reading of GetEntityRotation(handle, readOrder)
-- for the bone frame and the gizmo's world transform; both in the SAME (CONV.readOrder) convention.

-- True once the empirical convention is locked (prop_attach ADR). The gizmo path checks this and
-- refuses with a clear message while false, so nothing ships half-working.
da_obj.xformReady = function()
    return CONV ~= nil
end

local function gated()
    if CONV == nil then
        log.warn("da_obj transform: prop_attach convention not locked — run `testrun prop_attach`")
        return true
    end
    return false
end

-- WORLD -> BONE-LOCAL. Given the bone's world frame (bonePos + boneEuler) and a desired world
-- transform (from the gizmo), return the offset/rotation to pass to da_obj.attach.
--   offsetPos   = Rbone^-1 * (worldPos - bonePos)
--   offsetEuler = decompose( Rbone^-1 * Rworld )
da_obj.worldToLocal = function(bonePos, boneEuler, worldPos, worldEuler)
    if gated() then return nil end
    local Rb  = eulerMat(boneEuler, CONV.frameSeq)   -- frame from a readOrder-2 reading
    local RbT = matT(Rb)
    local dp  = vec3(worldPos.x - bonePos.x, worldPos.y - bonePos.y, worldPos.z - bonePos.z)
    local offsetPos = matVec(RbT, dp)
    local Roff = matMul(RbT, eulerMat(worldEuler, CONV.frameSeq))
    return offsetPos, matToEuler(Roff, CONV.attachSeq) -- decode in the AttachEntityToEntity order
end

-- BONE-LOCAL -> WORLD (inverse; for tests / seeding a gizmo from stored offsets).
--   worldPos   = bonePos + Rbone * offsetPos
--   worldEuler = decompose( Rbone * Roffset )
da_obj.localToWorld = function(bonePos, boneEuler, localPos, localEuler)
    if gated() then return nil end
    local Rb = eulerMat(boneEuler, CONV.frameSeq)
    local wp = matVec(Rb, localPos)
    local worldPos = vec3(bonePos.x + wp.x, bonePos.y + wp.y, bonePos.z + wp.z)
    local Rw = matMul(Rb, eulerMat(localEuler, CONV.attachSeq)) -- localEuler is an attach-input offset
    return worldPos, matToEuler(Rw, CONV.frameSeq)             -- world euler in the frame order
end

-- The read-order the caller must use for GetEntityRotation when sampling the bone/world frame, so
-- mode_prop and the math agree. nil until the convention is locked.
da_obj.xformReadOrder = function()
    return CONV and CONV.readOrder or nil
end
