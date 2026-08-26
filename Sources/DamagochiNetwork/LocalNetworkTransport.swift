import Foundation
import MultipeerConnectivity
import DamagochiCore

// MARK: - Local Network Transport (Phase 1)

/// MultipeerConnectivity 기반 로컬 네트워크 배틀 통신
public final class LocalNetworkTransport: NSObject, BattleTransport, @unchecked Sendable {

    private static let serviceType = "damagochi-btl"
    private static let displayNameKey = "displayName"

    private let myPeerId: MCPeerID
    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    private var continuation: AsyncStream<BattleTransportEvent>.Continuation?
    private let lock = NSLock()
    private var _connectedPeerId: MCPeerID?
    private var _displayName: String
    private var _isBrowsing = false
    private var connectedPeerId: MCPeerID? {
        get { lock.withLock { _connectedPeerId } }
        set { lock.withLock { _connectedPeerId = newValue } }
    }

    public let events: AsyncStream<BattleTransportEvent>

    public init(peerId: String, displayName: String) {
        self.myPeerId = MCPeerID(displayName: peerId)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self._displayName = displayName
        self.advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: [Self.displayNameKey: displayName],
            serviceType: Self.serviceType
        )
        self.browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: Self.serviceType)

        var cont: AsyncStream<BattleTransportEvent>.Continuation?
        self.events = AsyncStream { cont = $0 }
        self.continuation = cont

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    public convenience init(displayName: String) {
        self.init(peerId: displayName, displayName: displayName)
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
        continuation?.finish()
    }

    // MARK: - BattleTransport

    public func startBrowsing() {
        lock.withLock { _isBrowsing = true }
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    public func stopBrowsing() {
        lock.withLock { _isBrowsing = false }
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }

    public func updateDisplayName(_ displayName: String) {
        let shouldRestart = lock.withLock { () -> Bool? in
            guard _displayName != displayName else { return nil }
            _displayName = displayName
            return _isBrowsing
        }
        guard let shouldRestart else { return }

        advertiser.stopAdvertisingPeer()
        let updatedAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: [Self.displayNameKey: displayName],
            serviceType: Self.serviceType
        )
        updatedAdvertiser.delegate = self
        advertiser = updatedAdvertiser
        if shouldRestart {
            updatedAdvertiser.startAdvertisingPeer()
        }
    }

    public func invite(_ peerId: String) throws {
        guard let peer = session.connectedPeers.first(where: { $0.displayName == peerId })
                      ?? findDiscoveredPeer(named: peerId)
        else { throw TransportError.peerNotFound }
        browser.invitePeer(peer, to: session, withContext: nil, timeout: BattleTimeout.connectionSeconds)
    }

    public func connect(to peerId: String) async throws {
        try invite(peerId)
    }

    public func disconnect() {
        session.disconnect()
        lock.withLock { _connectedPeerId = nil }
    }

    public func send(_ message: BattleMessage) throws {
        guard let peer = lock.withLock({ _connectedPeerId }) else { throw TransportError.notConnected }
        let data = try JSONEncoder().encode(message)
        try session.send(data, toPeers: [peer], with: .reliable)
    }

    // MARK: - Private

    private var _discoveredPeers: [MCPeerID] = []
    private var discoveredPeers: [MCPeerID] {
        get { lock.withLock { _discoveredPeers } }
        set { lock.withLock { _discoveredPeers = newValue } }
    }

    private func findDiscoveredPeer(named name: String) -> MCPeerID? {
        lock.withLock { _discoveredPeers.first { $0.displayName == name } }
    }

    private func emit(_ event: BattleTransportEvent) {
        continuation?.yield(event)
    }
}

// MARK: - MCSessionDelegate

extension LocalNetworkTransport: MCSessionDelegate {

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            lock.withLock { _connectedPeerId = peerID }
            emit(.connected(peerId: peerID.displayName))
        case .notConnected:
            lock.withLock { if _connectedPeerId == peerID { _connectedPeerId = nil } }
            emit(.disconnected(peerId: peerID.displayName))
        default:
            break
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(BattleMessage.self, from: data) else { return }
        emit(.messageReceived(message))
    }

    public func session(_ session: MCSession, didReceive stream: InputStream,
                        withName streamName: String, fromPeer peerID: MCPeerID) {}
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID, with progress: Progress) {}
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension LocalNetworkTransport: MCNearbyServiceAdvertiserDelegate {

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                           didReceiveInvitationFromPeer peerID: MCPeerID,
                           withContext context: Data?,
                           invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 자동 수락 (UI에서 거절하려면 delegate 패턴 추가 가능)
        invitationHandler(true, session)
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        emit(.error(error))
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension LocalNetworkTransport: MCNearbyServiceBrowserDelegate {

    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                        withDiscoveryInfo info: [String: String]?) {
        lock.withLock {
            if !_discoveredPeers.contains(where: { $0 == peerID }) {
                _discoveredPeers.append(peerID)
            }
        }
        let displayName = info?[Self.displayNameKey] ?? peerID.displayName
        emit(.peerFound(peerId: peerID.displayName, peerName: displayName))
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        lock.withLock { _discoveredPeers.removeAll { $0 == peerID } }
        emit(.peerLost(peerId: peerID.displayName))
    }

    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        emit(.error(error))
    }
}

// MARK: - Errors

public enum TransportError: LocalizedError {
    case peerNotFound
    case notConnected

    public var errorDescription: String? {
        switch self {
        case .peerNotFound:  return "상대방을 찾을 수 없습니다"
        case .notConnected:  return "연결되지 않은 상태입니다"
        }
    }
}
