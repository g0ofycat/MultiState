local StateManager = require(game.ReplicatedStorage.MultiState)

print("=== Basic Usage ===")

-- // EXAMPLE 1: Basics
function OnPlayerNameChanged(newName: string, oldName: string)
    print(`Player name changed from "{oldName}" to "{newName}"`)
end

StateManager.NewState("PlayerName", "DefaultPlayer")
StateManager.NewState("Score", 0)
StateManager.NewState("IsReady", false)

StateManager.Subscribe("PlayerName", OnPlayerNameChanged)

print("Current player name:", StateManager.GetState("PlayerName"))
print("Current score:", StateManager.GetState("Score"))

StateManager.ChangeState("PlayerName", "Alice")
StateManager.ChangeState("PlayerName", "Bob")
StateManager.ChangeState("Score", 150)

print("\n=== Advanced Features ===")

-- // EXAMPLE 2: State Locking
StateManager.NewState("GameVersion", "1.0.0")
StateManager.LockState("GameVersion")
StateManager.ChangeState("GameVersion", "2.0.0") -- // Will warn and fail

-- // EXAMPLE 3: One-time Subscription
StateManager.SubscribeOnce("Score", function(newScore: number, oldScore: number)
    print(`Score milestone reached: {oldScore} -> {newScore}`)
end)

StateManager.ChangeState("Score", 200) -- // Triggers once
StateManager.ChangeState("Score", 250) -- // Won't trigger again

-- // EXAMPLE 4: Async Waiting
task.spawn(function() -- // Wrap since it yields thread
	local newValue, oldValue = StateManager.WaitForChange("IsReady")
    print(`Player: Changed from {tostring(oldValue)} to {tostring(newValue)}`)
end)

task.wait(1)

StateManager.ChangeState("IsReady", true)

-- // EXAMPLE 5: Complex Data Types
StateManager.NewState("PlayerStats", {
    Health = 100,
    Mana = 50,
    Level = 1
})

StateManager.Subscribe("PlayerStats", function(newStats, oldStats)
    print("New level:", newStats.Level)
end)

StateManager.ChangeState("PlayerStats", {
    Health = 120,
    Mana = 75,
    Level = 2
})

-- // Cleanup
StateManager.Unsubscribe("PlayerName", OnPlayerNameChanged)
StateManager.DeleteState("PlayerName")

print("\n=== Final State ===")
print("Score:", StateManager.GetState("Score"))
print("Is Ready:", StateManager.GetState("IsReady"))
print("Game Version:", StateManager.GetState("GameVersion"))
