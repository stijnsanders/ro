unit roDockTabWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, roDockWin, StdCtrls, Menus;

type
  TDockTabWin = class(TDockWin)
    PageControl1: TPageControl;
    Button1: TButton;
    pm1: TPopupMenu;
    Rename1: TMenuItem;
    N1: TMenuItem;
    Hide1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl1DockOver(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure PageControl1UnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure PageControl1GetSiteInfo(Sender: TObject;
      DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
      var CanDock: Boolean);
    procedure FormGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DockTabWin: TDockTabWin;

implementation

uses roGetVal;

{$R *.DFM}

procedure TDockTabWin.FormClose(Sender: TObject; var Action: TCloseAction);
var
// ARect:TRect;
 i:integer;
begin

 inherited;

 if PageControl1.DockClientCount=1 then
  begin
   {
   with PageControl1.DockClients[0] do
    begin
     ARect.TopLeft := ClientToScreen(Point(0, 0));
     ARect.BottomRight := ClientToScreen(Point(UndockWidth, UndockHeight));
     ManualFloat(ARect);
    end;
   }
   if Floating then
    PageControl1.DockClients[0].ManualFloat(BoundsRect)
   else
    PageControl1.DockClients[0].ManualDock(HostDockSite);
   Action:=caFree;
  end
 else
  begin
   for i:=PageControl1.DockClientCount-1 downto 0 do
    with (PageControl1.DockClients[i] as TDockWin) do
     begin
      Visible:=false;
      if not(ToggleMenu=nil) then ToggleMenu.Checked:=false;
     end;
   Action:=caHide;
  end;
end;

procedure TDockTabWin.PageControl1DockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
 ARect:TRect;
begin
  Accept := Source.Control is TDockWin;
  if Accept then
   begin
    ARect.TopLeft:=ClientToScreen(Point(ClientWidth div 5, ClientHeight div 5));
    ARect.BottomRight:=ClientToScreen(Point((ClientWidth div 5) * 4, (ClientHeight div 5) * 4));
    Source.DockRect:=ARect;
   end;
end;

procedure TDockTabWin.PageControl1UnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
 if (PageControl1.DockClientCount = 2) and (NewTarget <> Self) then
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TDockTabWin.PageControl1GetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
 CanDock := (DockClient is TDockWin) and not(DockClient.HostDockSite=PageControl1);
end;

procedure TDockTabWin.FormGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
 CanDock:=false;
end;

procedure TDockTabWin.Button1Click(Sender: TObject);
begin
  inherited;
 pm1.Popup(
  ClientOrigin.x+Button1.Left+3,
  ClientOrigin.y+3);
end;

procedure TDockTabWin.Hide1Click(Sender: TObject);
begin
  inherited;
 Close;
end;

procedure TDockTabWin.Rename1Click(Sender: TObject);
begin
  inherited;
 GetValWin.Caption:='Rename tabbed toolbox collection';
 GetValWin.Val.Text:=Caption;
 if GetValWin.ShowModal=mrOk then
  Caption:=GetValWin.Val.Text;
end;

procedure TDockTabWin.FormResize(Sender: TObject);
begin
  inherited;
 Button1.Left:=ClientWidth+Button1.Width;
 //Button1.Top:=0;
end;

procedure TDockTabWin.FormShow(Sender: TObject);
var
 i:integer;
begin
  inherited;
 for i:=PageControl1.DockClientCount-1 downto 0 do
  with (PageControl1.DockClients[i] as TDockWin) do
   begin
    Visible:=true;
    if not(ToggleMenu=nil) then ToggleMenu.Checked:=true;
   end;
end;

end.
