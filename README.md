# SwiftConnection

Library for making network requests.

Connection could be initialized with `TokenProvider`.

`TokenProvider` - protocol for entities, that could return valid access token. It could be, for example, [GoogleTokenProvider](https://github.com/alexfilimon/GoogleTokenProvider).

`Connection` have two public methods:

- `performRequest`, that return codable entity
- `performRequest`, that return `[String: Any]`

## Example

```swift
struct FileEntry: Codable {
    let id: String
    let name: String
    let mimeType: String
}
struct DriveResponseEntry: Codable {
    let nextPageToken: String?
    let files: [FileEntry]
}

let connection = Connection()
let result: DriveResponseEntry = try  connection.performRequest(
    urlString: "https://www.googleapis.com/drive/v3/files",
    method: .get,
    params: ["q": "'root' in parents"]
)
```

In real request, as a rule, you need to add authentication params to request. You can make it by passing `TokenProvider` in `Connection` initializer.

For example (if you are working with google):

1. Install `GoogleTokenProvider` via SPM

```swift
.package(url: "https://github.com/alexfilimon/GoogleTokenProvider"),
```

2. Pass GoogleTokenProvider in `Connection` initialization 

```swift
import GoogleTokenProvider

let googleTokenProvider = try GoogleTokenProvider(
    scopes: ["https://www.googleapis.com/auth/drive"],
    credentialFilePath: "path_to_cred_path"
)
let connection = Connection(tokenProvider: googleTokenProvider)
// ...
```
