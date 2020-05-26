# SwiftConnection

Library for making network requests.

## Review

### Features

- `get`, `post`, `put` requests only
- only JSON payload in body for `put` and `post`
- `URLSession` as a core 
- supports Linux 

### Public methods

- `performRequest`, that return codable entity
- `performRequest`, that return `[String: Any]`

## Example

```swift
struct IPInfoEntry: Codable {
    let status: String
    let message: String
    let country: String
}

let connection = Connection()
let result: DriveResponseEntry = try  connection.performRequest(
    urlString: "http://ip-api.com/json/24.48.0.1",
    method: .get,
    params: ["fields": "status,message,country"]
)
```

## Auth

In real request, as a rule, you need to add authentication params to request. You can make it by passing `TokenProvider` in `Connection` initializer.

`TokenProvider` - protocol for entities, that could return valid access token. You can create your own TokenProvider.

### Supported TokenProviders

- [GoogleTokenProvider](https://github.com/alexfilimon/GoogleTokenProvider)
