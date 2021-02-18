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
    @Published private(set) var image: UIImage?
    @Published private(set) var images = [Int: UIImage]() {
        didSet {
            if images.count == self.imagesCount {
                self.loadingImages = false
            }
        }
    }
    @Published var zoomScale: CGFloat = 1.0
    @Published var loadingImages: Bool = false
    
    var imagesGroup: DispatchGroup?

    @Published var imagesCount: Int?
    
    var imageURL: URL?
    private var fetchImageCancellables = [AnyCancellable]()
    
    // encodes uiImage into string to be put in db
    static func encodeImage(_ image: UIImage) -> String? {
        if let imageData = image.pngData() {
            return imageData.base64EncodedString(options: .lineLength64Characters)
        }
        return nil
    }
    
    
    // decodes image data into string to be used
    static func encodeImageFromData(_ imageData: Data) -> String? {
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func encodeImageToData(_ image: UIImage) -> Data? {
        if let imageData = image.pngData() {
            return imageData
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
    
    // decodes image string into uiImage to be used in UI
    static func decodeImageToData(_ imageString: String) -> Data? {
        if let decodedData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
            return decodedData
        }
        return nil
    }
    
    // decodes image string into uiImage to be used in UI
    static func decodeImageFromData(_ imageData: Data) -> UIImage? {
        return UIImage(data: imageData)
    }
    
    // sets images for UI from images pulled from db
    func setImages(_ images: [RecipeImage], onCompletion: @escaping (Bool) -> Void) {
        if images.count > 0 {
            self.loadingImages = true
            imagesCount = images.count
        }
        self.images = [Int: UIImage]()
        DispatchQueue.global(qos: .userInitiated).async {
            self.imagesGroup = DispatchGroup()
            for index in 0..<images.count {
                self.imagesGroup!.enter()
                self.setImage(images[index], at: index)
            }
            
            self.imagesGroup!.notify(queue: .main) {
                self.loadingImages = false
                self.imagesGroup = nil
                onCompletion(true)
            }
        }
    }
    
    // sets image for UI from images pulled from db
    func setImage(_ image: RecipeImage, at index: Int) {
        if image.type == ImageType.uiImage && image.id == RecipeImage.defaultId {
            imageURL = nil
            if let decodedImage = decodeImage(image.data) {
                addImage(uiImage: decodedImage, at: index)
            }
        }
        else {
            addImage(url: URL(string: image.data), at: index)
        }
    }
    
    // adds URL image to end of images
    func addImage(url: URL?) {
        self.loadingImages = true
        if self.imagesCount == nil {
            self.imagesCount = 0
        }
        if let imagesCount = self.imagesCount {
            self.imagesCount = imagesCount + 1
        }
        let index = self.images.count
        addImage(url: url, at: index)
    }
    
    // adds URL image at index
    private func addImage(url: URL?, at index: Int) {
        imageURL = url?.imageURL
        setImageData(at: index)
    }
    
    // adds UIImage to end of images
    func addImage(uiImage: UIImage) {
        self.loadingImages = true
        if self.imagesCount == nil {
            self.imagesCount = 0
        }
        if let imagesCount = self.imagesCount {
            self.imagesCount = imagesCount + 1
        }
        let index = self.images.count
        addImage(uiImage: uiImage, at: index)
    }
    
    // adds UIImage at index
    private func addImage(uiImage: UIImage, at index: Int) {
        DispatchQueue.main.async {
            self.images[index] = uiImage
            if self.imagesGroup != nil {
                self.imagesGroup!.leave()
            }
        }
    }
    
    func removeImage(at index: Int) {
        if let imagesCount = self.imagesCount {
            self.imagesCount = imagesCount - 1
        }
        updateMapIndices(forRemovedIndex: index)
        self.images[index] = nil
    }
    
    func updateMapIndices(forRemovedIndex removedIndex: Int) {
        if let imagesCount = self.imagesCount {
            for index in removedIndex..<imagesCount {
                if let newImage = self.images[index + 1] {
                    self.images.updateValue(newImage, forKey: index)
                }
            }
            self.images[imagesCount] = nil
        }
    }
    
    // sets image data for a imageURL
    private func setImageData(at index: Int) {
        if let imageUrl = imageURL {
            // TODO is being called async but it will cancel the prev async set image
//            fetchImageCancellable?.cancel()
            let fetchImageCancellable = URLSession.shared
                .dataTaskPublisher(for: imageUrl)
                .map { data, response in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        let message = error.localizedDescription
                        print("error: \(message)")
                        if self.imagesGroup != nil {
                            self.imagesGroup!.leave()
                        }
                        return
                    }
                }, receiveValue: { image in
                    self.images[index] = image
                    if self.imagesGroup != nil {
                        self.imagesGroup!.leave()
                    }
                })
            
            self.fetchImageCancellables.append(fetchImageCancellable)
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
