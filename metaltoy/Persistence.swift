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
    
    let container: NSPersistentCloudKitContainer
    let context: NSManagedObjectContext
    
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ToyShader")
        #if DEBUG
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        #endif
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        context = container.viewContext
        
        #if DEBUG
        _ = self.newToyShader(source: defaultShader1)
        _ = self.newToyShader(source: defaultShader2)
        #endif
    }
    
    func newToyShader(source: String = defaultShader1) -> ToyShader {
        let newShader = ToyShader(context: context)
        newShader.source = source
        newShader.createdOn = Date()
        newShader.updatedOn = newShader.createdOn
        
        
        try! context.save()
        
        return newShader
    }
    
    func getID( for url: URL) -> NSManagedObjectID? {
        return context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    }
    
    func getToyShader(id: NSManagedObjectID) -> ToyShader? {
        return try! context.existingObject(with: id) as? ToyShader
    }
   
    
    static let recentShadersRequest = {
        let request: NSFetchRequest<ToyShader> = NSFetchRequest(entityName: "ToyShader")
        request.fetchLimit = 5*2
        request.sortDescriptors = [
            NSSortDescriptor(keyPath:  \ToyShader.updatedOn, ascending: false)
        ]
        
        return request
    }()
    
    func updateToyShader(id: NSManagedObjectID, source: String) {
        let shader = getToyShader(id: id)!
        
        shader.setValue(source, forKey: "source")
        
        try! context.save()
    }
}

