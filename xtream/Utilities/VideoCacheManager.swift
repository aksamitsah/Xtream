//
//  VideoCacheManager.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import Foundation

class VideoCacheManager {
    
    static let shared = VideoCacheManager()
    
    private let tempDirectory: URL
    
    private init() {
        // Use the temporary directory for caching
        self.tempDirectory = FileManager.default.temporaryDirectory
    }
    
    // Generate a file path based on the URL of the video
    func cacheFilePath(for url: URL) -> URL {
        let fileName = url.lastPathComponent
        return tempDirectory.appendingPathComponent(fileName)
    }
    
    // Check if the video is cached in the temporary directory
    func isVideoCached(for url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: cacheFilePath(for: url).path)
    }
    
    // Get cached URL or download the video if not cached
    func getVideoURL(for url: URL, completion: @escaping (URL) -> Void) {
        if isVideoCached(for: url) {
            completion(cacheFilePath(for: url))
        } else {
            downloadVideo(from: url) { data in
                print(data)
            }
            completion(url)
        }
    }
    
    // Download the video from the URL and cache it in the temporary directory
    func downloadVideo(from url: URL, completion: @escaping (URL) -> Void) {
        
        let task = URLSession.shared.dataTask(
            with: url
        ) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                Log.error("Error downloading video: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Save the video data to the temporary directory
            let fileURL = self.cacheFilePath(for: url)
            try? data.write(to: fileURL)
            
            // Return the cached file URL
            completion(fileURL)
        }
        task.resume()
        
    }
}
