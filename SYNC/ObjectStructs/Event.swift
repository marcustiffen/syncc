//
//  Event.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 01/12/2025.
//


struct Event: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
}