import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date
}

extension TrackerRecord {
    static func fromCoreData(_ data: TrackerRecordCD) -> TrackerRecord? {
        guard let date = data.date, let trackerId = data.tracker?.id else { return nil }

        return .init(trackerId: trackerId, date: date)
    }
}
