import Combine
import Foundation
import Firebase



extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).users
    }
    
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (users: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let users = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        
        return (users, snapshot.documents.last)
    }
    
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    
    func addSnapShotListener<T>(as type: T.Type) -> (AnyPublisher<[T], any Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            let sessions: [T] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: T.self)
            }
            publisher.send(sessions)
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}
