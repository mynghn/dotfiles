# LP-1 - DESIGN RATIONALE

## Decision-1: async-publisher

### Context
Mission handling must not wait for anomaly reporting.

### Choice
Use asynchronous publishing.

### Forces
Mission reliability is more important than synchronous delivery.

### Alternatives Rejected
Blocking publish was rejected because it couples reporting to mission latency.

### Invalidation Triggers
Use an outbox if delivery loss becomes operationally unacceptable.

### Evidence Links
- `research.md#publisher-patterns`
