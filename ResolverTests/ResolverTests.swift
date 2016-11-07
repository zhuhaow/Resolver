import Quick
import Nimble
@testable import Resolver
import dnssd

class ResolverSpec: QuickSpec {
    override func spec() {
        describe("The resolve method") {
            context("If it is asked to resolve IPv4 address") {
                it("gives one IP") {
                    var result: Resolver?
                    var errorCode: DNSServiceErrorType?
                    waitUntil(timeout: 6) { done in
                        expect(Resolver.resolve(hostname: "yahoo.com") { res, error in
                            result = res
                            errorCode = error
                            done()
                        }) == true
                    }
                    expect(result?.result.count) == 1
                    expect(result?.ipv4Result.count) == 1
                    expect(errorCode).to(beNil())
                }
                
                it("gives all IPs") {
                    var result: Resolver?
                    var errorCode: DNSServiceErrorType?
                    waitUntil(timeout: 6) { done in
                        expect(Resolver.resolve(hostname: "yahoo.com", firstResult: false) { res, error in
                            result = res
                            errorCode = error
                            done()
                        }) == true
                    }
                    expect(result?.result.count) > 1
                    expect(result?.ipv4Result.count) > 1
                    expect(errorCode).to(beNil())
                }
            }
            
            context("If it is asked to resolve IPv6 address") {
                it("gives one IP") {
                    var result: Resolver?
                    var errorCode: DNSServiceErrorType?
                    waitUntil(timeout: 6) { done in
                        expect(Resolver.resolve(hostname: "yahoo.com", qtype: .ipv6) { res, error in
                            result = res
                            errorCode = error
                            done()
                        }) == true
                    }
                    expect(result?.result.count) == 1
                    expect(result?.ipv6Result.count) == 1
                    expect(errorCode).to(beNil())
                }
                
                it("gives all IPs") {
                    var result: Resolver?
                    var errorCode: DNSServiceErrorType?
                    waitUntil(timeout: 6) { done in
                        expect(Resolver.resolve(hostname: "yahoo.com", qtype: .ipv6, firstResult: false) { res, error in
                            result = res
                            errorCode = error
                            done()
                        }) == true
                    }
                    expect(result?.result.count) > 1
                    expect(result?.ipv6Result.count) > 1
                    expect(errorCode).to(beNil())
                }
            }
            
            context("When it is given an invalid domain") {
                it("gives error") {
                    var result: Resolver?
                    var errorCode: DNSServiceErrorType?
                    waitUntil(timeout: 6) { done in
                        expect(Resolver.resolve(hostname: "0.yahoo.com") { res, error in
                            result = res
                            errorCode = error
                            done()
                        }) == true
                    }
                    expect(result).to(beNil())
                    expect(errorCode).toNot(beNil())
                }
            }
            
            it("resolves queries asynchronously") {
                var count = 100
                waitUntil(timeout: 8) { done in
                    let semaphore = DispatchSemaphore(value: 1)
                    for i in 0..<count {
                        expect(Resolver.resolve(hostname: "\(i).yahoo.com") { res, error in
                            semaphore.wait()
                            count -= 1
                            if (count == 0) {
                                done()
                            }
                            semaphore.signal()
                        }) == true
                    }
                }
            }
        }
    }
}
