import SwiftUI

struct ContentView: View {
	@Binding var model: ViewModel
	
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
        }
        .padding()
    }
}

#Preview {
	@State var model = ContentView.ViewModel()
    return ContentView(model: $model)
}
