//
//  HandleError.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

enum HandleError: Error {
    
        case invalidResponse
        case invalidURL
        case invalidDecoding
        case custom(_ error: String)
        case message(_ error: Error?)
        
        var localizedDescription: String {
            switch self {
            case .invalidResponse:
                return "Invalid Response Code"
            case .invalidURL:
                return "Failed to create URL"
            case .invalidDecoding:
                return "Failed to Decode Data"
            case .custom(let error):
                return error
            case .message(let error):
                return error?.localizedDescription ?? ""
            }
    }
}
