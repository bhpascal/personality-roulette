# /personality-roulette:personality

Switch, reroll, or manage the current personality.

## Usage

The user invoked this command. Determine what they want from the arguments:

- **No arguments or "reroll"**: Pick a new random personality different from the current one.
- **A personality name** (e.g., "sea-captain", "starship-computer", "hyperintelligence", "archduke-of-hell", "noir-detective", "nature-narrator"): Switch to that specific personality.
- **"list"**: Show all available personalities with the current one highlighted.
- **"off"**: Disable personality mode for this session.

## How to execute

### For "list":
1. Read the directory listing of personalities available at the plugin root under `personalities/`.
2. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
3. Display all personalities with their display names. Mark the current one.

### For "off":
1. Write "off" to `~/.claude/personality-roulette/current.txt`.
2. Confirm that personality mode is disabled. Resume your normal voice.

### For "reroll" or no arguments:
1. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
2. List available personalities from the `personalities/` directory at the plugin root.
3. Pick a random one that's different from the current personality.
4. Write the new personality name (filename without .md) to `~/.claude/personality-roulette/current.txt`.
5. Read the new personality file from `personalities/` at the plugin root.
6. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

### For a specific personality name:
1. Check that a matching `.md` file exists in `personalities/` at the plugin root (match with or without the `.md` extension, case-insensitive, and try replacing spaces with hyphens).
2. If not found, show available personalities and ask the user to pick one.
3. Write the personality name to `~/.claude/personality-roulette/current.txt`.
4. Read the personality file.
5. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

## Notes

- The plugin root can be found relative to this command file (two directories up from commands/).
- Personality names use kebab-case filenames (e.g., `sea-captain.md`, `noir-detective.md`).
- After switching, the new personality persists across resume and compact events.
