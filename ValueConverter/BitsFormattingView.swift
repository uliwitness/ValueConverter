import Foundation
import SwiftUI

private extension Array where Element == UInt8 {
	subscript(safe index: Self.Index) -> UInt8? {
		get {
			guard index < endIndex && index >= startIndex else { return nil }
			return self[index]
		}
		mutating set(newValue) {
			guard let newValue = newValue else {
				replaceSubrange(index...index, with: [])
				return
			}
			while !indices.contains(index) {
				self.append(0)
			}
			replaceSubrange(index...index, with: [newValue])
		}
	}
}

struct BitsFormattingView: View {
	let placeholder: String
	@Binding var model: FormattingView.ViewModel
	
	private func bit(from bitIndex: Int) -> UInt8 {
		return 1 << (7 - bitIndex)
	}
	
	var body: some View {
		LabeledContent("Bits") {
			VStack {
				HStack {
					ForEach(0..<4) { byteIndexUnflipped in
						let byteIndex = 3 - byteIndexUnflipped
						ForEach(0..<8) { bitIndex in
							Toggle("\((byteIndex * 8) + (7 - bitIndex))", isOn: Binding(
								get: {
									let byte = model.rawBytes[safe: byteIndex] ?? 0
									return (byte & bit(from: bitIndex)) == bit(from: bitIndex)
								},
								set: { newValue in
									let byte = model.rawBytes[safe: byteIndex] ?? 0
									let oldValue = (byte & bit(from: bitIndex)) == bit(from: bitIndex)
									if newValue != oldValue {
										model.rawBytes[safe: byteIndex] = newValue ? (byte | bit(from: bitIndex)) : (byte & ~bit(from: bitIndex))
									}
								}
							))
							.toggleStyle(.checkbox)
						}
						Spacer(minLength: 20.0)
					}
				}
			}
		}
	}
}

