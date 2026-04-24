# LP-1 - SPEC

## Outcome

### AC-1: anomaly-visible
When an accepted reservation becomes invalid, an operational anomaly is emitted.

## Invariants

### INV-1: mission-fail-safe
Anomaly reporting never causes the reservation mission path to fail.
