import Foundation
import SwiftUI

struct Int32View: View {
	@Binding var model: ContentView.ViewModel
	@State var intValue: Int32 = 0

	var body: some View {
		TextField("Int32", text: Binding(
			get: {
				let intValue: Int32 = FormattingView.fromBytes(model.rawBytes)
				return "\(intValue)"
			},
			set: {
				model.rawBytes = FormattingView.toBytes(Int32($0) ?? 0)
			}
		))
	}
}

struct UInt32View: View {
	@Binding var model: ContentView.ViewModel

	var body: some View {
		TextField("UInt32", text: Binding(
			get: {
				let intValue: UInt32 = FormattingView.fromBytes(model.rawBytes)
				return "\(intValue)"
			},
			set: {
				model.rawBytes = FormattingView.toBytes(UInt32($0) ?? 0)
			}
		))
	}
}
