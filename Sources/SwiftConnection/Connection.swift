//
//  Connection.swift
//  
//
//  Created by Alexander Filimonov on 01/03/2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Class for connecting to the network (supports requests with accessToken)
public final class Connection {

    // MARK: - Constants

    private enum Constants {
        static let goodStatusCodes = (200...299)
        static let defaultStatusCode = -1
        static let authHeaderName = "Authorization"
        static let contentTypeHeaderName = "Content-Type"
        static let contentTypeHeaderJsonValue = "application/json"
    }

    // MARK: - Nested Types

    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }

    // MARK: - Private Properties

    private let tokenProvider: TokenProvider?
    private let shouldLog: Bool

    // MARK: - Initializaion

    /// Base initialization
    /// - Parameter tokenProvider: provider for token
    /// - Parameter shouldLog: if need log to console
    public init(tokenProvider: TokenProvider? = nil,
                shouldLog: Bool = false) {
        self.tokenProvider = tokenProvider
        self.shouldLog = shouldLog
    }

    // MARK: - Methods

    /// Method for performing network request (returns decodable obj)
    /// - Parameters:
    ///   - urlString: urlString address
    ///   - method: method for request
    ///   - params: dict with parameters
    public func performRequest<T: Decodable>(urlString: String,
                                             method: Method,
                                             params: [String: String] = [:]) throws -> T {
        guard let data = try getData(urlString: urlString, method: method, params: params) else {
            throw ConnectionError.dataIsNil
        }
        let responseObj = try JSONDecoder().decode(T.self, from: data)
        return responseObj
    }

    /// Method for performing network request (returns dict [String: Any])
    /// - Parameters:
    ///   - urlString: urlString address
    ///   - method: method for request
    ///   - params: dict with parameters
    public func performRequest(urlString: String,
                               method: Method,
                               params: [String: String] = [:]) throws -> [String: Any] {
        guard
            let data = try getData(urlString: urlString, method: method, params: params),
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            throw ConnectionError.dataIsNil
        }
        return jsonDict
    }

}

// MARK: - Private Methods

private extension Connection {

    func getData(urlString: String,
                 method: Method,
                 params: [String: String] = [:]) throws -> Data? {
        guard var urlComponents = URLComponents(string: urlString) else {
            throw ConnectionError.couldntCreateUrl
        }

        // add params for get
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        for (key, value) in params {
          queryItems.append(URLQueryItem(name: key, value: value))
        }
        if method == .get {
            urlComponents.queryItems = queryItems
        }

        // add auth header
        var request = URLRequest(url: urlComponents.url!)
        var usedToken: String?
        if let tokenProvider = tokenProvider {
            let token = try tokenProvider.getToken()
            let tokenStringValue = "\(token.tokenType) \(token.accessToken)"
            request.setValue(
                tokenStringValue,
                forHTTPHeaderField: Constants.authHeaderName
            )
            usedToken = tokenStringValue
        }
        request.httpMethod = method.rawValue

        // logging
        logIfNeeded(string: """

        ┌--------------------------┐
        |     Network request      |
        ├--------------------------┤
        | URL: \(urlString)
        | Token: \(usedToken ?? "<none>")
        | Method: \(method.rawValue)
        | Params: \(params)
        └--------------------------┘

        """)

        // add params for post
        if method == .post || method == .put {
          request.httpBody = try? JSONEncoder().encode(params)
            request.setValue(
                Constants.contentTypeHeaderJsonValue,
                forHTTPHeaderField: Constants.contentTypeHeaderName
            )
        }

        var responseData: Data?
        var responseError: Error?
        var responseCode = Constants.defaultStatusCode

        let sm = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            responseData = data
            responseError = error
            if let httpResponse = response as? HTTPURLResponse {
                responseCode = httpResponse.statusCode
            }
            sm.signal()
        }
        task.resume()
        _ = sm.wait(timeout: .distantFuture)

        if let error = responseError {
            logIfNeeded(string: """

            ┌--------------------------┐
            |      Network error       |
            ├--------------------------┤
            | \(error)
            └--------------------------┘

            """)
            throw ConnectionError.networkError(error)
        }

        logIfNeeded(string: """

        ┌--------------------------┐
        |     Network response     |
        ├--------------------------┤
        | Code: \(responseCode)
        | Data: \(String(data: responseData ?? Data(), encoding: .utf8) ?? "<no data>")
        └--------------------------┘

        """)

        guard Constants.goodStatusCodes.contains(responseCode) else {
            let jsonDict = try? JSONSerialization.jsonObject(with: responseData ?? Data(),
                                                             options: []) as? [String: Any]

            logIfNeeded(string: """

            ┌--------------------------┐
            |      Network error       |
            ├--------------------------┤
            | Code: \(responseCode)
            | Payload: \(jsonDict ?? [:])
            └--------------------------┘

            """)

            throw ConnectionError.networkCodeError(jsonData: jsonDict ?? [:], code: responseCode)
        }

        return responseData
    }

    func logIfNeeded(string: String) {
        guard shouldLog else { return }
        print("\(Date()) [SwiftConnection]: \(string)")
    }

}
