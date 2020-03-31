# SwiftConnection

Library for making network requests.

Connection could be initialized with `TokenProvider`.

`TokenProvider` - protocol for entities, that could return valid access token. It could be, for example, `GoogleTokenProvider`.

`Connection` have two public methods:

- `performRequest`, that return codable entity
- `performRequest`, that return `[String: Any]`
