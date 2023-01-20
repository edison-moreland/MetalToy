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

struct DataStore {
    #if DEBUG
    static let shared = DataStore(inMemory: true, withTestShaders: true)
    #else
    static let shared = DataStore()
    #endif
    
    let container: NSPersistentCloudKitContainer
    let context: NSManagedObjectContext
    
    init(inMemory: Bool = false, withTestShaders: Bool = false) {
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
        
        context = container.viewContext
        
        if inMemory && withTestShaders {
            _ = self.newToyShader(source: defaultShader1)
            _ = self.newToyShader(source: defaultShader2)
        }
    }
    
    func newToyShader(source: String = defaultShader1) -> ToyShader {
        let newShader = ToyShader(context: context)
        newShader.source = source
        newShader.createdOn = Date()
        newShader.updatedOn = newShader.createdOn
        newShader.revision = 1
        
        try! context.save()
        
        return newShader
    }
    
    func getID( for url: URL) -> NSManagedObjectID? {
        return context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url)
    }
    
    func getToyShader(id: NSManagedObjectID) -> ToyShader? {
        return try! context.existingObject(with: id) as? ToyShader
    }

    func getToyShader(url: URL) -> ToyShader? {
        return getToyShader(id: getID(for: url)!)
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
        context.perform {
            let shader = getToyShader(id: id)!
            
            //shader.setValue(source, forKey: "source")
            shader.setValuesForKeys([
                "source": source,
                "revision": shader.revision+1,
                "updatedOn": Date()
            ])
            
            try! context.save()
        }
    }
    
    func deleteToyShader(id: NSManagedObjectID) {
        context.perform {
            let shader = getToyShader(id: id)!
            
            context.delete(shader)
            
            try! context.save()
        }
    }
}

