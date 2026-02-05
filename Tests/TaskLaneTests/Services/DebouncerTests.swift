import Testing
import Foundation
@testable import TaskLane

@Suite("Debouncer Tests")
@MainActor
struct DebouncerTests {

    @Test("Debouncer executes action after delay")
    func executesAfterDelay() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var executed = false

        debouncer.debounce {
            executed = true
        }

        // Should not execute immediately
        #expect(executed == false)

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(150))

        #expect(executed == true)
    }

    @Test("Debouncer cancels previous action when called again")
    func cancelsPreviousAction() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var firstExecuted = false
        var secondExecuted = false

        debouncer.debounce {
            firstExecuted = true
        }

        // Immediately call again before delay
        debouncer.debounce {
            secondExecuted = true
        }

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(150))

        // Only second should execute
        #expect(firstExecuted == false)
        #expect(secondExecuted == true)
    }

    @Test("Debouncer cancel prevents execution")
    func cancelPreventsExecution() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var executed = false

        debouncer.debounce {
            executed = true
        }

        debouncer.cancel()

        // Wait longer than delay
        try await Task.sleep(for: .milliseconds(150))

        #expect(executed == false)
    }

    @Test("Debouncer coalesces rapid calls")
    func coalescesRapidCalls() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var counter = 0

        // Fire rapidly
        for _ in 1...10 {
            debouncer.debounce {
                counter += 1
            }
        }

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(150))

        // Should only execute once
        #expect(counter == 1)
    }

    @Test("Debouncer respects different delays")
    func respectsDifferentDelays() async throws {
        let shortDebouncer = Debouncer(delay: 0.05)
        let longDebouncer = Debouncer(delay: 0.2)
        var shortExecuted = false
        var longExecuted = false

        shortDebouncer.debounce {
            shortExecuted = true
        }

        longDebouncer.debounce {
            longExecuted = true
        }

        // Wait for short delay
        try await Task.sleep(for: .milliseconds(80))

        #expect(shortExecuted == true)
        #expect(longExecuted == false)

        // Wait for long delay
        try await Task.sleep(for: .milliseconds(150))

        #expect(longExecuted == true)
    }

    @Test("Debouncer works with zero delay")
    func worksWithZeroDelay() async throws {
        let debouncer = Debouncer(delay: 0)
        var executed = false

        debouncer.debounce {
            executed = true
        }

        // Give a tiny bit of time for async dispatch
        try await Task.sleep(for: .milliseconds(10))

        #expect(executed == true)
    }

    @Test("Multiple debouncers are independent")
    func multipleDebouncersIndependent() async throws {
        let debouncer1 = Debouncer(delay: 0.1)
        let debouncer2 = Debouncer(delay: 0.1)
        var count1 = 0
        var count2 = 0

        debouncer1.debounce {
            count1 += 1
        }

        debouncer2.debounce {
            count2 += 1
        }

        // Cancel only debouncer1
        debouncer1.cancel()

        try await Task.sleep(for: .milliseconds(150))

        #expect(count1 == 0)
        #expect(count2 == 1)
    }
}
