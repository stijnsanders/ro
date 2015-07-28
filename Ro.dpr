program Ro;

{$R 'roHTML.res' 'roHTML.rc'}

uses
  Forms,
  ActiveX,
  VBScript_RegExp_55_TLB in 'VBScript_RegExp_55_TLB.pas',
  SQLite in 'SQLite.pas',
  SQLiteData in 'SQLiteData.pas',
  roMain in 'roMain.pas' {MainWin},
  roDockWin in 'roDockWin.pas' {DockWin},
  roDockJoinWin in 'roDockJoinWin.pas' {DockJoinWin},
  roDockTabWin in 'roDockTabWin.pas' {DockTabWin},
  roWinDock in 'roWinDock.pas' {WindowsDock},
  roChildWin in 'roChildWin.pas' {ChildWin},
  roMsgWin in 'roMsgWin.pas' {MessageWin},
  roGetVal in 'roGetVal.pas' {GetValWin},
  roNetworks in 'roNetworks.pas' {NetworkWin},
  roNetworkProps in 'roNetworkProps.pas' {NetworkPropWin},
  roServerProps in 'roServerProps.pas' {ServerPropWin},
  roConWin in 'roConWin.pas' {ConnectionWin},
  roStuff in 'roStuff.pas',
  roHexTree in 'roHexTree.pas',
  roIdentDock in 'roIdentDock.pas' {IdentDock},
  roLogger in 'roLogger.pas',
  roDocHost in 'roDocHost.pas',
  roPaste in 'roPaste.pas' {PasteWin},
  roSettings in 'roSettings.pas' {SetsWin},
  roHTMLHelp in 'roHTMLHelp.pas',
  roChildFrame in 'roChildFrame.pas' {Frame1: TFrame},
  roSock in 'roSock.pas';

{$R *.RES}

begin
  OleInitialize(nil);
  GetVersion;
  Application.Initialize;
  Application.CreateForm(TMainWin, MainWin);
  Application.CreateForm(TDockTabWin, DockTabWin);
  Application.CreateForm(TWindowsDock, WindowsDock);
  Application.CreateForm(TGetValWin, GetValWin);
  Application.CreateForm(TNetworkPropWin, NetworkPropWin);
  Application.CreateForm(TServerPropWin, ServerPropWin);
  Application.CreateForm(TIdentDock, IdentDock);
  Application.Run;
  OleUninitialize;
end.
