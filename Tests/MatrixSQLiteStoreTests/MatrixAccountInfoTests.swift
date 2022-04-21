//
//  File.swift
//
//
//  Created by Finn Behrens on 16.04.22.
//

import GRDB
import MatrixClient
@testable import MatrixSQLiteStore
import XCTest

class AccountInfoTests: XCTestCase {
    func testGet() async throws {
        let dbQueue = DatabaseQueue()
        let store = try MatrixSQLiteStore(dbQueue)

        let id = MatrixUserIdentifier(rawValue: "@test:example.com")!
        let data = MatrixSQLAccountInfo(
            name: "test",
            mxID: id,
            homeServer: MatrixHomeserver(string: "https://example.com")!,
            accessToken: "secret"
        )

        defer {
            try! data.deleteFromKeychain()
        }

        try await store.saveAccountInfo(account: data)

        let account = try await store.getAccountInfo(accountID: id)

        XCTAssertEqual(account.accessToken, data.accessToken)
    }

    func testGetAll() async throws {
        let dbQueue = DatabaseQueue()

        let store = try MatrixSQLiteStore(dbQueue)
        let homeserver = MatrixHomeserver(string: "https://example.com")!

        let id1 = MatrixUserIdentifier(locapart: "test1", domain: "example.com")
        let data1 = MatrixSQLAccountInfo(name: "test1", mxID: id1, homeServer: homeserver, accessToken: "secret2")

        let id2 = MatrixUserIdentifier(locapart: "test2", domain: "example.com")
        let data2 = MatrixSQLAccountInfo(name: "test2", mxID: id2, homeServer: homeserver, accessToken: "secret2")

        defer {
            try! data1.deleteFromKeychain()
            try! data2.deleteFromKeychain()
        }

        try await store.saveAccountInfo(account: data1)
        try await store.saveAccountInfo(account: data2)

        let accounts = try await store.getAccountInfos()

        XCTAssertEqual(accounts.count, 2)

        XCTAssertEqual(accounts[0].name, data1.name)
        XCTAssertEqual(accounts[1].name, data2.name)

        XCTAssertEqual(accounts[0].accessToken, data1.accessToken)
        XCTAssertEqual(accounts[1].accessToken, data2.accessToken)

        XCTAssertEqual(accounts[0].mxID, data1.mxID)
        XCTAssertEqual(accounts[1].mxID, data2.mxID)
    }
}
