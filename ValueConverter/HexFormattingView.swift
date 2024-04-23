import Foundation
import SwiftUI

struct HexFormattingView: View {
	let placeholder: String
	@Binding var model: FormattingView.ViewModel
	
	var body: some View {
		HStack {
			Text(placeholder)
			TextField(placeholder, text: Binding(
				get: {
					return FormattingView.fromBytesToHex(model.rawBytes)
				},
				set: { newValue in
					let oldValue = FormattingView.fromBytesToHex(model.rawBytes)
					if newValue != oldValue {
						model.rawBytes = FormattingView.fromHexToBytes(newValue)
					}
				}
			))
		}
	}
}

