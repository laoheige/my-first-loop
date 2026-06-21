# Todo CLI — Project Specification

## Overview
A minimal command-line todo manager written in Python 3.
No external dependencies — only the Python standard library.

## Commands

### `python3 todo.py add "task text"`
- Adds a new task to the list.
- Prints: `Added task #N: task text` (N is the task number).
- Task numbers start at 1 and increment. Deleted task IDs are NOT reused.

### `python3 todo.py list`
- Lists all tasks, one per line.
- Format: `#N [ ] task text` for pending, `#N [x] task text` for done.
- If no tasks exist, prints: `No tasks yet. Add one with: python3 todo.py add "task text"`

### `python3 todo.py done <id>`
- Marks task #id as completed.
- Prints: `Completed task #N: task text`
- If task is already done: `Task #N is already completed.`
- If ID not found: `Error: Task #N not found.`

### `python3 todo.py delete <id>`
- Removes task #id from the list.
- Prints: `Deleted task #N: task text`
- Remaining tasks keep their original IDs (do NOT renumber).
- If ID not found: `Error: Task #N not found.`

### `python3 todo.py clear`
- Deletes all tasks.
- Prints: `Cleared N tasks.`

## Data Storage
- Tasks are persisted in `~/.todo.json`.
- JSON format: `{"next_id": N, "tasks": [task1, task2, ...]}`
  where `next_id` is the ID to assign to the next new task (only increments, never resets).
  Each task is `{"id": number, "text": string, "done": boolean}`.
- On startup, load from this file if it exists.
- After every modification, save to this file.
- If the file is missing or contains invalid JSON, start with
`{"next_id": 1, "tasks": []}`.
- Write atomically: write to a temp file first, then rename.

## Constraints
- Python 3.8+ only, no pip install needed.
- Single file: `todo.py`.
- Use `argparse` for CLI parsing.
- Use `os.path.expanduser` to resolve `~`.