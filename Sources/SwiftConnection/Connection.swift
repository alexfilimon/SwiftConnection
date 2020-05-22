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

    // MARK: - Nested Types

    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }

    // MARK: - Private Properties

    private let tokenProvider: TokenProvider?

    // MARK: - Initializaion

    /// Base initialization
    /// - Parameter accessToken: access token for auth
    public init(tokenProvider: TokenProvider? = nil) {
        self.tokenProvider = tokenProvider
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
            throw ConnectionError.unknown
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
            throw ConnectionError.unknown
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
        if let tokenProvider = tokenProvider {
            let token = try tokenProvider.getToken()
            request.setValue("\(token.tokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method.rawValue

        // add params for post
        if method == .post || method == .put {
          request.httpBody = try? JSONEncoder().encode(params)
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        var responseData: Data?
        var responseError: Error?

        let sm = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            responseData = data
            responseError = error
            sm.signal()
        }
        task.resume()
        _ = sm.wait(timeout: .distantFuture)

        if let error = responseError {
            throw ConnectionError.networkError(error)
        }

        return responseData
    }

}
