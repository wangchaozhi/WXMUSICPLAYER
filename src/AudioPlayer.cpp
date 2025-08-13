#include "AudioPlayer.h"
#include <wx/filename.h>
#include <wx/datetime.h>

AudioPlayer::AudioPlayer()
    : m_sound(nullptr)
    , m_isPlaying(false)
    , m_isPaused(false)
    , m_volume(1.0)
    , m_duration(0.0)
    , m_currentPosition(0.0)
{
}

AudioPlayer::~AudioPlayer()
{
    if (m_sound)
    {
        m_sound->Stop();
        delete m_sound;
    }
}

bool AudioPlayer::LoadFile(const wxString& filename)
{
    // 停止当前播放
    if (m_sound)
    {
        m_sound->Stop();
        delete m_sound;
        m_sound = nullptr;
    }

    // 创建新的声音对象
    m_sound = new wxSound();
    if (!m_sound->Create(filename, true))
    {
        delete m_sound;
        m_sound = nullptr;
        return false;
    }

    m_currentFile = filename;
    m_isPlaying = false;
    m_isPaused = false;
    m_currentPosition = 0.0;
    
    // 估算持续时间（wxSound不提供精确的持续时间）
    // 这里使用一个简单的估算方法
    wxFileName fn(filename);
    if (fn.GetSize() > 0)
    {
        // 假设平均比特率为128kbps
        m_duration = (fn.GetSize().ToDouble() * 8) / (128 * 1024);
    }
    else
    {
        m_duration = 0.0;
    }

    return true;
}

bool AudioPlayer::Play()
{
    if (!m_sound || !IsFileLoaded())
        return false;

    if (m_isPaused)
    {
        // 从暂停状态恢复播放
        m_isPaused = false;
        m_startTime = wxDateTime::Now();
        return true;
    }

    if (m_sound->Play(wxSOUND_ASYNC))
    {
        m_isPlaying = true;
        m_isPaused = false;
        m_startTime = wxDateTime::Now();
        return true;
    }

    return false;
}

bool AudioPlayer::Pause()
{
    if (!m_sound || !m_isPlaying)
        return false;

    m_sound->Stop();
    m_isPlaying = false;
    m_isPaused = true;
    UpdatePosition();
    return true;
}

bool AudioPlayer::Stop()
{
    if (!m_sound)
        return false;

    m_sound->Stop();
    m_isPlaying = false;
    m_isPaused = false;
    m_currentPosition = 0.0;
    return true;
}

bool AudioPlayer::IsPlaying() const
{
    return m_isPlaying && !m_isPaused;
}

bool AudioPlayer::IsPaused() const
{
    return m_isPaused;
}

wxString AudioPlayer::GetCurrentFile() const
{
    return m_currentFile;
}

double AudioPlayer::GetDuration() const
{
    return m_duration;
}

double AudioPlayer::GetCurrentPosition() const
{
    if (m_isPlaying)
    {
        UpdatePosition();
    }
    return m_currentPosition;
}

void AudioPlayer::SetPosition(double position)
{
    if (position < 0.0)
        position = 0.0;
    if (position > m_duration)
        position = m_duration;

    m_currentPosition = position;
    
    // 注意：wxSound不支持精确的定位，这里只是更新内部状态
    if (m_isPlaying)
    {
        m_startTime = wxDateTime::Now().Subtract(wxTimeSpan::Seconds((long)position));
    }
}

void AudioPlayer::SetVolume(double volume)
{
    if (volume < 0.0)
        volume = 0.0;
    if (volume > 1.0)
        volume = 1.0;

    m_volume = volume;
    
    // 注意：wxSound不直接支持音量控制
    // 在实际应用中，可能需要使用其他音频库如OpenAL或FMOD
}

double AudioPlayer::GetVolume() const
{
    return m_volume;
}

bool AudioPlayer::IsFileLoaded() const
{
    return m_sound != nullptr;
}

void AudioPlayer::UpdatePosition()
{
    if (m_isPlaying && m_startTime.IsValid())
    {
        wxTimeSpan elapsed = wxDateTime::Now() - m_startTime;
        m_currentPosition = elapsed.GetSeconds().ToDouble();
        
        // 检查是否播放完毕
        if (m_currentPosition >= m_duration)
        {
            m_isPlaying = false;
            m_currentPosition = 0.0;
        }
    }
}
