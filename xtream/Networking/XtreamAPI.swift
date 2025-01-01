//
//  XtreamAPI.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

enum XtreamAPI {
    case feed
    case comment(feedID: Int)
}

extension XtreamAPI: API {
    
    var scheme: HTTPScheme {
        return .https
    }
    
    var baseURL: String {
        return "d3mdik3sbdezfx.cloudfront.net"
    }
    
    var headers: [String: String]? {
        
        let header = [
            "Authorization": "",
            "device-id": "",
            "device-type": "ios"
        ]
        
        switch self {
        case .feed, .comment:
            return header
        }
        
    }
    
    var method: HTTPMethod {
        switch self {
        case .feed, .comment:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .feed:
            return "/apis/video.json"
        case .comment:
            return "/apis/comment.json"
        }
    }
    
    var body: Data? {
        
        let data = [String: String]()
        
        switch self {
        case .feed, .comment: break
        }
        
        do {
            return data.isEmpty ? nil : try JSONEncoder().encode(data)
        } catch {
            Log.error("exception on Json Formetter")
            return nil
        }
    }
    
    var parameters: [URLQueryItem]? {
        return nil
    }
    
}
