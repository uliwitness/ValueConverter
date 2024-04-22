import SwiftUI

@main
struct ValueConverter2App: App {
	@State var storage = ContentView.ViewModel()
	
    var body: some Scene {
        WindowGroup {
            ContentView(model: $storage)
        }
    }
}
