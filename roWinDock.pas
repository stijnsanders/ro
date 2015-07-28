unit roWinDock;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  roDockWin, StdCtrls, ExtCtrls, Menus, ImgList, ActnList;

const
  winPanelHeight=25;

type

  TWinButton=class(TObject)
  public
    WinPanel:TPanel;
    WinImage:TImage;
    WinLabel:TLabel;
    Owner:TForm;
    constructor Create(SetOwner:TForm);
    function IsYours(SomeControl:TObject):boolean;
  end;

  TWindowDockResizeAction=(waNone,waImNewHere,waImGonerz);

  TWindowsDock = class(TDockWin)
    Panel1: TPanel;
    Label1: TLabel;
    Image1: TImage;
    ChildWinPm: TPopupMenu;
    Restore1: TMenuItem;
    Minimize1: TMenuItem;
    Maximize1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    ImageList1: TImageList;
    procedure FormResize(Sender: TObject);
    procedure WinClick(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Minimize1Click(Sender: TObject);
    procedure Maximize1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure WinDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    MDIList:TList;
    function GetWinButton(Sender: TObject):TWinButton;
  public
    { Public declarations }
    LastCloseOk:boolean;
    procedure WinButtonsResize(What:TWindowDockResizeAction;Sender:TForm);
  end;

var
  WindowsDock: TWindowsDock;

implementation

uses roMain, roChildwin;

{$R *.DFM}

procedure TWindowsDock.WinButtonsResize(What:TWindowDockResizeAction;Sender:TForm);
var
 i:integer;
 f:TChildWin;
 ax,ay,bx,by,cx,cy,sx:integer;
begin

 case what of
  waNone:;
  waImNewHere:MDIList.Add(Sender);
  waImGonerz:MDIList.Remove(Sender);
 end;

 //systeem om de task bar na te doen...

 if not(Visible) then exit;

 i:=MainWin.MDIChildCount;
 if What=waImGonerz then dec(i); //bij OnClose is de form zelf nog net niet weg, dus

 ax:=0;
 ay:=0;
 //sx?
 cy:=((ClientHeight+2) div (WinPanelHeight+2)); //aantal verticaal
 if cy=0 then cy:=1; //minimum toch een!
 cx:=(i div cy); //hoeveel buttons dan per regel
 if (cx=0) or not((i mod cy)=0) then inc(cx); //naar boven afronden!

 sx:=(ClientWidth div cx);

 //assert(cx*cy>=i);

 //minimum
 if sx<55 then
  begin
   sx:=55;
   cx:=(ClientWidth div sx);
   if cx=0 then cx:=1;
  end;
 //maximum?
 if (cy<3) and (sx>200) then sx:=200;

 bx:=VertScrollBar.Position;
 by:=HorzScrollBar.Position;
 VertScrollBar.Position:=0;
 HorzScrollBar.Position:=0;
 for i:=0 to MDIList.Count-1 do
  begin
   f:=TChildWin(MDIList[i]);
   f.WinButton.WinPanel.SetBounds(
     ax*sx,ay*(WinPanelHeight+2),
     sx-1,WinPanelHeight);
   f.WinButton.WinPanel.TabOrder:=i;//nodig??

   inc(ax);
   if ax=cx then
    begin
     ax:=0;
     inc(ay);
    end;

  end;
 VertScrollBar.Position:=bx;
 HorzScrollBar.Position:=by;
end;

procedure TWindowsDock.FormResize(Sender: TObject);
begin
  inherited;
 WinButtonsResize(waNone,nil);
end;

constructor TWinButton.Create(SetOwner:TForm);
const
 pcount:integer=1;
begin
 Owner:=SetOwner;

 //kan dit beter? heb nu gewoon stuk van de DFM gepakt en herschreven...
 WinPanel:=TPanel.Create(Application);
 with WinPanel do
  begin
   Parent:=WindowsDock;
   Name:='wbp'+inttostr(pcount);
   Caption:='';
   Hint:='';
   inc(pcount);
   OnClick:=WindowsDock.WinClick;
   PopupMenu:=WindowsDock.ChildWinPm;
   ShowHint:=true;
  end;

 WinImage:=TImage.Create(Application);
 with WinImage do
  begin
   Parent:=WinPanel;
   BoundsRect:=Rect(2,2,18,18);
   OnClick:=WindowsDock.WinClick;
   Picture.Assign(SetOwner.Icon);
   PopupMenu:=WindowsDock.ChildWinPm;
  end;

 WinLabel:=TLabel.Create(Application);
 with WinLabel do
  begin
   Parent:=WinPanel;
   AutoSize:=False;
   BoundsRect:=Rect(WinPanelHeight,4,WinPanel.ClientWidth-2,winPanelHeight-2);
   Anchors:=[akLeft,akTop,akRight];
   Caption:=Self.Owner.Caption;
   OnClick:=WindowsDock.WinClick;
   PopupMenu:=WindowsDock.ChildWinPm;
  end;

end;

function TWindowsDock.GetWinButton(Sender: TObject):TWinButton;
var
 i:integer;
 wb:TWinButton;
begin
 i:=0;
 while not(i>=MainWin.MDIChildCount)
  and not((MainWin.MDIChildren[i] as TChildWin).WinButton.IsYours(Sender)) do
   inc(i);
 if not(i>=MainWin.MDIChildCount) then wb:=(MainWin.MDIChildren[i] as TChildWin).WinButton
  else wb:=nil;
 Result:=wb;
end;

function TWinButton.IsYours(SomeControl:TObject):boolean;
begin
 Result:=((WinPanel=SomeControl) or (WinImage=SomeControl) or (WinLabel=SomeControl))
end;

procedure TWindowsDock.WinClick(Sender: TObject);
var
 f:TForm;
begin
 f:=GetWinButton(Sender).Owner;
 if f=nil then exit;
 with f do
  begin
   Visible:=true;
   if ((WindowState=wsMinimized)
    and not(MainWin.ActiveMDIChild.WindowState=wsMaximized)) then
     WindowState:=wsNormal;
   BringToFront;
  end;
end;

procedure TWindowsDock.Close1Click(Sender: TObject);
begin
 GetWinButton(ChildWinPm.PopupComponent).Owner.Close;
end;

procedure TWindowsDock.Minimize1Click(Sender: TObject);
begin
 GetWinButton(ChildWinPm.PopupComponent).Owner.WindowState:=wsMinimized;
end;

procedure TWindowsDock.Maximize1Click(Sender: TObject);
begin
 with GetWinButton(ChildWinPm.PopupComponent).Owner do
  begin
   WindowState:=wsMaximized;
  end;
end;

procedure TWindowsDock.FormCreate(Sender: TObject);
begin
  inherited;
 MDIList:=TList.Create;
 VertScrollBar.Increment:=winPanelHeight+2;
 ToggleMenu:=MainWin.aDWWindows;
end;

procedure TWindowsDock.Restore1Click(Sender: TObject);
begin
 WinClick(ChildWinPm.PopupComponent);
end;

procedure TWindowsDock.WinDblClick(Sender: TObject);
var
 f:TForm;
begin
 f:=GetWinButton(Sender).Owner;
 if f=nil then exit;
 with f do
  begin
   if (WindowState=wsMaximized) then WindowState:=wsNormal;
   //nog?
   //BringToFront;
  end;
end;

procedure TWindowsDock.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
 //let op! onclose ook bij toolbar hide! 
end;

procedure TWindowsDock.FormDestroy(Sender: TObject);
begin
  inherited;
 MDIList.Free;
end;

end.

