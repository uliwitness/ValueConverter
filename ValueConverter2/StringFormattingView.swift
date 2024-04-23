import Foundation
import SwiftUI

struct StringFormattingView: View {
	let placeholder: String
	@Binding var model: FormattingView.ViewModel
	let encoding: String.Encoding

	var body: some View {
		HStack {
			Text(placeholder)
			TextField(placeholder, text: Binding(
				get: {
					return String(bytes: model.rawBytes, encoding: encoding) ?? ""
				},
				set: {
					let newValue = $0
					let oldValue = String(bytes: model.rawBytes, encoding: encoding) ?? ""
					if newValue != oldValue {
						let encodedData = newValue.data(using: encoding) ?? Data()
						model.rawBytes = [UInt8](repeating: 0, count: encodedData.count)
						model.rawBytes.withUnsafeMutableBytes { buffer in
							_ = encodedData.copyBytes(to: buffer)
						}
					}
				}
			))
		}
	}
}

