unit roDockWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ActnList;

type
  TDockWin = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    function ComputeDockingRect(var DockRect: TRect; MousePos: TPoint): TAlign;
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
  public
    { Public declarations }
    FirstDisplay:boolean;
    ToggleMenu:TAction;
  end;

var
  DockWin: TDockWin;

implementation

uses roDockJoinWin, roMain, roDockTabWin;

{$R *.DFM}

procedure TDockWin.FormShow(Sender: TObject);
begin
 if HostDockSite is TDockJoinWin then
  TDockJoinWin(HostDockSite).UpdateCaption(nil);
 if not(ToggleMenu=nil) then ToggleMenu.Checked:=true;
end;

procedure TDockWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if (HostDockSite is TDockJoinWin) then
  begin
   TDockJoinWin(HostDockSite).UpdateCaption(Self);
   if HostDockSite.VisibleDockClientCount <= 1 then HostDockSite.Hide;
  end;
 if (HostDockSite is TPanel) then
  MainWin.DockHide(HostDockSite as TPanel);
 if not(ToggleMenu=nil) then ToggleMenu.Checked:=false;
 Action := caHide;
end;

procedure TDockWin.FormDockOver(Sender: TObject; Source: TDragDockObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TDockWin);
  if Accept and (ComputeDockingRect(ARect, Point(X, Y)) <> alNone) then
    Source.DockRect := ARect;
end;

function TDockWin.ComputeDockingRect(var DockRect: TRect; MousePos: TPoint): TAlign;
var
  CRect:TRect;
begin
  Result:=alNone;

  //Client/Tabbed
  CRect.TopLeft := Point(ClientWidth div 5, ClientHeight div 5);
  CRect.BottomRight := Point((ClientWidth div 5) * 4, (ClientHeight div 5) * 4);
  if PtInRect(CRect, MousePos) then
   begin
    DockRect:=CRect;
    Result:=alClient;
   end
  else
   begin
    //Left
    CRect.TopLeft:=Point(0,0);
    CRect.BottomRight:=Point(ClientWidth div 5,ClientHeight);
    if PtInRect(CRect,MousePos) then
     begin
      DockRect:=CRect;
      DockRect.Right:=ClientWidth div 2;
      Result:=alLeft;
     end
    else
     begin
      //Top
      CRect.TopLeft:=Point(ClientWidth div 5,0);
      CRect.BottomRight:=Point(ClientWidth div 5*4,ClientHeight div 5);
      if PtInRect(CRect,MousePos) then
       begin
        DockRect:=cRect;
        DockRect.Left:= 0;
        DockRect.Right:=ClientWidth;
        DockRect.Bottom:=ClientHeight div 2;
        Result:=alTop;
       end
      else
       begin
        //Right
        CRect.TopLeft:=Point(ClientWidth div 5*4,0);
        CRect.BottomRight:=Point(ClientWidth,ClientHeight);
        if PtInRect(CRect,MousePos) then
         begin
          DockRect:=CRect;
          DockRect.Left:=ClientWidth div 2;
          Result:=alRight;
         end
        else
         begin
          //Bottom
          CRect.TopLeft:=Point(ClientWidth div 5,ClientHeight div 5*4);
          CRect.BottomRight:=Point(ClientWidth div 5*4,ClientHeight);
          if PtInRect(CRect,MousePos) then
           begin
            DockRect:=CRect;
            DockRect.Left:=0;
            DockRect.Right:=ClientWidth;
            DockRect.Top:=ClientHeight div 2;
            Result:=alBottom;
           end;
         end;
       end;
     end;
   end;
  if not(Result=alNone) then
   begin
    DockRect.TopLeft := ClientToScreen(DockRect.TopLeft);
    DockRect.BottomRight := ClientToScreen(DockRect.BottomRight);
   end;
end;

procedure TDockWin.CMDockClient(var Message: TCMDockClient);
var
 ARect:TRect;
 DockType:TAlign;
 Host:TForm;
 Pt:TPoint;
 a:TWinControl;
begin
 if Message.DockSource.Control is TDockWin then
  begin
   Pt.x:=Message.MousePos.x;
   Pt.y:=Message.MousePos.y;
   DockType:=ComputeDockingRect(ARect, Pt);

   if (HostDockSite is TPanel) then
    begin
     //alClient werkt niet? dan maar manueel
     if DockType=alClient then
      begin
       a:=HostDockSite;
       Host:=TDockTabWin.Create(Application);
       Host.BoundsRect:=BoundsRect;
       ManualDock(TDockTabWin(Host).PageControl1,nil,alClient);
       Message.DockSource.Control.ManualDock(TDockTabWin(Host).PageControl1,nil,alClient);
       Host.ManualDock(a,nil,alClient);
       Host.Visible:=True;
       MainWin.DockResize(a as TPanel);
      end
     else
      Message.DockSource.Control.ManualDock(HostDockSite,nil,DockType);
     Exit;
    end;

   if DockType = alClient then
    begin
     a:=HostDockSite;
     Host:=TDockTabWin.Create(Application);
     if LastDockBoundsSet then Host.BoundsRect:=LastDockBounds
      else Host.BoundsRect:=BoundsRect;
     LastDockBoundsSet:=false;
     ManualDock(TDockTabWin(Host).PageControl1,nil,alClient);
     Message.DockSource.Control.ManualDock(TDockTabWin(Host).PageControl1,nil,alClient);
     Host.ManualDock(a,nil,alClient);
     Host.Visible:=True;
    end
   else
    begin
     Host:=TDockJoinWin.Create(Application);
     Host.BoundsRect:=BoundsRect;
     ManualDock(Host,nil,alNone);
     DockSite:=False;
     Message.DockSource.Control.ManualDock(Host,nil,DockType);
     TDockWin(Message.DockSource.Control).DockSite:=False;
     Host.Visible:=True;
    end;
  end;
end;

procedure TDockWin.FormGetSiteInfo(Sender: TObject; DockClient: TControl;
  var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
begin
 //CanDock:=(DockClient is TDockWin) and (HostDockSite is TPageControl);
 CanDock:=DockClient is TDockWin;
end;

procedure TDockWin.FormCreate(Sender: TObject);
begin
 FirstDisplay:=true;
 ToggleMenu:=nil;
end;

end.
