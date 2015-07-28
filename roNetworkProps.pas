unit roNetworkProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TNetworkPropWin = class(TForm)
    Label1: TLabel;
    aName: TEdit;
    Label2: TLabel;
    aDescription: TMemo;
    aNick: TEdit;
    aAltNick: TEdit;
    aFullName: TEdit;
    aEmail: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    btnConnect: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
  public
    DoConnect:boolean;
  end;

var
  NetworkPropWin: TNetworkPropWin;

implementation

{$R *.dfm}

procedure TNetworkPropWin.FormShow(Sender: TObject);
begin
 aName.SelectAll;
 DoConnect:=false;
end;

procedure TNetworkPropWin.btnConnectClick(Sender: TObject);
begin
 DoConnect:=true;
 ModalResult:=mrOk;
end;

end.
