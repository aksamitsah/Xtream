//
//  API.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

protocol API {
    var scheme: HTTPScheme { get }
    var baseURL: String { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var parameters: [URLQueryItem]? { get }
    var method: HTTPMethod { get }
}
