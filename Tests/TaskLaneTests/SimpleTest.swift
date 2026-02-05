import Testing

@Suite("Simple Tests")
struct SimpleTests {
    @Test("Simple addition works")
    func simpleAddition() {
        #expect(1 + 1 == 2)
    }
}
