#include "MusicPlayerFrame.h"
#include "AudioPlayer.h"
#include <wx/filedlg.h>
#include <wx/filename.h>
#include <wx/msgdlg.h>
#include <wx/sizer.h>
#include <wx/statbox.h>

MusicPlayerFrame::MusicPlayerFrame(const wxString& title, const wxPoint& pos, const wxSize& size)
    : wxFrame(nullptr, wxID_ANY, title, pos, size)
    , m_currentTrack(-1)
{
    // 创建音频播放器
    m_audioPlayer = new AudioPlayer();
    
    // 创建UI
    CreateControls();
    LayoutControls();
    
    // 绑定事件
    BindEvents();
    
    // 创建定时器用于更新进度
    m_updateTimer = new wxTimer(this);
    m_updateTimer->Start(100); // 每100ms更新一次
    
    // 设置窗口图标和样式
    SetBackgroundColour(wxColour(240, 240, 240));
    Centre();
}

MusicPlayerFrame::~MusicPlayerFrame()
{
    if (m_updateTimer)
    {
        m_updateTimer->Stop();
        delete m_updateTimer;
    }
    
    if (m_audioPlayer)
    {
        delete m_audioPlayer;
    }
}

void MusicPlayerFrame::CreateControls()
{
    m_mainPanel = new wxPanel(this);
    
    // 创建播放列表
    m_playlistBox = new wxListBox(m_mainPanel, wxID_ANY, wxDefaultPosition, wxDefaultSize);
    
    // 创建控制按钮
    m_playButton = new wxButton(m_mainPanel, wxID_ANY, "播放");
    m_pauseButton = new wxButton(m_mainPanel, wxID_ANY, "暂停");
    m_stopButton = new wxButton(m_mainPanel, wxID_ANY, "停止");
    m_prevButton = new wxButton(m_mainPanel, wxID_ANY, "上一首");
    m_nextButton = new wxButton(m_mainPanel, wxID_ANY, "下一首");
    m_addButton = new wxButton(m_mainPanel, wxID_ANY, "添加");
    m_removeButton = new wxButton(m_mainPanel, wxID_ANY, "删除");
    
    // 创建进度条和音量控制
    m_progressSlider = new wxSlider(m_mainPanel, wxID_ANY, 0, 0, 100, 
        wxDefaultPosition, wxDefaultSize, wxSL_HORIZONTAL | wxSL_LABELS);
    m_volumeSlider = new wxSlider(m_mainPanel, wxID_ANY, 100, 0, 100, 
        wxDefaultPosition, wxDefaultSize, wxSL_VERTICAL | wxSL_LABELS);
    
    // 创建标签
    m_timeLabel = new wxStaticText(m_mainPanel, wxID_ANY, "00:00 / 00:00");
    m_titleLabel = new wxStaticText(m_mainPanel, wxID_ANY, "未选择文件");
    
    // 设置字体
    wxFont titleFont = m_titleLabel->GetFont();
    titleFont.SetPointSize(12);
    titleFont.SetWeight(wxFONTWEIGHT_BOLD);
    m_titleLabel->SetFont(titleFont);
}

void MusicPlayerFrame::LayoutControls()
{
    wxBoxSizer* mainSizer = new wxBoxSizer(wxHORIZONTAL);
    
    // 左侧播放列表区域
    wxStaticBoxSizer* playlistSizer = new wxStaticBoxSizer(wxVERTICAL, m_mainPanel, "播放列表");
    playlistSizer->Add(m_playlistBox, 1, wxEXPAND | wxALL, 5);
    
    wxBoxSizer* playlistButtonSizer = new wxBoxSizer(wxHORIZONTAL);
    playlistButtonSizer->Add(m_addButton, 1, wxEXPAND | wxRIGHT, 5);
    playlistButtonSizer->Add(m_removeButton, 1, wxEXPAND);
    playlistSizer->Add(playlistButtonSizer, 0, wxEXPAND | wxALL, 5);
    
    // 右侧控制区域
    wxBoxSizer* rightSizer = new wxBoxSizer(wxVERTICAL);
    
    // 标题和时间显示
    wxBoxSizer* infoSizer = new wxBoxSizer(wxVERTICAL);
    infoSizer->Add(m_titleLabel, 0, wxALIGN_CENTER | wxALL, 10);
    infoSizer->Add(m_timeLabel, 0, wxALIGN_CENTER | wxALL, 5);
    rightSizer->Add(infoSizer, 0, wxEXPAND | wxALL, 10);
    
    // 进度条
    wxStaticBoxSizer* progressSizer = new wxStaticBoxSizer(wxVERTICAL, m_mainPanel, "播放进度");
    progressSizer->Add(m_progressSlider, 0, wxEXPAND | wxALL, 5);
    rightSizer->Add(progressSizer, 0, wxEXPAND | wxALL, 10);
    
    // 播放控制按钮
    wxStaticBoxSizer* controlSizer = new wxStaticBoxSizer(wxVERTICAL, m_mainPanel, "播放控制");
    
    wxBoxSizer* controlButtonSizer = new wxBoxSizer(wxHORIZONTAL);
    controlButtonSizer->Add(m_prevButton, 1, wxEXPAND | wxRIGHT, 5);
    controlButtonSizer->Add(m_playButton, 1, wxEXPAND | wxRIGHT, 5);
    controlButtonSizer->Add(m_pauseButton, 1, wxEXPAND | wxRIGHT, 5);
    controlButtonSizer->Add(m_stopButton, 1, wxEXPAND | wxRIGHT, 5);
    controlButtonSizer->Add(m_nextButton, 1, wxEXPAND);
    
    controlSizer->Add(controlButtonSizer, 0, wxEXPAND | wxALL, 5);
    rightSizer->Add(controlSizer, 0, wxEXPAND | wxALL, 10);
    
    // 音量控制
    wxStaticBoxSizer* volumeSizer = new wxStaticBoxSizer(wxHORIZONTAL, m_mainPanel, "音量");
    volumeSizer->Add(m_volumeSlider, 0, wxEXPAND | wxALL, 5);
    rightSizer->Add(volumeSizer, 0, wxEXPAND | wxALL, 10);
    
    // 组合左右两侧
    mainSizer->Add(playlistSizer, 1, wxEXPAND | wxALL, 10);
    mainSizer->Add(rightSizer, 1, wxEXPAND | wxALL, 10);
    
    m_mainPanel->SetSizer(mainSizer);
    
    // 设置最小窗口大小
    SetMinSize(wxSize(600, 400));
}

