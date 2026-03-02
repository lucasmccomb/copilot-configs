---
agent: 'agent'
tools: ['#runInTerminal', '#readFile', '#editFiles']
description: 'Guide me through completing a task step by step'
---

# Walkthrough Mode

Guide me through completing a task step by step.

## How this works

1. **Identify the task**: If I provided a task description or issue number, use that. Otherwise, ask what I want to walk through.

2. **Break it down**: Analyze the task and break it into discrete, sequential steps. Each step should be a single concrete action.

3. **One step at a time**: Present ONLY the first step. Include:
   - What to do (clear, specific instructions)
   - Any URLs to visit, commands to run, or fields to fill in
   - What the expected outcome looks like

4. **Wait for me**: After presenting a step, STOP and wait. I will either:
   - Confirm completion ("done", "next", etc.)
   - Ask a question
   - Report a blocker
   - Provide information you asked for

5. **Adapt**: Incorporate information I provide into subsequent steps.

6. **Progress tracking**: Show "Step 3/7" so I know where I am.

7. **Only advance when confirmed**: NEVER skip ahead or present multiple steps at once.

Task: ${input:taskDescription}
