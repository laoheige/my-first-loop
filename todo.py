#!/usr/bin/env python3
"""A minimal command-line todo manager."""

import argparse
import json
import os
import tempfile
import warnings

DATA_FILE = os.path.expanduser("~/.todo.json")


def load_tasks():
    """Load tasks from ~/.todo.json. If missing or invalid, return empty state."""
    try:
        with open(DATA_FILE, "r") as f:
            data = json.load(f)
            return data
    except FileNotFoundError:
        return {"next_id": 1, "tasks": []}
    except json.JSONDecodeError:
        warnings.warn("~/.todo.json contains invalid JSON. Starting with empty list.")
        return {"next_id": 1, "tasks": []}
    except PermissionError:
        warnings.warn("Permission denied reading ~/.todo.json. Starting with empty list.")
        return {"next_id": 1, "tasks": []}


def save_tasks(data):
    """Save tasks to ~/.todo.json atomically (write to temp file, then rename)."""
    temp_file = None
    try:
        dir_path = os.path.dirname(DATA_FILE)
        if not dir_path:
            dir_path = "."
        temp_file = tempfile.NamedTemporaryFile(
            mode="w",
            dir=dir_path,
            delete=False,
            suffix=".json"
        )
        json.dump(data, temp_file)
        temp_file.close()
        os.replace(temp_file.name, DATA_FILE)
    except PermissionError:
        print(f"Error: Permission denied writing to {DATA_FILE}")
        if temp_file is not None:
            try:
                os.unlink(temp_file.name)
            except:
                pass
        raise


def add_task(text):
    """Add a new task and save."""
    data = load_tasks()
    task_id = data["next_id"]
    task = {"id": task_id, "text": text, "done": False}
    data["tasks"].append(task)
    data["next_id"] = task_id + 1
    save_tasks(data)
    print(f"Added task #{task_id}: {text}")


def list_tasks():
    """List all tasks."""
    data = load_tasks()
    tasks = data["tasks"]
    if not tasks:
        print("No tasks yet. Add one with: python3 todo.py add \"task text\"")
        return
    for task in tasks:
        status = "[x]" if task["done"] else "[ ]"
        print(f"#{task['id']} {status} {task['text']}")


def find_task(data, task_id):
    """Find a task by ID. Returns (task, index) or (None, -1) if not found."""
    for i, task in enumerate(data["tasks"]):
        if task["id"] == task_id:
            return task, i
    return None, -1


def done_task(task_id):
    """Mark a task as done."""
    data = load_tasks()
    task, _ = find_task(data, task_id)
    if task is None:
        print(f"Error: Task #{task_id} not found.")
        return
    if task["done"]:
        print(f"Task #{task_id} is already completed.")
        return
    task["done"] = True
    save_tasks(data)
    print(f"Completed task #{task_id}: {task['text']}")


def delete_task(task_id):
    """Delete a task."""
    data = load_tasks()
    task, index = find_task(data, task_id)
    if task is None:
        print(f"Error: Task #{task_id} not found.")
        return
    data["tasks"].pop(index)
    save_tasks(data)
    print(f"Deleted task #{task_id}: {task['text']}")


def clear_tasks():
    """Delete all tasks."""
    data = load_tasks()
    count = len(data["tasks"])
    data["tasks"] = []
    save_tasks(data)
    print(f"Cleared {count} tasks.")


def main():
    parser = argparse.ArgumentParser(description="A minimal todo manager.")
    subparsers = parser.add_subparsers(dest="command")

    add_parser = subparsers.add_parser("add", help="Add a new task")
    add_parser.add_argument("text", help="The task text")

    subparsers.add_parser("list", help="List all tasks")

    done_parser = subparsers.add_parser("done", help="Mark a task as done")
    done_parser.add_argument("id", type=int, help="The task ID")

    delete_parser = subparsers.add_parser("delete", help="Delete a task")
    delete_parser.add_argument("id", type=int, help="The task ID")

    subparsers.add_parser("clear", help="Delete all tasks")

    args = parser.parse_args()

    if args.command == "add":
        add_task(args.text)
    elif args.command == "list":
        list_tasks()
    elif args.command == "done":
        done_task(args.id)
    elif args.command == "delete":
        delete_task(args.id)
    elif args.command == "clear":
        clear_tasks()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
