--[[
    chip.lua: a simple 2D game framework built off of Love2D
    Copyright (C) 2024  swordcube

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

---
--- @class chip.core.Group : chip.core.Actor
--- 
--- An object which represents a group of actors.
---
local Group = Actor:extend("Group", ...)

function Group:constructor()
    Group.super.constructor(self)

    ---
    --- @protected
    ---
    self._members = {} --- @type table<chip.core.Actor>

    ---
    --- @protected
    ---
    self._length = 0 --- @type integer
end

---
--- Returns a list of all members in this group.
---
function Group:getMembers()
    return self._members
end

---
--- Returns the amount of members in this group.
---
function Group:getLength()
    return self._length
end

---
--- Updates all of this group's members.
--- 
--- @param  delta  number  The time since the last frame. (in seconds)
---
function Group:update(delta)
    local members = self._members
    for i = 1, self._length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() then
            actor:update(delta)
        end
    end
end

---
--- Draws all of this group's members to the screen.
---
function Group:draw()
    local cam = Camera.currentCamera
    if cam then
        cam:attach()
    end
    local members = self._members
    for i = 1, self._length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() and actor:isVisible() then
            if actor:is(CanvasLayer) then
                if cam then
                    cam:detach()
                end
                actor:draw()
                if cam then
                    cam:attach()
                end
            else
                actor:draw()
            end
        end
    end
    if cam then
        cam:detach()
    end
end

---
--- Adds an actor to this group.
--- 
--- @param  actor  chip.core.Actor  The actor to add.
---
function Group:add(actor)
    if actor == nil then
        print("Cannot add an invalid actor to this group!")
        return
    end
    if table.contains(self._members, actor) then
        print("This group already contains that actor!")
        return
    end
    actor._parent = self
    self._length = self._length + 1
    table.insert(self._members, actor)
end

---
--- Inserts an actor at the specified index in this group.
--- 
--- @param  idx    integer          The index to insert the actor at.
--- @param  actor  chip.core.Actor  The actor to insert.
---
function Group:insert(idx, actor)
    if actor == nil then
        print("Cannot add an invalid actor to this group!")
        return
    end
    if table.contains(self._members, actor) then
        print("This group already contains that actor!")
        return
    end
    actor._parent = self
    self._length = self._length + 1
    table.insert(self._members, idx, actor)
end

---
--- Removes an actor from this group.
--- 
--- @param  actor  chip.core.Actor  The actor to remove.
---
function Group:remove(actor)
    if actor == nil then
        print("Cannot remove an invalid actor from this group!")
        return
    end
    if not table.contains(self._members, actor) then
        print("This group does not contain that actor!")
        return
    end
    actor._parent = nil
    self._length = self._length - 1
    table.removeItem(self._members, actor)
end

---
--- Moves an actor in this group to the specified index.
--- 
--- @param  actor  chip.core.Actor  The actor to move.
--- @param  idx    integer          The index to move the actor to.
---
function Group:move(actor, idx)
    if actor == nil then
        print("Cannot move an invalid actor in this group!")
        return
    end
    if not table.contains(self._members, actor) then
        print("This group does not contain that actor!")
        return
    end
    table.removeItem(self._members, actor)
    table.insert(self._members, idx, actor)
end

---
--- The function that gets called when
--- this group receives an input event.
--- 
--- @param  event  chip.input.InputEvent
---
function Group:input(event)
    for i = 1, self._length do
        local actor = self._members[i] --- @type chip.core.Actor
        actor:input(event)
    end
end

function Group:findMinX()
    return self._length == 0 and self._x or self:_findMinXHelper()
end

function Group:findMaxX()
    return self._length == 0 and self._x or self:_findMaxXHelper()
end

function Group:findMinY()
    return self._length == 0 and self._y or self:_findMinYHelper()
end

function Group:findMaxY()
    return self._length == 0 and self._y or self:_findMaxYHelper()
end

function Group:getWidth()
    if self._length == 0 then
        return 0
    end
    return self:_findMaxXHelper() - self:_findMinXHelper()
end

function Group:getHeight()
    if self._length == 0 then
        return 0
    end
    return self:_findMaxYHelper() - self:_findMinYHelper()
end

---
--- Frees all of this group's members.
---
function Group:free()
    for i = 1, self._length do
        local actor = self._members[i] --- @type chip.core.Actor
        actor._parent = nil
        actor:free()
    end
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Group:_findMinXHelper()
    local value = math.huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local minX = 0.0
            if member:is(Group) then
                minX = member:findMinX()
            else
                minX = member:getX()
            end
            if minX < value then
                value = minX
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMaxXHelper()
    local value = -math.huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local maxX = 0.0
            if member:is(Group) then
                maxX = member:findMaxX()
            else
                maxX = member:getX() + member:getWidth()
            end
            if maxX > value then
                value = maxX
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMinYHelper()
    local value = math.huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local minY = 0.0
            if member:is(Group) then
                minY = member:findMinY()
            elseif member:is(Actor2D) then
                minY = member:getY()
            end
            if minY < value then
                value = minY
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMaxYHelper()
    local value = -math.huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local maxY = 0.0
            if member:is(Group) then
                maxY = member:findMaxY()
            elseif member:is(Actor2D) then
                maxY = member:getY() + member:getHeight()
            end
            if maxY > value then
                value = maxY
            end
        end
    end
    return value
end

return Group