import XCTest
import SwiftUI
@testable import ValueConverter

final class ValueConverterTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testHexString() throws {
		let bytes: [UInt8] = [0x01, 0x02, 0x20, 0x21]
		XCTAssertEqual(FormattingView.fromBytesToHex(bytes), "01022021")
		
		XCTAssertEqual(FormattingView.fromHexToBytes("01022021"), bytes)
		
		let paddedBytes: [UInt8] = [0x01, 0x02, 0x20, 0x20]
		XCTAssertEqual(FormattingView.fromHexToBytes("0102202"), paddedBytes)

		XCTAssertEqual(FormattingView.fromHexToBytes("0x0102202"), paddedBytes)
		
		XCTAssertEqual(FormattingView.fromHexToBytes("0X01022021"), bytes)

		XCTAssertEqual(FormattingView.fromHexToBytes("01'02'202"), paddedBytes)
		
		XCTAssertEqual(FormattingView.fromHexToBytes("01 02 202"), paddedBytes)
		
		XCTAssertEqual(FormattingView.fromHexToBytes("01,02.202"), paddedBytes)
		
		XCTAssertEqual(FormattingView.fromHexToBytes("01_02_202"), paddedBytes)

		XCTAssertEqual(FormattingView.fromHexToBytes(""), [])
		
		XCTAssertEqual(FormattingView.fromHexToBytes("0x"), [])

		XCTAssertEqual(FormattingView.fromHexToBytes("'_."), [])

	}
	
}
