--!Header("Zoom Settings")
--!SerializeField
local zoom : number = 15
--!SerializeField
local zoomMin : number = 10
--!SerializeField
local zoomMax : number = 50
--!SerializeField
local cameraFollowSpeed : number = 2.0  -- The speed at which the camera follows the player
--!SerializeField
local xOffset : number = 0.0  -- The offset in the x-axis
--!SerializeField
local yOffset : number = 0.0  -- The offset in the y-axis

local pitch : number = 0
local yaw : number = 0

local camera = self.gameObject:GetComponent(Camera)
if camera == nil then
    print("HighriseCameraController requires a Camera component on the GameObject its attached to.")
    return
end
local cameraRig : Transform = camera.transform   -- quick reference to the camera's transform

local inertiaVelocity : Vector3 = Vector3.zero;  -- the current velocity of the camera fom inertia
local inertiaMagnitude : number = 0;             -- the magnitude of the current InertiaVelocity (this is an optimization to avoid calculating it every frame)
local inertiaMultiplier : number = 2             -- A multiplier to the inertia force to make it feel more or less initially intense.
local closeMaxInitialInertia : number = 35       -- The maximum amount of force when applying inertia to the panning of the camera at closest zoom
local farMaxInitialIntertia : number = 150       -- The maximum amount of force when applying inertia to the panning of the camera at farthest zoom
local inertiaDampeningFactor : number = 0.93     -- The multiplier used to scale the inertia force back over time.

local initialZoomOfPinch : number = zoom         -- the zoom level at the start of the pinch gesture
local lastZoomScale : number = 1                 -- the scale that the pinch applied to InitialZoomOfPinch on the last frame, 1 being no change
local wasPinching : boolean = false                 -- whether the last frame was pinching (two fingers) or not

local rotation : Vector3 = Vector3.zero          -- the rotation of the camera (.y can be thought of it as the "swivel" of the camera around the Target)
local lastDirection : Vector2 = Vector2.zero     -- the direction of the last frame of the pinch gesture (for rotating the camera with touch controls)

local target = Vector3.zero                      -- the point the camera is looking at
local offset = Vector3.zero                      -- the offset from the Target

local cameraOverridden = false                   -- whether the camera has been overridden by a pan
local myChar = nil

client.localPlayer.CharacterChanged:Connect(function(player, character)
    if character then
        myChar = character
    end
end)

Input.MouseWheel:Connect(function(evt)
    if not IsActive() then
        return
    end
    if evt.delta.y < 0.0 then
        ZoomIn()
    else
        ZoomOut()
    end
end)

function IsActive()
    return camera ~= nil and camera.isActiveAndEnabled
end

Input.PinchOrDragBegan:Connect(function(evt)
    if not IsActive() then
        return
    end

    lastDirection = Vector2.zero
    ResetInertia()
end)

Input.PinchOrDragChanged:Connect(function(evt)
    if not IsActive() then
        return
    end
    if not RotateCamera(evt) then
        PanCamera(evt)
        cameraOverridden = true

    end
    if evt.isPinching then
        ZoomCamera(evt)
    end

    wasPinching = evt.isPinching
end)

Input.PinchOrDragEnded:Connect(function(evt)
    if not IsActive() then
        return
    end
    if not Input.isMouseInput then
        ApplyInertia(CalculateWorldVelocity(evt))
    end
end)

local worldUpPlane = Plane.new(Vector3.back, Vector3.new(0,0,0)) -- cached to avoid re-generating every call
function ScreenPositionToWorldPoint(camera, screenPosition)
    local ray = camera:ScreenPointToRay(screenPosition)

    local success, distance = worldUpPlane:Raycast(ray)
    if not success then
        print("HighriseCameraController Failed to cast ray down into the world. Is the camera not looking down?")
        return Vector3.zero
    end

    return ray:GetPoint(distance)
end

function PanCamera(evt)
    local lastPosition = evt.position - evt.deltaPosition
    local startPoint = ScreenPositionToWorldPoint(camera, lastPosition)
    local endPoint = ScreenPositionToWorldPoint(camera, evt.position)
    local dragAdjustment = -(endPoint - startPoint)

    target = target + dragAdjustment
end

function RotateCamera(evt)
    if Input.isMouseInput then
        if not Input.isAltPressed then
            return false
        end

        -- Full screen width drag is 360 degrees and full screen height is the pitch range
        local screenDelta = evt.position - (evt.position - evt.deltaPosition)
        local xAngle = screenDelta.x / Screen.width * 360.0
        Rotate(Vector2.new(xAngle, 0))
    else
        if not evt.isPinching then
            return false
        end

        -- First frame of pinch
        if lastDirection == Vector2.zero then
            lastDirection = evt.direction
        -- Subsequent frames of pinch. Use the delta direction between two fingers to rotate the camera
        elseif evt.direction ~= Vector2.zero then
            local deltaAngle = Vector2.SignedAngle(lastDirection, evt.direction)
            Rotate(Vector2.new(deltaAngle, 0))

            -- Update LastDirection for the next frame
            lastDirection = evt.direction
        end
    end

    return true
