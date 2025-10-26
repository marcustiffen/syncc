import FirebaseFirestore



class ReportManager {
    private let db = Firestore.firestore()
    
    func reportUser(reportedUserId: String, reportedByUserId: String, reason: String, completion: @escaping (Bool) -> Void) {
        let reportData: [String: Any] = [
            "reportedUserId": reportedUserId,
            "reportedByUserId": reportedByUserId,
            "reason": reason,
            "timestamp": Timestamp(),
            "status": "pending"
        ]

        db.collection("reports").document(reportedUserId).setData(reportData) { error in
            if let error = error {
                print("Error reporting user: \(error.localizedDescription)")
                completion(false)
            } else {
                self.incrementReportCount(for: reportedUserId)
                completion(true)
            }
        }
    }

    private func incrementReportCount(for userId: String) {
        let reportedUserRef = db.collection("reportedUsers").document(userId)
        
        reportedUserRef.getDocument { document, error in
            if let document = document, document.exists {
                reportedUserRef.updateData([
                    "reportCount": FieldValue.increment(Int64(1)),
                    "lastReportDate": Timestamp()
                ])
            } else {
                reportedUserRef.setData([
                    "userId": userId,
                    "reportCount": 1,
                    "lastReportDate": Timestamp(),
                    "isUnderReview": false
                ])
            }
        }
    }
}
