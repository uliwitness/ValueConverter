import Foundation
import SwiftUI

func toBytes<T>(_ value: T) -> [UInt8] {
	var myValue = value
	return withUnsafeBytes(of: &myValue) { Array($0) }
}

func fromBytes<T>(_ bytes: [UInt8]) -> T {
	var resizedBytes = bytes
	while resizedBytes.count < MemoryLayout<T>.size {
		resizedBytes.append(0)
	}
	return bytes.withUnsafeBufferPointer() {
		return $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
			$0.pointee
		}
	}
}
