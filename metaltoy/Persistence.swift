//
//  Persistence.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/16/23.
//

import CoreData

let defaultShader1 = loadShader(name: "DefaultShader1")
let defaultShader2 = loadShader(name: "DefaultShader2")

func loadShader(name: String) -> String {
    let file = Bundle.main.url(forResource: name, withExtension: nil)!

    let data = try! String(contentsOf: file)

    return data
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContent = result.container.viewContext
        
        _ = PersistenceController.newToyShader(viewContent, source: defaultShader1)
        _ = PersistenceController.newToyShader(viewContent, source: defaultShader2)

        try! viewContent.save()
        
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ToyShader")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static func newToyShader(_ context: NSManagedObjectContext, source: String = defaultShader1) -> ToyShader {
        let newShader = ToyShader(context: context)
        newShader.source = source
        newShader.createdOn = Date()
        newShader.updatedOn = newShader.createdOn
        
        
        try! context.save()
        
        return newShader
    }
    
    static func getID(_ context: NSManagedObjectContext, for url: URL) -> NSManagedObjectID? {
        return context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    }
    
    static func getToyShader(_ context: NSManagedObjectContext, id: NSManagedObjectID) -> ToyShader? {
        return try! context.existingObject(with: id) as? ToyShader
    }
   
    static func getToyShader(_ context: NSManagedObjectContext, url: URL) -> ToyShader? {
        let objectID = PersistenceController.getID(context, for: url)
        
        return objectID.map {
            PersistenceController.getToyShader(context, id: $0)
        }!
    }
    
    static func getRecentShaders(context: NSManagedObjectContext) -> [ToyShader] {
        let request: NSFetchRequest<ToyShader> = NSFetchRequest(entityName: "ToyShader")
        request.fetchLimit = 5*2
        request.sortDescriptors = [
            NSSortDescriptor(keyPath:  \ToyShader.updatedOn, ascending: false)
        ]
        
        let shaders = try? context.fetch(request)
        
        return shaders ?? []
    }
    
    static func updateToyShader(_ context: NSManagedObjectContext, id: NSManagedObjectID, source: String) {
        let shader = PersistenceController.getToyShader(context, id: id)!
        
        shader.setValue(source, forKey: "source")
        
        try! context.save()
    }
}

