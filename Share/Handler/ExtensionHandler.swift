//
//  ExtensionHandler.swift
//  Share
//
//  Created by Ivan Ou on 9/3/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

class ExtensionHandler {
    
    static let shared = ExtensionHandler()

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
    
//    handle(input: extensionContext) { (result) in
//        switch result {
//        case .success(let urlResponse):
////                return urlResponse
//            print(urlResponse)
//            break // Handle response
//        case .failure(let error):
//            print(error.localizedDescription)
//            break // Handle error
//        }
//    }
    
//    func callHandleFunction(input: NSExtensionContext) -> NSURL {
//
//        handle(input: input, completion: { (result) in
//            switch result {
//            case .success(let url):
//                return url
//            case .failure(let error):
//                return error
////                switch error {
////                case .failureReason1:
////                    return
////                case .failureReason2:
////                    return
////                }
//            }
//        })()
//    }
    
    
//    func handle(input: NSExtensionContext) -> NSURL {
//        handlerResult(input: input) { (result) in
//            switch result {
//            case .success(let urlResponse):
//                return urlResponse
//                break // Handle response
//            case .failure(let error):
//                break // Handle error
//            }
//        }
//    }
    
    
}
