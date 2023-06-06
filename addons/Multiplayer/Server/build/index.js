"use strict";
function InitModule(ctx, logger, nk, initializer) {
    initializer.registerRpc("healthcheck", rpcHealthCheck);
    logger.info("Javascript module loaded");
}
function rpcHealthCheck(ctx, logger, nk, payload) {
    logger.info("healthcheck rpc called");
    return JSON.stringify({
        success: true
    });
}
