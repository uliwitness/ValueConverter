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
	
	var body: some View {
		LabeledContent("Bits") {
			VStack {
				BitView(model: $model, byteIndex: 0)
				BitView(model: $model, byteIndex: 1)
				BitView(model: $model, byteIndex: 2)
				BitView(model: $model, byteIndex: 3)
				BitView(model: $model, byteIndex: 4)
				BitView(model: $model, byteIndex: 5)
				BitView(model: $model, byteIndex: 6)
				BitView(model: $model, byteIndex: 7)
			}
		}
	}
}

struct BitView: View {
	
	@Binding var model: FormattingView.ViewModel
	let byteIndex: Int
	
	private func bit(from reverseBitIndex: Int) -> UInt8 {
		return 1 << (7 - reverseBitIndex)
	}
	
	private func padded(_ title: String) -> String {
		return (title.count < 2) ? title + " " : title // Figure space, the width of a number.
	}

	var body: some View {
		HStack {
			ForEach(0..<8) { bitIndex in
				Toggle(padded("\((byteIndex * 8) + (7 - bitIndex))"), isOn: Binding(
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
				.monospacedDigit()
				.lineLimit(1)
				.fixedSize()
			}
		}
	}

}
