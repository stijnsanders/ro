unit roChildWin;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  roWinDock, StdCtrls;
                                
type
  TChildWin = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    SelfSince:TDateTime;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    WinButton:TWinButton;
    constructor Create(AOwner: TComponent); override;
    procedure SetIcon(Index:integer);
    procedure SetCaption(s:string);
    procedure AppDeactivate; virtual;
  end;

var
  ChildWin: TChildWin;

implementation

uses roMain;

{$R *.DFM}

var
 SetState:TWindowState;

constructor TChildWin.Create(AOwner: TComponent);
begin
 if MainWin.ActiveMDIChild=nil then SetState:=wsMaximized else
  SetState:=MainWin.ActiveMDIChild.WindowState;
 //SetState:=wsNormal;
 inherited;
end;

procedure TChildWin.FormCreate(Sender: TObject);
begin
 //Exclude(FFormState,fsVisible);
 WindowState:=SetState;

 WinButton:=TWinButton.Create(Self);
 WindowsDock.WinButtonsResize(waImNewHere,Self);
 SelfSince:=Now;
end;

procedure TChildWin.FormActivate(Sender: TObject);
begin
 with WinButton do
  if not(WinPanel=nil) then
   begin
    WinPanel.BevelOuter:=bvLowered;
    WinPanel.Font.Color:=clCaptionText;
    WinPanel.Color:=clActiveCaption;
   end;
end;

procedure TChildWin.FormDeactivate(Sender: TObject);
begin
 with WinButton do
  if not(WinPanel=nil) then
   begin
    WinPanel.BevelOuter:=bvRaised;
    WinPanel.Font.Color:=clBtnText;
    WinPanel.Color:=clBtnFace;
   end;
end;

procedure TChildWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin

 WindowsDock.LastCloseOk:=not(Action=caNone);

 if not(Action=caNone) then
  begin
   WindowsDock.WinButtonsResize(waImGonerz,Self);
   //WinButton.Destroy doet raar, dan maar hier...
   with WinButton do
    begin
     FreeAndNil(WinLabel);
     FreeAndNil(WinImage);
     FreeAndNil(WinPanel);
    end;
   Action:=caFree;
  end;
end;

procedure TChildWin.SetIcon(Index:integer);
begin
 if not(WinButton.WinImage=nil) then
  begin
   WindowsDock.ImageList1.GetIcon(Index,Icon);
   WinButton.WinImage.Picture.Assign(Icon);
   //WinButton.Font bold italic?
  end;
end;

procedure TChildWin.SetCaption(s:string);
begin
 Caption:=s;
 Self.WinButton.WinLabel.Caption:=StringReplace(s,'&','&&',[rfReplaceAll]);
 Self.WinButton.WinPanel.Hint:=StringReplace(s,'|','',[rfReplaceAll]);
end;

procedure TChildWin.AppDeactivate;
begin
 //??
end;

procedure TChildWin.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{
  with Params do begin
    ExStyle := ExStyle or WS_EX_APPWINDOW;
    WndParent := GetDesktopwindow;
  end;
}  
end;

end.
