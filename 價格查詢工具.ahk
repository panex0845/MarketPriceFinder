;@Ahk2Exe-SetName Market Price Finder
;@Ahk2Exe-SetDescription Market Price Finder
;@Ahk2Exe-SetVersion 1.0.0.0
;@Ahk2Exe-SetMainIcon 022.ico

#SingleInstance, force
SetTitleMatchMode, 3
Menu, Tray, Icon, Shell32.dll, 23
Gui, 1:new, +resize +minsize1130x880
Gui, 1:font, s16, 新細明體
Gui, 1:add, text, x10 y13, 勾選查詢資料庫
Gui, 1:add, checkbox, x+10 y10 h30 vWsite1 checked, 1. 高價屋
Gui, 1:add, checkbox, x+10 y10 h30 vWsite2 checked, 2. 藍色佛堂
Gui, 1:add, text, x10 y53, 請輸入商品名稱
Gui, 1:add, edit, x+10 y50 w350 h30 vInputtext, DDR4 8G
Gui, 1:add, button, x+10 y50 w180 h30 vInquire gInquire, 查詢
Gui, 1:add, button, x+10 y50 w180 h30 vCopy gCopy, 複製所有列表
Gui, 1:add, button, x+10 y50 w180 h30 vReload gReload, 重新載入資料庫
Gui, 1:add, text, x10 y93, 拒絕的字串　　
Gui, 1:add, edit, x+10 y90 w350 h30 vDe_Iptx, 
Gui, 1:add, text, x+10 y93 w400 h30 vNowText, 等待載入查詢網址中
Gui, 1:add, ListView, x10 y130 r20 w1100 h500 gListView vListView, 來源|商品名稱|價格|
Gui, 1:add, text, x10 h20 vEZNotpadT, 簡易記事本(無存檔功能)
Gui, 1:add, edit, x10 y670 w1100 h200 vEZNotpad, 
Gui, 1:Show, w1130 h880, 價格查詢工具
guicontrol, disable, Inquire
guicontrol, disable, Copy
gosub, Disclaimer
gosub, Load
return

Disclaimer:
LV_Add("", " ")
LV_Add("", "使用說明：")
LV_Add("", "1. 關鍵字以空白分隔，例如搜尋:「DDR4 8G」則會列出同時含有DDR4 8G名稱的品項")
LV_Add("", "2. 查詢多筆資料請用「//」分隔，//號後面不要加空格，例: R5 3600//9700")
LV_Add("", "3. 拒絕多個字串使用//號分隔 ，例:搜尋「R5 3600」 拒絕「x//一搭三」")
LV_Add("", "4. 雙擊複製")
LV_Add("", "5. 查詢快速鍵：LShift + Enter")
LV_Add("", " ")
LV_Add("", "免責聲明：")
LV_Add("", "1. 本工具僅供程式語言上學術交流之用，請勿非法或不當使用。")
LV_Add("", "2. 本工具不負責任何包括但不限於濫用、資料錯誤而發生之任何賠償或損失。", "　　　　")
LV_Add("", " ")
LV_Add("", "版權宣告：")
LV_Add("", "本著作係採用創用 CC 姓名標示-非商業性-相同方式分享 4.0 國際 授權條款授權")
LV_Add("", " ")
LV_ModifyCol() 
return

Load:
gui, submit, nohide
Site1 := "http://www.coolpc.com.tw/evaluate.php"
Site2 := "https://www.isunfar.com.tw/ecdiy/getitem.ashx"
guicontrol, ,NowText, % "載入資料庫：高價屋"
liststringArray_Coolpc := GetData(Site1, 1)
guicontrol, ,NowText, % "載入資料庫：藍色佛堂"
liststringArray_isunfar := GetData(Site2, 2)
guicontrol, Enable, Inquire
guicontrol, Enable, Copy
guicontrol, ,NowText, % "載入完畢，請輸入商品名稱"
Loaded := 1
return

#IfWinActive 價格查詢工具
~LShift & Enter::
if Loaded
    goto, Inquire
return

Copy:
Clipboard := allcommodities
Tooltip, 已複製所有列表至剪貼簿
sleep 1500
tooltip
return

