//
//  CommentModel.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

struct CommentModel: Codable {
    let id: Int
    let username: String
    let picURL: String
    let comment: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case picURL
        case comment
    }
    
    init(id: Int, username: String, picURL: String, comment: String) {
        self.id = id
        self.username = username
        self.picURL = picURL
        self.comment = comment
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try? container.decode(Int.self, forKey: .id)) ?? 0
        username = (try? container.decode(String.self, forKey: .username)) ?? ""
        picURL = (try? container.decode(String.self, forKey: .picURL)) ?? ""
        comment = (try? container.decode(String.self, forKey: .comment)) ?? ""
        
    }
}
