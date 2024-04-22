import SwiftUI

struct ContentView: View {
	@Binding var model: ViewModel
	
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
			Int32View(model: $model)
			UInt32View(model: $model)
        }
        .padding()
    }
}

#Preview {
	@State var model = ContentView.ViewModel()
    return ContentView(model: $model)
}
