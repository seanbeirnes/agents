// OpenCode plugin: passes tool calls to the shared hooks/guard.sh.
//
// OpenCode plugins can block a tool call (by throwing) but can't ask for
// approval, so anything guard.sh would ask about is blocked here with a
// message telling the agent to ask the user first.

import { spawnSync } from "node:child_process";
import { realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

// This file is symlinked into ~/.config/opencode/plugins/, so resolve the
// link to find the repository and guard.sh next to it.
const repo = dirname(dirname(dirname(realpathSync(fileURLToPath(import.meta.url)))));
const guardScript = join(repo, "hooks", "guard.sh");

function guard(mode: "bash" | "path", input: string): void {
  const result = spawnSync("sh", [guardScript, mode], { input, encoding: "utf8" });
  const reason = (result.stderr ?? "").trim();

  if (result.status === 0) return;
  if (result.status === 3) {
    throw new Error(`${reason} Ask the user for permission before trying this again.`);
  }
  throw new Error(reason || `Blocked by guard (${guardScript} failed to run).`);
}

export const Guard = async () => ({
  "tool.execute.before": async (input: { tool: string }, output: { args: Record<string, unknown> }) => {
    const { args } = output;

    if (input.tool === "bash" && typeof args.command === "string") {
      guard("bash", args.command);
    } else if (["read", "edit", "write"].includes(input.tool) && typeof args.filePath === "string") {
      guard("path", args.filePath);
    }
  },
});
