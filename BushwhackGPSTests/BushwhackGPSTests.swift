//
//  BushwhackGPSTests.swift
//  BushwhackGPSTests
//
//  Created by William Hause on 1/11/22.
//

import XCTest
@testable import BushwhackGPS

class BushwhackGPSTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //
    // MARK: AppSettingsEntity
    //
    func testAppSettingsEntity() throws {
        let settings = AppSettingsEntity.getAppSettingsEntity()
        settings.metricUnits = true
        settings.orientNorth = true
        settings.save()
        
        let settings2 = AppSettingsEntity.getAppSettingsEntity()
        XCTAssertEqual(settings2.orientNorth, true, "AppSettingsEntity.orientNorth should have been true")
        XCTAssertEqual(settings2.metricUnits, true, "AppSettingsEntity.metric should have been true")
        
        settings.metricUnits = false
        settings.orientNorth = false
        settings.save()
        
        XCTAssertEqual(settings2.orientNorth, false, "AppSettingsEntity.orientNorth should have been false")
        XCTAssertEqual(settings2.metricUnits, false, "AppSettingsEntity.metric should have been false")
    }
    
    
    //
    // MARK: ID_GeneratorEntity
    //
    func testID_GeneratorEntity() throws {
        let id1 = ID_GeneratorEntity.getNextID()
        let id2 = ID_GeneratorEntity.getNextID()
        print("NextID: \(id2)")
        XCTAssertEqual(id1, id2-1, "ID_Generator Failed to increment by 1")
    }
    func testPerformanceID_GeneratorEntity() throws {
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 1..<100 {
                _ = ID_GeneratorEntity.getNextID()
            }
        }
    }

    
    //
    // MARK: DotEntity
    //
    func testDotEntity() throws {
        let de = DotEntity.createDotEntity(lat: 100.0, lon: 100.0, speed: 0.0, course: 1.0)
        // Make sure none of the fields are nil
        XCTAssertNotNil(de.course)
        XCTAssertNotNil(de.id)
        XCTAssertNotNil(de.lat)
        XCTAssertNotNil(de.lon)
        XCTAssertNotNil(de.speed)
        XCTAssertNotNil(de.timestamp)
        XCTAssertNotNil(de.uuid)
        DotEntity.deleteDotEntity(de) // remove the test dot from the database
    }

    
    //
    // MARK: MarkerEntity
    //
    func testMarkerEntity() throws {
        let me = MarkerEntity.createMarkerEntity(lat: 100.0, lon: 100.0)
        // Make sure none of the fields are nil
        XCTAssertNotNil(me.colorRed)
        XCTAssertNotNil(me.colorBlue)
        XCTAssertNotNil(me.colorAlpha)
        XCTAssertNotNil(me.colorGreen)
        XCTAssertNotNil(me.desc)
        XCTAssertNotNil(me.iconName)
        XCTAssertNotNil(me.id)
        XCTAssertNotNil(me.lat)
        XCTAssertNotNil(me.lon)
        XCTAssertNotNil(me.timestamp)
        XCTAssertNotNil(me.title)
        XCTAssertNotNil(me.uuid)
        MarkerEntity.deleteMarkerEntity(me) // remove the test marker from the database
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
