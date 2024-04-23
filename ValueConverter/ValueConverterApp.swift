import SwiftUI

@main
struct ValueConverterApp: App {
	@State var storage = FormattingView.ViewModel()
	
	var body: some Scene {
		WindowGroup {
			ContentView(model: $storage)
		}
	}
}
