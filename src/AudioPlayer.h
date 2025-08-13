#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <wx/wx.h>
#include <wx/sound.h>
#include <string>

class AudioPlayer
{
public:
    AudioPlayer();
    ~AudioPlayer();

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
    void SetPosition(double position);
    void SetVolume(double volume);
    double GetVolume() const;

    // 状态
    bool IsFileLoaded() const;

private:
    wxSound* m_sound;
    wxString m_currentFile;
    bool m_isPlaying;
    bool m_isPaused;
    double m_volume;
    double m_duration;
    double m_currentPosition;
    wxDateTime m_startTime;

    void UpdatePosition();
};

#endif // AUDIOPLAYER_H
