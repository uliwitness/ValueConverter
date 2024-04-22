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
	
}

struct IntFormattingView<T: LosslessStringConvertible & ExpressibleByIntegerLiteral>: View {
	let placeholder: String
	@Binding var model: FormattingView.ViewModel

	var body: some View {
		HStack {
			Text(placeholder)
			TextField(placeholder, text: Binding(
				get: {
					let intValue: T = FormattingView.fromBytes(model.rawBytes)
					return "\(intValue)"
				},
				set: {
					model.rawBytes = FormattingView.toBytes(T($0) ?? 0)
				}
			))
		}
	}
}
