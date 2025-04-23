//
//  Media+PreviewItem.swift
//  MediaBook
//
//  Created by deeje on 2025-04-23.
//

import UIKit
import AVFoundation
import MediaViewer

extension Media: PreviewItem {
    
    public func makeViewController() async -> UIViewController {
        if mediaType == .video {
            let avPlayer = AVPlayer(url: video!.url)
            return PlayerPreviewItemViewController(player: avPlayer)
        } else {
            let image = UIImage(contentsOfFile: image!.url.path)!
            return ImagePreviewItemViewController(image: image)
        }
    }
    
    public func makeThumbnailViewController() -> UIViewController? {
        var image: UIImage?
        
        if let thumbnail, let data = try? Data(contentsOf: thumbnail.url) {
            image = UIImage(data: data)
        } else {
            image = mediaType == .video ? UIImage(systemName: "film")! : UIImage(systemName: "photo")!
        }
        
        return ThumbnailViewController {
            return image
        }
    }
        
}
