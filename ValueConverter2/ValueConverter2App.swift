import SwiftUI

@main
struct ValueConverter2App: App {
	@State var storage = FormattingView.ViewModel()
	
    var body: some Scene {
        WindowGroup {
            ContentView(model: $storage)
        }
    }
}
