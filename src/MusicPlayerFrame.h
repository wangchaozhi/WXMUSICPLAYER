#ifndef MUSICPLAYERFRAME_H
#define MUSICPLAYERFRAME_H

#include <wx/wx.h>
#include <wx/listbox.h>
#include <wx/slider.h>
#include <wx/button.h>
#include <wx/panel.h>
#include <wx/stattext.h>
#include <wx/timer.h>
#include <vector>
#include <string>

class AudioPlayer;

class MusicPlayerFrame : public wxFrame
{
public:
    MusicPlayerFrame(const wxString& title, const wxPoint& pos, const wxSize& size);
    ~MusicPlayerFrame();

private:
    // UI组件
    wxPanel* m_mainPanel;
    wxListBox* m_playlistBox;
    wxSlider* m_progressSlider;
    wxSlider* m_volumeSlider;
    wxButton* m_playButton;
    wxButton* m_pauseButton;
    wxButton* m_stopButton;
    wxButton* m_prevButton;
    wxButton* m_nextButton;
    wxButton* m_addButton;
    wxButton* m_removeButton;
    wxStaticText* m_timeLabel;
    wxStaticText* m_titleLabel;
    wxTimer* m_updateTimer;

    // 音频播放器
    AudioPlayer* m_audioPlayer;
    
    // 播放列表
    std::vector<wxString> m_playlist;
    int m_currentTrack;

    // 事件处理函数
    void OnPlay(wxCommandEvent& event);
    void OnPause(wxCommandEvent& event);
    void OnStop(wxCommandEvent& event);
    void OnPrev(wxCommandEvent& event);
    void OnNext(wxCommandEvent& event);
    void OnAdd(wxCommandEvent& event);
    void OnRemove(wxCommandEvent& event);
    void OnPlaylistSelect(wxCommandEvent& event);
    void OnProgressSlider(wxScrollEvent& event);
    void OnVolumeSlider(wxScrollEvent& event);
    void OnTimer(wxTimerEvent& event);
    void OnClose(wxCloseEvent& event);

    // 辅助函数
    void CreateControls();
    void LayoutControls();
    void BindEvents();
    void UpdateTimeDisplay();
    void UpdateTitleDisplay();
    void LoadTrack(int index);
    void UpdatePlaylistDisplay();

};

#endif // MUSICPLAYERFRAME_H
