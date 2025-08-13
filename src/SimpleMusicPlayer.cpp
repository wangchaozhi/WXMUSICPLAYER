#include <wx/wx.h>
#include <wx/filedlg.h>
#include <wx/filename.h>
#include <wx/msgdlg.h>
#include <wx/sizer.h>
#include <wx/statbox.h>
#include <wx/sound.h>
#include <wx/intl.h>
#include <wx/string.h>
#include <vector>

class SimpleMusicPlayer : public wxFrame
{
public:
    SimpleMusicPlayer() : wxFrame(nullptr, wxID_ANY, "简单音乐播放器", wxDefaultPosition, wxSize(600, 400))
    {
        // 创建UI
        CreateControls();
        LayoutControls();
        BindEvents();
        
        // 设置窗口样式
        SetBackgroundColour(wxColour(240, 240, 240));
        
        // 设置支持中文的字体
        SetFont(wxFont(9, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, false, wxT("Microsoft YaHei")));
        
        Centre();
    }

private:
    // UI组件
    wxListBox* m_playlistBox;
    wxButton* m_playButton;
    wxButton* m_pauseButton;
    wxButton* m_stopButton;
    wxButton* m_addButton;
    wxButton* m_removeButton;
    wxStaticText* m_statusLabel;
    
    // 音频播放器
    wxSound* m_sound;
    
    // 播放列表
    std::vector<wxString> m_playlist;
    int m_currentTrack;
    bool m_isPlaying;

    void CreateControls()
    {
        m_playlistBox = new wxListBox(this, wxID_ANY);
        m_playButton = new wxButton(this, wxID_ANY, "播放");
        m_pauseButton = new wxButton(this, wxID_ANY, "暂停");
        m_stopButton = new wxButton(this, wxID_ANY, "停止");
        m_addButton = new wxButton(this, wxID_ANY, "添加");
        m_removeButton = new wxButton(this, wxID_ANY, "删除");
        m_statusLabel = new wxStaticText(this, wxID_ANY, "未选择文件");
        
        m_sound = nullptr;
        m_currentTrack = -1;
        m_isPlaying = false;
    }

    void LayoutControls()
    {
        wxBoxSizer* mainSizer = new wxBoxSizer(wxHORIZONTAL);
        
        // 左侧播放列表
        wxStaticBoxSizer* playlistSizer = new wxStaticBoxSizer(wxVERTICAL, this, "播放列表");
        playlistSizer->Add(m_playlistBox, 1, wxEXPAND | wxALL, 5);
        
        wxBoxSizer* playlistButtonSizer = new wxBoxSizer(wxHORIZONTAL);
        playlistButtonSizer->Add(m_addButton, 1, wxEXPAND | wxRIGHT, 5);
        playlistButtonSizer->Add(m_removeButton, 1, wxEXPAND);
        playlistSizer->Add(playlistButtonSizer, 0, wxEXPAND | wxALL, 5);
        
        // 右侧控制面板
        wxStaticBoxSizer* controlSizer = new wxStaticBoxSizer(wxVERTICAL, this, "播放控制");
        controlSizer->Add(m_statusLabel, 0, wxALIGN_CENTER | wxALL, 10);
        
        wxBoxSizer* buttonSizer = new wxBoxSizer(wxHORIZONTAL);
        buttonSizer->Add(m_playButton, 1, wxEXPAND | wxRIGHT, 5);
        buttonSizer->Add(m_pauseButton, 1, wxEXPAND | wxRIGHT, 5);
        buttonSizer->Add(m_stopButton, 1, wxEXPAND);
        controlSizer->Add(buttonSizer, 0, wxEXPAND | wxALL, 5);
        
        mainSizer->Add(playlistSizer, 1, wxEXPAND | wxALL, 10);
        mainSizer->Add(controlSizer, 1, wxEXPAND | wxALL, 10);
        
        SetSizer(mainSizer);
    }