void MusicPlayerFrame::BindEvents()
{
    // 绑定按钮事件
    m_playButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnPlay, this);
    m_pauseButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnPause, this);
    m_stopButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnStop, this);
    m_prevButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnPrev, this);
    m_nextButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnNext, this);
    m_addButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnAdd, this);
    m_removeButton->Bind(wxEVT_BUTTON, &MusicPlayerFrame::OnRemove, this);
    
    // 绑定列表事件
    m_playlistBox->Bind(wxEVT_LISTBOX, &MusicPlayerFrame::OnPlaylistSelect, this);
    
    // 绑定滑块事件
    m_progressSlider->Bind(wxEVT_SLIDER, &MusicPlayerFrame::OnProgressSlider, this);
    m_volumeSlider->Bind(wxEVT_SLIDER, &MusicPlayerFrame::OnVolumeSlider, this);
    
    // 绑定定时器事件
    m_updateTimer->Bind(wxEVT_TIMER, &MusicPlayerFrame::OnTimer, this);
    
    // 绑定窗口关闭事件
    Bind(wxEVT_CLOSE_WINDOW, &MusicPlayerFrame::OnClose, this);
}

void MusicPlayerFrame::OnPlay(wxCommandEvent& event)
{
    if (m_playlist.empty())
    {
        wxMessageBox("播放列表为空，请先添加音乐文件", "提示", wxOK | wxICON_INFORMATION);
        return;
    }
    
    if (m_currentTrack < 0)
    {
        m_currentTrack = 0;
        LoadTrack(m_currentTrack);
    }
    
    if (m_audioPlayer->Play())
    {
        m_playButton->Enable(false);
        m_pauseButton->Enable(true);
        UpdateTitleDisplay();
    }
}

void MusicPlayerFrame::OnPause(wxCommandEvent& event)
{
    if (m_audioPlayer->Pause())
    {
        m_playButton->Enable(true);
        m_pauseButton->Enable(false);
    }
}

void MusicPlayerFrame::OnStop(wxCommandEvent& event)
{
    if (m_audioPlayer->Stop())
    {
        m_playButton->Enable(true);
        m_pauseButton->Enable(false);
        m_progressSlider->SetValue(0);
        UpdateTimeDisplay();
    }
}

void MusicPlayerFrame::OnPrev(wxCommandEvent& event)
{
    if (m_playlist.empty())
        return;
    
    if (m_currentTrack > 0)
    {
        m_currentTrack--;
    }
    else
    {
        m_currentTrack = m_playlist.size() - 1;
    }
    
    LoadTrack(m_currentTrack);
    if (m_audioPlayer->IsPlaying())
    {
        m_audioPlayer->Play();
    }
}

void MusicPlayerFrame::OnNext(wxCommandEvent& event)
{
    if (m_playlist.empty())
        return;
    
    if (m_currentTrack < (int)m_playlist.size() - 1)
    {
        m_currentTrack++;
    }
    else
    {
        m_currentTrack = 0;
    }
    
    LoadTrack(m_currentTrack);
    if (m_audioPlayer->IsPlaying())
    {
        m_audioPlayer->Play();
    }
}

