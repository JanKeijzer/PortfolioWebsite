---
date: 2026-03-06
authors:
  - jan
categories:
  - AI-Augmented Development
  - Developer Productivity
description: Claude Code has powerful native tools for file operations, but the model stubbornly defaults to Bash. After nearly a year of working with it, here's what actually works to fix that.
---

# Claude Code Has Native Tools. Why Won't It Use Them?

*After nearly a year of daily work with Claude Code, one pattern keeps coming back: the model prefers Bash over its own native tools. Here's what I've learned about why that happens and what you can do about it.*

![Claude Code native tools vs Bash — training the model to use its own capabilities](images/claude-code-native-tools.png)

<!-- more -->

Claude Code ships with a set of purpose-built tools for file operations: Read, Write, Edit, Grep, Glob. These tools are designed to give both you and the model more control, better visibility, and cleaner permission management. They're not optional extras. They're the intended way to work with files.

And yet, after nearly a year of intensive daily use, I can tell you with confidence: Claude Code does not want to use them. Left to its own devices, it reaches for `cat`, `sed`, heredocs, `echo >`, and `awk` as if the native tools don't exist.

This isn't a minor annoyance. It's a pattern that costs real time and creates real friction in professional workflows.

## Why This Matters

The native tools exist for good reasons. When Claude uses `Read` instead of `cat`, you see a clean file read in your session. When it uses `Edit` instead of `sed`, the change is atomic, visible, and easy to review. When it uses `Write` instead of a heredoc, the permission system works as designed.

When it falls back to Bash for file operations, several things break:

**Permission mismatches.** If you've configured permissions like `Bash(git *)`, a `cat` or `sed` command won't match that pattern. You get unexpected permission prompts, or worse, the operation succeeds silently when you expected a gate.

**Lost visibility.** A `sed -i` command modifies a file in place. You don't see a clean diff. You don't get the structured output that the Edit tool provides. If something goes wrong, the debugging trail is murkier.

**Harder to review.** When you look back at a session, native tool calls are self-documenting: "Read file X", "Edit lines Y-Z in file X". A sequence of piped Bash commands is not.

## The Default Behaviour

Out of the box, Claude Code gravitates toward Bash for file operations. This isn't a bug per se. It reflects the model's training data, where shell commands are overwhelmingly more common than tool-use patterns. The model has seen millions of examples of `cat file.txt`, `sed 's/old/new/' file.txt`, and `echo "content" > file.txt`. It has seen far fewer examples of structured tool calls.

The result is a strong prior toward shell idioms, even in a context where better alternatives are available. The model knows the native tools exist. If you ask it, it will explain what each one does and why they're preferable. But when it's actually working on a task, the default path is Bash.

This is a common pattern in LLMs more broadly. There's a gap between declarative knowledge ("I know I should use Edit") and procedural behaviour ("in the moment, I reach for sed"). Anyone who has tried to change a habit will recognise the dynamic.

## What Doesn't Work

Let me save you some time with approaches I've tried that don't reliably work.

**Generic instructions.** Writing "prefer native tools over Bash" in your CLAUDE.md helps somewhat, but the instruction is too vague to override a strong default. The model interprets "prefer" as a soft suggestion and reverts under cognitive load.

**One-time corrections.** Telling Claude "you should have used Edit there" in the moment works for the next operation. Maybe the one after that. Then the habit reasserts itself.

**Assuming the model reads and retains instructions.** CLAUDE.md is loaded into context, but that doesn't mean every instruction in it influences every action. The model's attention is finite. Instructions that aren't specific enough get deprioritised.

## What Actually Works

After months of iteration, I've found a combination of strategies that makes a meaningful difference. None of them work perfectly in isolation. Together, they shift the default behaviour.

### 1. Be Exhaustively Specific

Don't write "use native tools". Write exactly which commands are forbidden and what to use instead:

> *"ALWAYS prefer native tools (Read, Write, Edit, Grep, Glob) over Bash equivalents. Bash is ONLY for actual shell operations (git, docker, npm, etc.) — never for file reading, writing, searching, or editing."*

And then enumerate the specific substitutions:

> *"Never use `cat`, `head`, `tail`, `sed`, `awk`, `echo >`, `cat <<`, `tee`, or heredoc for file operations."*

The model responds better to explicit prohibitions than to positive preferences. "Never use X" is stronger than "prefer Y".

### 2. Explain the Reason