    void BindEvents()
    {
        m_playButton->Bind(wxEVT_BUTTON, &SimpleMusicPlayer::OnPlay, this);
        m_pauseButton->Bind(wxEVT_BUTTON, &SimpleMusicPlayer::OnPause, this);
        m_stopButton->Bind(wxEVT_BUTTON, &SimpleMusicPlayer::OnStop, this);
        m_addButton->Bind(wxEVT_BUTTON, &SimpleMusicPlayer::OnAdd, this);
        m_removeButton->Bind(wxEVT_BUTTON, &SimpleMusicPlayer::OnRemove, this);
        m_playlistBox->Bind(wxEVT_LISTBOX, &SimpleMusicPlayer::OnPlaylistSelect, this);
    }

    void OnPlay(wxCommandEvent& event)
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
        
        if (m_sound && m_sound->Play(wxSOUND_ASYNC))
        {
            m_isPlaying = true;
            m_playButton->Enable(false);
            m_pauseButton->Enable(true);
            UpdateStatus();
        }
    }

    void OnPause(wxCommandEvent& event)
    {
        if (m_sound)
        {
            m_sound->Stop();
            m_isPlaying = false;
            m_playButton->Enable(true);
            m_pauseButton->Enable(false);
            UpdateStatus();
        }
    }

    void OnStop(wxCommandEvent& event)
    {
        if (m_sound)
        {
            m_sound->Stop();
            m_isPlaying = false;
            m_playButton->Enable(true);
            m_pauseButton->Enable(false);
            UpdateStatus();
        }
    }

    void OnAdd(wxCommandEvent& event)
    {
        wxFileDialog dialog(this, "选择音乐文件", "", "",
            "音频文件 (*.wav;*.mp3)|*.wav;*.mp3|所有文件 (*.*)|*.*",
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

    void OnRemove(wxCommandEvent& event)
    {
        int selection = m_playlistBox->GetSelection();
        if (selection != wxNOT_FOUND)
        {
            m_playlist.erase(m_playlist.begin() + selection);
            UpdatePlaylistDisplay();
            
            if (m_playlist.empty())
            {
                m_currentTrack = -1;
                if (m_sound)
                {
                    m_sound->Stop();
                    delete m_sound;
                    m_sound = nullptr;
                }
                m_statusLabel->SetLabel("未选择文件");
            }
        }
    }

    void OnPlaylistSelect(wxCommandEvent& event)
    {
        int selection = m_playlistBox->GetSelection();
        if (selection != wxNOT_FOUND && selection != m_currentTrack)
        {
            m_currentTrack = selection;
            LoadTrack(m_currentTrack);
        }
    }

    void LoadTrack(int index)
    {
        if (index >= 0 && index < (int)m_playlist.size())
        {
            // 停止当前播放
            if (m_sound)
            {
                m_sound->Stop();
                delete m_sound;
            }
            
            // 创建新的声音对象
            m_sound = new wxSound();
            if (m_sound->Create(m_playlist[index], true))
            {
                m_playlistBox->SetSelection(index);
                UpdateStatus();
            }
            else
            {
                delete m_sound;
                m_sound = nullptr;
                wxMessageBox(wxString::Format("无法加载文件: %s", m_playlist[index]), 
                    "错误", wxOK | wxICON_ERROR);
            }
        }
    }

    void UpdatePlaylistDisplay()
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

    void UpdateStatus()
    {
        if (m_currentTrack >= 0 && m_currentTrack < (int)m_playlist.size())
        {
            wxFileName fn(m_playlist[m_currentTrack]);
            wxString status = fn.GetName();
            if (m_isPlaying)
            {
                status += " (播放中)";
            }
            m_statusLabel->SetLabel(status);
        }
        else
        {
            m_statusLabel->SetLabel("未选择文件");
        }
    }
};

class SimpleMusicPlayerApp : public wxApp
{
public:
    virtual bool OnInit()
    {
        if (!wxApp::OnInit())
            return false;

        // 设置本地化（可选，因为使用了-fexec-charset=GBK）
        // wxSetlocale(LC_ALL, "");

        SimpleMusicPlayer* frame = new SimpleMusicPlayer();
        frame->Show(true);
        SetTopWindow(frame);
        
        return true;
    }
};

wxIMPLEMENT_APP(SimpleMusicPlayerApp);