Inquire:
gui, submit, nohide
c_string := ""
c_list := ""
global allcommodities := ""
if (Inputtext="" or (!Wsite1 and !Wsite2))
{
    LV_Delete()
    LV_Add("", "錯誤！未輸入商品名稱或資料庫未勾選！","　　　　","　　　　")
    LV_ModifyCol() 
    guicontrol, ,NowText, % ""
}
else
{
    if !De_Iptx
        De_Iptx := "AAAAAAAAAAAAAAAAAA叔叔開剁"
    Inputtext := StrSplit(Inputtext, "//")
    global M_De_Iptx := StrSplit(De_Iptx, "//")
    global M_dt := M_De_Iptx.MaxIndex()
    guicontrol, Disable, Inquire
    goods := 0
    LV_Delete()
    LV_ModifyCol(1, "80") 
    LV_ModifyCol(2, "850") 
    LV_ModifyCol(3, "150 Integer")
    if Wsite1
        Goods += SearchGoods(inputtext, liststringArray_Coolpc, 1)
    if Wsite2
        Goods += SearchGoods(inputtext, liststringArray_isunfar, 2) 
    guicontrol, ,NowText, % "查詢完畢，共 " goods " 筆"
    guicontrol, Enable, Inquire
}
return

SearchGoods(inputtext, liststringArray, Data=0) {
    for k, v in Inputtext
    {
        guicontrol, ,NowText, % "查詢中請稍後..."
        Loop % liststringArray.MaxIndex()
        {
            c_string := liststringArray[A_Index]
            if Data=1
            {
                c_stringArray := StrSplit(c_string, ", ")
                fdata := "高價　"
            }
            else if Data=2
            {
                c_stringArray := StrSplit(c_string, "＄")
                fdata := "佛堂　"
            }
            c_text := c_stringArray[1]
            If TList := CheckString(c_text, v)
            {
                dt := 0
                if TList=1
                {
                    for k, dv in M_De_Iptx
                    {
                        IfNotInString, c_text, % dv
                        {
                            dt++
                        }
                    }
                }
                else if TList=2
                {
                    for k, dv in M_De_Iptx
                    {
                        IfNotInString, c_text, % dv
                        {
                            dt++
                        }
                    }
                    if dt
                    {
                        t := StrSplit(v, A_Space)
                        for k, sv in t
                        {
                            IfnotInString, c_text, % sv
                                dt := 0
                        }
                    }
                }
                if (dt=M_dt)
                {
                    c_stringArray[2] := RegExReplace(c_stringArray[2], "|\$|◆|★|熱|賣| |")
                    LV_Add("", fdata, c_stringArray[1], c_stringArray[2])
                    goods++
                    allcommodities .= c_stringArray[1] . c_stringArray[2] "`n"
                }
            }
        }
    }
    return goods
}

GetData(Site, Data=0) {
    ComObjError(false)
    oHttp := ComObjCreate("WinHttp.Winhttprequest.5.1")
    oHttp.open("GET", Site, true) 
    oHttp.Send()
    oHttp.WaitForResponse()
    arr :=  oHttp.responseBody
    pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
    length := arr.MaxIndex() + 1
    if data=1
    {
        php := StrSplit(StrGet(pData, length, "CP950") , "`n")
        Loop % php.MaxIndex()
        {
            string := php[A_Index]
            IfInString, string, `, $
                    liststring .= StringTL(string) "`n"  ;List of commodities
        }
    }
    else if data=2
    {
        php := StrSplit(StrGet(pData, length, "utf-8") , "},{")
        Loop % php.MaxIndex()
        {
            string := php[A_Index]
            IfInString, string, pc
                liststring .= StringTL_isunfar(string) "`n"  ;List of commodities
        }
    }
    return StrSplit(liststring, "`n")
}

StringTL(ipt) 
{
    StringGetPos, opt, ipt, > ,L
    StringMid, opt, ipt, opt+2
    StringGetPos, out, opt, `</ , L
    StringLeft , opt, opt, out
    return opt 
}

StringTL_isunfar(ipt) 
{
    StringGetPos, opt, ipt, pc ,L
    StringMid, opt, ipt, opt+6
    StringGetPos, out, opt, sn , R
    StringLeft , opt, opt, out-3
    return opt 
}

CheckString(text, var)
{
    IfInString, var,  % A_Space
    {
        t := StrSplit(var, A_Space)
        for k, v in t
            IfInString, text,  % v
                return 2
    }
    IfInString, text, % var
        return 1
    return 0
}

ListView:
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(RowText, A_EventInfo, 2)
    LV_GetText(RowText2, A_EventInfo, 3)
    Clipboard := % RowText . " " RowText2
    tooltip, % Clipboard " 已複製到剪貼簿!"
    sleep 1500
    tooltip
}
return

Guiclose:
ExitApp
return

GUISize:
LVwidth:=A_GuiWidth-25
LVheight:=A_GuiHeight-380
EZwidth := A_GuiWidth-25
EZY := A_GuiHeight -220
EZTY := A_GuiHeight -245
guicontrol, move, ListView, w%LVwidth% h%LVheight%
guicontrol, move, EZNotpadT, y%EZTY%
guicontrol, move, EZNotpad, y%EZY% w%EZwidth% 
return

Reload:
GuiControl, disable, Reload
Reload
return