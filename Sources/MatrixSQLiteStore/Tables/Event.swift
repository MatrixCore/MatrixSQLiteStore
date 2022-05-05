//
//  File.swift
//
//
//  Created by Finn Behrens on 02.05.22.
//

import Foundation
import GRDB
import MatrixClient
import MatrixCore

public struct MatrixStoreEvent: Codable {
    public var streamingOrder: Int?
    public var topologicalOrdering: Int = 1
    public var eventId: String
    public var roomId: Int
    public var type: String
    public var stateKey: String?
    public var printable: Bool?
    public var senderId: Int64
    // public var content: MatrixCodableContent?
}

public extension MatrixStoreEvent {
    static let room = belongsTo(MatrixStoreRoom.self)
    var room: QueryInterfaceRequest<MatrixStoreRoom> {
        request(for: MatrixStoreEvent.room)
    }

    static let sender = belongsTo(MatrixStoreHandle.self)
    var sender: QueryInterfaceRequest<MatrixStoreHandle> {
        request(for: MatrixStoreEvent.sender)
    }
}

extension MatrixStoreEvent: TableRecord, FetchableRecord, MutablePersistableRecord {
    public static var databaseTableName: String = "event"

    public mutating func didInsert(with _: Int64, for _: String?) {
        streamingOrder = roomId
    }

    enum CodingKeys: String, CodingKey {
        case streamingOrder = "streaming_order"
        case topologicalOrdering = "topological_ordering"
        case eventId = "event_id"
        case roomId = "room_id"
        case type
        case stateKey = "state_key"
        case printable
        case senderId = "sender_id"
        // case content
    }
}
