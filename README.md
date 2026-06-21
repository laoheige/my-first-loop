# My First Loop 🚀

一个基于 Claude Code 自动化循环开发的 **Todo CLI** 待办事项管理器。

## 功能

```bash
python todo.py add "买咖啡"     # 添加任务
python todo.py list             # 列出所有任务
python todo.py done 1           # 标记完成
python todo.py delete 1         # 删除任务
python todo.py clear            # 清空所有任务
```

## 技术栈

- Python 3（标准库，零外部依赖）
- 数据存储：`~/.todo.json`（JSON 持久化）
- 原子写入防止数据丢失

## 自动化循环

`loop.ps1` 脚本会自动调用 Claude Code AI 代理，按 `plan.md` 的里程碑分步实现项目：

1. 读取 `spec.md`（需求）、`plan.md`（计划）、`progress.md`（进度）
2. 启动 Claude 完成当前里程碑
3. 自动验证，推进到下一步
4. 直到所有里程碑完成

## 项目结构

```
├── todo.py        # 主程序
├── spec.md        # 项目需求文档
├── plan.md        # 分步实施计划
├── progress.md    # 当前进度
├── loop.ps1       # PowerShell 自动化循环脚本
├── loop.sh        # Linux Bash 自动化循环脚本
└── README.md      # 本文件
```
