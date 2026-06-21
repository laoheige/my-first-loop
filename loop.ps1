<#
.SYNOPSIS
  autoresearch 循环脚本 — PowerShell 版本
.DESCRIPTION
  自动循环调用 Claude Code 代理，逐一完成 plan.md 中的里程碑。
#>

# ═══ Configuration ═══════════════════════════════════════════════════
$MAX_ITERATIONS       = 8
$MAX_TURNS_PER_ITERATION = 25
$SPEC_FILE            = "spec.md"
$PLAN_FILE            = "plan.md"
$PROGRESS_FILE        = "progress.md"

# ═══ Pre-flight checks ═══════════════════════════════════════════════
Write-Host "Pre-flight checks..." -ForegroundColor White

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Error: 'claude' not found." -ForegroundColor Red
    Write-Host "Install it with: npm install -g @anthropic-ai/claude-code"
    exit 1
}

foreach ($file in @($SPEC_FILE, $PLAN_FILE, $PROGRESS_FILE)) {
    if (-not (Test-Path $file)) {
        Write-Host "Error: $file not found in $(Get-Location)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "All checks passed. Starting loop..." -ForegroundColor Green
Write-Host ""

# ═══ Main loop ═══════════════════════════════════════════════════════
$ITERATION = 0

while ($ITERATION -lt $MAX_ITERATIONS) {
    $ITERATION++

    $milestoneLine = Select-String -Path $PROGRESS_FILE -Pattern "^## Current Milestone:" | Select-Object -First 1
    $currentMilestone = ""
    if ($milestoneLine) {
        $currentMilestone = $milestoneLine.Line -replace '^## Current Milestone:\s*', ''
    }

    Write-Host ""
    Write-Host ("═" * 60) -ForegroundColor White
    Write-Host "Iteration $ITERATION / $MAX_ITERATIONS" -ForegroundColor White
    Write-Host "  Current Milestone: $currentMilestone" -ForegroundColor Yellow
    Write-Host ("═" * 60) -ForegroundColor White
    Write-Host ""

    $PROMPT = @"
You are continuing a software project. Start by reading these three files in the current directory:

1. ${SPEC_FILE} — The project specification (what to build and why)
2. ${PLAN_FILE} — The implementation plan with milestones
3. ${PROGRESS_FILE} — Current progress and status

Your task: Complete the current milestone described in ${PROGRESS_FILE}.

Rules:
- Read ALL three files before writing any code.
- Implement ONLY the current milestone described in ${PROGRESS_FILE}.
  Do NOT skip ahead to future milestones.
- After completing the milestone, run the verification commands
  from ${PLAN_FILE} to confirm your work is correct.
- If verification fails, fix the issues and re-verify.
- After successful verification, update ${PROGRESS_FILE}:
  - Add the completed milestone under '## Completed Milestones'
  - Change '## Current Milestone: ...' to the next milestone
    (keep it on the SAME line as the heading, e.g.
     '## Current Milestone: Milestone 2: Robust Persistence')
  - Update '## Current Status' to reflect progress
- If ALL milestones are complete, set ## Current Status to 'ALL DONE'
- CRITICAL — STOP AFTER ONE MILESTONE:
  Once you finish the current milestone and update progress.md, STOP.
  Do NOT begin the next milestone even if you have tool budget left.
  The loop will call you again for the next milestone. Stopping early
  after exactly one milestone is the correct behavior, not a failure.

Start by reading the three files now.
"@

    Write-Host "Launching agent..." -ForegroundColor DarkGray
    Write-Host "───────────────── Claude 输出 ─────────────────" -ForegroundColor Cyan
    Write-Host ""

    # 通过 stdin 管道传提示词，使用 --print 模式（专为管道设计）
    $PROMPT | claude --print --max-turns $MAX_TURNS_PER_ITERATION --dangerously-skip-permissions

    $exitCode = $LASTEXITCODE

    Write-Host ""
    Write-Host "───────────────── Claude 结束 (退出码: $exitCode) ─────────────────" -ForegroundColor Cyan
    Write-Host ""

    $allDone = Select-String -Path $PROGRESS_FILE -Pattern "ALL DONE" -Quiet
    if ($allDone) {
        Write-Host ""
        Write-Host ("═" * 60) -ForegroundColor White
        Write-Host "All milestones completed!" -ForegroundColor Green
        Write-Host ("═" * 60) -ForegroundColor White
        Write-Host ""
        $completedContent = Select-String -Path $PROGRESS_FILE -Pattern "^## Completed Milestones" -Context 0, 10
        if ($completedContent) {
            $completedContent.Context.PostContext | ForEach-Object { Write-Host $_ }
        }
        exit 0
    }

    $newLine = Select-String -Path $PROGRESS_FILE -Pattern "^## Current Milestone:" | Select-Object -First 1
    $newMilestone = ""
    if ($newLine) {
        $newMilestone = $newLine.Line -replace '^## Current Milestone:\s*', ''
    }

    if ($newMilestone -ne $currentMilestone -and $newMilestone -ne "") {
        Write-Host "Milestone completed: $currentMilestone" -ForegroundColor Green
        Write-Host "Next up: $newMilestone" -ForegroundColor Yellow
    } else {
        Write-Host "Warning: Milestone did not change. The agent may have stalled." -ForegroundColor Yellow
        Write-Host "Check progress.md for issues. The loop will continue." -ForegroundColor Yellow
    }

    Write-Host ""
}

Write-Host ""
Write-Host ("═" * 60) -ForegroundColor White
Write-Host "Reached maximum iterations ($MAX_ITERATIONS)" -ForegroundColor Red
Write-Host "Manual review needed. Check ${PROGRESS_FILE} for current status."
Write-Host ("═" * 60) -ForegroundColor White
exit 1
