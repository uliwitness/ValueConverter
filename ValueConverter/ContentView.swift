import SwiftUI

struct ContentView: View {
	@Binding var model: FormattingView.ViewModel
	@State var intValue: Int = 42
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Hello, world!")
			IntFormattingView<Int8>(placeholder: "Int8", model: $model)
			IntFormattingView<UInt8>(placeholder: "UInt8", model: $model)
			IntFormattingView<Int16>(placeholder: "Int16", model: $model)
			IntFormattingView<UInt16>(placeholder: "UInt16", model: $model)
			IntFormattingView<Int32>(placeholder: "Int32", model: $model)
			IntFormattingView<UInt32>(placeholder: "UInt32", model: $model)
			IntFormattingView<Int64>(placeholder: "Int64", model: $model)
			IntFormattingView<UInt64>(placeholder: "UInt64", model: $model)
			StringFormattingView(placeholder: "UTF8", model: $model, encoding: .utf8)
			StringFormattingView(placeholder: "MacRoman", model: $model, encoding: .macOSRoman)
			StringFormattingView(placeholder: "Windows Latin", model: $model, encoding: .windowsCP1252)
			StringFormattingView(placeholder: "ShiftJIS", model: $model, encoding: .shiftJIS)
			HexFormattingView(placeholder: "Hex Bytes", model: $model)
			BitsFormattingView(placeholder: "Bits", model: $model)
		}
		.padding()
	}
}

#Preview {
	@State var model = FormattingView.ViewModel()
	return ContentView(model: $model)
}
