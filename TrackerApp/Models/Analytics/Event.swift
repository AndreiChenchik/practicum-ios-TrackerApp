enum Event {
    case open(scene: EventScene)
    case close(scene: EventScene)
    case tap(scene: EventScene, object: String)
}
