import Foundation

extension ContentView {
	@Observable
	class ViewModel {
		var rawBytes: [UInt8] = [0xff, 0xff, 0xff, 0xff]
	}
}
