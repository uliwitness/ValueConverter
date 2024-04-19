import SwiftUI

class ValueModel {
	@State var rawBytes: [UInt8] = [0xff, 0xff, 0xff, 0xff]
}

@main
struct ValueConverter2App: App {
	@State var storage = ValueModel()
	
    var body: some Scene {
        WindowGroup {
            ContentView(model: $storage)
        }
    }
}
