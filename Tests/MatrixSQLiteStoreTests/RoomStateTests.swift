//
//  RoomStateTests.swift
//
//
//  Created by Finn Behrens on 25.04.22.
//

import GRDB
import MatrixClient
@testable import MatrixSQLiteStore
import XCTest

class RoomStateTests: XCTestCase {
    func testExample() async throws {
        let dbQueue = try DatabasePool(path: "/tmp/test.sqlite")
        // let dbQueue = DatabaseQueue()
        let store = try MatrixSQLiteStore(dbQueue)

        let inSender = MatrixFullUserIdentifier(localpart: "user", domain: "example.com")
        let inContent = MatrixRoomCreateEvent(creator: inSender, roomVersion: "1")
        let inEvent = MatrixStateEvent(
            eventID: "!event:example.com",
            stateKey: "",
            sender: inSender,
            content: inContent
        )
        let inData = try MatrixSQLiteStore.RoomState(roomId: "!room:example.com", event: inEvent)

        try await store.addRoomState(state: inData)

        let state = try await store.getRoomState(eventId: "!event:example.com")
        XCTAssertNotNil(state)

        guard let content = state?.content as? MatrixRoomCreateEvent else {
            XCTFail("content not of type MatrixRoomCreateEvent")
            return
        }
        XCTAssertEqual(content.creator, inContent.creator)
        XCTAssertEqual(content.federate, inContent.federate)
        XCTAssertEqual(content.roomType, inContent.roomType)
        XCTAssertEqual(content.roomVersion, inContent.roomVersion)
        XCTAssertEqual(content.predecessor, inContent.predecessor)
        XCTAssertEqual(state?.sender, inSender)
    }
}
