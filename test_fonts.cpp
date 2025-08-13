#include <wx/wx.h>
#include <wx/font.h>
#include <wx/msgdlg.h>

class FontTestFrame : public wxFrame
{
public:
    FontTestFrame() : wxFrame(nullptr, wxID_ANY, "字体测试程序", wxDefaultPosition, wxSize(600, 400))
    {
        // 创建测试按钮
        wxButton* testButton = new wxButton(this, wxID_ANY, "测试字体显示");
        testButton->Bind(wxEVT_BUTTON, &FontTestFrame::OnTestFonts, this);
        
        // 创建文本显示区域
        m_textCtrl = new wxTextCtrl(this, wxID_ANY, "", wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE | wxTE_READONLY);
        
        // 布局
        wxBoxSizer* sizer = new wxBoxSizer(wxVERTICAL);
        sizer->Add(testButton, 0, wxALL | wxALIGN_CENTER, 10);
        sizer->Add(m_textCtrl, 1, wxEXPAND | wxALL, 10);
        SetSizer(sizer);
        
        // 测试不同字体
        TestAvailableFonts();
        
        Centre();
    }

private:
    wxTextCtrl* m_textCtrl;

    void OnTestFonts(wxCommandEvent& event)
    {
        TestAvailableFonts();
        wxMessageBox("字体测试完成，请查看文本区域的结果", "测试完成");
    }

    void TestAvailableFonts()
    {
        m_textCtrl->Clear();
        
        wxString report = "=== 字体测试报告 ===\n\n";
        
        // 测试系统默认字体
        report += "1. 系统默认字体测试：\n";
        wxFont defaultFont = wxFont(12, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL);
        report += wxString::Format("   默认字体: %s\n", defaultFont.GetFaceName());
        report += wxString::Format("   字体大小: %d\n", defaultFont.GetPointSize());
        report += wxString::Format("   支持中文: %s\n", defaultFont.IsOk() ? "是" : "否");
        
        // 测试中文字符显示
        report += "\n2. 中文字符显示测试：\n";
        report += "   测试文本: 你好世界 Hello World 123\n";
        
        // 测试常见中文字体
        report += "\n3. 常见中文字体测试：\n";
        wxString chineseFonts[] = {
            "WenQuanYi Micro Hei",
            "Noto Sans CJK SC", 
            "DejaVu Sans",
            "Liberation Sans",
            "Ubuntu",
            "Arial"
        };
        
        for (const auto& fontName : chineseFonts)
        {
            wxFont testFont(12, wxFONTFAMILY_DEFAULT, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL, false, fontName);
            if (testFont.IsOk())
            {
                report += wxString::Format("   ✅ %s - 可用\n", fontName);
            }
            else
            {
                report += wxString::Format("   ❌ %s - 不可用\n", fontName);
            }
        }
        
        // 环境信息
        report += "\n4. 环境信息：\n";
        report += wxString::Format("   操作系统: %s\n", wxGetOsDescription());
        report += wxString::Format("   桌面环境: %s\n", wxGetDisplayName());
        report += wxString::Format("   语言设置: %s\n", wxLocale::GetSystemLanguageName());
        
        m_textCtrl->SetValue(report);
    }
};

class FontTestApp : public wxApp
{
public:
    virtual bool OnInit()
    {
        if (!wxApp::OnInit())
            return false;

        FontTestFrame* frame = new FontTestFrame();
        frame->Show(true);
        SetTopWindow(frame);
        
        return true;
    }
};

wxIMPLEMENT_APP(FontTestApp);
