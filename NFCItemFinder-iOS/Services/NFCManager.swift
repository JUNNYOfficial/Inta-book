import Foundation
import CoreNFC
import Combine

enum NFCResult: Equatable {
    case payload(NFCTagPayload)
    case raw(text: String)
    case error(String)
    case cancelled
}

final class NFCManager: NSObject, ObservableObject {
    @Published var lastResult: NFCResult?
    @Published var lastTagID: String?
    @Published var isScanning = false
    @Published var statusMessage = "准备扫描"

    private var readerSession: NFCTagReaderSession?
    private var pendingWriteItem: Item?
    private var isWriting = false

    func startReading() {
        guard NFCTagReaderSession.readingAvailable else {
            lastResult = .error("当前设备不支持 NFC 标签读取")
            return
        }
        isWriting = false
        pendingWriteItem = nil
        lastTagID = nil
        statusMessage = "请将手机靠近 NFC 标签"
        readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        readerSession?.alertMessage = "将手机靠近物品上的 NFC 标签"
        readerSession?.begin()
        isScanning = true
    }

    func startWriting(item: Item) {
        guard NFCTagReaderSession.readingAvailable else {
            lastResult = .error("当前设备不支持 NFC 标签写入")
            return
        }
        isWriting = true
        pendingWriteItem = item
        lastTagID = nil
        statusMessage = "请将手机靠近要写入的 NFC 标签"
        readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        readerSession?.alertMessage = "将手机靠近空白 NFC 标签以写入信息"
        readerSession?.begin()
        isScanning = true
    }

    func reset() {
        lastResult = nil
        lastTagID = nil
        statusMessage = "准备扫描"
    }
}

extension NFCManager: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            if let readerError = error as? NFCReaderError, readerError.code == .readerSessionInvalidationErrorUserCanceled {
                self.lastResult = .cancelled
                self.statusMessage = "已取消扫描"
            } else {
                self.lastResult = .error(error.localizedDescription)
                self.statusMessage = "扫描失败: \(error.localizedDescription)"
            }
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "连接标签失败: \(error.localizedDescription)")
                return
            }

            if self.isWriting, let item = self.pendingWriteItem {
                self.writeNDEF(tag: tag, item: item, session: session)
            } else {
                self.readNDEF(tag: tag, session: session)
            }
        }
    }

    private func readNDEF(tag: NFCTag, session: NFCTagReaderSession) {
        guard case .miFare(let mifareTag) = tag else {
            session.invalidate(errorMessage: "仅支持 ISO14443 类型标签（如 NTAG213/215/216）")
            return
        }

        let tagID = mifareTag.identifier.hexString

        mifareTag.readNDEF { message, error in
            DispatchQueue.main.async {
                self.isScanning = false
                self.lastTagID = tagID
                if let error = error {
                    self.lastResult = .error("读取失败: \(error.localizedDescription)")
                    session.invalidate(errorMessage: "读取失败")
                    return
                }

                guard let message = message, !message.records.isEmpty else {
                    self.lastResult = .error("标签为空或未写入 NDEF 数据")
                    session.invalidate(errorMessage: "标签为空")
                    return
                }

                for record in message.records {
                    if let payload = NFCTagPayload.from(jsonData: record.payload) {
                        self.lastResult = .payload(payload)
                        session.alertMessage = "读取成功: \(payload.name)"
                        session.invalidate()
                        return
                    }
                    if let payloadData = record.payload.nonEmptyData,
                       let payload = NFCTagPayload.from(jsonData: payloadData) {
                        self.lastResult = .payload(payload)
                        session.alertMessage = "读取成功: \(payload.name)"
                        session.invalidate()
                        return
                    }
                }

                if let first = message.records.first, let text = String(data: first.payload, encoding: .utf8) {
                    self.lastResult = .raw(text: text)
                    session.alertMessage = "读取到文本"
                } else {
                    self.lastResult = .error("无法解析标签内容")
                    session.invalidate(errorMessage: "解析失败")
                    return
                }
                session.invalidate()
            }
        }
    }

    private func writeNDEF(tag: NFCTag, item: Item, session: NFCTagReaderSession) {
        guard case .miFare(let mifareTag) = tag else {
            session.invalidate(errorMessage: "仅支持 ISO14443 类型标签")
            return
        }

        let tagID = mifareTag.identifier.hexString

        guard let payload = NFCTagPayload(item: item).toJSON() else {
            session.invalidate(errorMessage: "生成标签数据失败")
            return
        }

        let typeNameFormat = NFCTypeNameFormat.media
        let type = Data("application/json".utf8)
        let identifier = Data()
        let record = NFCNDEFPayload(format: typeNameFormat, type: type, identifier: identifier, payload: payload)
        let message = NFCNDEFMessage(records: [record])

        mifareTag.writeNDEF(message) { error in
            DispatchQueue.main.async {
                self.isScanning = false
                self.lastTagID = tagID
                if let error = error {
                    self.lastResult = .error("写入失败: \(error.localizedDescription)")
                    session.invalidate(errorMessage: "写入失败")
                    return
                }
                self.lastResult = .payload(NFCTagPayload(item: item))
                session.alertMessage = "已成功写入: \(item.name)"
                session.invalidate()
            }
        }
    }
}

private extension Data {
    var nonEmptyData: Data? {
        if self.isEmpty { return nil }
        if self.count > 1 {
            return self.advanced(by: 1)
        }
        return self
    }

    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
