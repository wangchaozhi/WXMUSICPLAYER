#ifndef ADVANCEDAUDIOPLAYER_H
#define ADVANCEDAUDIOPLAYER_H

#include <wx/wx.h>
#include <wx/thread.h>
#include <string>
#include <vector>
#include <memory>

// 前向声明
struct AudioFile;
class AudioDecoder;

class AdvancedAudioPlayer : public wxThread
{
public:
    AdvancedAudioPlayer();
    ~AdvancedAudioPlayer();

    // 播放控制
    bool LoadFile(const wxString& filename);
    bool Play();
    bool Pause();
    bool Stop();
    bool IsPlaying() const;
    bool IsPaused() const;

    // 播放信息
    wxString GetCurrentFile() const;
    double GetDuration() const;
    double GetCurrentPosition() const;
    bool SetPosition(double position);
    void SetVolume(double volume);
    double GetVolume() const;

    // 状态
    bool IsFileLoaded() const;
    wxString GetError() const;

    // 播放列表控制
    void SetPlaylist(const std::vector<wxString>& playlist);
    void SetCurrentTrack(int track);
    int GetCurrentTrack() const;
    void SetLoopMode(bool loop);
    bool GetLoopMode() const;

protected:
    virtual wxThread::ExitCode Entry() override;

private:
    // 音频数据
    std::unique_ptr<AudioFile> m_audioFile;
    std::unique_ptr<AudioDecoder> m_decoder;
    wxString m_currentFile;
    
    // 播放状态
    bool m_isPlaying;
    bool m_isPaused;
    bool m_shouldStop;
    double m_volume;
    double m_duration;
    double m_currentPosition;
    wxDateTime m_startTime;
    
    // 播放列表
    std::vector<wxString> m_playlist;
    int m_currentTrack;
    bool m_loopMode;
    
    // 错误信息
    wxString m_errorMessage;
    
    // 线程同步
    wxMutex m_mutex;
    wxCondition m_condition;
    
    // 辅助函数
    void UpdatePosition();
    bool LoadNextTrack();
    void SetError(const wxString& error);
    void ClearError();
    
    // 音频处理
    bool InitializeAudio();
    void CleanupAudio();
    bool ProcessAudioData();
};

// 音频文件信息结构
struct AudioFile
{
    wxString filename;
    std::vector<uint8_t> data;
    int sampleRate;
    int channels;
    int bitsPerSample;
    double duration;
    
    AudioFile() : sampleRate(0), channels(0), bitsPerSample(0), duration(0.0) {}
};

// 音频解码器基类
class AudioDecoder
{
public:
    virtual ~AudioDecoder() = default;
    virtual bool LoadFile(const wxString& filename, AudioFile& audioFile) = 0;
    virtual bool DecodeFrame(std::vector<uint8_t>& buffer) = 0;
    virtual void Reset() = 0;
    virtual bool IsEndOfFile() const = 0;
};

#endif // ADVANCEDAUDIOPLAYER_H
