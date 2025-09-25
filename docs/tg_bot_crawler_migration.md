# Migration: Remove direct DRb crawler interface from TgBotService

## Context
Previously, `TgBotService` directly called methods on a `crawler` object (e.g., `@crawler.unwatch(search_id: ...)`). This tight coupling is being removed in favor of event-based communication (e.g., via Redis Streams).

## Migration Plan
- Remove all commented-out direct calls to `crawler` in `TgBotService`.
- Implement `watch` and `unwatch` logic in the `catalog` service instead of the crawler or an event-based approach.

## Example (to be implemented)
Instead of calling:
```ruby
@crawler.unwatch(search_id: chat_id)
```
The `watch`/`unwatch` logic should be implemented in the `catalog` service, which will manage subscriptions and filtering directly.

## TODO
- Implement `watch` and `unwatch` logic in the `catalog` service and update `TgBotService#rewatch` and related methods to use this new interface.

---
This document tracks the migration and should be updated as the new event-based approach is implemented.
