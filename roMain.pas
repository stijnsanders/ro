unit roMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Menus, ActnList, AppEvnts, ImgList, StdCtrls,
  SQLiteData, roHexTree;

var
  AppName:string;//zie project source

procedure GetVersion;

const
  iiNetwork=31;
  iiServer=27;

{
 hoe blanco bijmaken:

var
 dw:TDockWin;
begin
 dw:=TDockWin.Create(Owner);
 //verdere init! pointer opslaan ergens!

 dw.ManualDock(DockTop);
 ShowDockWin(dw);
end;
}

type
  TMainWin = class(TForm)
    StatusBar1: TStatusBar;
    SplitBottom: TSplitter;
    SplitTop: TSplitter;
    SplitLeft: TSplitter;
    SplitRight: TSplitter;
    DockLeft: TPanel;
    DockTop: TPanel;
    DockRight: TPanel;
    DockBottom: TPanel;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Toolbars1: TMenuItem;
    Windows1: TMenuItem;
    MDIWindows: TMenuItem;
    Arrangeicons1: TMenuItem;
    Cascade1: TMenuItem;
    Tilevertical1: TMenuItem;
    Tilehorizontally1: TMenuItem;
    Debug1: TMenuItem;
    newtoolbar1: TMenuItem;
    Closeall1: TMenuItem;
    New1: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    aNew: TAction;
    ImageList1: TImageList;
    aCloseAll: TAction;
    aWinArrIcons: TAction;
    aWinCascade: TAction;
    aWinTileV: TAction;
    aWinTileH: TAction;
    aDWWindows: TAction;
    aViewSettings: TAction;
    Settings1: TMenuItem;
    aClose: TAction;
    N4: TMenuItem;
    Close1: TMenuItem;
    GeneralPm: TPopupMenu;
    N5: TMenuItem;
    Closeall2: TMenuItem;
    aExit: TAction;
    Exit2: TMenuItem;
    OpenDialog1: TOpenDialog;
    N1: TMenuItem;
    aNetwork: TAction;
    Networks1: TMenuItem;
    test1: TMenuItem;
    aDWIndentD: TAction;
    identdlistener1: TMenuItem;
    N2: TMenuItem;
    QCon: TMenuItem;
    N3: TMenuItem;
    Windows2: TMenuItem;
    N6: TMenuItem;
    aStatusBar: TAction;
    N7: TMenuItem;
    StatusBar2: TMenuItem;
    Networks2: TMenuItem;
    New2: TMenuItem;
    procedure DockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer); reintroduce;
    procedure DockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean); reintroduce;
    procedure DockUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure DockGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure SplitBottomMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure newtoolbar1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure aCloseAllExecute(Sender: TObject);
    procedure aWinArrIconsExecute(Sender: TObject);
    procedure aWinCascadeExecute(Sender: TObject);
    procedure aWinTileHExecute(Sender: TObject);
    procedure aWinTileVExecute(Sender: TObject);
    procedure aDWWindowsExecute(Sender: TObject);
    procedure aCloseExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure aNetworkExecute(Sender: TObject);
    procedure test1Click(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure aDWIndentDExecute(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure QConClick(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure aViewSettingsExecute(Sender: TObject);
    procedure aStatusBarExecute(Sender: TObject);
    procedure ScrollBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    //voor multi-select
    //mx,my,px,py:integer;
    function GetVisibleCount(Sender:TObject;Exclude:TControl):integer;
    function CloseAll:boolean;
    function MainClose:boolean;
    procedure WMQueryEndSession(var Msg:TWMQueryEndSession); message WM_QueryEndSession;
  public
    dbCon:TSQLiteConnection;
    NewItemPos:TPoint;
    ExitCommandCalled:boolean;//vlag voor decentraal globaal te sluiten
    MainIsQuitting:boolean;//vlag voor centraal globaal aan het sluiten
    HexTree:THexTree;
    ConWindows:TList;
    AppSince:TDateTime;
    procedure DockHide(d:TPanel);
    procedure DockResize(d:TPanel);
    procedure ShowDockWin(dw:TForm);
    function GetLogDir:string;
    function GetResHTML(id:string):string;
  end;

var
  MainWin: TMainWin;

implementation

uses roDockWin, roDockTabWin, roDockJoinWin, roWinDock, roChildwin,
  Clipbrd, roMsgWin, roNetworks, roConWin, roIdentDock, Variants,
  roStuff, roSettings;

{$R *.DFM}

procedure TMainWin.DockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  //if (Sender as TPanel).DockClientCount = 1 then
  if GetVisibleCount(Sender,nil)=1 then
   DockResize(Sender as TPanel);
  (Sender as TPanel).DockManager.ResetBounds(True);
end;

procedure TMainWin.DockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect:TRect;
  i:integer;
begin
 Accept := Source.Control is TDockWin;
 if Accept then
  begin
   ARect.Top:=0;
   ARect.Left:=0;
   if Sender=DockBottom then
    begin
     ARect.Top:=-(ClientHeight div 4);
     ARect.Bottom:=0;
     ARect.Right:=ClientWidth;
    end;
   if Sender=DockRight then
    begin
     ARect.Left:=-(ClientWidth div 4);
     ARect.Right:=0;
    end;

   if (Sender=DockLeft) or (Sender=DockRight) then
    begin
     i:=ClientHeight-StatusBar1.Height;
     if SplitBottom.Visible then dec(i,DockBottom.Height+4);
     if SplitTop.Visible then dec(i,DockTop.Height+4);
     ARect.Bottom:=i;
    end;

   if Sender=DockLeft then
    begin
     ARect.Right:=ClientWidth div 4;
    end;
   if Sender=DockTop then
    begin
     ARect.Bottom:=ClientHeight div 4;
     ARect.Right:=ClientWidth;
    end;

   ARect.BottomRight:=(Sender as TPanel).ClientToScreen(ARect.BottomRight);
   ARect.TopLeft:=(Sender as TPanel).ClientToScreen(ARect.TopLeft);

   Source.DockRect := ARect;
  end;
end;

procedure TMainWin.DockUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
 //if (Sender as TPanel).DockClientCount = 1 then DockHide(Sender as TPanel);
 if GetVisibleCount(Sender,Client)=0 then DockHide(Sender as TPanel);
end;

procedure TMainWin.DockGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
  CanDock := DockClient is TDockWin;
end;

procedure TMainWin.ShowDockWin(dw:TForm);
var
 i:integer;
 pc:TPageControl;
 adw:TDockWin;
 procedure GetHostDockSite;
 begin
  if adw.HostDockSite is TDockWin then
   adw:=(adw.HostDockSite as TDockWin)
  else
   adw:=nil;
 end;
begin
 adw:=(dw as TDockWin);
 if adw.Visible=false then adw.Visible:=true;

 while not(adw=nil) do
  begin
   if adw.HostDockSite is TPageControl then
    begin
     TDockTabWin(adw.HostDockSite.Owner).Show;
     //tab zoeken!
     i:=0;
     pc:=(adw.HostDockSite as TPageControl);
     while (i<pc.PageCount) and not(pc.Pages[i].Controls[0]=adw) do inc(i);
     if (i<pc.PageCount) then pc.ActivePageIndex:=i;
     adw:=TDockTabWin(adw.HostDockSite.Owner);
    end
   else
    if (adw.HostDockSite is TDockJoinWin) then
     begin
      if not(adw.HostDockSite.Visible) then
       begin
        adw.HostDockSite.Show;
        (adw.HostDockSite as TDockJoinWin).UpdateCaption(nil);
        adw.Show;
       end;
      GetHostDockSite;
     end
    else
     begin
      adw.Show;
      if (adw.HostDockSite is TPanel) then
       begin
        if ((adw.HostDockSite.Height = 0) or (adw.HostDockSite.Width = 0)) then
         DockResize(adw.HostDockSite as TPanel);
        adw:=nil;
       end
      else
       GetHostDockSite;
     end;
  end;

end;

procedure TMainWin.DockResize(d:TPanel);
var
 i:integer;
begin
 if d=DockTop then
  begin
   i:=ClientHeight div 4;
   SplitTop.Visible:=true;
   DockTop.Height:=i;
   SplitTop.Top:=i+4;
  end;
 if d=DockBottom then
  begin
   i:=ClientHeight div 4;
   SplitBottom.Visible:=true;
   DockBottom.Height:=i;
   SplitBottom.Top:=ClientHeight-(i+4);
   StatusBar1.Top:=ClientHeight;
  end;
 if d=DockLeft then
  begin
   i:=ClientWidth div 4;
   SplitLeft.Visible:=true;
   DockLeft.Width:=i;
   SplitLeft.Left:=i+4;
  end;
 if d=DockRight then
  begin
   i:=ClientWidth div 4;
   SplitRight.Visible:=true;
   DockRight.Width:=i;
   SplitRight.Left:=ClientWidth-(i+4);
  end;
end;

procedure TMainWin.DockHide(d:TPanel);
begin
 if not(d.VisibleDockClientCount>1) then
  begin
   if d=DockTop then
    begin
     DockTop.Height:=0;
     SplitTop.Visible:=false;
    end;
   if d=DockBottom then
    begin
     DockBottom.Height:=0;
     SplitBottom.Visible:=false;
    end;
   if d=DockLeft then
    begin
     DockLeft.Width:=0;
     SplitLeft.Visible:=false;
    end;
   if d=DockRight then
    begin
     DockRight.Width:=0;
     SplitRight.Visible:=false;
    end;
  end;
end;

function TMainWin.GetVisibleCount(Sender:TObject;Exclude:TControl):integer;
var
 i,j:integer;
begin
 j:=0;
 for i:=0 to (Sender as TPanel).DockClientCount-1 do
  if not((Sender as TPanel).DockClients[i]=Exclude) then
   if ((Sender as TPanel).DockClients[i]).Visible then inc(j);
 Result:=j;
end;

procedure TMainWin.SplitBottomMoved(Sender: TObject);
begin
 if DockBottom.Height=0 then
  begin
   DockBottom.Height:=21;
   StatusBar1.Top:=ClientHeight;
  end;
end;

procedure TMainWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if MainClose then
  begin
   //sureclose!

   ConWindows.Free;

   HexTree.Free;
   dbCon.Free;
  end
 else
  Action:=caNone;
end;

function TMainWin.MainClose:boolean;
var
 a:boolean;
begin

 a:=Application.MessageBox(PChar(roClose),
  PChar(AppName),MB_OKCANCEL or MB_ICONQUESTION)=idOK;

 if a then
  begin

   MainIsQuitting:=true;

   //eerst alle MDI Children en save check...
   a:=CloseAll;

   //Dan alle toolboxes (Docks)

   //dock position opslaan?
  end;

 Result:=a;
end;

procedure TMainWin.newtoolbar1Click(Sender: TObject);
begin
 ShowDockWin(TDockWin.Create(Application));
end;

function TMainWin.CloseAll:boolean;
var
 f:TChildWin;      
 c:TConnectionWin;
 a:boolean;
 i:integer;
begin

 //preclose?
 //voor conwins die aan msgwins hangen?
 for i:=0 to ConWindows.Count-1 do
  begin                          
   c:=ConWindows[i];
   c.PreClose;
   //assert conwins sluiten zelf nog niet!
  end;

 Application.ProcessMessages; 

 //de rest sluiten
 a:=true;
 while a and not(MDIChildCount=0) do
  begin
   f:=MDIChildren[0] as TChildWin;
   f.Close;
   if WindowsDock.LastCloseOk then f.Free else a:=false;
  end;
 Result:=a;
end;

procedure TMainWin.FormCreate(Sender: TObject);
var
 i:integer;
 s:string;
begin
 AppSince:=Now;
 ExitCommandCalled:=false;
 MainIsQuitting:=false;
 HexTree:=THexTree.Create;
 ConWindows:=TList.Create;
 for i:= 1 to paramcount do
  begin
   s:=paramstr(i);

   if UpperCase(s)='/D' then Debug1.Visible:=true;

  end;
end;

procedure TMainWin.ApplicationEvents1Hint(Sender: TObject);
begin
 if length(Application.Hint)=0 then
  begin
   StatusBar1.SimplePanel:=false;
  end
 else
  begin
   StatusBar1.SimplePanel:=true;
   StatusBar1.SimpleText:=Application.Hint;
  end;
end;

procedure TMainWin.aCloseAllExecute(Sender: TObject);
begin
 CloseAll;
end;

procedure TMainWin.aWinArrIconsExecute(Sender: TObject);
begin
 ArrangeIcons;
end;

procedure TMainWin.aWinCascadeExecute(Sender: TObject);
begin
 Self.Cascade;
end;

procedure TMainWin.aWinTileHExecute(Sender: TObject);
begin
 TileMode:=tbHorizontal;
 Tile;
end;

procedure TMainWin.aWinTileVExecute(Sender: TObject);
begin
 TileMode:=tbVertical;
 Tile;
end;

procedure TMainWin.aDWWindowsExecute(Sender: TObject);
begin
 if WindowsDock.Visible then WindowsDock.Close else
  begin
   ShowDockWin(WindowsDock);
   if WindowsDock.FirstDisplay then
    begin
     WindowsDock.ManualDock(DockTop);
     WindowsDock.FirstDisplay:=false;
     //hoogte standaard beetje te groot
     DockTop.ClientHeight:=winPanelHeight;
    end;
  end;
end;

procedure TMainWin.aCloseExecute(Sender: TObject);
begin
 if not(ActiveMdiChild=nil) then ActiveMdiChild.Close;
end;

procedure TMainWin.aExitExecute(Sender: TObject);
begin
 Close;
end;

procedure TMainWin.aNewExecute(Sender: TObject);
begin
 TConnectionWin.Create(Application);
end;

procedure TMainWin.FormShow(Sender: TObject);
const
 first:boolean=true;
var
 fn:string;
begin
 if first then
  begin
   //parameters lezen!!

   // /D database
   // /L login to database...

   //assert(Application.Exename eindigt op .exe)
   fn:=Application.Exename;
   fn:=copy(fn,1,length(fn)-3);

   if FileExists(fn+'db') then
     dbCon:=TSQLiteConnection.Create(fn+'db')
   else
    begin
     //No DB found!
     Application.MessageBox(PChar(roNoDB),PChar(AppName),MB_OK or MB_ICONERROR);
     Application.Terminate;
    end;

   //al toolbars openen?

   LongTimeFormat:='hh:mm:ss';

   //script action?

   first:=false;
  end;
end;

procedure TMainWin.aNetworkExecute(Sender: TObject);
var
  n:TForm;
  i:integer;
begin
  i:=0;
  n:=nil;
  while i<MDIChildCount do
   begin
    n:=MDIChildren[i];
    if n is TNetworkWin then i:=MDIChildCount else inc(i);
   end;
  if i<MDIChildCount then
   begin
    n.BringToFront;
    n.SetFocus;
   end
  else
    TNetworkWin.Create(Application);
end;

procedure TMainWin.test1Click(Sender: TObject);
var
  f:TConnectionWin;
begin
  inherited;
  f:=TConnectionWin.Create(Application);
  f.ConnectOnComplete:=false;
  f.DoDebugLog;
end;

procedure TMainWin.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
  if ExitCommandCalled then Close;
end;

procedure TMainWin.aDWIndentDExecute(Sender: TObject);
begin
  if IdentDock.Visible then IdentDock.Close else
   begin
    ShowDockWin(IdentDock);
    if IdentDock.FirstDisplay then
     begin
      IdentDock.ManualDock(DockRight);
      IdentDock.FirstDisplay:=false;
      if DockRight.Width=0 then DockRight.Width:=120;
     end;
   end;
end;

procedure TMainWin.File1Click(Sender: TObject);
var
  rs:TSQLiteStatement;
  m:TMenuItem;
begin
  QCon.Clear;
  rs:=TSQLiteStatement.Create(MainWin.dbCon,
   'SELECT * FROM Network ORDER BY name');
  try
    if rs.EOF then
      QCon.Enabled:=false
    else
      while rs.Read do
       begin
        m:=TMenuItem.Create(Application);
        QCon.Add(m);
        m.ImageIndex:=iiNetwork;
        m.Caption:=rs.GetStr('name');
        m.Tag:=rs.GetInt('id');
        m.OnClick:=QConClick;
       end;
  finally
    rs.Free;
  end;
end;

procedure TMainWin.QConClick(Sender: TObject);
var
  f:TConnectionWin;
begin
  f:=TConnectionWin.Create(Application);
  f.DataByNetwork((Sender as TMenuItem).Tag);
  f.ConnectOnComplete:=true;
end;

function TMainWin.GetLogDir:string;
var
  s:string;
begin
  s:=Application.ExeName;
  //setting???
  while not(s='') and not(s[length(s)]='\') do setlength(s,length(s)-1);
  s:=s+'logs';
  Result:=s;
end;

procedure TMainWin.ApplicationEvents1Deactivate(Sender: TObject);
begin
  if ActiveMDIChild<>nil then
   begin
    //gewone child.ondeactivate is te sterk,

    //hoofd-icoon?

    if ActiveMDIChild is TChildWin then
      (ActiveMDIChild as TChildWin).AppDeactivate;
   end;
end;

function TMainWin.GetResHTML(id:string):string;
var
 h:THandle;
begin
 h:=FindResource(0,PChar(id),pointer(23));
 h:=LoadResource(0,h);
 Result:=PChar(LockResource(h));
end;

procedure TMainWin.aViewSettingsExecute(Sender: TObject);
begin
 //...

 //settings invullen
 SetsWin:=TSetsWin.Create(Application);

 if SetsWin.ShowModal=mrOk then
  begin
   //settings terug inlezen
  end;

 SetsWin.Free;

end;

procedure TMainWin.aStatusBarExecute(Sender: TObject);
var
 a:boolean;
begin
 a:=not(aStatusBar.Checked);
 aStatusBar.Checked:=a;
 StatusBar1.Visible:=a;
end;

procedure TMainWin.WMQueryEndSession(var Msg : TWMQueryEndSession); 
begin
 if MainClose then Msg.Result:=1 else Msg.Result:=0;
 //if 1 then ook free zoals OnClose???

 //anders, wordt in dit geval de OnDestroy aangeroepen??

end;

procedure GetVersion;
var
 h,d:Cardinal;
 p:pointer;
 verblock:PVSFIXEDFILEINFO;
 versionMS,versionLS:cardinal;
 verlen:cardinal;
 m:TMemoryStream;
 osv:TOSVersionInfo;
 s:string;
begin
 //uses Windows,Classes,SysUtils;
 //eigen versie opvragen
 try
  h:=FindResource(0,'#1',RT_VERSION);
  if h=0 then raise Exception.Create('No version info found');
  d:=LoadResource(0,h);
  if d=0 then raise Exception.Create('Could not load version info');
  p:=LockResource(d);
  if p=nil then raise Exception.Create('Could not lock version info');
  m:=TMemoryStream.Create;
  m.Position:=0;
  m.WriteBuffer(p^,SizeofResource(0,h));
  if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then
   begin
    VersionMS:=verblock.dwFileVersionMS;
    VersionLS:=verblock.dwFileVersionLS;
    AppName:='Ro° v'+
      inttostr(versionMS shr 16)+'.'+
      inttostr(versionMS and $FFFF)+'.'+
      inttostr(VersionLS shr 16)+'.'+
      inttostr(VersionLS and $FFFF)+
      ' by Siggma';
   end
  else
   raise Exception.Create('Version query value failed');
  m.Free;
 except
  on e:Exception do
   AppName:='Ro° sr2 by Siggma ['+e.Message+']';
 end;

 //windows versie uitvissen

 osv.dwOSVersionInfoSize:=SizeOf(osv);
 if GetVersionEx(osv) then
  begin
   s:=osv.szCSDVersion;
   setlength(s,length(s));
   case osv.dwPlatformId of
    VER_PLATFORM_WIN32s:s:=s+' (Win32s)';
    VER_PLATFORM_WIN32_WINDOWS:
     if osv.dwMinorVersion=0 then s:=s+' (Win95)' else s:=s+' (Win98)';
    VER_PLATFORM_WIN32_NT:s:=s+' (WinNT)';
    //nog?
   end;
   AppName:=AppName+'; Windows '+
    IntToStr(osv.dwMajorVersion)+'.'+
    IntToStr(osv.dwMinorVersion)+'.'+
    IntToStr(osv.dwBuildNumber)+' '+s;
  end
 else
  begin
   AppName:=AppName+'; ['+SysErrorMessage(GetLastError)+']';
  end;

end;

procedure TMainWin.ScrollBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 {
 if Shift=[ssLeft] then
  begin
   mx:=Mouse.CursorPos.X;
   my:=Mouse.CursorPos.Y;
   px:=x;
   py:=y;
   SelSquare.BoundsRect:=Rect(x,y,x+2,y+2);
   SelSquare.Visible:=true;
  end;
 if Shift=[ssRight] then
  begin
   NewItemPos:=Point(X,Y);
   GeneralPm.Popup(ScrollBox1.ClientOrigin.X+X,ScrollBox1.ClientOrigin.Y+Y);
  end;
 }
end;

procedure TMainWin.ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 {
 if SelSquare.Visible then
  begin
   mx:=Mouse.CursorPos.X;
   my:=Mouse.CursorPos.Y;
   SelSquare.BoundsRect:=Rect(px,py,x,y);
  end;
 }
end;

procedure TMainWin.ScrollBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 {
 if SelSquare.Visible then
  begin
   //selectie opvullen
  end;
 SelSquare.Visible:=false;
 }
end;

end.


