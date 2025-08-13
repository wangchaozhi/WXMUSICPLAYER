#include <wx/wx.h>
#include "MusicPlayerFrame.h"

class MusicPlayerApp : public wxApp
{
public:
    virtual bool OnInit()
    {
        if (!wxApp::OnInit())
            return false;

        // 创建主窗口
        MusicPlayerFrame* frame = new MusicPlayerFrame("音乐播放器", 
            wxPoint(50, 50), wxSize(800, 600));
        
        frame->Show(true);
        SetTopWindow(frame);
        
        return true;
    }
};

wxIMPLEMENT_APP(MusicPlayerApp);
