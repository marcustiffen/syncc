import Combine
import Foundation
import Firebase


extension Query {
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
