// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation
import HTTPTypes

/// A client middleware that injects a value into the `Authorization` header field of the request.
struct AuthenticationMiddleware {

    /// The value for the `Authorization` header field.
    private let value: String

    /// Creates a new middleware.
    /// - Parameter value: The value for the `Authorization` header field.
    package init(authorizationHeaderFieldValue value: String) { self.value = value }
}

extension AuthenticationMiddleware: ClientMiddleware {
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        // Adds the `Authorization` header field with the provided value.
        request.headerFields[.init("X-Kit-Api-Key")!] = value
        request.headerFields[.accept] = "application/json"
        request.headerFields[.ifNoneMatch] = ""
        return try await next(request, body, baseURL)
    }
}


let client = Client(
    serverURL: try Servers.Server1.url(),
    transport: URLSessionTransport(),
    middlewares: [AuthenticationMiddleware(authorizationHeaderFieldValue: "kit_9d6a061a34fb7c59f974a28737f0fd09")]
)

let query = Operations.GetV4TagsTagIdSubscribers.Input.Query(includeTotalCount: "true", perPage: OpenAPIValueContainer(integerLiteral: 1))
let response = try await client.getV4TagsTagIdSubscribers(
    path: Operations.GetV4TagsTagIdSubscribers.Input.Path(tagId: 5380473),
    query: query
)

switch response {
case .ok(let value):
    guard let totalCount = try? value.body.json.pagination.totalCount else { break }
    print("SwiftLee Weekly Subscribers count is \(totalCount)")
default:
    print("Request failed")
}

print(response)
