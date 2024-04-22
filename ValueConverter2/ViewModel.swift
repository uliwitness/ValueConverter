import Foundation
import SwiftUI

@Observable
class ValueModel {
	var rawBytes: [UInt8] = [0xff, 0xff, 0xff, 0xff]
}
