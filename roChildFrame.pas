unit roChildFrame;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, Menus;

type
  TFrame1 = class(TFrame)
    cfPanMain: TPanel;
    cfPanHeader: TPanel;
    cfIconImg: TImage;
    cfPanCaption: TLabel;
    cfMainMenu: TMainMenu;
    cfActionList: TActionList;
    imgResize: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses roMain;

{$R *.dfm}

end.
