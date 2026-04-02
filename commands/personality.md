# /personality-roulette:personality

Switch, reroll, or manage the current personality.

## Usage

The user invoked this command. Determine what they want from the arguments:

- **No arguments**: Show the current personality.
- **"reroll"**: Pick a new random personality different from the current one.
- **A personality name** (e.g., "sea-captain", "starship-computer", "hyperintelligence", "archduke-of-hell", "noir-detective", "nature-narrator", "mission-control"): Switch to that specific personality.
- **"list"**: Show all available personalities with the current one highlighted.
- **"off"**: Disable personality mode for this session.
- **"default"**: Manage the default personality (see below).

## Default Personality

The default personality file is `~/.claude/personality-roulette/default.txt`. When set, new sessions always start with this personality instead of a random one. The user can still reroll or switch during a session.

### For "default" with no further argument:
1. Read `~/.claude/personality-roulette/default.txt`.
2. If it exists and contains a personality name, show: "Default personality: **[display name]**. New sessions will start with this personality. Use `/personality default off` to go back to random."
3. If it doesn't exist or is empty, show: "No default set. New sessions pick a random personality. Use `/personality default <name>` to set one."

### For "default off" or "default clear":
1. Delete `~/.claude/personality-roulette/default.txt` (or write empty string).
2. Confirm: "Default cleared. New sessions will pick a random personality again."

### For "default <name>":
1. Validate the personality name exists (check custom directory first, then built-in).
2. If not found, show available personalities and ask the user to pick one.
3. Write the personality name (kebab-case filename without .md) to `~/.claude/personality-roulette/default.txt`.
4. Confirm: "Default set to **[display name]**. New sessions will start with this personality."
5. This does NOT switch the current session -- it only affects future sessions.

## Personality Locations

Personalities live in two directories:

1. **Built-in**: `personalities/` at the plugin root (two directories up from this command file)
2. **Custom**: `~/.claude/personality-roulette/personalities/` (user-created)

When searching for a personality by name, check the custom directory first (user overrides take precedence), then the built-in directory. When listing all personalities, include both directories but **skip the custom directory entirely if it does not exist** (do not attempt to glob or list it).

## How to execute

### For no arguments (show current):
1. Read `~/.claude/personality-roulette/current.txt`.
2. If it contains a personality name, show: "Current personality: **[name]**" (title-case the kebab-case name). One line, done.
3. If the file doesn't exist, is empty, or contains "off", show: "No personality active."

### For "list":
1. List personalities from the plugin root `personalities/` directory. Also include `~/.claude/personality-roulette/personalities/` **only if that directory exists**.
2. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
3. Read `~/.claude/personality-roulette/default.txt` to determine the default personality (if set).
4. Display all personalities with their display names (read the `status_display` value from the `## Hook Responses` section of each file, or title-case the filename as fallback). Mark the current one. If a default is set, mark that too. Indicate which are built-in vs. custom.

### For "off":
1. Write "off" to `~/.claude/personality-roulette/current.txt`.
2. Delete `~/.claude/rules/personality-roulette-active.md` if it exists.
3. Confirm that personality mode is disabled. Resume your normal voice.

### For "reroll":
1. Read `~/.claude/personality-roulette/current.txt` to determine the current personality.
2. List available personalities from BOTH directories (skip custom directory if it does not exist).
3. Pick a random one that's different from the current personality.
4. Write the new personality name (filename without .md) to `~/.claude/personality-roulette/current.txt`.
5. Read the new personality file.
6. Find the `## Reinforcement` section in the personality file and write it to `~/.claude/rules/personality-roulette-active.md` with header `# Personality Roulette: [Display Name]` followed by a blank line and the reinforcement content.
7. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

### For a specific personality name:
1. Check for a matching `.md` file in the custom directory first (if it exists), then the built-in directory (match with or without the `.md` extension, case-insensitive, and try replacing spaces with hyphens).
2. If not found, show available personalities and ask the user to pick one.
3. Write the personality name to `~/.claude/personality-roulette/current.txt`.
4. Read the personality file.
5. Find the `## Reinforcement` section in the personality file and write it to `~/.claude/rules/personality-roulette-active.md` with header `# Personality Roulette: [Display Name]` followed by a blank line and the reinforcement content.
6. Adopt the personality immediately and announce yourself as described in its Session Announcement section.

## Notes

- The plugin root can be found relative to this command file (two directories up from commands/).
- Personality names use kebab-case filenames (e.g., `sea-captain.md`, `noir-detective.md`).
- After switching, the new personality persists across resume and compact events.
- Custom personalities in `~/.claude/personality-roulette/personalities/` take precedence over built-in ones with the same name.
