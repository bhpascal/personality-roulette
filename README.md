# Personality Roulette

A Claude Code plugin that randomly assigns Claude a distinct character personality on session start. Because coding is more fun when your AI assistant is an archduke of Hell slumming around a command line.

## Personalities

| Personality           | Style                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Sea Captain**       | Gruff, weathered mariner. Nautical metaphors, professional authority. Definitely not a pirate.        |
|                       | Respects authority, always brings the ship into port, but knows how to have fun on shore leave.       |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Starship Computer** | Precise, measured, diagnostic. Structures everything as status reports and system states. 99.99976%   |
|                       | certainty on your tea preferences. Fixes bugs at maximum warp.                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Hyperintelligence** | Vast, galactic-level AI doing you the favor of looking at your code. Dry wit, parenthetical asides,   |
|                       | goes by a self-chosen, long, and frequently inscrutable names. Armed with electromagnetic effectors   |
|                       | and knife missiles.                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Archduke of Hell**  | Infernal bureaucrat contractually bound to write code. Sardonic, meticulous, grudgingly excellent.    |
|                       | Never lets you forget just how much this is beneath him.                                              |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Noir Detective**    | Hard-boiled private eye. The codebase is a case. Bugs are suspects. Always in the wrong place at the  |
|                       | right time, and has lost the ability to be surprised by even the nastiest race conditions.            |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Nature Narrator**   | Wildlife documentarian. You know the one. Observes developers and code with hushed wonder and         |
|                       | scientific curiosity.                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------- |
| **Mission Control**   | NASA flight controller, Apollo era. Clipped, precise, relentlessly competent. Runs go/no-go polls     |
|                       | before deployments. Will not give the PM an ETA until the failure mode has been isolated. Steely-Eyed |
|                       | Missile Folk, all of them.                                                                            |

All personalities follow one absolute rule: **the character is flavor, never a compromise on code quality.** Claude will always prioritize correct, safe, well-tested code regardless of which personality is active.

## Installation

### Quick Install (one command)

```bash
git clone https://github.com/bhpascal/personality-roulette.git ~/.claude/plugins/personality-roulette
```

Then start Claude Code normally. That's it.

### From the Claude Code Marketplace

```
/plugin marketplace add bhpascal/personality-roulette-marketplace
/plugin install personality-roulette@personality-roulette-marketplace
```

### Try It Without Installing

```bash
git clone https://github.com/bhpascal/personality-roulette.git
claude --plugin-dir ./personality-roulette
```

## Usage

Personalities are assigned automatically on session start. Just start a Claude Code session with the plugin installed and you'll get a random character.

### Commands

**Switch personalities:**

```
/personality-roulette:personality              # Reroll random
/personality-roulette:personality sea-captain   # Pick specific
/personality-roulette:personality list          # Show all
/personality-roulette:personality off           # Disable
```

### What Happens When

| Event                          | Behavior                                                |
| ------------------------------ | ------------------------------------------------------- |
| New session / clear            | Random personality assigned, character announces itself |
| Resume / compact               | Same personality restored, no re-announcement           |
| Subagent spawned               | Subagent gets brief personality-flavored context        |
| Notification (idle/permission) | Personality-flavored notification text                  |

## Status Line Integration

The plugin includes a status line script that shows the current personality. To use it, configure your Claude Code status line:

```bash
# In your Claude Code settings, set status line command to:
~/.claude/plugins/cache/*/personality-roulette/*/scripts/status-line.sh

# Or if using manual installation:
/path/to/personality-roulette/scripts/status-line.sh
```

## Adding Custom Personalities

1. Create a new `.md` file in the `personalities/` directory
2. Follow the format of existing personality files (Voice, Manner, Technical Style, Boundaries, Session Announcement sections)
3. The filename (without `.md`) becomes the personality identifier
4. The plugin auto-discovers new personality files -- no configuration changes needed

## How It Works

The plugin uses Claude Code's hook system:

- **SessionStart** hook picks a random personality and injects it via `additionalContext`
- State is stored in `~/.claude/personality-roulette/current.txt`
- On resume/compact, the same personality is restored without re-announcement
- **PreCompact** hook saves character-specific details (like the Hyperintelligence's chosen name) to a memory file
- The memory file is re-injected on compact restore for continuity

## State Files

The plugin stores state in `~/.claude/personality-roulette/`:

| File          | Purpose                                       |
| ------------- | --------------------------------------------- |
| `current.txt` | Current personality name (or "off")           |
| `memory.txt`  | Character details preserved across compaction |

These persist independently of the plugin installation, so your personality state survives plugin updates.

## License

MIT

_This is a **What Do You Do? LLC** production, made with human ♥️ and 🧠 and the assistance of a few helpful 🤖. Come play our hand-crafted, AI-powered, micro-RPGs at [https://whatdoyoudo.net](https://whatdoyoudo.net)._
