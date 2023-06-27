import YandexMobileMetrica

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(
            apiKey: "ca56bb94-8fbf-42cf-937e-c32f7d0e65ae"
        ) else {
            return
        }

        YMMYandexMetrica.activate(with: configuration)
    }

    func log(_ event: Event) {
        YMMYandexMetrica.reportEvent("appEvent", parameters: paramsFor(event), onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

private extension AnalyticsService {
    func paramsFor(_ event: Event) -> [String: String] {
        var params = ["event": event.label]

        switch event {
        case let .open(scene), let .tap(scene), let .close(scene):
            params["screen"] = scene.label
            if let objectLabel = scene.objetLabel {
                params["item"] = objectLabel
            }
        }

        return params
    }
}
