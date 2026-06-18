import Testing
internal import SwiftUI
@testable import Talk

@Suite("Color+Hex")
struct ColorHexTests {

    private func components(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let resolved = color.resolve(in: .init())
        return (Double(resolved.red), Double(resolved.green), Double(resolved.blue), Double(resolved.opacity))
    }

    @Test func sixCharHex_white() {
        let c = components(Color(hex: "FFFFFF"))
        #expect(abs(c.r - 1.0) < 0.01)
        #expect(abs(c.g - 1.0) < 0.01)
        #expect(abs(c.b - 1.0) < 0.01)
        #expect(abs(c.a - 1.0) < 0.01)
    }

    @Test func sixCharHex_black() {
        let c = components(Color(hex: "000000"))
        #expect(abs(c.r - 0.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
        #expect(abs(c.a - 1.0) < 0.01)
    }

    @Test func sixCharHex_red() {
        let c = components(Color(hex: "FF0000"))
        #expect(abs(c.r - 1.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
    }

    @Test func threeCharHex_white() {
        let c = components(Color(hex: "FFF"))
        #expect(abs(c.r - 1.0) < 0.01)
        #expect(abs(c.g - 1.0) < 0.01)
        #expect(abs(c.b - 1.0) < 0.01)
    }

    @Test func threeCharHex_black() {
        let c = components(Color(hex: "000"))
        #expect(abs(c.r - 0.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
    }

    @Test func threeCharHex_red() {
        let c = components(Color(hex: "F00"))
        #expect(abs(c.r - 1.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
    }

    @Test func eightCharHex_withAlpha() {
        let c = components(Color(hex: "80FFFFFF"))
        #expect(abs(c.r - 1.0) < 0.01)
        #expect(abs(c.g - 1.0) < 0.01)
        #expect(abs(c.b - 1.0) < 0.01)
        #expect(abs(c.a - 0.502) < 0.01)
    }

    @Test func eightCharHex_fullAlpha() {
        let c = components(Color(hex: "FFFFFFFF"))
        #expect(abs(c.a - 1.0) < 0.01)
    }

    @Test func eightCharHex_zeroAlpha() {
        let c = components(Color(hex: "00FFFFFF"))
        #expect(abs(c.a - 0.0) < 0.01)
    }

    @Test func invalidHex_fallsBackToBlack() {
        let c = components(Color(hex: "ZZZZZZ"))
        #expect(abs(c.r - 0.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
        #expect(abs(c.a - 1.0) < 0.01)
    }

    @Test func emptyString_fallsBackToBlack() {
        let c = components(Color(hex: ""))
        #expect(abs(c.r - 0.0) < 0.01)
        #expect(abs(c.g - 0.0) < 0.01)
        #expect(abs(c.b - 0.0) < 0.01)
    }

    @Test func hashPrefixStripped() {
        let withHash = components(Color(hex: "#FF0000"))
        let withoutHash = components(Color(hex: "FF0000"))
        #expect(abs(withHash.r - withoutHash.r) < 0.01)
        #expect(abs(withHash.g - withoutHash.g) < 0.01)
        #expect(abs(withHash.b - withoutHash.b) < 0.01)
    }
}
