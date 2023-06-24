import YandexMobileMetrica

final class AnalyticsService {
    func log(event: Event) {
        YMMYandexMetrica.reportEvent("appEvent", parameters: paramsFor(event), onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

private extension AnalyticsService {
    func paramsFor(_ event: Event) -> [String: String] {
        switch event {
        case let .open(scene):
            return ["event": "open", "screen": scene.rawValue]
        case let .close(scene):
            return ["event": "close", "screen": scene.rawValue]
        case let .tap(scene, object):
            return ["event": "click", "screen": scene.rawValue, "item": object]
        }
    }
}
