import CoreData
import UIKit

protocol StoreDelegate: AnyObject {
    func didChangeContent()
}

protocol CoreDataIdentifiable {
    var id: UUID? { get set }
}

protocol CoreDataDated {
    var createdAt: Date? { get set }
}

final class Store<Entity>: NSObject, NSFetchedResultsControllerDelegate
where Entity: NSManagedObject & CoreDataIdentifiable & CoreDataDated {
    var data: [Entity] { resultController.fetchedObjects ?? [] }

    private weak var delegate: StoreDelegate?
    private let context: NSManagedObjectContext
    private lazy var resultController: NSFetchedResultsController<Entity> = {
        guard let fetchRequest = Entity.fetchRequest() as? NSFetchRequest<Entity> else {
            preconditionFailure("Can't create fetch request")
        }

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(delegate: StoreDelegate, context: NSManagedObjectContext? = nil) {
        if let context {
            self.context = context
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                preconditionFailure("Something went terribly wrong")
            }

            self.context = appDelegate.persistentContainer.viewContext
        }

        self.delegate = delegate

        super.init()
        _ = data
    }

    func create(configure: (Entity) -> Void) {
        var entity = Entity(context: context)

        entity.createdAt = Date()
        entity.id = UUID()

        configure(entity)

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    func getById(_ id: UUID) -> Entity? {
        guard let request = Entity.fetchRequest() as? NSFetchRequest<Entity> else {
            preconditionFailure("Can't create fetch request")
        }

        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.didChangeContent()
    }
}
