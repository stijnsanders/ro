unit roPaste;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Menus;

type
  TPasteWin = class(TForm)
    txtData: TMemo;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    udInterval: TUpDown;
    Label2: TLabel;
    btnSingle: TButton;
    MainMenu1: TMainMenu;
    skMenu: TMenuItem;
    center1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure center1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PasteWin: TPasteWin;

implementation

{$R *.dfm}

procedure TPasteWin.FormShow(Sender: TObject);
begin
 txtData.SelStart:=length(txtData.Text);
 //selstart:=0?
end;

procedure TPasteWin.center1Click(Sender: TObject);
begin
 //ModalResult:=mrOk;
 btnOk.Click;
end;

end.
