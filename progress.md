# Progress

## Current Status
ALL DONE

## Completed Milestones

### Milestone 1: Basic CLI with Add, List, and Simple Persistence
- Created `todo.py` with argparse for `add` and `list` subcommands
- Tasks persisted to `~/.todo.json` in correct format: `{"next_id": N, "tasks": [...]}`
- Each task has `id`, `text`, and `done` fields
- IDs increment and are never reused
- Verified: add, list, and help output all work correctly

### Milestone 2: Robust Persistence
- Implemented atomic writes: write to temp file first, then `os.replace()`
- Handles invalid JSON gracefully: prints warning, returns empty state
- Handles file permission errors gracefully
- Verified: normal persistence, corrupt file handling, recovery after corrupt file

### Milestone 3: Done and Delete Commands
- Implemented `done <id>` command: marks task as completed, prints confirmation
- Implemented `delete <id>` command: removes task, prints confirmation
- Handles "Task not found" errors correctly
- Handles "Task already completed" case correctly
- Remaining tasks keep their original IDs after deletion (no renumbering)
- Verified: done, delete, list output with [x], error handling for invalid IDs

### Milestone 4: Polish and Edge Cases
- Empty list message: `No tasks yet. Add one with: python3 todo.py add "task text"`
- Already completed message: `Task #N is already completed.`
- Implemented `clear` command: deletes all tasks, prints "Cleared N tasks."
- Verified: empty list message, already completed message, clear command

## Current Milestone: (none — all milestones complete)

## Issues
(none)

## Notes
All four milestones completed successfully. The todo CLI is fully functional
and meets all requirements from spec.md.