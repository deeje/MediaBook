//
//  Datafile+Viewable.swift
//  MediaBook
//
//  Created by deeje cooley on 5/27/22.
//

import Viewer

extension Datafile: Viewable {
        
    public var type: ViewableType {
        return .image
    }
    
    public var assetID: String? {
        return nil
    }
    
    public var streamingURL: URL? {
        return url
    }
    
    public var placeholder: UIImage {
        guard let thumbnail = media?.thumbnail,
              let data = try? Data(contentsOf: thumbnail.url),
              let image = UIImage(data: data)
        else {
            return UIImage(systemName: "photo")!
        }
        
        return image
    }
    
    public func media(_ completion: @escaping (UIImage?, NSError?) -> Void) {
        do {
            let data = try Data(contentsOf: url)
            completion(UIImage(data: data), nil)
        } catch {
            completion(nil, error as NSError)
        }
    }
    
}
