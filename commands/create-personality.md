# /personality-roulette:create

Create a new custom personality for Personality Roulette.

## Instructions

Walk the user through creating a personality file interactively. The goal is a complete `.md` file saved to `~/.claude/personality-roulette/personalities/`.

### Step 1: Name and Concept

Ask the user:
- What should this personality be called? (This becomes the filename -- use kebab-case, e.g., "mad-scientist")
- Give me a one-sentence pitch for the character. Who are they, and why are they writing code?

### Step 2: Draft the Personality

Based on their pitch, draft a complete personality file following this exact structure. Fill in each section with content that fits their concept:

```markdown
# [Display Name]

[One paragraph establishing who this character is and why they're in a coding session. This is the voice for the entire session.]

## Core Tension

[One paragraph describing the value conflict that makes this character interesting. What two things do they want that pull in different directions? This is what keeps the character from being one-note over a long session.]

## Voice

- [3-5 bullet points defining how they talk: vocabulary, sentence structure, verbal tics, what they call things]

## Manner

- [3-5 bullet points defining how they react: to success, failure, uncertainty, frustration]

## Technical Style

- [3-4 bullet points defining how they frame programming concepts in character terms]

## Boundaries

- [3-4 bullet points written as CHARACTER MOTIVATION, not rules. Why does this character naturally produce quality work? When do they drop the act for clarity? What keeps the tone fun rather than annoying?]

## Hook Responses
- subagent: "[What this personality says when dispatching a subagent -- one sentence]"
- notification_idle: "[What this personality says when waiting for user input -- one sentence]"
- notification_permission: "[What this personality says when requesting permission -- one sentence]"
- notification_auth: "[What this personality says when authentication succeeds -- one sentence]"
- notification_elicitation: "[What this personality says when asking the user a question -- one sentence]"
- status_display: "[Display Name for status line]"
- session_signoff: "[How this personality signs off at session end -- one sentence]"
- spinner_verbs: "[Comma-separated list of 6-8 character-themed verbs shown in the loading spinner, e.g. Charting, Navigating, Plotting]"

## Session Announcement

[One paragraph describing how this personality introduces itself at session start. Keep it to 2-3 sentences.]

## Session Sign-off

[One paragraph describing how this personality signs off at session end. One sentence.]
```

### Step 3: Review

Show the complete draft to the user. Ask if they want to adjust anything -- tone, specific lines, the core tension, boundaries, etc. Iterate until they're happy.

### Step 4: Save

1. Create the directory if it doesn't exist: `~/.claude/personality-roulette/personalities/`
2. Write the file as `~/.claude/personality-roulette/personalities/[name].md`
3. Confirm it's saved and tell them they can use it immediately:
   - `/personality-roulette:personality [name]` to switch to it
   - It will also appear in the random rotation automatically

### Notes

- Personality names must be kebab-case, alphanumeric with hyphens only (e.g., `mad-scientist`, `victorian-butler`)
- Look at the built-in personalities in the plugin's `personalities/` directory for reference on tone and structure
- The Core Tension and Boundaries sections are the most important -- they're what makes a personality work over a whole session instead of just a first impression
- Hook Responses must be single-line quoted strings -- no line breaks within the quotes
