//
//  ImageCacheManager.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

class ImageCacheManager: NSObject {
    
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    private let urlSession: URLSession
    private var runningTasks = [String: URLSessionTask]()
    private var pendingRequests = [String: (UIImage?, Error?) -> Void]() // Queue for pending requests
    private let queue = DispatchQueue(
        label: "com.dreamcoder.imagecache",
        qos: .userInitiated
    ) // Serial queue for thread safety
    private let memoryLimit: Int = 1024 * 1024 * 50 // 50MB
    private let purgeThreshold: Int = 1024 * 1024 * 10 // 10MB to clear on purge
    private var currentMemoryUsage: Int = 0
    
    private override init() {
        
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 5
        urlSession = URLSession(configuration: config)
        
        cache.countLimit = 100
        cache.totalCostLimit = memoryLimit // Set the total cost limit
        
    }
    
    func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?, Error?
        ) -> Void
    ) {
        
        queue.async { [weak self] in // Dispatch to serial queue
            guard let self = self else { return }
            
            if let cachedImage = self.cache.object(forKey: urlString as NSString) {
                DispatchQueue.main.async { completion(cachedImage, nil) }
                return
            }
            
            if self.runningTasks[urlString] != nil {
                self.pendingRequests[urlString] = completion // Queue the request
                return
            }
            
            if self.runningTasks.count >= 5 { // Limit concurrent downloads
                self.pendingRequests[urlString] = completion
                return
            }
            
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async { completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil)) }
                return
            }
            
            let task = self.urlSession.dataTask(with: url) { [weak self] data, response, error in
                self?.queue.async { // Back on serial queue
                    defer {
                        self?.runningTasks.removeValue(forKey: urlString)
                        self?.executePendingRequests()
                    }
                    
                    if let error = error {
                        DispatchQueue.main.async { completion(nil, error) }
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
                    else {
                        DispatchQueue.main.async {
                            completion( nil, NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
                        }
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        let cost = data.count
                        self?.cache.setObject(image, forKey: urlString as NSString, cost: cost)
                        self?.currentMemoryUsage += cost
                        DispatchQueue.main.async { completion(image, nil) }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "ImageDataError", code: 0, userInfo: nil))
                        }
                    }
                }
            }
            self.runningTasks[urlString] = task
            task.resume()
        }
    }
    
    private func executePendingRequests() {
        
        queue.async { [weak self] in
            guard let self = self else { return }
            guard self.runningTasks.count < 5 else { return } // Check if there's room for more requests
            
            if let (url, completion) = self.pendingRequests.first {
                self.pendingRequests.removeValue(forKey: url)
                self.loadImage(from: url, completion: completion)
            }
        }
        
    }
    
    func cancelLoad(for urlString: String) {
        queue.async { [weak self] in
            self?.runningTasks[urlString]?.cancel()
            self?.runningTasks.removeValue(forKey: urlString)
            self?.pendingRequests.removeValue(forKey: urlString) // Remove from pending requests as well
        }
    }
}

extension ImageCacheManager: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        queue.async { [weak self] in
            guard let self = self,
                  let image = obj as? UIImage,
                  let data = image.pngData() ?? image.jpegData(compressionQuality: 1.0)
            else { return }
            self.currentMemoryUsage -= data.count
        }
    }
}
