function rpcCreatePublicMatch(ctx : nkruntime.Context, logger : nkruntime.Logger, nk : nkruntime.Nakama, payload : string): string {

	var matchId = nk.matchCreate('pingpong');
	return JSON.stringify({ matchId });
}