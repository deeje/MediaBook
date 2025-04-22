//
//  Media+Viewable.swift
//  MediaBook
//
//  Created by deeje cooley on 5/27/22.
//

import Viewer

extension Media: Viewable {
        
    public var type: ViewableType {
        return mediaType == .video ? .video : .image
    }
    
    public var assetID: String? {
        return nil
    }
    
    public var streamingURL: URL? {
        return mediaType == .video ? video?.url : image?.url
    }
    
    public var placeholder: UIImage {
        guard let thumbnail,
              let data = try? Data(contentsOf: thumbnail.url),
              let image = UIImage(data: data)
        else {
            return mediaType == .video ? UIImage(systemName: "film")! : UIImage(systemName: "photo")!
        }
        
        return image
    }
    
    public func media(_ completion: @escaping (UIImage?, NSError?) -> Void) {
        do {
            var data: Data?
            if mediaType == .video, let thumbnail {
                data = try Data(contentsOf: thumbnail.url)
            } else if let image {
                data = try Data(contentsOf: image.url)
            }
            
            if let data {
                completion(UIImage(data: data), nil)
            } else {
                completion(nil, NSError(domain: "mediabook", code: -12301))
            }
        } catch {
            completion(nil, error as NSError)
        }
    }
    
}