end

-- Pan the camera on the X/Y plane by the given amount
function Rotate(rotate)
    rotation = rotation + Vector3.new(rotate.y, rotate.x, 0)
    rotation.y = rotation.y + 3600  -- Ensure positive value
    rotation.y = rotation.y % 360  -- Ensure value is between 0 and 360
end

function ZoomIn()
    zoom = Mathf.Clamp(zoom - 1, zoomMin, zoomMax)
end

function ZoomOut()
    zoom = Mathf.Clamp(zoom + 1, zoomMin, zoomMax)
end

function ResetInertia()
    inertiaVelocity = Vector3.zero
    inertiaMagnitude = 0
end

local MaxSwipeVelocity = 400 -- the maximum velocity of a swipe to apply inertia with
function CalculateWorldVelocity(evt)
    local velocity = evt.velocity
    velocity.x = Mathf.Clamp(velocity.x, -MaxSwipeVelocity, MaxSwipeVelocity)
    velocity.y = Mathf.Clamp(velocity.y, -MaxSwipeVelocity, MaxSwipeVelocity)

    local screenStart = evt.position
    local screenEnd = evt.position + velocity

    local worldStart = ScreenPositionToWorldPoint(camera, screenStart)
    local worldEnd = ScreenPositionToWorldPoint(camera, screenEnd)

    local result = -(worldEnd - worldStart) -- swiping right means moving the camera left
    return result
end

function ApplyInertia(worldVelocity)
    local t = Easing.Quadratic((zoom - zoomMin) / (zoomMax - zoomMin)) -- closer camera means slower inertia
    local currentMaxVelocity = Mathf.Lerp(closeMaxInitialInertia, farMaxInitialIntertia, t)

    inertiaVelocity = Vector3.ClampMagnitude(worldVelocity * inertiaMultiplier, currentMaxVelocity)
    inertiaMagnitude = inertiaVelocity.magnitude
end

function CenterOn(newTarget, newZoom)
    zoom = newZoom or zoom

    target = newTarget
    zoom = Mathf.Clamp(zoom, zoomMin, zoomMax)
    offset = Vector3.new(0, 0, offset.z)
end

local InertiaMinVelocity = 0.5; -- prevents the infinite slow drag at the end of inertia
local InertiaStepDuration = 1 / 60; -- each "inertia step" is normalized to 60fps
function UpdateInertia()
    if not Input.isMouseInput and inertiaMagnitude > InertiaMinVelocity then
        local stepReduction = (1.0 - inertiaDampeningFactor) / (InertiaStepDuration / Time.deltaTime)
        local velocityDampener = 1.0 - math.min(math.max(stepReduction, 0), 1)
        inertiaVelocity = inertiaVelocity * velocityDampener
        inertiaMagnitude = inertiaMagnitude * velocityDampener
        target = target + (inertiaVelocity * Time.deltaTime)
    end
end

function UpdatePosition()
    local playerOffCenter = Vector3.Distance(myChar.gameObject.transform.position, Vector3.new(self.transform.position.x - xOffset, self.transform.position.y - yOffset, 0)) > 0.17
    if myChar then
        if myChar.isMoving then cameraOverridden = false end
        if playerOffCenter and not cameraOverridden then
            -- Get the current position of the camera and player
            local cameraPosition = camera.transform.position
            local playerPosition = myChar.transform.position
        
            -- Calculate the new position with easing
            local newPosition = Vector3.Lerp(cameraPosition, playerPosition + Vector3.new(xOffset, yOffset, 0), Time.deltaTime * cameraFollowSpeed)
            -- Keep the Z position of the camera to avoid moving it forward or backward
            newPosition.z = cameraPosition.z
        
            -- Set the new position to the camera
            camera.transform.position = newPosition
            target = newPosition
            return
        end
    else
        print("No Character")
    end

    local rotation = Quaternion.Euler(
        pitch + rotation.x,
        yaw + rotation.y,
        0
    )

    local frustumHeight = zoom
    local distance = 0 -- (frustumHeight * 0.5) / math.tan(fov * 0.5 * Mathf.Deg2Rad)
    --camera.fieldOfView = fov

    local cameraPos = Vector3.back * distance
    cameraPos = rotation * cameraPos
    cameraPos = cameraPos + target
    local cameraOffset = cameraRig.rotation * offset

    cameraRig.position = cameraPos
    cameraRig:LookAt(target)
    cameraRig.position = cameraRig.position + cameraOffset
end

function UpdateZoom()
    camera.orthographicSize = zoom
end

function self:Start()
    local startPos = self.transform.position
    CenterOn(startPos)
end

function self:Update()
    if not IsActive() then
        return
    end

    UpdateInertia()
    UpdatePosition()
    UpdateZoom()
end