void MusicPlayerFrame::OnAdd(wxCommandEvent& event)
{
    wxFileDialog dialog(this, "选择音乐文件", "", "",
        "音频文件 (*.mp3;*.wav;*.flac;*.ogg)|*.mp3;*.wav;*.flac;*.ogg|所有文件 (*.*)|*.*",
        wxFD_OPEN | wxFD_FILE_MUST_EXIST | wxFD_MULTIPLE);
    
    if (dialog.ShowModal() == wxID_OK)
    {
        wxArrayString paths;
        dialog.GetPaths(paths);
        
        for (size_t i = 0; i < paths.GetCount(); i++)
        {
            m_playlist.push_back(paths[i]);
        }
        
        UpdatePlaylistDisplay();
        
        if (m_currentTrack < 0 && !m_playlist.empty())
        {
            m_currentTrack = 0;
            LoadTrack(m_currentTrack);
        }
    }
}

void MusicPlayerFrame::OnRemove(wxCommandEvent& event)
{
    int selection = m_playlistBox->GetSelection();
    if (selection != wxNOT_FOUND)
    {
        m_playlist.erase(m_playlist.begin() + selection);
        UpdatePlaylistDisplay();
        
        if (m_playlist.empty())
        {
            m_currentTrack = -1;
            m_audioPlayer->Stop();
            m_titleLabel->SetLabel("未选择文件");
            m_timeLabel->SetLabel("00:00 / 00:00");
        }
        else if (selection == m_currentTrack)
        {
            if (m_currentTrack >= (int)m_playlist.size())
            {
                m_currentTrack = m_playlist.size() - 1;
            }
            LoadTrack(m_currentTrack);
        }
        else if (selection < m_currentTrack)
        {
            m_currentTrack--;
        }
    }
}

void MusicPlayerFrame::OnPlaylistSelect(wxCommandEvent& event)
{
    int selection = m_playlistBox->GetSelection();
    if (selection != wxNOT_FOUND && selection != m_currentTrack)
    {
        m_currentTrack = selection;
        LoadTrack(m_currentTrack);
    }
}

void MusicPlayerFrame::OnProgressSlider(wxScrollEvent& event)
{
    if (m_audioPlayer->IsFileLoaded())
    {
        double position = (double)m_progressSlider->GetValue() / 100.0 * m_audioPlayer->GetDuration();
        m_audioPlayer->SetPosition(position);
        UpdateTimeDisplay();
    }
}

void MusicPlayerFrame::OnVolumeSlider(wxScrollEvent& event)
{
    double volume = (double)m_volumeSlider->GetValue() / 100.0;
    m_audioPlayer->SetVolume(volume);
}

void MusicPlayerFrame::OnTimer(wxTimerEvent& event)
{
    UpdateTimeDisplay();
    
    // 检查播放是否结束
    if (m_audioPlayer->IsFileLoaded() && !m_audioPlayer->IsPlaying() && !m_audioPlayer->IsPaused())
    {
        // 自动播放下一首
        wxCommandEvent dummyEvent;
        OnNext(dummyEvent);
    }
}

void MusicPlayerFrame::OnClose(wxCloseEvent& event)
{
    if (m_audioPlayer)
    {
        m_audioPlayer->Stop();
    }
    event.Skip();
}

void MusicPlayerFrame::UpdateTimeDisplay()
{
    if (m_audioPlayer->IsFileLoaded())
    {
        double current = m_audioPlayer->GetCurrentPosition();
        double total = m_audioPlayer->GetDuration();
        
        int currentMin = (int)current / 60;
        int currentSec = (int)current % 60;
        int totalMin = (int)total / 60;
        int totalSec = (int)total % 60;
        
        wxString timeStr = wxString::Format("%02d:%02d / %02d:%02d", 
            currentMin, currentSec, totalMin, totalSec);
        m_timeLabel->SetLabel(timeStr);
        
        // 更新进度条
        if (total > 0)
        {
            int progress = (int)((current / total) * 100);
            m_progressSlider->SetValue(progress);
        }
    }
}

void MusicPlayerFrame::UpdateTitleDisplay()
{
    if (m_currentTrack >= 0 && m_currentTrack < (int)m_playlist.size())
    {
        wxFileName fn(m_playlist[m_currentTrack]);
        m_titleLabel->SetLabel(fn.GetName());
    }
    else
    {
        m_titleLabel->SetLabel("未选择文件");
    }
}

void MusicPlayerFrame::LoadTrack(int index)
{
    if (index >= 0 && index < (int)m_playlist.size())
    {
        if (m_audioPlayer->LoadFile(m_playlist[index]))
        {
            m_playlistBox->SetSelection(index);
            UpdateTitleDisplay();
            UpdateTimeDisplay();
            m_progressSlider->SetValue(0);
        }
        else
        {
            wxMessageBox(wxString::Format("无法加载文件: %s", m_playlist[index]), 
                "错误", wxOK | wxICON_ERROR);
        }
    }
}

void MusicPlayerFrame::UpdatePlaylistDisplay()
{
    m_playlistBox->Clear();
    for (const auto& file : m_playlist)
    {
        wxFileName fn(file);
        m_playlistBox->Append(fn.GetName());
    }
    
    if (m_currentTrack >= 0 && m_currentTrack < (int)m_playlist.size())
    {
        m_playlistBox->SetSelection(m_currentTrack);
    }
}
