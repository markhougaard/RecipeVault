import Testing
@testable import RecipeVault

@Suite("DurationBuilder")
struct DurationBuilderTests {

    @Test func buildsHoursAndMinutes() {
        #expect(DurationBuilder.iso8601(hours: 1, minutes: 30) == "PT1H30M")
    }

    @Test func buildsMinutesOnly() {
        #expect(DurationBuilder.iso8601(hours: 0, minutes: 45) == "PT45M")
    }

    @Test func buildsHoursOnly() {
        #expect(DurationBuilder.iso8601(hours: 2, minutes: 0) == "PT2H")
    }

    @Test func returnsNilForZero() {
        #expect(DurationBuilder.iso8601(hours: 0, minutes: 0) == nil)
    }

    @Test func roundTripsWithDurationFormatter() {
        // DurationBuilder → DurationFormatter should produce readable output
        let iso = DurationBuilder.iso8601(hours: 1, minutes: 15)
        #expect(iso == "PT1H15M")
        #expect(DurationFormatter.formatted(iso) == "1 hr 15 min")
    }
}
