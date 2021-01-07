//
//  ImageHandler.swift
//  CookingThyme
//
//  Created by Rebecca Nybo on 12/3/20.
//

import SwiftUI
import Combine

// convert urls to base64 encoded image in db
// handles URL and UI Images
class ImageHandler: ObservableObject {
    @Published private(set) var image: UIImage? {
        willSet {
            if let image = newValue {
                self.images.append(image)
            }
        }
    }
    @Published private(set) var images: [UIImage] = []
    @Published var zoomScale: CGFloat = 1.0

    var imageURL: URL?
    private var fetchImageCancellable: AnyCancellable?
    
    // encodes uiImage into string to be put in db
    static func encodeImage(_ image: UIImage) -> String? {
        if let imageData = image.pngData() {
            return imageData.base64EncodedString(options: .lineLength64Characters)
        }
        return nil
    }
    
    // decodes image string into uiImage to be used in UI
    func decodeImage(_ imageString: String) -> UIImage? {
        if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
            return UIImage(data: decodedData)
        }
        return nil
    }
    
    // adds recipe images for UI
    func addImages(_ images: [RecipeImage]) {
        for image in images {
            setImage(image)
        }
    }
    
    // sets images for UI
    func setImages(_ images: [RecipeImage]) {
        self.images = []
        for image in images {
            setImage(image)
        }
    }
    
    // sets image for UI
    func setImage(_ image: RecipeImage) {
        if image.type == ImageType.url {
            addImage(url: URL(string: image.data))
        }
        else if image.type == ImageType.uiImage {
            imageURL = nil
            let decodedImage = decodeImage(image.data)
            self.image = decodedImage
        }
//        let images = self.images
//        print(images)
    }
    
    // adds URL image
    func addImage(url: URL?) {
        imageURL = url?.imageURL
        setImageData()
    }
    
    // adds UIImage
    func addImage(uiImage: UIImage) {
        self.image = uiImage
//        self.images.append(uiImage)
    }
    
    func removeImage(at index: Int) {
        self.images.remove(at: index)
    }
    
    // sets image data for a imageURL
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
    
    // sets zoom scale to fit for gien image and size
    func zoomToFit(_ image: UIImage?, in size: CGSize) {
        self.zoomScale = ImageHandler.getZoomScale(image, in: size)
    }
    
    // gets zoom scale for image in size
    static func getZoomScale(_ image: UIImage?, in size: CGSize) -> CGFloat {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let horizontalZoom = size.width / image.size.width
            let verticalZoom = size.height / image.size.height

            return max(horizontalZoom, verticalZoom)
        }
        return 1.0
    }
}

extension URL {
    // gets imageURL from URL
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
