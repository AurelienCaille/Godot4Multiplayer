"use strict";
function InitModule(ctx, logger, nk, initializer) {
    initializer.registerRpc("healthcheck", rpcHealthCheck);
    initializer.registerRpc("createPublicMatch", rpcCreatePublicMatch);
    initializer.registerMatch("lobby", {
        matchInit,
        matchJoinAttempt,
        matchJoin,
        matchLeave,
        matchLoop,
        matchSignal,
        matchTerminate
    });
    logger.info("Javascript module loaded");
}
function rpcHealthCheck(ctx, logger, nk, payload) {
    logger.info("healthcheck rpc called");
    return JSON.stringify({
        success: true
    });
}
function rpcCreatePublicMatch(ctx, logger, nk, payload) {
    var matchId = nk.matchCreate('pingpong');
    return JSON.stringify({ matchId });
}
const tickRate = 5;
const maxEmptySec = 30;
let matchInit = function (ctx, logger, nk, params) {
    var label = {
        is_private: true,
        max_player: 8,
        open: 1,
    };
    var state = {
        label: label,
        presences: {},
        joinsInProgress: 0,
        playing: false,
        emptyTicks: 0,
    };
    return {
        state,
        tickRate,
        label: JSON.stringify(label)
    };
};
let matchJoinAttempt = function (ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
    // Check if it's a user attempting to rejoin after a disconnect.
    if (presence.userId in state.presences) {
        if (state.presences[presence.userId] === null) {
            // User rejoining after a disconnect.
            state.joinsInProgress++;
            return {
                state: state,
                accept: false,
                rejectMessage: 'already joinded',
            };
        }
    }
    // Check if match is full
    if (connectedPlayer(state) + state.joinsInProgress >= state.label.max_player) {
        return {
            state: state,
            accept: false,
            rejectMessage: 'match full'
        };
    }
    // New player attempting to connect.
    state.joinsInProgress++;
    return {
        state,
        accept: true,
    };
};
let matchJoin = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    for (const presence of presences) {
        state.presences[presence.userId] = presence;
        state.joinsInProgress--;
        // Check if we must send a message to this user to update them on the current game state.
        if (state.playing) {
            // There's a game still currently in progress, the player is re-joining after a disconnect. Give them a state update.
            let update = {};
            // Send a message to the user that just joinded.
            dispatcher.broadcastMessage(OpCode.UPDATE, JSON.stringify(update));
        }
    }
    // Check if match was open to new players, but should now be closed.
    if (Object.keys(state.presences).length >= state.label.max_player && state.label.open) {
        state.label.open = 0;
        const labelJSON = JSON.stringify(state.label);
        dispatcher.matchLabelUpdate(labelJSON);
    }
    return { state };
};
let matchLeave = function (ctx, logger, nk, dispatcher, tick, state, presences) {
    for (let presence of presences) {
        logger.info("Player: %s left match: %s.", presence.userId, ctx.matchId);
        state.presences[presence.userId] = null;
    }
    return { state };
};
let matchLoop = function (ctx, logger, nk, dispatcher, tick, state, messages) {
    logger.debug('Running match loop. Tick %d', tick);
    if (connectedPlayer(state) + state.joinsInProgress === 0) {
        state.emptyTicks++;
        if (state.emptyTicks >= maxEmptySec * tickRate) {
            // Match has been empty for too long, close it.
            logger.info('closing idle match');
            return null;
        }
    }
    let t = msecToSec(Date.now());
    // If there's no game in progress check if we can (and should) start one!
    if (!state.playing) {
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
        let msg = {};
        dispatcher.broadcastMessage(OpCode.START, JSON.stringify(msg));
        return { state };
    }
    // There's a game in progress
    // TODO: refacto gameplay loop in another script
    for (const message of messages) {
        switch (message.opCode) {
            case OpCode.MOVE:
                continue;
            default:
                // No other opcodes are expected from the client, so automatically treat it as an error.
                dispatcher.broadcastMessage(OpCode.REJECTED, null, [message.sender]);
                logger.error('Unexpected opcode received: %d', message.opCode);
        }
    }
    return { state };
};
let matchTerminate = function (ctx, logger, nk, dispatcher, tick, state, graceSeconds) {
    return { state };
};
let matchSignal = function (ctx, logger, nk, dispatcher, tick, state) {
    return { state };
};
function connectedPlayer(s) {
    let count = 0;
    for (const p of Object.keys(s.presences)) {
        if (s.presences[p] != null) {
            count++;
        }
    }
    return count;
}
// The complete set of opcodes used for communication between clients and server.
var OpCode;
(function (OpCode) {
    // New game round starting.
    OpCode[OpCode["START"] = 1] = "START";
    // Update to the state of an ongoing round.
    OpCode[OpCode["UPDATE"] = 2] = "UPDATE";
    // A game round has just completed.
    OpCode[OpCode["DONE"] = 3] = "DONE";
    // A move the player wishes to make and sends to the server.
    OpCode[OpCode["MOVE"] = 4] = "MOVE";
    // Move was rejected.
    OpCode[OpCode["REJECTED"] = 5] = "REJECTED";
})(OpCode || (OpCode = {}));
function msecToSec(n) {
    return Math.floor(n / 1000);
}
