//
//  ExtensionHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/3/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation
import PromiseKit
import AwaitKit

// Extract IMDb url from share
class ExtensionHandler {

    // External method
    func handleShare(context: NSExtensionContext) throws -> URL {
        
        print("ExtensionHandler.handleShare")
        
        do {
            let provider = try extractProviderFrom(context)
            
            guard let attachment = try await(loadAttachmentsFrom(provider)) else {
                throw ExtensionError.cannotLoadAttachment
            }
            
            guard let url = try await(loadUrlFrom(attachment)) else {
                throw ExtensionError.cannotLoadURL
            }
            
            return url
            
        } catch {
            throw error
        }

    }
    
    // Extract item provider from share context
    private func extractProviderFrom(_ context: NSExtensionContext) throws -> [NSItemProvider] {
        
        print("ExtensionHandler.extractProviderFromContext")
        
        guard let item = context.inputItems.first as? NSExtensionItem else {
            throw ExtensionError.cannotExtractProvider
        }
        
        guard let attachment = item.attachments else {
            throw ExtensionError.cannotExtractAttachment
        }
        
        return attachment
    }
    
    // Return only the provider whose attachment contains "public.url" type
    private func loadAttachmentsFrom(_ provider: [NSItemProvider]) -> Promise<NSItemProvider?> {
        
        print("ExtensionHandler.loadAttachmentsFrom")
        
        return Promise { result in
        
            provider.forEach({ (attachment) in
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    
                    print(attachment.debugDescription)
                    result.fulfill(attachment)
                }
            })
        }
    }
    
    // Extract URL from attachment
    private func loadUrlFrom(_ attachment: NSItemProvider) -> Promise<URL?> {
        
        print("ExtensionHandler.loadUrlFrom")
        
        print(attachment.debugDescription)
        
        return Promise { result in
    
            attachment.loadItem(
                forTypeIdentifier: "public.url",
                options: nil,
                completionHandler: { (url, error) -> Void in
                    
                    print("print url: \(url.debugDescription)")
                                    
                    if let shareURL = url as? URL {
                        
                        print("print shareURL: \(shareURL.debugDescription)")
                        
                        result.fulfill(shareURL)
                    }
                    
                    if let error = error {
                        
                        print("print error: \(error.localizedDescription)")
                        result.reject(error)
                    }
            })
        }
    }
    
}
