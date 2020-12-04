//
//  ImageHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

class ImageHandler: ObservableObject {
    
    @Published private(set) var image: UIImage?
    @Published var zoomScale: CGFloat = 1.0

    var imageURL: URL?
    private var fetchImageCancellable: AnyCancellable?
    
    func addImage(url: URL?) {
        imageURL = url?.imageURL
        setImageData()
    }
    
    private func setImageData() {
        image = nil
        if let imageUrl = imageURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared
                .dataTaskPublisher(for: imageUrl)
                .map { data, response in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \ImageHandler.image, on: self)
        }
    }
    
    func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let horizontalZoom = size.width / image.size.width
            let verticalZoom = size.height / image.size.height

            zoomScale = max(horizontalZoom, verticalZoom)
        }
    }
}

extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }

        return self.baseURL ?? self
    }
}
