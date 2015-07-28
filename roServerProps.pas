unit roServerProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TServerPropWin = class(TForm)
    Label1: TLabel;
    aName: TEdit;
    Label2: TLabel;
    aHost: TEdit;
    Label3: TLabel;
    aPort: TEdit;
    Label4: TLabel;
    aDescription: TMemo;
    Label5: TLabel;
    aPorts: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    btnConnect: TButton;
    procedure btnConnectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    DoConnect:boolean;
  end;

var
  ServerPropWin: TServerPropWin;

implementation

{$R *.dfm}

procedure TServerPropWin.btnConnectClick(Sender: TObject);
begin
  DoConnect:=true;
  ModalResult:=mrOk;
end;

procedure TServerPropWin.FormShow(Sender: TObject);
begin
  DoConnect:=false;
end;

end.
