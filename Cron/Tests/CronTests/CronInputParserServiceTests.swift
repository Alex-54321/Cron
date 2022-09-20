import XCTest
@testable import Cron

final class CronInputParserServiceTests: XCTestCase {
    private var parser: CronInputParserService!

    override func setUp() {
        super.setUp()
        parser = CronInputParserService()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    func testParsingDailyScheduler() {
        let line = "30 1 /bin/run_me_daily"
        let result = parser.parseConfig(line)
        let expectedResult = Scheduler(minute: .some(30), hour: .some(1), strategy: .daily)
        XCTAssertEqual(result, expectedResult)
    }

    func testParsingHourlyScheduler() {
        let line = "45 * /bin/run_me_hourly"
        let result = parser.parseConfig(line)
        let expectedResult = Scheduler(minute: .some(45), hour: .anytime, strategy: .hourly)
        XCTAssertEqual(result, expectedResult)
    }

    func testParsingEveryMinuteScheduler() {
        let line = "* * /bin/run_me_every_minute"
        let result = parser.parseConfig(line)
        let expectedResult = Scheduler(minute: .anytime, hour: .anytime, strategy: .everyMinute)
        XCTAssertEqual(result, expectedResult)
    }

    func testParsingSixtyTimesScheduler() {
        let line = "* 19 /bin/run_me_sixty_times"
        let result = parser.parseConfig(line)
        let expectedResult = Scheduler(minute: .anytime, hour: .some(19), strategy: .sixtyTimes)
        XCTAssertEqual(result, expectedResult)
    }
}
