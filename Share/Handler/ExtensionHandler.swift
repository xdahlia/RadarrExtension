//
//  ExtensionHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/3/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

// Extract IMDb url from share
class ExtensionHandler {
    
    static let shared = ExtensionHandler()
    
    func handleShare(context: NSExtensionContext) throws -> URL? {
        
        guard let provider = try extractProviderFromContext(input: context) else {
            throw ExtensionError.cannotExtractProvider
        }
        
        guard let url = extractUrlFromProvider(provider: provider) else {
            throw ExtensionError.cannotLoadAttachment
        }
        
        return url
        
    }
    
    private func extractProviderFromContext(input context: NSExtensionContext) throws -> [NSItemProvider]? {
        
        if let item = context.inputItems.first as? NSExtensionItem {
            
            return item.attachments
        } else {
            throw ExtensionError.cannotExtractProvider
        }
    }
    
    private func extractUrlFromProvider(provider: [NSItemProvider]) -> URL? {
        
        var imdbURL: URL?
        
        provider.forEach({ (attachment) in
            if attachment.hasItemConformingToTypeIdentifier("public.url") {
                
                attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                    
                    if let shareURL = url as? URL {
                        imdbURL = shareURL
                    }
                    
                    // TODO: Add error handling
//                    if let error = error {
//                        throw ExtensionError.cannotLoadAttachment
//                    }
                    
                }
            }
        })
        
        return imdbURL
    }
    

    

    typealias T = NSExtensionContext
    typealias R = NSURL

    typealias Handler = (Result<NSURL, Error>) -> Void

    func handle(input context: NSExtensionContext?, completion: @escaping Handler) {

        if let item = context?.inputItems.first as? NSExtensionItem {

            item.attachments?.forEach({ (attachment) in
                if attachment.hasItemConformingToTypeIdentifier("public.url") {

                    attachment.loadItem(
                        forTypeIdentifier: "public.url",
                        options: nil,
                        completionHandler: { (url, error) -> Void in

                            if let shareURL = url as? NSURL {
                                completion(.success(shareURL))
                            }

                            if let error = error {
                                completion(.failure(error))
                            }

                    })
                }
            })
        }
    }

    
}
