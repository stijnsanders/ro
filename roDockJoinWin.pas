unit roDockJoinWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  roDockWin;

type
  TDockJoinWin = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure FormUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure FormDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure DoFloat(AControl: TControl);
  public
    { Public declarations }
    procedure UpdateCaption(Exclude: TControl);
  end;

var
  DockJoinWin: TDockJoinWin;
  LastDockBounds: TRect;
  LastDockBoundsSet: boolean;

implementation

{$R *.DFM}

procedure TDockJoinWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
 i:integer;
begin
 if DockClientCount = 1 then
  begin
   DoFloat(DockClients[0]);
   LastDockBounds:=BoundsRect;
   LastDockBoundsSet:=true;
   Action:=caFree;
  end
 else
  begin
   for i:=DockClientCount-1 downto 0 do
    with (DockClients[i] as TDockWin) do
     begin
      Visible:=false;
      if not(ToggleMenu=nil) then ToggleMenu.Checked:=false;
     end;
   Action:=caHide;
  end;
end;

procedure TDockJoinWin.FormDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
 UpdateCaption(nil);
 DockManager.ResetBounds(True);
end;

procedure TDockJoinWin.FormUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
begin
 if Client is TDockWin then TDockWin(Client).DockSite:=True;
 if (DockClientCount=2) and (NewTarget <> Self) then
  PostMessage(Handle,WM_CLOSE,0,0);
 UpdateCaption(Client);
end;

procedure TDockJoinWin.FormDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
 Accept:=Source.Control is TDockWin;
end;

procedure TDockJoinWin.FormGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
begin
 CanDock:=DockClient is TDockWin;
end;

procedure TDockJoinWin.DoFloat(AControl: TControl);
{var
 ARect:TRect;
begin

 ARect.TopLeft:=AControl.ClientToScreen(Point(0, 0));
 ARect.BottomRight:=AControl.ClientToScreen(Point(AControl.UndockWidth,
                    AControl.UndockHeight));
 AControl.ManualFloat(ARect);
end;}
begin
 AControl.ManualFloat(BoundsRect);
end;

procedure TDockJoinWin.UpdateCaption(Exclude: TControl);
var
 i:integer;
 s:string;
begin
 s:='';
 for i:=0 to DockClientCount-1 do
  if DockClients[i].Visible and (DockClients[i] <> Exclude) then
   begin
    if not(s='') then s:=s+', ';
    s:=s+TDockWin(DockClients[i]).Caption;
   end;
 Caption:=s;
end;

procedure TDockJoinWin.FormShow(Sender: TObject);
var
 i:integer;
begin
 for i:=DockClientCount-1 downto 0 do
  with (DockClients[i] as TDockWin) do
   begin
    Visible:=true;
    if not(ToggleMenu=nil) then ToggleMenu.Checked:=true;
   end;
end;

end.

