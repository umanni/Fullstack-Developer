#!/usr/bin/env bash
# Shows Solid Queue processes, queue depth and failed jobs.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
rails_exec ./bin/rails runner '
  puts "processes: #{SolidQueue::Process.count}"
  puts "ready:     #{SolidQueue::ReadyExecution.count}"
  puts "claimed:   #{SolidQueue::ClaimedExecution.count}"
  puts "failed:    #{SolidQueue::FailedExecution.count}"
'
