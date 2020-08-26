local super = Class("Container", Component).getSuperclass()function Container:init()	super.init(self)	self.components = ArrayList("table")	self.nativeContainer = nil	self.focus = nil		self.focusTraversalPolicy = nil		self.focusCycleRoot = false	self.focusTraversalPolicyProvider = false	self:setFocusCycleRoot(true)	return selfendfunction Container:add(comp, index, constraints)--[[	local index = nil	local constraints = nil	if(a) then		if(type(a) == "number") then			index = a		elseif(type(a) == "table") then			constraints = a		end	end	if(b) then		if(type(b) == "number") then			index = b		elseif(type(b) == "table") then			constraints = b		end	end]]	return self:addImpl(comp, index, constraints)endfunction Container:addImpl(comp, index, constraints)	if(comp ~= nil) then		--if (index and (index > self.components:size() or (index < 0 and index ~= -1))) then		--	outputDebugString("illegal component position")		--end				if(self:checkAddToSelf(comp)) then return nil end				if(comp.parent ~= nil) then			comp.parent:remove(comp)			--if (index and index > self.components:size()) then			--	outputDebugString("illegal component position")			--end		end			self.components:add(comp)		comp.parent = self		comp:invalidateIfValid()		comp:addNotify()		return comp	end	return nilendfunction Container:checkAddToSelf(comp)	if (instanceOf(comp,Container)) then		local cn = self		while(cn ~= nil) do			if (cn == comp) then				outputDebugString("adding container's parent to itself")				return true			end			cn = cn.parent		end	end	return falseendfunction Container:remove(comp)	if(comp and comp.parent == self) then		comp:removeNotify()		self.components:remove(comp)		comp.parent = nil	endendfunction Container:getComponentAt(x, y)	if (not self:contains(x, y)) then	    return nil	end	local components = self:zIndexComponents()	local normalComponents = {}	if (#components) then		for k,component in pairs(components) do			if(component ~= nil and component:contains(x-component.x,y-component.y) and component:isShowing()) then				if(instanceOf(component, Container)) then					local subComponent = component:getComponentAt(x-component.x,y-component.y)					if(subComponent ~= nil) then						return subComponent					end					return self				end				table.insert(normalComponents, component)			end		end	end		if (#normalComponents) then		for k,component in pairs(normalComponents) do			return component		end	end	return selfendfunction Container:addNotify()	self.nativeContainer = Graphics.getInstance()endfunction Container:removeNotify()endfunction Container:paintComponent(g)	if (self:isShowing() and not self.components:isEmpty()) then		for k,component in ipairs(self:printComponents()) do			if(component ~= nil and component:isShowing()) then				component:paint(g)			end		end	endendfunction Container:processEvent(e)	--if (instanceOf(e,ContainerEvent)) then	--	self:processContainerEvent(e)	--	return	--end	if (instanceOf(e,MouseEvent)) then		local id = e:getID()		if(id == MouseEvent.MOUSE_WHEEL) then			self:processMouseWheelEvent(e)		else			self:processMouseEvent(e)		end		return	end	super.processEvent(self,e)endfunction Container:revertComponents()	local cid = {}	local components = {}		for k, v in pairs( self.cid ) do		if(self.components.table[v.index]:isShowing()) then			--outputDebugString('index ='.. self.components[v.index].name)		end		table.insert(cid, v)	end	table.sort(cid,function ( a , b) return a.index > b.index end )	for k, v in pairs( cid ) do		if(self.components.table[v.index]:isShowing()) then			--outputDebugString('index ='.. self.components[v.index].name)		end		components[v.index] = self.components.table[v.id]	end	return componentsendfunction Container:zIndexComponents()	local components = {}	for k, v in pairs(self.components.table) do		table.insert(components, v)	end	table.sort(components, function ( a , b) 		--if(a:isShowing() and not b:isShowing()) then		--	return true		--end		return a.zOrder > b.zOrder  	end )	return componentsendfunction Container:printComponents()	local components = {}	for k, v in pairs(self.components.table) do		table.insert(components, v)	end	table.sort(components, function ( a , b) 		return a.zOrder < b.zOrder  	end)	return componentsendfunction Container:reverseComponents(e)	local cid = {}	local components = {}	if(MouseEvent.MOUSE_PRESSED == e:getID()) then		--outputChatBox("ordenando")		components = self:zIndexComponents()		--[[		for k, v in pairs( self.cid ) do			--outputDebugString('index ='..v.index)			table.insert(cid, v)		end		table.sort(cid,function ( a , b) return a.index > b.index end )		for k, v in pairs( cid ) do			--outputDebugString('index ='..v.index)			components[v.index] = self.components[v.id]		end		]]	end	return componentsendfunction Container:processMouseEvent(e)	self.nativeContainer = Toolkit.getNativeContainer()		local id = e:getID()			--[[	self.mouseEventTarget = true	if (self.mouseEventTarget ~= nil) then	    if( id == MouseEvent.MOUSE_ENTERED or		    id == MouseEvent.MOUSE_EXITED) then		elseif(true) then			case MouseEvent::MOUSE_PRESSED:			//retargetMouseEvent(mouseEventTarget, id, e);			break;			case MouseEvent::GUI_MOUSE_RELEASED:				//retargetMouseEvent(mouseEventTarget, id, e);			break;			case MouseEvent::GUI_MOUSE_CLICKED:			if (mouseOver == m_mouseEventTarget) {				//retargetMouseEvent(mouseOver, id, e);			}			break;			case MouseEvent::GUI_MOUSE_MOVED:				RetargetMouseEvent(m_mouseEventTarget,id,e);			break;			case MouseEvent::GUI_MOUSE_DRAGGED:				if (IsMouseGrab(e)) {					//retargetMouseEvent(mouseEventTarget, id, e);				}			break;			case MouseEvent::GUI_MOUSE_WHEEL:				if (dbg.on && mouseOver != null) {					dbg.println("LD retargeting mouse wheel to " +									mouseOver.getName() + ", " +									mouseOver.getClass());				}				retargetMouseEvent(mouseOver, id, e);			break;	    }		end	    --e:consume()    end	]]	if (not e:isConsumed() and self:isShowing() and not self.components:isEmpty()) then		for k,component in pairs(self:reverseComponents(e)) do					if(component ~= nil and component:contains(e.x-component.x, e.y-component.y) and component:isShowing()) then				if(instanceOf(component,Container)) then					local child = component					e:translatePoint(-child.x,-child.y)					if(child:processMouseEvent(e) or not self.mouseMotionListener) then						return true					end				elseif(component.mouseMotionListener) then					e:translatePoint(-component.x,-component.y)					component:processMouseMotionEvent(e)					return true				end			end		end	end	if(self.mouseMotionListener) then		super.processMouseMotionEvent(self, e)		e:consume()	end	super.processMouseEvent(self, e)	return e:isConsumed()endfunction Container:isContainer()    return trueendfunction Container:getComponents()    return self.componentsendfunction Container:setFocusCycleRoot(focusCycleRoot)	local oldFocusCycleRoot = self.focusCycleRoot	self.focusCycleRoot = focusCycleRoot;	self:firePropertyChange("focusCycleRoot", oldFocusCycleRoot, focusCycleRoot);end	function Container:isFocusCycleRoot(container)	if(container) then        if (self:isFocusCycleRoot() and container == self) then            return true        else            return super.isFocusCycleRoot(self, container)        end	end	return self.focusCycleRootendfunction Container:isFocusTraversalPolicyProvider()	return self.focusTraversalPolicyProviderendfunction Container:getFocusTraversalPolicy()	if (not self:isFocusTraversalPolicyProvider() and not self:isFocusCycleRoot()) then		return nil	end	local policy = self.focusTraversalPolicy	if (policy ~= nil) then		return policy	end	local rootAncestor = self:getFocusCycleRootAncestor()	if (rootAncestor ~= nil) then		return rootAncestor:getFocusTraversalPolicy()	else		return KeyboardFocusManager.getCurrentKeyboardFocusManager():getDefaultFocusTraversalPolicy()	endend