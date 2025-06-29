local StateManager = require(game.ReplicatedStorage.MultiState)

function OnStateChanged(New, Old)
	print("Hello has changed! Old: "..tostring(Old)..". New: "..tostring(New)..".")
end

StateManager.NewState("Hello", false)

StateManager.NewState("Numbers", 102)

StateManager.Subscribe("Hello", OnStateChanged)

print(tostring(StateManager.GetState("Hello")))

StateManager.ChangeState("Hello", true)

StateManager.ChangeState("Hello", "Pan")

StateManager.Unsubscribe("Hello", OnStateChanged)

StateManager.ChangeState("Hello", 13.214)

StateManager.ChangeState("Numbers", 10)

print(StateManager.GetState("Hello"))

print(StateManager.GetState("Numbers"))
