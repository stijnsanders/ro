unit roSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, roDocHost, ExtCtrls, StdCtrls;

type
  TSetsWin = class(TForm)
    Button1: TButton;
    Button2: TButton;
    panWeb: TPanel;
    Web1: TRestrictedWebBrowser;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetsWin: TSetsWin;

implementation

{$R *.dfm}

procedure TSetsWin.FormShow(Sender: TObject);
begin
 //?
 Application.ProcessMessages;
 Web1.Navigate('res://'+Application.ExeName+'/settings');
end;

end.
