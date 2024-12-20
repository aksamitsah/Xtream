//
//  FeedModel.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

struct FeedModel: Codable {
    let id: Int
    let userID: Int
    let username: String
    let profilePicURL: String
    let description: String
    let topic: String
    let viewers: Int
    let likes: Int
    let video: String
    let thumbnail: String
    let shareCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case username
        case profilePicURL
        case description
        case topic
        case viewers
        case likes
        case video
        case thumbnail
        case shareCount
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        userID = (try? container.decode(Int.self, forKey: .userID)) ?? 0
        username = (try? container.decode(String.self, forKey: .username)) ?? ""
        profilePicURL = (try? container.decode(String.self, forKey: .profilePicURL)) ?? ""
        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        topic = (try? container.decode(String.self, forKey: .topic)) ?? ""
        video = (try? container.decode(String.self, forKey: .video)) ?? ""
        thumbnail = (try? container.decode(String.self, forKey: .thumbnail)) ?? ""
        
        shareCount = (try? container.decode(Int.self, forKey: .shareCount)) ?? 0
        viewers = (try? container.decode(Int.self, forKey: .viewers)) ?? 0
        likes = (try? container.decode(Int.self, forKey: .likes)) ?? 0
        
    }
}
