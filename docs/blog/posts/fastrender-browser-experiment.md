---
date: 2026-02-28
authors:
  - jan
categories:
  - AI-Augmented Development
  - Developer Productivity
description: Cursor's FastRender project used hundreds of AI agents to build a browser in a week. Six weeks later, what can we actually learn from it?
---

# FastRender: What Cursor's AI Browser Experiment Teaches Us About Agentic Coding

*Cursor had hundreds of AI agents build a browser in a week. Three million lines of Rust. Six weeks later: one developer with one agent built the same thing in 20,000 lines. What does that tell us about multi-agent coding?*

![FastRender: what Cursor's AI browser experiment teaches us about agentic coding](images/fastrender-browser-experiment.png)

<!-- more -->

*A note upfront: developments in AI move fast. The research I reference here dates from mid-2025 to early 2026. Claims that hold today may be outdated in a few months. I include dates for each study. Read with that context in mind.*

In mid-January, Michael Truell, CEO of Cursor, announced that hundreds of AI agents had built a web browser in one week [1]. Three million lines of Rust code. Thousands of files. A custom rendering engine with HTML parsing, CSS cascade, layout, text shaping and a JavaScript VM.

Six weeks later, the dust has settled. A good moment to look at what we can learn from this. Both from the project itself and from the reactions it provoked.

## What happened

Cursor engineer Wilson Lin started FastRender as a personal side project in November 2025 [2]. He wanted to test how well frontier models like Claude Opus 4.5 and GPT-5.1 handle complex tasks. A browser rendering engine was a good choice: very ambitious, but well specified through existing web standards. And you can visually see whether it works.

When results with individual agents looked promising, it escalated into an official Cursor research project. Hundreds of GPT-5.2 agents (Cursor's own wording; some sources mention up to 2,000 [10]) worked together non-stop for almost a week. The architecture consisted of three roles. **Planners** explored the codebase and created tasks. **Workers** executed tasks and pushed commits. **Judge agents** evaluated per cycle whether work was good enough or needed to be redone. The WhatWG and CSS-WG web standards were included as git submodules, so agents could consult reference material [2].

The result: over one million lines of Rust (three million according to the CEO on X), spread across thousands of files. Demos showed that simple websites like GitHub, Wikipedia and CNN rendered in a rudimentary way [2].

## What the code looks like

When developers cloned the repo, problems started [4]. `cargo check` produced dozens of errors and about a hundred warnings. All CI runs on the main branch failed. Looking back through git history, there was not a single commit that compiled cleanly [4, 5].

The "from scratch" claim also turned out to be more nuanced. The dependency list includes html5ever (Servo's HTML parser), cssparser (Servo's CSS parser) and rquickjs (a JavaScript runtime). These are core components from Mozilla's Servo browser engine [5]. Wilson Lin responded that the JS VM, DOM, paint systems and text pipeline were built as part of the project [6]. A Servo maintainer called the code a "tangle of spaghetti", but gave the backhanded compliment that at least it was not copied from existing implementations [7].

The Dutch Software Improvement Group (SIG) conducted a formal analysis in February 2026 using their Sigrid platform [8]. The codebase corresponds to roughly 110 person-years of Rust development. The maintainability score is 1.3 out of 5, placing it in the bottom 5% of all systems SIG sees on the market. Architecture quality scores 2.1 out of 5. That indicates tightly coupled components and low modularity. Changes to FastRender take on average four times longer than in a four-star codebase [8].

Cursor's blog post created the impression of a working prototype, but included no reproducible demo, no build instructions and no known-good commit [4].

## What it cost

Estimates vary, but the picture is consistent: this was expensive. The Register estimated 10-20 trillion tokens and several million dollars [7]. A GitHub issue put the cost at 5-6 million dollars [9]. The Decoder mentioned costs in the high five to six figures [10].

## What others did since

Two weeks after FastRender, "embedding-shapes", the same developer who first critically examined Cursor's claims, published the project **one-agent-one-browser** [11]. In three days, this developer used a single Codex CLI agent to build 20,000 lines of Rust into a browser that successfully renders HTML and CSS. Without external Rust crate dependencies. Simon Willison installed the 1MB binary, tested it on his blog and was positively surprised [12].

He also admitted: he had thought building a browser was the perfect problem to demonstrate massively parallel agent setups, because it could not be achieved in a few thousand lines of code by a single agent. Turns out it could [13]. That is an interesting finding in itself.

In parallel, **HiWave** appeared, a privacy-first browser with "RustKit", also a custom engine in Rust. With pixel-perfect visual parity tests against Chrome 120 baselines [14].

Cursor itself built a Windows emulator, a Java LSP implementation and an Excel clone alongside FastRender. All as test cases for GPT-5.2's agent capabilities [1].

## What the research says

This is where it gets most interesting for me. The studies I reference below date from March 2025 to January 2026. Given the pace of developments, it is worth weighing the date of each study.

**METR Time Horizons (March 2025, updated January 2026).** Research institute METR showed that the duration of tasks AI agents can complete autonomously (with 50% reliability) is growing exponentially. The doubling time is approximately 7 months [15]. In the 2024-2025 period, this accelerated to every 4 months [16]. But there is an important nuance in how METR defines tasks: they must be coherent, self-contained units that cannot be trivially split. Solving a thousand separate one-hour problems is not a thousand-hour task but a one-hour task done a thousand times [15]. FastRender looks more like the latter: many small tasks in parallel, not one coherent whole.

MIT Technology Review raised concerns about the METR graph in February 2026 [17]. The error margins are large. And the measurements are primarily based on coding tasks, not software development in the broader sense.

**METR Developer Productivity Study (July 2025).** In a controlled experiment with 16 experienced open-source developers, developers using AI tools were 19% slower than without. While they believed they were 20% faster [18]. A perception gap of 39 percentage points. This does not mean AI is useless. It means that in July 2025, we were still learning how to use it effectively. Whether this has improved since is unknown. The researchers themselves acknowledge that learning effects may only become visible after hundreds of hours [18].

**Google DORA Report (2025).** A 90% increase in AI adoption correlated with 9% more bugs, 91% more code review time and 154% larger pull requests [19]. That is not an argument against AI. It is a signal that how we use it matters.

**Multi-agent vs. single-agent.** The Decoder reported in January 2026 that single agents achieve up to five times more successful tasks per 1,000 tokens than the most complex multi-agent architectures [10]. The one-agent-one-browser project fits that pattern: one agent plus one capable engineer produced a working result in three days [11].

**UC San Diego/Cornell (December 2025).** Experienced developers do not "vibe code". They control. Professionals retain agency in software design, insist on fundamental quality attributes and deploy explicit control strategies to manage agent behaviour [19]. Stack Overflow's 2025 survey confirms: 72% of developers say vibe coding is not part of their professional work [19].

**METR: Algorithmic vs. Holistic Evaluation (August 2025).** AI agents often produce functionally correct code that is not directly usable due to issues with test coverage, formatting and general code quality [20]. Automatic scoring as used by many benchmarks may overestimate real-world AI agent performance. This aligns with what we see in FastRender: code that looks like a browser at first glance, but does not compile.

## What we can learn from this

FastRender is an experiment. An expensive experiment with clear shortcomings, but an experiment we can learn from. The same applies to the criticism it received.

**What it shows.** AI agents can produce enormous amounts of code in a short time. The planner/worker/judge architecture is an interesting approach for future research. For well-specified domains with visual feedback loops, this produces usable results.

**Where it falls short.** The code is in the bottom 5% for maintainability [8]. It barely compiles [4]. And one developer with one agent produced comparable work in three days, in 20,000 lines instead of 3 million [11]. More agents and more tokens are not a substitute for architectural insight.

**The practical lesson.** The value of AI is not in unleashing agents on a problem. It is in orchestrating them well. That requires someone who knows which problems lend themselves to AI delegation, how to set up feedback loops and when to tighten the reins.

The difference between FastRender and one-agent-one-browser is the difference between undirected AI and AI under the direction of a capable engineer. We are all learning how that works. Projects like FastRender, however imperfect, help with that.

---

## References

[1] Cursor, "Scaling long-running autonomous coding", 14 January 2026.
[https://cursor.com/blog/scaling-agents](https://cursor.com/blog/scaling-agents)

[2] S. Willison, "FastRender: a browser built by thousands of parallel agents" (including interview with Wilson Lin), 23 January 2026.
[https://simonw.substack.com/p/fastrender-a-browser-built-by-thousands](https://simonw.substack.com/p/fastrender-a-browser-built-by-thousands)

[3] GitHub repository FastRender.
[https://github.com/wilsonzlin/fastrender](https://github.com/wilsonzlin/fastrender)

[4] embedding-shapes, "Cursor's latest browser experiment implied success without evidence", January 2026.
[https://emsh.cat/cursor-implied-success-without-evidence/](https://emsh.cat/cursor-implied-success-without-evidence/)

[5] EverydayAI Blog, "Cursor AI Browser Can't Compile: Developers Call It 'AI Slop'", 24 February 2026.
[https://everydayaiblog.com/cursor-ai-browser-cant-compile/](https://everydayaiblog.com/cursor-ai-browser-cant-compile/)

[6] The Register, "Cursor used agents to write a browser, proving AI can write shoddy code at scale", 22 January 2026.
[https://www.theregister.com/2026/01/22/cursor_ai_wrote_a_browser/](https://www.theregister.com/2026/01/22/cursor_ai_wrote_a_browser/)

[7] The Register, "Cursor is better at marketing than coding" (opinion), 26 January 2026.
[https://www.theregister.com/2026/01/26/cursor_opinion/](https://www.theregister.com/2026/01/26/cursor_opinion/)

[8] Software Improvement Group, "We analyzed the code of Cursor's AI-built browser FastRender", February 2026.
[https://www.softwareimprovementgroup.com/blog/quality-of-fastrender/](https://www.softwareimprovementgroup.com/blog/quality-of-fastrender/)

[9] GitHub Issue #115, "AI slop lol" (cost estimate), 28 January 2026.
[https://github.com/wilsonzlin/fastrender/issues/115](https://github.com/wilsonzlin/fastrender/issues/115)

[10] The Decoder, "Frontier Radar #1: From chatbots to problem solvers", January 2026.
[https://the-decoder.com/frontier-radar-1-from-chatbots-to-problem-solvers-the-state-of-ai-agents-in-2026/](https://the-decoder.com/frontier-radar-1-from-chatbots-to-problem-solvers-the-state-of-ai-agents-in-2026/)

[11] GitHub repository one-agent-one-browser (embedding-shapes).
[https://github.com/embedding-shapes/one-agent-one-browser](https://github.com/embedding-shapes/one-agent-one-browser)

[12] S. Willison, "One Human + One Agent = One Browser From Scratch", 27 January 2026.
[https://simonwillison.net/2026/Jan/27/one-human-one-agent-one-browser/](https://simonwillison.net/2026/Jan/27/one-human-one-agent-one-browser/)

[13] Hacker News, "Show HN: One Human + One Agent = One Browser From Scratch in 20K LOC", January 2026.
[https://news.ycombinator.com/item?id=46779522](https://news.ycombinator.com/item?id=46779522)

[14] HiWave Browser, homepage with RustKit engine information.
[https://www.hiwavebrowser.com/](https://www.hiwavebrowser.com/)

[15] METR, "Measuring AI Ability to Complete Long Tasks", March 2025.
[https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/](https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/)

[16] The AI Digest, "A new Moore's Law for AI agents" (summary of METR data), 2025-2026.
[https://theaidigest.org/time-horizons](https://theaidigest.org/time-horizons)

[17] MIT Technology Review, "This is the most misunderstood graph in AI", 5 February 2026.
[https://www.technologyreview.com/2026/02/05/1132254/this-is-the-most-misunderstood-graph-in-ai/](https://www.technologyreview.com/2026/02/05/1132254/this-is-the-most-misunderstood-graph-in-ai/)

[18] METR, "Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity", July 2025.
[https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)

[19] M. Mason, "AI Coding Agents in 2026: Coherence Through Orchestration, Not Autonomy", January 2026. Contains references to Google DORA Report 2025, UC San Diego/Cornell study (December 2025) and Stack Overflow survey 2025.
[https://mikemason.ca/writing/ai-coding-agents-jan-2026/](https://mikemason.ca/writing/ai-coding-agents-jan-2026/)

[20] METR, "Research Update: Algorithmic vs. Holistic Evaluation", August 2025.
[https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons/](https://metr.org/blog/2025-08-12-research-update-towards-reconciling-slowdown-with-time-horizons/)

---

*Jan Keijzer is founder of [Imperial Automation](https://imperial-automation.eu), an AI automation consultancy helping European businesses turn friction into flow. With a PhD in Nuclear Reactor Physics from TU Delft and 30+ years of software development experience, he helps organisations deploy AI effectively.*
