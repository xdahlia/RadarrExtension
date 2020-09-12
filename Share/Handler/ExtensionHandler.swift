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
    
    static let shared = ExtensionHandler()
    
    // External method
    func handleShare(context: NSExtensionContext) throws -> URL? {
        
        print("ExtensionHandler.handleShare")
        
        guard let provider = try extractProviderFrom(context) else {
            throw ExtensionError.cannotExtractProvider
        }
        
        guard let attachment = try? await(loadAttachmentsFrom(provider)) else {
            throw ExtensionError.cannotLoadAttachment
        }
        print("exit from attachment guard")
        
        guard let url = try await(loadUrlFrom(attachment)) else {
            print("before throwing cannotloadURL")
            throw ExtensionError.cannotLoadURL
        }
        return url
    }
    
    // Extract item provider from share context
    private func extractProviderFrom(_ context: NSExtensionContext) throws -> [NSItemProvider]? {
        
        print("ExtensionHandler.extractProviderFromContext")
        
        if let item = context.inputItems.first as? NSExtensionItem {
            
            return item.attachments
        } else {
            throw ExtensionError.cannotExtractProvider
        }
    }
    
    // Return only the provider whose attachment contains "public.url" type
    private func loadAttachmentsFrom(_ provider: [NSItemProvider]) -> Promise<NSItemProvider> {
        
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
