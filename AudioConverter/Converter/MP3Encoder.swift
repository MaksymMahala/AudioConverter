//
//  MP3Converter.swift
//  AudioConverter
//
//  Created by Max on 01.07.2025.
//

import Foundation
import lame

class MP3Encoder {
    static func convertPCMtoMP3(pcmURL: URL, mp3URL: URL) -> Bool {
        guard let pcmFile = fopen(pcmURL.path, "rb") else {
            print("Unable to open PCM file")
            return false
        }
        fseek(pcmFile, 44, SEEK_SET)

        guard let mp3File = fopen(mp3URL.path, "wb") else {
            print("Unable to create MP3 file")
            fclose(pcmFile)
            return false
        }

        let lame = lame_init()
        lame_set_in_samplerate(lame, 44100)
        lame_set_VBR(lame, vbr_default)
        lame_init_params(lame)

        let PCM_SIZE = 8192
        let MP3_SIZE = 8192
        let pcmBuffer = UnsafeMutablePointer<Int16>.allocate(capacity: PCM_SIZE * 2)
        let mp3Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MP3_SIZE)

        var read: Int32 = 0
        var write: Int32 = 0

        repeat {
            read = Int32(fread(pcmBuffer, MemoryLayout<Int16>.size, PCM_SIZE * 2, pcmFile) / 2)
            if read == 0 {
                write = lame_encode_flush(lame, mp3Buffer, Int32(MP3_SIZE))
            } else {
                write = lame_encode_buffer_interleaved(lame, pcmBuffer, read, mp3Buffer, Int32(MP3_SIZE))
            }
            fwrite(mp3Buffer, 1, Int(write), mp3File)
        } while read != 0

        lame_close(lame)
        fclose(mp3File)
        fclose(pcmFile)
        pcmBuffer.deallocate()
        mp3Buffer.deallocate()

        return true
    }
}
