import XCTest
@testable import Cron

final class CronSchedulerServiceTests: XCTestCase {
    private var scheduler: CronSchedulerService!

    override func setUp() {
        super.setUp()
        scheduler = CronSchedulerService()
    }

    override func tearDown() {
        scheduler = nil
        super.tearDown()
    }

    func testCronReturnsSameTime() throws {
        let schedule = Scheduler(minute: .anytime, hour: .anytime)
        let time = "12:12"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(12), hour: .some(12))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameTime_whenInputHourAndMinuteAreSame() throws {
        let schedule = Scheduler(minute: .some(25), hour: .some(9))
        let time = "09:25"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(25), hour: .some(9))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameTime_whenInputHourIsSame() throws {
        let schedule = Scheduler(minute: .some(45), hour: .some(0))
        let time = "00:50"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(45), hour: .some(0))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameTime_whenInputMinuteIsSame() throws {
        let schedule = Scheduler(minute: .some(15), hour: .some(9))
        let time = "23:15"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(15), hour: .some(9))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameHour() throws {
        let schedule = Scheduler(minute: .some(25), hour: .anytime)
        let time = "09:15"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(25), hour: .some(9))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameMinute() throws {
        let schedule = Scheduler(minute: .anytime, hour: .some(19))
        let time = "18:15"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(0), hour: .some(19))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameTime_edgeCaseTime() throws {
        let schedule = Scheduler(minute: .anytime, hour: .anytime)
        let time = "00:00"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(0), hour: .some(0))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameHour_edgeCaseTime() throws {
        let schedule = Scheduler(minute: .anytime, hour: .some(1))
        let time = "00:00"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(0), hour: .some(1))
        XCTAssertEqual(result, expectedResult)
    }

    func testCronReturnsSameMinute_edgeCaseTime() throws {
        let schedule = Scheduler(minute: .some(1), hour: .anytime)
        let time = "00:00"
        let date = DateFormatter.timeOfTheDay(time: time)
        let result = scheduler.calculateNextScheduler(schedule, referenceTime: try XCTUnwrap(date))
        let expectedResult = Scheduler(minute: .some(1), hour: .some(0))
        XCTAssertEqual(result, expectedResult)
    }

    func testIsWithinToday() throws {
        let schedules = [
            Scheduler(minute: .some(12), hour: .some(12)),
            Scheduler(minute: .some(13), hour: .some(12)),
            Scheduler(minute: .some(13), hour: .some(13)),
            Scheduler(minute: .some(59), hour: .some(23)),
            Scheduler(minute: .some(8), hour: .some(15)),
            Scheduler(minute: .some(8), hour: .some(15))
        ]
        let time = "12:12"
        let date = DateFormatter.timeOfTheDay(time: time)
        let results = try schedules.map { scheduler.isWithinToday(scheduler: $0, referenceTime: try XCTUnwrap(date)) }
        results.forEach { XCTAssertTrue($0) }
    }

    func testIsNotWithinToday() throws {
        let schedules = [
            Scheduler(minute: .some(11), hour: .some(12)),
            Scheduler(minute: .some(11), hour: .some(0)),
            Scheduler(minute: .some(0), hour: .some(0)),
            Scheduler(minute: .some(1), hour: .some(0)),
            Scheduler(minute: .some(7), hour: .some(7)),
            Scheduler(minute: .some(0), hour: .some(12))
        ]
        let time = "12:12"
        let date = DateFormatter.timeOfTheDay(time: time)
        let results = try schedules.map { scheduler.isWithinToday(scheduler: $0, referenceTime: try XCTUnwrap(date)) }
        results.forEach { XCTAssertFalse($0) }
    }

    func testIsWithinToday_edgeCase() throws {
        let schedules = [
            Scheduler(minute: .some(0), hour: .some(0)),
            Scheduler(minute: .some(1), hour: .some(0)),
            Scheduler(minute: .some(13), hour: .some(12)),
            Scheduler(minute: .some(13), hour: .some(13)),
            Scheduler(minute: .some(59), hour: .some(23)),
            Scheduler(minute: .some(8), hour: .some(15)),
            Scheduler(minute: .some(8), hour: .some(15)),
            Scheduler(minute: .some(11), hour: .some(12)),
            Scheduler(minute: .some(11), hour: .some(0)),
            Scheduler(minute: .some(0), hour: .some(0)),
            Scheduler(minute: .some(1), hour: .some(0)),
            Scheduler(minute: .some(7), hour: .some(7)),
            Scheduler(minute: .some(0), hour: .some(12))
        ]
        let time = "00:00"
        let date = DateFormatter.timeOfTheDay(time: time)
        let results = try schedules.map { scheduler.isWithinToday(scheduler: $0, referenceTime: try XCTUnwrap(date)) }
        results.forEach { XCTAssertTrue($0) }
    }

    func testIsWithinToday_edgeCase_endOfDay() throws {
        let schedules = [
            Scheduler(minute: .some(0), hour: .some(0)),
            Scheduler(minute: .some(1), hour: .some(0)),
            Scheduler(minute: .some(13), hour: .some(12)),
            Scheduler(minute: .some(13), hour: .some(13))
        ]
        let time = "23:59"
        let date = DateFormatter.timeOfTheDay(time: time)
        let results = try schedules.map { scheduler.isWithinToday(scheduler: $0, referenceTime: try XCTUnwrap(date)) }
        results.forEach { XCTAssertFalse($0) }
    }

    func testIsNotWithinToday_edgeCase_endOfDay() throws {
        let schedules = [
            Scheduler(minute: .some(0), hour: .some(0)),
            Scheduler(minute: .some(1), hour: .some(0)),
            Scheduler(minute: .some(13), hour: .some(12)),
            Scheduler(minute: .some(13), hour: .some(13))
        ]
        let time = "23:59"
        let date = DateFormatter.timeOfTheDay(time: time)
        let results = try schedules.map { scheduler.isWithinToday(scheduler: $0, referenceTime: try XCTUnwrap(date)) }
        results.forEach { XCTAssertFalse($0) }
    }
}

private extension Scheduler {
    init(minute: Time, hour: Time)  {
        self.init(minute: minute, hour: hour, strategy: .daily)
    }
}
