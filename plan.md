# Implementation Plan

## Milestone 1: Basic CLI with Add, List, and Simple Persistence

Create the minimum viable CLI that can add and list tasks, with basic
JSON file persistence so tasks survive between commands:

- Create `todo.py` with `argparse` setup for `add` and `list` subcommands
- `python3 todo.py add "task text"` adds a task and saves to `~/.todo.json`
- `python3 todo.py list` loads from `~/.todo.json` and prints all tasks
  in `#N [ ] task text` format
- JSON format: `{"next_id": N, "tasks": [...]}` where `next_id` tracks
  the next ID to assign (only increments, never resets — this ensures
  deleted IDs are never reused)
- On startup, load tasks from `~/.todo.json` if it exists;
  if missing or invalid JSON, start with `{"next_id": 1, "tasks": []}`
- After every add, save tasks to `~/.todo.json`
- Use `os.path.expanduser` to resolve `~`

Note: Do NOT implement done/delete/clear yet. Do NOT implement atomic
writes yet. Simple open/write/close is fine for this milestone.

**Verification:**
```bash
rm -f ~/.todo.json
python3 todo.py add "First task"
python3 todo.py add "Second task"
python3 todo.py list
# Expected output:
# #1 [ ] First task
# #2 [ ] Second task
python3 todo.py
# Expected: help message is printed
```

## Milestone 2: Robust Persistence

Make the file persistence production-ready:

- Write atomically: write to a temp file first, then use `os.replace()`
  to rename (prevents data corruption on crash)
- Handle corrupt/invalid JSON gracefully: if `~/.todo.json` contains
  invalid JSON, treat it as an empty list and log a warning
- Handle file permission errors gracefully

**Verification:**
```bash
# Test normal persistence
rm -f ~/.todo.json
python3 todo.py add "Persistent task"
python3 todo.py list
# Expected: "Persistent task" is listed

# Test corrupt file handling
echo "not valid json" > ~/.todo.json
python3 todo.py list
# Expected: treats as empty list, no crash
# (may print a warning about invalid JSON)

# Test that valid data still works after corrupt file was encountered
python3 todo.py add "New task after corrupt"
python3 todo.py list
# Expected: "New task after corrupt" is listed
```

## Milestone 3: Done and Delete Commands

Implement the `done` and `delete` subcommands:

- `python3 todo.py done <id>` marks a task as done, changes `[ ]` to `[x]`
  in list output, prints "Completed task #N: text"
- `python3 todo.py delete <id>` removes a task from the list,
  prints "Deleted task #N: text"
- If the ID does not exist, print "Error: Task #N not found."
- After delete, remaining tasks keep their original IDs (do not renumber)

**Verification:**
```bash
rm -f ~/.todo.json
python3 todo.py add "Task A"
python3 todo.py add "Task B"
python3 todo.py add "Task C"
python3 todo.py done 2
python3 todo.py list
# Expected: Task B shows [x], others show [ ]
python3 todo.py delete 1
python3 todo.py list
# Expected: Task A is gone, Task B and C remain with IDs #2 and #3
python3 todo.py done 999
# Expected: "Error: Task #999 not found."
```

## Milestone 4: Polish and Edge Cases

Handle all remaining edge cases from the spec:

- `python3 todo.py list` on empty list prints:
`No tasks yet. Add one with: python3 todo.py add "task text"`
- `python3 todo.py done <id>` on an already-done task prints:
`Task #N is already completed.`
- Add a `python3 todo.py clear` command that deletes all tasks
  and prints "Cleared N tasks."

**Verification:**
```bash
rm -f ~/.todo.json
python3 todo.py list
# Expected: "No tasks yet. Add one with: python3 todo.py add \"task text\""
python3 todo.py add "Test"
python3 todo.py done 1
python3 todo.py done 1
# Expected: "Task #1 is already completed."
python3 todo.py add "Another"
python3 todo.py clear
# Expected: "Cleared 2 tasks."
python3 todo.py list
# Expected: "No tasks yet. Add one with: python3 todo.py add \"task text\""
```

## Completion

When all four milestones are verified, the project is complete.
Update progress.md to set status to "ALL DONE".