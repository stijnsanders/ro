unit roGetVal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TGetValWin = class(TForm)
    Val: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GetValWin: TGetValWin;

implementation

{$R *.DFM}

procedure TGetValWin.FormShow(Sender: TObject);
begin
 Val.SelectAll;
 Val.SetFocus;
end;

end.
