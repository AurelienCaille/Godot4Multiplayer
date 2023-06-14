function InitModule(ctx : nkruntime.Context, logger : nkruntime.Logger, nk : nkruntime.Nakama, initializer : nkruntime.Initializer) {
	initializer.registerRpc("healthcheck", rpcHealthCheck);
	initializer.registerRpc("createPublicMatch", rpcCreatePublicMatch);

	initializer.registerMatch("lobby", {
		matchInit,
		matchJoinAttempt,
		matchJoin,
		matchLeave,
		matchLoop,
		matchTerminate,
		matchSignal
	});


	logger.info("Javascript module loaded");
}