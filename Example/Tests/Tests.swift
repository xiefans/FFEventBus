import XCTest
import FFEventBus

class Tests: XCTestCase {
    
    var bus: FFEventBus!
    
    override func setUp() {
        super.setUp()
        bus  = FFEventBus(name: "test")
    }
    
    func testExcuteOrder() {
        var string = ""
        bus.begin { then, end, params in
            string += "a"
            then(params)
        }
        
        bus.then { then, end, params in
            string += "b"
            then(params)
        }
        
        bus.then { then, end, params in
            string += "c"
            then(params)
        }
        
        bus.end { params in
            XCTAssert(string == "abc", "excute order is error")
        }
    }
    
    func testExcuteSkipOrder() {
        var string = ""
        bus.begin { then, end, params in
            string += "a"
            then(params)
        }
        
        bus.then { then, end, params in
            string += "b"
            end(params)
        }
        
        bus.then { then, end, params in
            string += "c"
            then(params)
        }
        
        bus.end { params in
            XCTAssert(string == "ab", "excute order is error")
        }
    }
    
}
