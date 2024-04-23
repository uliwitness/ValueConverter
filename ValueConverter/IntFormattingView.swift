import Foundation
import SwiftUI

enum FormattingView {
	
	static func toBytes<T>(_ value: T) -> [UInt8] {
		var myValue = value
		return withUnsafeBytes(of: &myValue) { Array($0) }
	}
	
	static func fromBytes<T>(_ bytes: [UInt8]) -> T {
		var resizedBytes = bytes
		while resizedBytes.count < MemoryLayout<T>.size {
			resizedBytes.append(0)
		}
		return bytes.withUnsafeBufferPointer() {
			return $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
				$0.pointee
			}
		}
	}
	
	static func fromHexToBytes(_ hexString: String) -> [UInt8] {
		var hexStringToParse = hexString
		if (hexString.count % 2) != 0 {
			hexStringToParse += "0"
		}
		var bytes = [UInt8]()
		var currIndex = hexString.startIndex
		while currIndex < hexStringToParse.endIndex {
			let nextIndex = hexStringToParse.index(currIndex, offsetBy: 2)
			let hexByteStr = hexStringToParse[currIndex..<nextIndex]
			bytes.append(UInt8(hexByteStr, radix: 16) ?? 0)
			currIndex = nextIndex
		}
		return bytes
	}

	static func fromBytesToHex(_ bytes: [UInt8]) -> String {
		var str = ""
		for currCharacter in bytes {
			str += String(format: "%02X", arguments: [UInt32(currCharacter)])
		}
		return str
	}
	
}

struct IntFormattingView<T: LosslessStringConvertible & ExpressibleByIntegerLiteral & Equatable>: View {
	let placeholder: String
	@Binding var model: FormattingView.ViewModel
	
	var body: some View {
		TextField(placeholder, text: Binding(
			get: {
				let intValue: T = FormattingView.fromBytes(model.rawBytes)
				return "\(intValue)"
			},
			set: {
				let newValue = T($0) ?? 0
				let oldValue: T = FormattingView.fromBytes(model.rawBytes)
				if newValue != oldValue {
					model.rawBytes = FormattingView.toBytes(newValue)
				}
			}
		))
	}
}
