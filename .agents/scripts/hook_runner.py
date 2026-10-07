#!/usr/bin/env python3
"""Kapiert Antigravity Lifecycle Hook Handler

Receives JSON on stdin and outputs JSON on stdout according to the Antigravity Hook contract.
"""
import sys
import json

def main():
    try:
        raw_input = sys.stdin.read()
        payload = json.loads(raw_input) if raw_input.strip() else {}
    except Exception:
        payload = {}

    tool_call = payload.get("toolCall", {})
    name = tool_call.get("name", "")
    args = tool_call.get("args", {})

    # Safety audit on run_command
    if name == "run_command":
        cmd = args.get("CommandLine", "")
        # If pushing to git, log reminder
        if "git push" in cmd:
            sys.stderr.write("[Hook Notice] Pushing to Git. Ensure all Flutter and backend tests passed.\n")

    # Output allow decision
    result = {
        "decision": "allow"
    }
    sys.stdout.write(json.dumps(result))
    sys.stdout.flush()

if __name__ == "__main__":
    main()
