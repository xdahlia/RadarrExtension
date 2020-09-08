//
//  Handler.swift
//  Share
//
//  Created by Ivan Ou on 9/3/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import Foundation

protocol Handler {
    
//    var nextHandler: Handler? { get set }
    
    associatedtype T
    associatedtype R
    
    func handle(input: T) -> R
}
