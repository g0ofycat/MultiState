--!strict

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

export type QueuedState = {
	OldValue: any,
	NewValue: any
}

export type QueuedStates = { [string]: QueuedState }

export type ChangeQueue = { string }

return nil
