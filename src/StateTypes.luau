--!strict

export type StateManager = {
	--// Basic operations
	NewState: <T>(StateName: string, Value: T) -> (),
	GetState: <T>(StateName: string) -> T?,
	ChangeState: <T>(StateName: string, Value: T) -> (),
	DeleteState: (StateName: string) -> (),

	-- // State locking
	LockState: (StateName: string) -> (),
	UnlockState: (StateName: string) -> (),

	-- // Subscriptions
	Subscribe: <T>(StateName: string, callback: (newValue: T, oldValue: T) -> ()) -> (),
	SubscribeOnce: <T>(StateName: string, callback: (newValue: T, oldValue: T) -> ()) -> (),
	Unsubscribe: <T>(StateName: string, callback: ((newValue: T, oldValue: T) -> ())?) -> (),

	-- // Async operations
	WaitForChange: <T>(StateName: string) -> (T, T),
	WaitForChangeAsync: <T>(StateName: string) -> (T, T),
}

export type StateValue<T> = {
	Value: T,
	Locked: boolean,
}

export type StateHolders = {
	[string]: StateValue<any>
}

export type StateWatcher = {
	Callback: (newValue: any, oldValue: any) -> (),
	Once: boolean
}

export type StateWatchers = {
	[string]: { StateWatcher }
}

return nil
