# /personality-roulette:personality

Switch, reroll, or manage the current personality.

## Usage

The user invoked this command. Determine what they want from the arguments:

- **No arguments or "reroll"**: Pick a new random personality different from the current one.
- **A personality name** (e.g., "sea-captain", "starship-computer", "hyperintelligence", "archduke-of-hell", "noir-detective", "nature-narrator", "mission-control"): Switch to that specific personality.
- **"list"**: Show all available personalities with the current one highlighted.
- **"off"**: Disable personality mode for this session.

## Personality Locations

Personalities live in two directories:

1. **Built-in**: `personalities/` at the plugin root (two directories up from this command file)
2. **Custom**: `~/.claude/personality-roulette/personalities/` (user-created)

When searching for a personality by name, check the custom directory first (user overrides take precedence), then the built-in directory. When listing all personalities, include both directories.

## How to execute

### For "list":
1. List personalities from BOTH the plugin root `personalities/` directory and `~/.claude/personality-roulette/personalities/`.
2. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
3. Display all personalities with their display names (read the `status_display` value from the `## Hook Responses` section of each file, or title-case the filename as fallback). Mark the current one. Indicate which are built-in vs. custom.

### For "off":
1. Write "off" to `~/.claude/personality-roulette/current.txt`.
2. Confirm that personality mode is disabled. Resume your normal voice.

### For "reroll" or no arguments:
1. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
2. List available personalities from BOTH directories.
3. Pick a random one that's different from the current personality.
4. Write the new personality name (filename without .md) to `~/.claude/personality-roulette/current.txt`.
5. Read the new personality file.
6. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

### For a specific personality name:
1. Check for a matching `.md` file in the custom directory first, then the built-in directory (match with or without the `.md` extension, case-insensitive, and try replacing spaces with hyphens).
2. If not found, show available personalities and ask the user to pick one.
3. Write the personality name to `~/.claude/personality-roulette/current.txt`.
4. Read the personality file.
5. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

## Notes

- The plugin root can be found relative to this command file (two directories up from commands/).
- Personality names use kebab-case filenames (e.g., `sea-captain.md`, `noir-detective.md`).
- After switching, the new personality persists across resume and compact events.
- Custom personalities in `~/.claude/personality-roulette/personalities/` take precedence over built-in ones with the same name.
