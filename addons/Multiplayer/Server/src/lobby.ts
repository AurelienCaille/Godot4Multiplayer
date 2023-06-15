function rpcCreatePublicMatch(ctx : nkruntime.Context, logger : nkruntime.Logger, nk : nkruntime.Nakama, payload : string): string {
	var params = {
		is_private: false
	}
	var matchId = nk.matchCreate('lobby', params);
	
	return JSON.stringify({ matchId });
}

function rpcListPublicMatch(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string): string {
	let matches: nkruntime.Match[];
	var label: MatchLabel = {
		"is_private": false,
		"max_player": 8,
		"open": 1
	};
	matches = nk.matchList(50, null, JSON.stringify(label));

	return JSON.stringify({ matches });
}