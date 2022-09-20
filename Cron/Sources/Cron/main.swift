import Foundation

main()

func main() {
    let scheduler = CronSchedulerService()
    let inputParser = CronInputParserService()
    let outputParser = CronOutputParserService()
    let expectedSchedulersCount = 4
    guard let rawConfig = collectConfigInput(schedulersCount: expectedSchedulersCount),
          let rawReferenceTime = CommandLine.arguments[safe: 1]
    else {
        print("Faulty input detected")
        return
    }
    let config = rawConfig.compactMap(inputParser.parseConfig)
    let referenceTime = DateFormatter.timeOfTheDay(time: rawReferenceTime)
    guard let referenceTime = referenceTime, config.count == expectedSchedulersCount else {
        print("Faulty data detected")
        return
    }
    let cron = config.map { schedule -> String? in
        guard let nextSchedule = scheduler.calculateNextScheduler(schedule, referenceTime: referenceTime) else {
            print("Faulty data detected")
            return nil
        }
        let isToday = scheduler.isWithinToday(scheduler: nextSchedule, referenceTime: referenceTime)
        let output = outputParser.formatOutput(nextSchedule, isToday: isToday, referenceTime: referenceTime)
        return output
    }
    cron.compactMap { $0 }.forEach { print($0) }
}

fileprivate func collectConfigInput(schedulersCount: Int) -> [String]? {
    var result: [String] = []
    while let line = readLine() {
        result.append(line)
        guard result.count != schedulersCount else { break }
    }
    return result
}

// MARK: - CronSchedulerService
struct CronSchedulerService {
    func calculateNextScheduler(_ scheduler: Scheduler, referenceTime: Date) -> Scheduler? {
        guard let date = DateFormatter.timeOfTheDay(date: referenceTime) else { return nil }
        let dateComponents = date.split(separator: ":")
        guard let hourStr = dateComponents.first, let referenceHour = Int(hourStr),
              let minuteStr = dateComponents.last, let referenceMinute = Int(minuteStr)
        else {
            return nil
        }
        switch (scheduler.hour, scheduler.minute) {
        case (.anytime, .anytime):
            return Scheduler(minute: .some(referenceMinute), hour: .some(referenceHour), strategy: scheduler.strategy)
        case let (.anytime, .some(minute)):
            return Scheduler(minute: .some(minute), hour: .some(referenceHour), strategy: scheduler.strategy)
        case let (.some(hour), .anytime):
            let minute: Scheduler.Time = hour == referenceHour ? .some(referenceMinute) : .some(0)
            return Scheduler(minute: minute, hour: .some(hour), strategy: scheduler.strategy)
        case let (.some(hour), .some(minute)):
            return Scheduler(minute: .some(minute), hour: .some(hour), strategy: scheduler.strategy)
        }
    }

    func isWithinToday(scheduler: Scheduler, referenceTime: Date) -> Bool {
        guard let date = DateFormatter.timeOfTheDay(date: referenceTime) else { return false }
        let dateComponents = date.split(separator: ":")
        guard let hourStr = dateComponents.first, let referenceHour = Int(hourStr),
              let minuteStr = dateComponents.last, let referenceMinute = Int(minuteStr)
        else {
            return false
        }
        switch (scheduler.hour, scheduler.minute) {
        case (.anytime, .anytime):
            return true
        case let (.anytime, .some(value: value)):
            return value >= referenceMinute
        case let (.some(value: value), .anytime):
            return referenceHour < value
        case let (.some(value: hourValue), .some(value: minuteValue)):
            if hourValue == referenceHour {
                if minuteValue == referenceMinute { return true }
                return minuteValue >= referenceMinute
            }
            return hourValue >= referenceHour
        }
    }
}

// MARK: - CronInputParserService
struct CronInputParserService {
    func parseConfig(_ configLine: String) -> Scheduler? {
        var input = configLine.split(separator: " ")
        guard let rawStrategy = input.popLast(),
              let rawHour = input.popLast(),
              let rawMinute = input.popLast(),
              let strategy = Scheduler.Strategy(rawValue: String(rawStrategy)),
              let hour = Scheduler.Time(rawValue: String(rawHour), withRangeBoundary: .init(0...23)),
              let minute = Scheduler.Time(rawValue: String(rawMinute), withRangeBoundary: .init(0...59))
        else {
            return nil
        }
        return Scheduler(minute: minute, hour: hour, strategy: strategy)
    }
}

// MARK: - CronOutputParserService
struct CronOutputParserService {
    func formatOutput(_ nextSchedule: Scheduler, isToday: Bool, referenceTime: Date) -> String? {
        guard let prefix = formatScheduler(nextSchedule) else { return nil }
        let mid = isToday ? "today" : "tomorrow"
        let suffix = "- " + nextSchedule.strategy.rawValue
        return [prefix, mid, suffix].joined(separator: " ")
    }

    private func formatScheduler(_ scheduler: Scheduler) -> String? {
        let date = Date()
        let cal = Calendar.current
        guard let hour = scheduler.hour.value,
              let minute = scheduler.minute.value,
              let date = cal.date(bySettingHour: hour, minute: minute, second: 0, of: date)
        else {
            return nil
        }
        let localizedDate = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        return localizedDate.first == "0" ? String(localizedDate.dropFirst()) : localizedDate
    }
}

// MARK: - Scheduler struct
struct Scheduler: Equatable {
    enum Strategy: String {
        case daily = "/bin/run_me_daily"
        case hourly = "/bin/run_me_hourly"
        case everyMinute = "/bin/run_me_every_minute"
        case sixtyTimes = "/bin/run_me_sixty_times"
    }

    enum Time: Equatable {
        case some(Int)
        case anytime
    }

    let minute: Time
    let hour: Time
    let strategy: Strategy
}

extension Scheduler.Time {
    init?(rawValue: String, withRangeBoundary rangeBoundary: Range<Int>) {
        switch rawValue {
        case "*":
            self = .anytime
        default:
            guard let value = Int(rawValue), rangeBoundary.contains(value) else { return nil }
            self = .some(value)
        }
    }

    var value: Int? {
        switch self {
        case let .some(value):
            return value
        case .anytime:
            return nil
        }
    }
}

// MARK: - DateFormatter extensions
extension DateFormatter {
    /// Formats date with specified hour and minute in HH:mm format
    /// - Parameter time: Requested time in HH:mm format
    /// - Returns: Date with specified hour and minute
    static func timeOfTheDay(time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: time)
        return date
    }

    /// Converts date into HH:mm format
    /// - Parameter time: Date to be converted
    /// - Returns: String in HH:mm format of the date
    static func timeOfTheDay(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        return dateFormatter.string(from: date)
    }
}

// MARK: - Array extensions
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else { return nil }
        return self[index]
    }
}
