# ADR 0006: SwiftLint Analyzer Rule Placement

## Status

Accepted

## Context

SwiftLint reports a configuration warning when analyzer-only rules are listed under `opt_in_rules`.
The project runs SwiftLint in strict mode, so warning-free local checks are part of the expected workflow.

## Decision

Move `unused_declaration` from `opt_in_rules` to `analyzer_rules`.

## Consequences

- `swiftlint lint --strict` no longer emits the analyzer-rule placement warning.
- Analyzer-only checks remain explicitly documented for future `swiftlint analyze` usage.
