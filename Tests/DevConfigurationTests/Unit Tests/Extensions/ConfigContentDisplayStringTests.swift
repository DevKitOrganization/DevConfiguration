//
//  ConfigContentDisplayStringTests.swift
//  DevConfiguration
//
//  Created by Prachi Gauriar on 3/8/2026.
//

import Configuration
import DevTesting
import Foundation
import Testing

@testable import DevConfiguration

struct ConfigContentDisplayStringTests: RandomValueGenerating {
    var randomNumberGenerator = makeRandomNumberGenerator()


    @Test(arguments: [false, true])
    mutating func boolDisplayString(value: Bool) {
        #expect(ConfigContent.bool(value).displayString == "\(value)")
    }


    @Test
    mutating func intDisplayString() {
        let value = randomInt(in: -100 ... 100)
        #expect(ConfigContent.int(value).displayString == value.formatted())
    }


    @Test
    mutating func doubleDisplayString() {
        let value = randomFloat64(in: -100 ... 100)
        #expect(ConfigContent.double(value).displayString == value.formatted())
    }


    @Test
    mutating func stringDisplayString() {
        let value = randomAlphanumericString()
        #expect(ConfigContent.string(value).displayString == value)
    }


    @Test
    mutating func bytesDisplayString() {
        let bytes = Array(count: randomInt(in: 1 ... 10)) { random(UInt8.self, in: .min ... .max) }
        #expect(ConfigContent.bytes(bytes).displayString == bytes.count.formatted(.byteCount(style: .memory)))
    }


    @Test
    mutating func boolArrayDisplayString() {
        let value = Array(count: randomInt(in: 2 ... 5)) { randomBool() }
        let expected = value.map(String.init).formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.boolArray(value).displayString == expected)
    }


    @Test
    mutating func intArrayDisplayString() {
        let value = Array(count: randomInt(in: 2 ... 5)) { randomInt(in: -100 ... 100) }
        let expected = value.map { $0.formatted() }.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.intArray(value).displayString == expected)
    }


    @Test
    mutating func doubleArrayDisplayString() {
        let value = Array(count: randomInt(in: 2 ... 5)) { randomFloat64(in: -100 ... 100) }
        let expected = value.map { $0.formatted() }.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.doubleArray(value).displayString == expected)
    }


    @Test
    mutating func stringArrayDisplayString() {
        let value = Array(count: randomInt(in: 2 ... 5)) { randomAlphanumericString() }
        let expected = value.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.stringArray(value).displayString == expected)
    }


    @Test
    mutating func byteChunkArrayDisplayString() {
        let value = Array(count: randomInt(in: 2 ... 5)) {
            Array(count: randomInt(in: 1 ... 10)) { random(UInt8.self, in: .min ... .max) }
        }
        let expected = value.map { $0.count.formatted(.byteCount(style: .memory)) }
            .formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.byteChunkArray(value).displayString == expected)
    }


    @Test
    func emptyBoolArrayDisplayString() {
        let stringArray: [String] = []
        let expected = stringArray.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.boolArray([]).displayString == expected)
    }


    @Test
    func emptyIntArrayDisplayString() {
        let stringArray: [String] = []
        let expected = stringArray.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.intArray([]).displayString == expected)
    }


    @Test
    func emptyStringArrayDisplayString() {
        let stringArray: [String] = []
        let expected = stringArray.formatted(.list(type: .and, width: .narrow))
        #expect(ConfigContent.stringArray([]).displayString == expected)
    }


    @Test
    func emptyBytesDisplayString() {
        let expected = 0.formatted(.byteCount(style: .memory))
        #expect(ConfigContent.bytes([]).displayString == expected)
    }
}
