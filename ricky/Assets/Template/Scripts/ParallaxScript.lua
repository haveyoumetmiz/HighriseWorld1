--!Type(Client)

--!SerializeField
local Cam : GameObject = nil

--!SerializeField
local parallaxFactor : Vector2 = nil
-- Parallax Factor Explanation:
-- Values of (1, 1) mean the sprite moves at the same speed as the camera (no parallax effect).
-- Values less than 1 mean the sprite moves slower than the camera (parallax effect).
-- Values greater than 1 mean the sprite moves faster than the camera (reverse parallax effect).

local startPos : Vector3 = nil
local camStartPos : Vector3 = nil

function self:Awake()
    Cam = GameObject.FindGameObjectWithTag("MainCamera")
    startPos = self.transform.position
    camStartPos = Cam.transform.position
end

function self:Update()
    -- Get the current camera position
    local camPos = Cam.transform.position

    -- Calculate the distance the camera has moved from its initial position
    local camDistX = camPos.x - camStartPos.x
    local camDistY = camPos.y - camStartPos.y

    -- Calculate the parallax effect based on the initial position and the camera's movement
    local distX = camDistX * parallaxFactor.x
    local distY = camDistY * parallaxFactor.y

    -- Construct the new Vector3
    local dist = Vector3.new(distX, distY, 0)

    -- Update the position relative to the initial position
    self.transform.position = startPos + dist
end
