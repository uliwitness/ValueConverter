//
//  ValueConverter2Tests.swift
//  ValueConverter2Tests
//
//  Created by Uli Kusterer on 19.04.24.
//

import XCTest
import SwiftUI
@testable import ValueConverter2

final class ValueConverter2Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	struct TestModel {
		@State var model: ValueModel = ValueModel()
	}
	
    func testExample() throws {
		let valueModel = TestModel()
		var fmt = Int32Format(model: valueModel.$model)
		fmt.value = 500
		print("\(fmt.value)")
		valueModel.model.rawBytes = [0, 1, 0, 0]
		print("\(fmt.value)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
