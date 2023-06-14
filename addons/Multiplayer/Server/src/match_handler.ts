const tickRate = 5;
const maxEmptySec = 30;

interface MatchLabel {
	open: number
	is_private: boolean
	max_player: number
}

interface State {
	// Match label
	label: MatchLabel
	// Currently connected users, or reserved spaces
	presences: {[userId: string]: nkruntime.Presence | null}
	// Number of users currently in the process of connecting to the match.
	joinsInProgress: number
	// True if there's a game currently in progress.
	playing: boolean
	// Ticks where no actions have occurred.
	emptyTicks: number

}

let matchInit: nkruntime.MatchInitFunction<State> = function (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, params: {[key: string]: string}) {
	var label: MatchLabel = {
		is_private: true,
		max_player: 8,
		open: 1,
	}

	var state: State = {
		label: label,
		presences: {},
		joinsInProgress: 0,
		playing: false,
		emptyTicks: 0,
	}

	return {
		state,
		tickRate,
		label: JSON.stringify(label)
	}
}

let matchJoinAttempt: nkruntime.MatchJoinAttemptFunction<State> = function (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State, presence: nkruntime.Presence, metadata: {[key: string]: any}) {
	// Check if it's a user attempting to rejoin after a disconnect.
	if (presence.userId in state.presences) {
		if (state.presences[presence.userId] === null) {
			// User rejoining after a disconnect.
			state.joinsInProgress++;
			return {
				state: state,
				accept: false,
				rejectMessage: 'already joinded',
			}
		}
	}

	// Check if match is full
	if (connectedPlayer(state) + state.joinsInProgress >= state.label.max_player) {
		return {
			state: state,
			accept: false,
			rejectMessage: 'match full'
		}
	}

	// New player attempting to connect.
	state.joinsInProgress++;
	return {
		state,
		accept: true,
	}
}

let matchJoin: nkruntime.MatchJoinFunction<State> = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State, presences: nkruntime.Presence[]) {
	for (const presence of presences) {
		state.presences[presence.userId] = presence;
		state.joinsInProgress--;

		// Check if we must send a message to this user to update them on the current game state.
		if (state.playing) {
			// There's a game still currently in progress, the player is re-joining after a disconnect. Give them a state update.
			let update: UpdateMessage = {}

			// Send a message to the user that just joinded.
			dispatcher.broadcastMessage(OpCode.UPDATE, JSON.stringify(update))
		}
	}

	// Check if match was open to new players, but should now be closed.
	if (Object.keys(state.presences).length >= state.label.max_player && state.label.open) {
		state.label.open = 0;
		const labelJSON = JSON.stringify(state.label);
		dispatcher.matchLabelUpdate(labelJSON);
	}

		return {state};
}


let matchLeave: nkruntime.MatchLeaveFunction<State> = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State, presences: nkruntime.Presence[]) {
	for (let presence of presences) {
		logger.info("Player: %s left match: %s.", presence.userId, ctx.matchId);
		state.presences[presence.userId] = null;
	}

	return {state};
}

let matchLoop: nkruntime.MatchLoopFunction<State> = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State, messages: nkruntime.MatchMessage[]) {
	logger.debug('Running match loop. Tick %d', tick);

	if (connectedPlayer(state) + state.joinsInProgress ===0) {
		state.emptyTicks++;
		if (state.emptyTicks >= maxEmptySec * tickRate) {
			// Match has been empty for too long, close it.
			logger.info('closing idle match');
			return null;
		}
	}

	let t = msecToSec(Date.now());

	// If there's no game in progress check if we can (and should) start one!
	if(!state.playing) {
		// Betweeen games any disconnected users are purged, there's no in-progress game for them to return to anyway.
		for (let userID in state.presences) {
			if (state.presences[userID] === null) {
				delete state.presences[userID];
			}
		}

		// Check if we need to update the label so the match advertises itself as open to join.
		if (Object.keys(state.presences).length < state.label.max_player && state.label.open != 1) {
			state.label.open = 1;
			let labelJSON = JSON.stringify(state.label);
			dispatcher.matchLabelUpdate(labelJSON);
		}

		// We can start a game! Set up the game state and prepare players.
		state.playing = true;
		
		// Notify the players a new game has started.
		let msg: StartMessage = {};
		dispatcher.broadcastMessage(OpCode.START, JSON.stringify(msg));

		return { state };
	}

	// There's a game in progress
	// TODO: refacto gameplay loop in another script
	for (const message of messages) {
		switch(message.opCode) {
			case OpCode.MOVE:
				continue;
			default:
				// No other opcodes are expected from the client, so automatically treat it as an error.
				dispatcher.broadcastMessage(OpCode.REJECTED, null, [message.sender]);
				logger.error('Unexpected opcode received: %d', message.opCode);
		}
	}

	return { state };
}

let matchTerminate: nkruntime.MatchTerminateFunction<State> = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State, graceSeconds: number) {
	return { state };
}

let matchSignal: nkruntime.MatchSignalFunction<State> = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, dispatcher: nkruntime.MatchDispatcher, tick: number, state: State) {
	return { state };
}



function connectedPlayer(s: State): number {
	let count = 0;
	for(const p of Object.keys(s.presences)) {
		if (s.presences[p] != null) {
			count++;
		}
	}

	return count;
}

interface UpdateMessage {
	// WIP
}

interface StartMessage {
	// WIP
}

// The complete set of opcodes used for communication between clients and server.
enum OpCode {
	// New game round starting.
	START = 1,
	// Update to the state of an ongoing round.
	UPDATE = 2,
	// A game round has just completed.
	DONE = 3,
	// A move the player wishes to make and sends to the server.
	MOVE = 4,
	// Move was rejected.
	REJECTED = 5
}

function msecToSec(n: number): number {
    return Math.floor(n / 1000);
}