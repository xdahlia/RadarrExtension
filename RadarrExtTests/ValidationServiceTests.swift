//
//  ValidationServiceTests.swift
//  RadarrExtTests
//
//  Created by Ivan Ou on 8/26/20.
//  Copyright © 2020 Ivan Ou. All rights reserved.
//

import XCTest
@testable import Share

class ValidationServiceTests: XCTestCase {

    var validation: ValidationService!

    override func setUp() {
        super.setUp()
        validation = ValidationService.shared
    }
    
    override func tearDown() {
        super.tearDown()
        validation = nil
    }
    
    func test_url_is_imdb_movie() throws {
        let good_url = NSURL(string: "https://www.imdb.com/title/tt123456")!
        XCTAssertNoThrow(try validation.validateSharedURL(with: good_url))
    }
    
    func test_is_valid_url() throws {
        let expectedError = UrlError.notMovie
        var error: UrlError?
        let bad_url2 = NSURL(string: "https://www.imdb.com/movie/tt123456")!
        XCTAssertThrowsError(try validation.validateSharedURL(with: bad_url2)) { thrownError in
            error = thrownError as? UrlError
        }
        XCTAssertEqual(expectedError, error)
        XCTAssertEqual(expectedError.localizedDescription, error?.localizedDescription)
        
//        let bad_url3 = NSURL(string: "https://www.imdb.com/")!
//        XCTAssertThrowsError(try validation.validateSharedURL(with: bad_url3))
//
//        let bad_url4 = NSURL(string: "https://www.google.com/")!
//        XCTAssertThrowsError(try validation.validateSharedURL(with: bad_url4))
        
    }

}
