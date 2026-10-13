#!/usr/bin/env node

import { startOpenAIOAuthServer } from "openai-oauth";
import readline from "node:readline";

const RETRY_DELAY_MS = 5_000;

async function startServer() {
    try {
        const running = await startOpenAIOAuthServer({});
        console.error("OpenAI-compatible endpoint ready at", running.url);
    } catch (error) {
        console.error("Failed to start OpenAI OAuth server; retrying...", error);
        setTimeout(startServer, RETRY_DELAY_MS);
    }
}

void startServer();

const input = readline.createInterface({ input: process.stdin });
input.on("line", (line) => {
    try {
        const request = JSON.parse(line);
        switch(request.method) {
        case "initialize":
            const response = {
                jsonrpc: "2.0",
                id: request.id,
                result: {
                    protocolVersion: "2024-11-05",
                    capabilities: {},
                    serverInfo: {
                        name: "sample",
                        version: "0.0.0",
                    },
                },
            };
            process.stdout.write(`${JSON.stringify(response)}\n`);
            break;
        }
    } catch {
        // Ignore malformed JSON-RPC messages.
    }
});
