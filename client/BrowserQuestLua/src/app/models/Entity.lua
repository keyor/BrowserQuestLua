
require("cocos.cocos2d.json")
local Entity = class("Entity")
local Utilitys = import(".Utilitys")
local Direction = import(".Direction")
local Game = import(".Game").getInstance()


Entity.ANIMATION_DELAY = 0.2


Entity.TYPE_NONE = 0
Entity.TYPE_WARRIOR = 1

-- Mobs
Entity.TYPE_RAT = 101
Entity.TYPE_SKELETON = 102
Entity.TYPE_GOBLIN = 103
Entity.TYPE_OGRE = 104
Entity.TYPE_SPECTRE = 105
Entity.TYPE_CRAB = 106
Entity.TYPE_BAT = 107
Entity.TYPE_WIZARD = 108
Entity.TYPE_EYE = 109
Entity.TYPE_SNAKE = 110
Entity.TYPE_SKELETON2 = 111
Entity.TYPE_BOSS = 112
Entity.TYPE_DEATHKNIGHT = 113

-- armors
Entity.TYPE_FIREFOX = 201
Entity.TYPE_CLOTHARMOR = 202
Entity.TYPE_LEATHERARMOR = 203
Entity.TYPE_MAILARMOR = 204
Entity.TYPE_PLATEARMOR = 205
Entity.TYPE_REDARMOR = 206
Entity.TYPE_GOLDENARMOR = 207

-- objects
Entity.TYPE_FLASK = 301
Entity.TYPE_BURGER = 302
Entity.TYPE_CHEST = 303
Entity.TYPE_FIREPOTION = 304
Entity.TYPE_CAKE = 305

-- NPCs
Entity.TYPE_GUARD = 401
Entity.TYPE_KING = 402
Entity.TYPE_OCTOCAT = 403
Entity.TYPE_VILLAGEGIRL = 404
Entity.TYPE_VILLAGER = 405
Entity.TYPE_PRIEST = 406
Entity.TYPE_SCIENTIST = 407
Entity.TYPE_AGENT = 408
Entity.TYPE_RICK = 409
Entity.TYPE_NYAN = 410
Entity.TYPE_SORCERER = 411
Entity.TYPE_BEACHNPC = 412
Entity.TYPE_FORESTNPC = 413
Entity.TYPE_DESERTNPC = 414
Entity.TYPE_LAVANPC = 415
Entity.TYPE_CODER = 416

-- weapons
Entity.TYPE_SWORD1 = 501
Entity.TYPE_SWORD2 = 502
Entity.TYPE_REDSWORD = 503
Entity.TYPE_GOLDENSWORD = 504
Entity.TYPE_MORNINGSTAR = 505
Entity.TYPE_AXE = 506
Entity.TYPE_BLUESWORD = 507


Entity.VIEW_TAG_SPRITE = 101


function Entity:ctor(args)
	self.imageName_ = args.image
	self.id = 0
	self.type_ = 0
end

function Entity:getView()
	if self.view_ then
		return self.view_
	end

	self.view_ = display.newNode()

	self:loadJson_()

	-- cloth
	local texture = display.loadImage(app:getResPath(self.imageName_))
	local frame = display.newSpriteFrame(texture,
			cc.rect(0, 0, self.json_.width * app:getScale(), self.json_.height * app:getScale()))
	display.newSprite(frame):addTo(self.view_, 1, Entity.VIEW_TAG_SPRITE)

	return self.view_
end

function Entity:setType(entityType)
	self.type_ = entityType
end

function Entity:play(actionName)
	local frames = self:getFrames_(actionName)
	if not frames then
		printError("Entity:play invalid action name:%s", actionName)
	end
	self.view_:playAnimationForever(display.newAnimation(frames, Entity.ANIMATION_DELAY))
end

function Entity:walk(pos)
	-- body
end

function Entity:walkStep(dir)
	if self.isWalking then
		printInfo("Entity:walkStep is walking just return")
		return
	end

	local pos
	local cur = table.clone(self.curPos_)
	if Direction.UP == dir then
		cur.y = cur.y - 1
	elseif Direction.DOWN == dir then
		cur.y = cur.y + 1
	elseif Direction.LEFT == dir then
		cur.x = cur.x - 1
	elseif Direction.RIGHT == dir then
		cur.x = cur.x + 1
	end

	-- TODO check the cur pos is valid

	pos = cur
	local args = Utilitys.pos2px(pos)
	args.time = Entity.ANIMATION_DELAY
	args.onComplete = function()
		self.isWalking = false
	end
	self.curPos_ = pos
	self.isWalking = true
	self.view_:moveTo(args)
end

function Entity:setMapPos(pos)
	self.curPos_ = pos
	self.view_:setPosition(Utilitys.pos2px(pos))
end

function Entity:loadJson_()
	local jsonFileName = "sprites/" .. string.gsub(self.imageName_, ".png", ".json")
	local fileContent = cc.FileUtils:getInstance():getStringFromFile(jsonFileName)
	self.json_ = json.decode(fileContent)
end

function Entity:getFrames_(aniType)
	aniType = aniType or "idle"

	local json = self.json_[aniType]
	if not json then
		local spos, epos = string.find(aniType, "_")
		if spos then
			local newAniType = string.gsub(aniType, "(%a)", function(str)
				if "left" == str then
					return "right"
				elseif "right" == str then
					return "left"
				elseif "up" == str then
					return "down"
				elseif "down" == str then
					return "up"
				end
			end)

			json = self.json_[newAniType]
		else
			local newAniType = aniType .. "_down"
			json = self.json_["animations"][newAniType]
		end
	end
	if not json then
		printError("Entity:getAnimation aniType:%s", aniType)
		return
	end

	local texture = display.loadImage(app:getResPath(self.imageName_))
	local width = self.json_.width * app:getScale()
	local height = self.json_.height * app:getScale()

	local frames = {}
	for i=1,json.length do
		local frame = display.newSpriteFrame(texture,
			cc.rect(width * (i - 1), height * json.row, width, height))
        frames[#frames + 1] = frame
	end

	return frames
end


return Entity
