//
//  HomeViewModel.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import Foundation

final class HomeViewModel: NSObject {
    
    private(set) var feeds: [FeedModel] = [] {
        didSet {
            onFeedsUpdated?()
        }
    }
    
    private(set) var comments: [CommentModel] = [] {
        didSet {
            onCommentsUpdated?()
        }
    }
    
    var onFeedsUpdated: (() -> Void)?
    var onCommentsUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    func getData() {
        getFeed()
        getComment()
    }
    
    // Fetch feeds from the server.
    private func getFeed() {
        APIManager.request(endpoint: XtreamAPI.feed) { [weak self] (result: Result<[FeedModel], HandleError>) in
            switch result {
            case .success(let data):
                self?.feeds = data
            case .failure(let error):
                self?.onErrorOccurred?(error.localizedDescription)
            }
        }
    }
    
    // Fetch comments from the server (only once).
    private func getComment() {
        if !comments.isEmpty {
            // Notify the view that comments are already loaded
            onCommentsUpdated?()
            return
        }
        
        APIManager.request(endpoint: XtreamAPI.comment(feedID: 0)) { [weak self] (result: Result<[CommentModel], HandleError>) in
            switch result {
            case .success(let data):
                self?.comments = data
            case .failure(let error):
                self?.onErrorOccurred?(error.localizedDescription)
            }
        }
    }
}
