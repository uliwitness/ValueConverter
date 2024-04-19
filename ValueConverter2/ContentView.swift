import SwiftUI

struct ContentView: View {
	@Binding var model: ValueModel
	
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
			Int32Format(model: $model)
			UInt32Format(model: $model)
        }
        .padding()
    }
}

#Preview {
	@State var model = ValueModel()
    return ContentView(model: $model)
}
