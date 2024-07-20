import SwiftUI

struct ContentView: View {
	@Binding var model: FormattingView.ViewModel
	@State var intValue: Int = 42

#if _endian(big)
	static let oppositeEndianness = Endianness.littleEndian
#else
	static let oppositeEndianness = Endianness.bigEndian
#endif
	
	var body: some View {
		VStack {
			TabView {
				Form {
					IntFormattingView<Int8>(placeholder: "Int8", endianness: .machineByteOrder, model: $model)
					IntFormattingView<UInt8>(placeholder: "UInt8", endianness: .machineByteOrder, model: $model)
					IntFormattingView<Int16>(placeholder: "Int16", endianness: .machineByteOrder, model: $model)
					IntFormattingView<UInt16>(placeholder: "UInt16", endianness: .machineByteOrder, model: $model)
					IntFormattingView<Int32>(placeholder: "Int32", endianness: .machineByteOrder, model: $model)
					IntFormattingView<UInt32>(placeholder: "UInt32", endianness: .machineByteOrder, model: $model)
					IntFormattingView<Int64>(placeholder: "Int64", endianness: .machineByteOrder, model: $model)
					IntFormattingView<UInt64>(placeholder: "UInt64", endianness: .machineByteOrder, model: $model)
					StringFormattingView(placeholder: "UTF8", model: $model, encoding: .utf8)
					StringFormattingView(placeholder: "MacRoman", model: $model, encoding: .macOSRoman)
					StringFormattingView(placeholder: "Windows Latin", model: $model, encoding: .windowsCP1252)
					StringFormattingView(placeholder: "ShiftJIS", model: $model, encoding: .shiftJIS)
					HexFormattingView(placeholder: "Hex Bytes", model: $model)
					BitsFormattingView(placeholder: "Bits", model: $model)
				}
				.tabItem {
					Text("Native")
				}
				Form {
					IntFormattingView<Int8>(placeholder: "Int8", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<UInt8>(placeholder: "UInt8", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<Int16>(placeholder: "Int16", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<UInt16>(placeholder: "UInt16", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<Int32>(placeholder: "Int32", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<UInt32>(placeholder: "UInt32", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<Int64>(placeholder: "Int64", endianness: Self.oppositeEndianness, model: $model)
					IntFormattingView<UInt64>(placeholder: "UInt64", endianness: Self.oppositeEndianness, model: $model)
					StringFormattingView(placeholder: "UTF8", model: $model, encoding: .utf8)
					StringFormattingView(placeholder: "MacRoman", model: $model, encoding: .macOSRoman)
					StringFormattingView(placeholder: "Windows Latin", model: $model, encoding: .windowsCP1252)
					StringFormattingView(placeholder: "ShiftJIS", model: $model, encoding: .shiftJIS)
					HexFormattingView(placeholder: "Hex Bytes", model: $model)
					BitsFormattingView(placeholder: "Bits", model: $model)
				}
				.tabItem {
					if Self.oppositeEndianness == .littleEndian {
						Text("Little Endian")
					} else {
						Text("Big Endian")
					}
				}
			}
		}
		.padding()
	}
}

#Preview {
	@State var model = FormattingView.ViewModel()
	return ContentView(model: $model)
}
