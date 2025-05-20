//
//  AuthDataResultModel.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 10/12/2024.
//
import Firebase
import FirebaseAuth
import Foundation


struct AuthDataResultModel: Codable {
    let uid: String
    var phoneNumber: String?
    var email: String?
    var name: String?
    
    init(user: User) {
        self.uid = user.uid
        self.phoneNumber = user.phoneNumber
        self.email = user.email
        self.name = user.displayName
    }
    
    enum CodingKeys: CodingKey {
        case uid
        case phoneNumber
        case email
        case name
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uid, forKey: .uid)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.name, forKey: .name)
    }
}
