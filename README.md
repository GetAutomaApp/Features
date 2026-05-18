# Features

Feature rollout + experimentation package for Vapor.

## Targets

- `FeaturesServer`: evaluation, overrides (with audit history), middleware, and routes.
- `FeaturesClient`: lightweight API client for fetching and toggling features.
- `FeaturesAdmin`: scaffold target (not implemented yet).
- `FeaturesShared`: DTOs and shared feature key/value types.

## Example App

`FeaturesExampleServer` uses Vapor + Fluent + SQLite and wires the package in `configure.swift`.

Run server:

```bash
swift run FeaturesExampleServer serve --hostname 127.0.0.1 --port 8080
```

Seeded users:

- `11111111-1111-1111-1111-111111111111` (free)
- `22222222-2222-2222-2222-222222222222` (pro)
- `33333333-3333-3333-3333-333333333333` (internal)

Call routes:

```bash
curl -s -H 'x-user-id: 11111111-1111-1111-1111-111111111111' http://127.0.0.1:8080/features
curl -s -H 'x-user-id: 11111111-1111-1111-1111-111111111111' -H 'content-type: application/json' -d '{"key":"new_checkout","enabled":true}' http://127.0.0.1:8080/features/toggle
curl -s -H 'x-user-id: 11111111-1111-1111-1111-111111111111' http://127.0.0.1:8080/features/debug
curl -s -H 'x-user-id: 11111111-1111-1111-1111-111111111111' http://127.0.0.1:8080/game
```

## Integration Pattern

Inside your app `configure.swift`:

1. Register your app DB.
2. Build a `FeatureRegistry` with `active(ctx)` closures.
3. Call `FeaturesServer.configure(on:config:registry:actorResolver:)`.
4. Pass your auth middleware through `FeaturesConfiguration(authMiddleware:)`.

`FeaturesServer.configure` automatically registers the feature override migration.
