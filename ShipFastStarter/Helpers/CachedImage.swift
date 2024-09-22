//
//  CachedImage.swift
//  ONG
//
//  Created by Dante Kim on 9/10/24.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
        print("Cached image for key: \(key)")
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: NSString(string: key))
        print("Removed cached image for key: \(key)")
    }
    
    func preloadImages(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    await self.preloadImage(url: url)
                }
            }
        }
    }
    
    private func preloadImage(url: URL) async {
        if self.get(forKey: url.absoluteString) != nil {
            print("Image already cached for URL: \(url.absoluteString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.set(uiImage, forKey: url.absoluteString)
                print("Preloaded image: \(url.absoluteString)")
            }
        } catch {
            print("Failed to preload image: \(url.absoluteString), error: \(error.localizedDescription)")
        }
    }
}

struct CachedAsyncImage<Content: View>: View {
    @State private var phase: AsyncImagePhase
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL?,
         scale: CGFloat = 1,
         transaction: Transaction = Transaction(),
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        
        _phase = State(initialValue: .empty)
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                if let url = url {
                    loadImage(url: url)
                }
            }
            .onChange(of: url) { newURL in
                if let newURL = newURL {
                    loadImage(url: newURL)
                } else {
                    phase = .empty
                }
            }
    }
    
    private func loadImage(url: URL) {
        if let cachedImage = ImageCache.shared.get(forKey: url.absoluteString) {
            phase = .success(Image(uiImage: cachedImage))
        } else {
            phase = .empty
            
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let uiImage = UIImage(data: data) {
                        ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                        withAnimation(transaction.animation) {
                            phase = .success(Image(uiImage: uiImage))
                        }
                    } else {
                        print("Failed to create UIImage from data for URL: \(url.absoluteString)")
                        phase = .failure(URLError(.cannotDecodeContentData))
                    }
                } catch {
                    print("Error loading image for URL: \(url.absoluteString), error: \(error.localizedDescription)")
                    phase = .failure(error)
                }
            }
        }
    }
}
