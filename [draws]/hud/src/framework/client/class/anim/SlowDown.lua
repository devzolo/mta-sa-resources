local super = Class("SlowDown", LuaObject).getSuperclass()function SlowDown:init(component, speedX, speedY, easing)	super.init(self)	self.offsets = {component:getX(), component:getY(), Graphics.getInstance():getWidth(), Graphics.getInstance():getHeight()}	self.sx = speedX*0.3	self.sy = speedY*0.3	self.tick = getTickCount()	self.time = 3000	self.component = component	self.startX = component:getX()	self.startY = component:getY()		self.easing = easing	return selfendfunction SlowDown:setBounds(x, y, w, h)	self.offsets = {x, y, w, h}	return selfendfunction SlowDown:process()	self.length = self.length + getFrameTime()	local prog = self.length/(self.time/1000)	if length <= (self.time/1000) then		local startX = self.startX		local startY = self.startY		local maxX = self.offsets[3]		local maxY = self.offsets[4]		local easing		if not self.easing then 			easing = getEasingValue(prog, "OutQuad")		else			easing = getEasingValue(prog, self.easing)		end		local addX = easing*(self.sx)		local addY = easing*(self.sy)				local newX = self.startX - addX		local newY = self.startY - addY		if newX < 0 then newX = 0 end		if newX > maxX then newX = maxX end		if newY < 0 then newY = 0 end		if newY > maxY then newY = maxY end		self.component:setLocation(newX, newY)	else		self:toEnd()	endendfunction SlowDown:toEnd()	local newX = self.startX - self.sx	local newY = self.startY - self.sy	if newX < self.minX then newX = self.minY end	if newX > self.maxX then newX = self.maxX end	if newY < self.minY then newY = self.minY end	if newY > self.maxY then newY = self.maxY end	self.component:setLocation(newX, newY)end