Claude follows instructions better when it understands why the instruction exists. Adding context like "these don't match permission patterns like `Bash(git *)`" or "dedicated tools allow the user to better understand and review your work" gives the instruction weight beyond a bare rule.

This makes sense from a model perspective. An instruction with a rationale is more information-rich. The model can generalise from the reason, not just pattern-match on the rule.

### 3. Use Multiple Reinforcement Points

My CLAUDE.md isn't the only place these instructions live. I've found that redundancy helps:

- **CLAUDE.md** contains the master rules.
- **Auto-memory** (`~/.claude/projects/*/memory/MEMORY.md`) captures project-specific patterns and reinforces the same principles.
- **In-session corrections** build contextual reinforcement. When I catch a violation, I correct it. The correction stays in context for the rest of the session.

This isn't elegant. It feels like writing the same thing three times. But in practice, it measurably reduces violations. The model's attention is distributed across its context. Multiple touchpoints increase the probability that the right instruction is attended to at the right moment.

### 4. Design Around the Limitation

Some of the most effective strategies are architectural rather than instructional.

For example, my CLAUDE.md includes workarounds for common failure modes:

> *"Never write files via Bash. Instead: use the Write tool to write to `/tmp/`, then reference the file in Bash (e.g., `git commit -F /tmp/commit-msg`)."*

This doesn't just forbid the wrong approach. It provides a concrete alternative path. The model doesn't have to figure out what to do instead. It just follows the pattern.

Similarly, for API responses:

> *"Always save API responses to a file first, then read the file."*

These workarounds feel inelegant. They are inelegant. But they're effective because they work with the model's tendencies rather than against them.

### 5. Correct in Context, Then Persist

When Claude falls back to Bash in a session, I correct it immediately. The response is usually:

> *"You're right, I should have used the native Edit tool. My apologies."*

That apology buys you exactly nothing by itself. The file may already have been modified via `sed`. But the correction does serve a purpose: it reinforces the instruction in the current context window. For the remainder of the session, compliance improves noticeably.

The key is to then persist the lesson. If a particular pattern keeps recurring, I add it to the CLAUDE.md or memory file. The in-session correction handles the immediate context. The persisted instruction handles future sessions.

## The Bigger Picture

This challenge with native tools is a microcosm of a larger dynamic in AI-augmented development. We have a powerful tool. It doesn't always do what we want. And the gap between "it can do X" and "it reliably does X" is where the real work happens.

The vendors don't advertise this gap. Demo videos show smooth, cooperative sessions where the AI follows instructions flawlessly. Reality is different. Effective use of AI coding tools requires ongoing calibration: refining your instructions, building workarounds, and accepting that some friction is part of the process.

That's not a criticism. It's a description of where the technology is right now. And it's getting better. Instructions that were routinely ignored six months ago are now usually followed. The native tools themselves have been improved. The model's tool-use capabilities continue to advance.

But if you're starting with Claude Code today, know that getting the most out of it is an investment. Your CLAUDE.md will evolve over weeks and months. Your patterns for interacting with the model will change. And the occasional `sed` that should have been an `Edit` is part of the journey.

## Practical Checklist

If you're dealing with the same pattern, here's a condensed version of what works:

1. **Be specific.** Enumerate forbidden commands. Provide exact alternatives.
2. **Explain why.** Give the model context for the instruction.
3. **Reinforce across layers.** CLAUDE.md, memory files, and in-session corrections.
4. **Provide alternative paths.** Don't just forbid the wrong approach. Show the right one.
5. **Iterate your instructions.** Treat CLAUDE.md as a living document. Add rules when patterns emerge. Remove rules when the model improves.
6. **Accept imperfection.** The model will still slip sometimes. Budget for that.

## The Takeaway

Claude Code is a genuinely powerful tool. After nearly a year of daily use, I wouldn't go back to working without it. But it's not an assistant that reads your instructions once and follows them forever. It's a capable partner that needs clear, repeated, specific guidance.

The native tools issue is a good example of this broader principle. The tools are there. They work well. Getting the model to consistently use them requires effort. That effort pays off. And over time, both the model and your instructions get better.

Nobody tells you this in the demo. But it's where the real value is created.

---

*Jan Keijzer is founder of [Imperial Automation](https://imperial-automation.eu), an AI automation consultancy helping European businesses turn friction into flow. With a PhD in Nuclear Reactor Physics from TU Delft and 30+ years of software development experience, he helps organisations deploy AI effectively.*
