import Foundation
import SwiftUI

struct Int32Format: View {
	@State var value: Int32 = -10_000 {
		mutating didSet {
			model.rawBytes = toBytes(value)
		}
	}
	
	@Binding var model: ValueModel {
		mutating didSet(model) {
			value = fromBytes(model.rawBytes)
		}
	}
	
	var body: some View {
		TextField("Int32", value: $value, format: .number)
	}
}

struct UInt32Format: View {
	@State var value: UInt32 = 10_000 {
		mutating didSet {
			model.rawBytes = toBytes(value)
		}
	}
	
	@Binding var model: ValueModel {
		mutating didSet(model) {
			value = fromBytes(model.rawBytes)
		}
	}
	
	var body: some View {
		TextField("UInt32", value: $value, format: .number)
	}
}
