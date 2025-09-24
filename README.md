# MultiState

A lightweight **state management module** for Roblox that lets you create, track, and react to named states across your game.
It supports subscriptions, one-time listeners, queued updates, and state locking, making it easy to maintain global or per-system states.

## Features
- **Create & manage named states** with any Lua value.
- **Subscribe / SubscribeOnce** to react when a state changes.
- **Lock / Unlock** states to prevent unwanted modifications or deletion.
- **Queued updates** via `ChangeStateQueue` for rapid-fire changes (processed on `RunService.Heartbeat`).
- **Async waiting** using `WaitForChange` that yields until a state updates.

## Quick Start

```lua
-- // Create a state
StateManager.NewState("Score", 0)

-- // Subscribe to changes
StateManager.Subscribe("Score", function(newValue, oldValue)
    print(("Score changed: %d → %d"):format(oldValue, newValue))
end)

-- // Change state value
StateManager.ChangeState("Score", 100)
```

## API

### `NewState(StateName: string, Value: any)`
Create a new state. Warns if the state name already exists.

### `GetState(StateName: string): any?`
Returns the current value of a state or `nil` if it doesn’t exist.

### `ChangeState(StateName: string, Value: any)`
Immediately updates a state’s value and fires any subscribers.  
Does nothing if the value is unchanged or the state is locked.

### `ChangeStateQueue(StateName: string, Value: any)`
Queues a state change to be applied on the next `Heartbeat`.  
Useful when making rapid changes to the same state.

### `Subscribe(StateName: string, Callback: (newValue, oldValue) -> ())`
Registers a callback that fires every time the state changes.

### `SubscribeOnce(StateName: string, Callback: (newValue, oldValue) -> ())`
Same as `Subscribe` but automatically unsubscribes after the first trigger.

### `WaitForChange(StateName: string): (newValue, oldValue)`
Yields the calling coroutine until the state changes, then returns new and old values.  
Wrap in `task.spawn` if you don’t want to block the main thread.

### `Unsubscribe(StateName: string, Callback?: function)`
Removes a specific callback or **all** callbacks if `Callback` is nil.

### `LockState(StateName: string)`
Locks the state so it cannot be changed or deleted.

### `UnlockState(StateName: string)`
Unlocks the state to allow changes.

### `DeleteState(StateName: string)`
Deletes the state unless it’s locked.

## Example

```lua
local StateManager = require(path.to.MultiState)

-- // Basic states
StateManager.NewState("PlayerName", "DefaultPlayer")
StateManager.NewState("Score", 0)

-- // React to name change
StateManager.Subscribe("PlayerName", function(newName, oldName)
    print(`Player name changed from "{oldName}" to "{newName}"`)
end)

StateManager.ChangeState("PlayerName", "Alice")
StateManager.ChangeState("Score", 150)

-- // One-time subscription
StateManager.SubscribeOnce("Score", function(newScore, oldScore)
    print(`Score milestone: {oldScore} -> {newScore}`)
end)
StateManager.ChangeState("Score", 200)

-- // Locking
StateManager.NewState("GameVersion", "1.0.0")
StateManager.LockState("GameVersion")
StateManager.ChangeState("GameVersion", "2.0.0") -- // Warns and fails

-- // Async wait
task.spawn(function()
    local newVal, oldVal = StateManager.WaitForChange("IsReady")
    print(`IsReady changed from {tostring(oldVal)} to {tostring(newVal)}`)
end)

StateManager.NewState("IsReady", false)
StateManager.ChangeState("IsReady", true)
```

## Notes
- All queued changes via `ChangeStateQueue` are processed each `Heartbeat`.
- If a state is locked, `ChangeState`, `ChangeStateQueue`, or `DeleteState` will warn and skip the operation.
- Callbacks run in separate tasks and are wrapped in `xpcall` to prevent errors from breaking execution.