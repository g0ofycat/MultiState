--!strict
--!native
--!optimize 2

--[[ TODO:

	- Add bulk changing, creating, subscribing, etc
	- Batch changes
	- Debouncing / Queueing
	- Filter and get certain states based on their value / Searching states in general
	- Saved States using DataStores
	
]]

local StateManager = {}

local Types = require(script.StateTypes)

local StateHolders = {} :: Types.StateHolders -- // Table that holds all of the states

local StateWatchers = {} :: Types.StateWatchers -- // Holds the Subscribers

---------------------------------
-- // BASICS
---------------------------------

-- NewState(): Creates a new state given a string and a value. (Cannot have 2 states with the same name)
-- @param StateName: The name of the State
-- @param Value: The data that is held by the State
function StateManager.NewState<T>(StateName: string, Value: T): ()
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return
	end

	if StateHolders[StateName] then
		warn("State already exists: "..StateName)
		return
	end

	StateHolders[StateName] = {
		Value = Value,
		Locked = false
	}
end

-- GetState(): Returns the value of a state given the StateName.
-- @param StateName: The name of the State
function StateManager.GetState<T>(StateName: string): T?
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return nil
	end
	local state = StateHolders[StateName]
	if state then
		return state.Value
	else
		warn("There is no Value found for "..StateName)
		return nil
	end
end


-- ChangeState(): Changes a states value given a string and a value.
-- @param StateName: The name of the State
-- @param Value: The data that is held by the State
function StateManager.ChangeState<T>(StateName: string, Value: T): ()
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return
	end

	local state = StateHolders[StateName]

	if not state then 
		warn("State not found: "..StateName)
		return
	end

	if state.Value == Value then
		return
	end

	if state.Locked then
		warn("State is locked and cannot be changed: "..StateName)
		return
	end

	local oldValue = state.Value

	state.Value = Value
	
	local watchers = StateWatchers[StateName]
	
	if watchers then
		for i = #watchers, 1, -1 do -- // Backwards incrementing so it doesn't shift elements
			local watcher = watchers[i]
			task.spawn(function()
				local function errorHandler(err)
					warn("Error in StateManager callback:", err)
				end

				xpcall(function()
					watcher.Callback(Value, oldValue)
				end, errorHandler)
			end)
			if watcher.Once then
				StateManager.Unsubscribe(StateName, watcher.Callback)
			end
		end
	end
end

-- LockState(): Locks a state. When locked, you can not change the value OR delete it.
-- @param StateName: The name of the State
function StateManager.LockState(StateName: string): ()
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return
	end

	local state = StateHolders[StateName]
	if state then
		state.Locked = true
	end
end

-- UnlockState(): Unlocks a state. When unlocked, the value can be changed.
-- @param StateName: The name of the State
function StateManager.UnlockState(StateName: string): ()
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return
	end

	local state = StateHolders[StateName]
	if state then
		state.Locked = false
	end
end

-- DeleteState(): Deletes a State.
-- @param StateName: The name of the State
function StateManager.DeleteState(StateName: string): ()
	if typeof(StateName) ~= "string" then 
		warn("StateName must be a String")
		return
	end

	local state = StateHolders[StateName]

	if state and state.Locked then
		warn("Cannot delete locked state: " .. StateName)
		return
	end

	StateHolders[StateName] = nil
end

---------------------------------
-- // ADVANCED
---------------------------------

-- Subscribe(): Subscribes to a state. When subscribed, it will trigger if the states value has changed. Can subscribe to the same State.
-- @param StateName: The name of the State
-- @param Callback: The function to trigger when Subscribe() is triggered
function StateManager.Subscribe<T>(StateName: string, Callback: (newValue: T, oldValue: T) -> ()): ()
	if not StateHolders[StateName] then
		warn("Cannot subscribe to a state that doesn't exist.")
		return
	end

	if not StateWatchers[StateName] then
		StateWatchers[StateName] = {}
	end

	table.insert(StateWatchers[StateName], {Callback = Callback, Once = false})
end

-- SubscribeOnce(): Subscribes to a state once. When triggered, removes all callbacks.
-- @param StateName: The name of the State
-- @param Callback: The function to trigger when SubscribeOnce() is triggered
function StateManager.SubscribeOnce<T>(StateName: string, Callback: (newValue: T, oldValue: T) -> ()): ()
	if not StateHolders[StateName] then
		warn("Cannot subscribe to a state that doesn't exist.")
		return
	end

	if not StateWatchers[StateName] then
		StateWatchers[StateName] = {}
	end

	table.insert(StateWatchers[StateName], {Callback = Callback, Once = true})
end

-- WaitForChange(): An asynchronous function that functions the same as SubscribeOnce() except yields all code until it is triggered.
-- @param StateName: The name of the State
function StateManager.WaitForChange<T>(StateName: string): (T, T)
	local co = coroutine.running()
	if not co then
		error("WaitForChange must be called from within a coroutine")
	end

	StateManager.SubscribeOnce(StateName, function(newValue: T, oldValue: T)
		coroutine.resume(co, newValue, oldValue)
	end)

	return coroutine.yield()
end

-- Unsubscribe(): Unsubscribes from a state and a specific Callback. When setting Callback to nil, all Callbacks (and duplicates) from that state will be removed.
-- @param StateName: The name of the State	
-- @param Callback: The function to remove when Unsubscribe() is triggered
function StateManager.Unsubscribe<T>(StateName: string, Callback: (newValue: T, oldValue: T) -> ()?): ()
	local watchers = StateWatchers[StateName]
	if not watchers then return end

	if not Callback then
		StateWatchers[StateName] = nil
		return
	end

	for i = #watchers, 1, -1 do
		if watchers[i].Callback == Callback then
			table.remove(watchers, i)
		end
	end

	if #watchers == 0 then
		StateWatchers[StateName] = nil
	end
end

return StateManager
