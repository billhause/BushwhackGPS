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
        
        // When the title is nil, the wrappedTitle should come back as "Unnamed"
        // The map pop-up bubbles will not work if the wrappedTitle is an empty string ""
        me.title = nil
        XCTAssertEqual(me.wrappedTitle, "Unnamed")
        me.title = ""
        XCTAssertEqual(me.wrappedTitle, "Unnamed")

        
        MarkerEntity.deleteMarkerEntity(me) // remove the test marker from the database
    }
    
    
    //
    // MARK: TripEntity
    //
    func testTripEntity() throws {
        let te = TripEntity.createTripEntity(dotSize: 6.0)
        // Make sure none of the fields are nil except start and end date which MUST be nil
        XCTAssertNotNil(te.uuid)
        XCTAssertNotNil(te.title)
        XCTAssertNotNil(te.desc)
        XCTAssertNotNil(te.dotColorRed)
        XCTAssertNotNil(te.dotColorBlue)
        XCTAssertNotNil(te.dotColorGreen)
        XCTAssertNotNil(te.dotColorAlpha)
        XCTAssertNotNil(te.dotSize)
        XCTAssertNotNil(te.id)
        XCTAssertNotNil(te.startTime) // must be nil
        XCTAssertNil(te.endTime)   // must be nil
        TripEntity.deleteTripEntity(te) // Remove the test TripEntity from the db
    }

    //
    // MARK: DashboardEntity
    //
    func testDashboardEntity() throws {
        var de = DashboardEntity.getDashboardEntity()
        DashboardEntity.deleteDashboardEntity(de) // Delete any old DashboardEntity that was there
        de = DashboardEntity.getDashboardEntity() // Get new DashboardEntity
        XCTAssertTrue(de.prevLon == 181.0) // Shold start at 181 to indicate it's not valid yet
        XCTAssertTrue(de.prevLat == 181.0) // Shold start at 181 to indicate it's not valid yet
        DashboardEntity.deleteDashboardEntity(de) // Delete the DashboardEntity we just created
    }

    //
    // MARK: Map_ViewModel
    //
    func testMap_ViewModel() throws {
        
        // Test getDistanceInMeters
        let mapViewModel = Map_ViewModel()
        let distance = mapViewModel.getDistanceInMeters(lat1: 181, lon1: 181, lat2: 0, lon2: 0)
        XCTAssertTrue(distance == 0.0) // Invalid input like 181 should get 0 distance returned from getDistanceInMeters
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
