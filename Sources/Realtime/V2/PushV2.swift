//
//  PushV2.swift
//
//
//  Created by Guilherme Souza on 02/01/24.
//

import _Helpers
import Foundation

actor PushV2 {
  private weak var channel: RealtimeChannelV2?
  let message: RealtimeMessageV2

  private var receivedContinuation: CheckedContinuation<PushStatus, Never>?

  init(channel: RealtimeChannelV2?, message: RealtimeMessageV2) {
    self.channel = channel
    self.message = message
  }

  func send() async -> PushStatus {
    await channel?.socket?.push(message)

    if channel?.config.broadcast.acknowledgeBroadcasts == true {
      do {
        return try await withTimeout(interval: channel?.socket?.config.timeoutInterval ?? 10) {
          await withCheckedContinuation {
            self.receivedContinuation = $0
          }
        }
      } catch is TimeoutError {
        return .timeout
      } catch {
        channel?.logger?.error("error sending Push: \(error)")
        return .error
      }
    }

    return .ok
  }

  func didReceive(status: PushStatus) {
    receivedContinuation?.resume(returning: status)
    receivedContinuation = nil
  }
}
