unit roDocHost;

interface

uses
  Windows, ActiveX, SHDocVw, Classes;

type
  TDocHostUIInfo = packed record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwDoubleClick: DWORD;
  end;

const
  DOCHOSTUIFLAG_DIALOG = 1;
  DOCHOSTUIFLAG_DISABLE_HELP_MENU = 2;
  DOCHOSTUIFLAG_NO3DBORDER = 4;
  DOCHOSTUIFLAG_SCROLL_NO = 8;
  DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = 16;
  DOCHOSTUIFLAG_OPENNEWWIN = 32;
  DOCHOSTUIFLAG_DISABLE_OFFSCREEN = 64;
  DOCHOSTUIFLAG_FLAT_SCROLLBAR = 128;
  DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = 256;
  DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = 512;

const
  DOCHOSTUIDBLCLK_DEFAULT = 0;
  DOCHOSTUIDBLCLK_SHOWPROPERTIES = 1;
  DOCHOSTUIDBLCLK_SHOWCODE = 2;

type
  { IDocHostUIHandler }
  IDocHostUIHandler = interface(IUnknown)
    ['{bd3f23c0-d43e-11cf-893b-00aa00bdce1a}']
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT; stdcall;
    function ShowUI(const dwID: DWORD; const pActiveObject:
      IOleInPlaceActiveObject; const pCommandTarget: IOleCommandTarget;
      const pFrame: IOleInPlaceFrame; const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function ResizeBorder(const prcBorder: PRECT; const pUIWindow:
      IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget; out ppDropTarget:
      IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HRESULT; stdcall;
    function FilterDataObject(const pDO: IDataObject; out ppDORet: IDataObject): HRESULT; stdcall;
  end;

  { TRestrictedWebBrowser }
  TRestrictedWebBrowser = class(TWebBrowser, IDocHostUIHandler)
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT; stdcall;
    function ShowUI(const dwID: DWORD; const pActiveObject:
      IOleInPlaceActiveObject; const pCommandTarget: IOleCommandTarget;
      const pFrame: IOleInPlaceFrame; const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function ResizeBorder(const prcBorder: PRECT; const pUIWindow:
      IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget; out ppDropTarget:
      IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HRESULT; stdcall;
    function FilterDataObject(const pDO: IDataObject; out ppDORet: IDataObject): HRESULT; stdcall;
  public
    OnTranslateAccelerator:function(Sender:TObject;const lpMsg: PMSG):boolean of object;
    PoppedUp:record
     ScreenCoordinates:TPoint;
     MenuID:DWORD;
     CommandTarget:IInterface;
     HTMLObject:IDispatch;
    end;
    constructor Create(AOwner: TComponent); override;
  end;

  procedure Register;

implementation

uses
  Messages;

procedure Register;
begin
  RegisterComponents('Internet', [TRestrictedWebBrowser]);
end;

{ TRestrictedWebBrowser }

constructor TRestrictedWebBrowser.Create(AOwner: TComponent);
begin
 inherited;
 OnTranslateAccelerator:=nil;
end;

function TRestrictedWebBrowser.EnableModeless(
  const fEnable: BOOL): HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HRESULT;
begin
  ppDORet := nil;
  Result := S_FALSE;
end;

function TRestrictedWebBrowser.GetDropTarget(
  const pDropTarget: IDropTarget; out ppDropTarget: IDropTarget): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TRestrictedWebBrowser.GetExternal(
  out ppDispatch: IDispatch): HRESULT;
begin
  ppDispatch := nil;
  Result := S_FALSE;
end;

function TRestrictedWebBrowser.GetHostInfo(
  var pInfo: TDOCHOSTUIINFO): HRESULT;
begin
  pInfo.cbSize := sizeof(TDOCHOSTUIINFO);
  pInfo.dwFlags :=
    //DOCHOSTUIFLAG_DIALOG or
    DOCHOSTUIFLAG_DISABLE_HELP_MENU;// or
    //DOCHOSTUIFLAG_NO3DBORDER or
    //DOCHOSTUIFLAG_SCROLL_NO or
    //DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE;
  pInfo.dwDoubleClick := DOCHOSTUIDBLCLK_DEFAULT;
  Result := S_OK;
end;

function TRestrictedWebBrowser.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HRESULT;
begin
  pchKey := nil;
  Result := S_FALSE;
end;

function TRestrictedWebBrowser.HideUI: HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.OnDocWindowActivate(
  const fActivate: BOOL): HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.OnFrameWindowActivate(
  const fActivate: BOOL): HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HRESULT;
begin
 //context menu tonen?
 with PoppedUp do
  begin
   ScreenCoordinates:=ppt^;
   MenuID:=dwID;
   CommandTarget:=pcmdtReserved;
   HTMLObject:=pdispReserved;
  end;
 if not(PopupMenu=nil) then
  PopupMenu.Popup(PoppedUp.ScreenCoordinates.X,PoppedUp.ScreenCoordinates.Y);
 Result := S_OK;
end;

function TRestrictedWebBrowser.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HRESULT;
begin
  Result := S_OK;
end;

function TRestrictedWebBrowser.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HRESULT;
begin
  //if (lpMsg.message = WM_KEYDOWN) and (lpMsg.wParam = VK_F5) then Result := S_OK;
 if @OnTranslateAccelerator=nil then
  begin
   if lpMsg.wParam in [VK_F1..VK_F12] then
    Result:=S_OK
   else
    Result:=S_FALSE;
  end
 else
  begin
   if OnTranslateAccelerator(Self,lpMsg) then
    Result:=S_OK
   else
    Result:=S_FALSE;
  end;
end;

function TRestrictedWebBrowser.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
begin
  ppchURLOut := nil;
  Result := S_FALSE;
end;

function TRestrictedWebBrowser.UpdateUI: HRESULT;
begin
  Result := S_OK;
end;

end.

