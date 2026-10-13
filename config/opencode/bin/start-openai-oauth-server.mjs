#!/usr/bin/env node

import { startOpenAIOAuthServer } from "openai-oauth";
import readline from "node:readline";

const running = await startOpenAIOAuthServer({});
console.error("OpenAI-compatible endpoint ready at", running.url);

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
