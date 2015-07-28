unit roEnter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, roDockWin, StdCtrls;

type
  TEnterDock = class(TDockWin)
    procedure FormShow(Sender: TObject);
    procedure ComKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EnterDock: TEnterDock;

implementation

uses roMain, roConWin;

{$R *.dfm}

procedure TEnterDock.FormShow(Sender: TObject);
begin
  inherited;
  Com.SetFocus;
end;

procedure TEnterDock.ComKeyPress(Sender: TObject; var Key: Char);
var
 f:TForm;
begin
  inherited;
  case Key of
   #9:
    begin
     //Com.Text:=Com.Text+'/';
     //DO COMPLETION!!!
     Key:=#0;
    end;
   #13:
    begin
     //enter!

     f:=MainWin.ActiveMDIChild;
     if f is TConnectionWin then (f as TConnectionWin).DoCommand(Com.Text);

     Com.SelectAll;
     Key:=#0;
    end;
  end;
end;

end.
