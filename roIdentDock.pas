unit roIdentDock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, roDockWin, ComCtrls, StdCtrls, ExtCtrls, OleCtrls,
  SHDocVw, roDocHost, MSHTML, Menus, ActnList, roSock;

type
  TIdentDock = class(TDockWin)
    Web1: TRestrictedWebBrowser;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    aListen: TAction;
    aTTime: TAction;
    aWordWrap: TAction;
    StartStopserver1: TMenuItem;
    N1: TMenuItem;
    imetags1: TMenuItem;
    Wordwrap1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Web1BeforeNavigate2(Sender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure Web1DocumentComplete(Sender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure aListenExecute(Sender: TObject);
    procedure aTTimeExecute(Sender: TObject);
    procedure aWordWrapExecute(Sender: TObject);
  private
    Listener:TThread;
    WebDoc:IHTMLDocument2;
    WebNavOk,WebNavKeepContent:boolean;
    WebNavKeptContent:WideString;
    rotateLine,rotateBlockPos:integer;
    rotateBlock:IHTMLElement;

    procedure Msg(s:string);
  protected
    procedure DoIncoming(var Msg: TMessage); message WM_USER;
  public
    Data,Remote:AnsiString;
  end;

var
  IdentDock: TIdentDock;

implementation

uses roMain, roStuff, roConWin, roHTMLHelp;

{$R *.dfm}

type
  TSThread=class(TThread)
  private
    FServer:TTcpServer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  PSThread=^TSThread;

procedure TIdentDock.FormCreate(Sender: TObject);
begin
  inherited;
 rotateLine:=0;
 rotateBlockPos:=0;
 rotateBlock:=nil;
 Web1.PopupMenu:=PopupMenu1;
 if not(Web1.HandleAllocated) then Web1.HandleNeeded;
 //Web1.OnTranslateAccelerator:=WebTranslateAccelerator;
 WebDoc:=nil;
 WebNavOk:=true;
 WebNavKeepContent:=false;
 Web1.Navigate('res://'+application.ExeName+'/base');

 while WebDoc=nil do Application.ProcessMessages;

 aTTime.Checked:=true;
 SetStyle(WebDoc,'.time',true);

 Listener:=TSThread.Create;
 ToggleMenu:=MainWin.aDWIndentD;
end;

procedure TIdentDock.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
 //let op! wordt ook aangeroepen bij sluiten toolbar, beter OnDestroy 
end;

procedure TIdentDock.DoIncoming(var Msg: TMessage);
var
 cw:TConnectionWin;
begin
 case Msg.LParam of
   1://listening
    begin
     aListen.Caption:='Stop server';
     Self.Msg('Listening on port '+Data);
    end;
   2:
     Self.Msg('Connect '+Remote);
   3://incoming
    begin
     Self.Msg('Request "'+Data+'"');
     cw:=MainWin.HexTree.GetObject(htIdentD+Data);
     if cw=nil then
       Data:=Data+' : ERROR : NO-USER'
     else
       Data:=cw.IdentdReply(Remote);
     Self.Msg('Reply "'+Data+'"');
    end;
   4:
     Self.Msg('Error: '+Data);
 end;
end;

procedure TIdentDock.Web1BeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  inherited;
 if WebNavOk then
  begin
   if not(WebNavKeepContent) then
    begin
     rotateLine:=0;
     rotateBlockPos:=0;
     rotateBlock:=nil;
    end;
   WebNavOk:=false;
   WebDoc:=nil;
   //SetCaption(VarToStr(URL));
  end
 else
  begin
   {
   s:=URL;
   if (length(s)>9) and (copy(s,1,9)='ro:paste?') then
    Com.Text:=Com.Text+URLDecode(copy(s,10,length(s)-9));
   }
   Cancel:=true;
  end;
end;

procedure TIdentDock.Web1DocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  inherited;
 if WebDoc=nil then
 WebDoc:=Web1.Document as IHTMLDocument2;//pdisp?
 //if OnComplete then Do...;

 if WebNavKeepContent then
  begin
   WebNavKeepContent:=false;

   //styles terug zetten
   SetStyle(WebDoc,'.time',aTTime.Checked);
   if aWordWrap.Checked then
    WebDoc.body.style.whiteSpace:='nowrap'
   else
    WebDoc.body.style.whiteSpace:='';

   //content terug zetten
   WebDoc.body.innerHTML:=WebNavKeptContent;

   //rotate terug opzoeken!
   rotateBlock:=WebDoc.all.item(rotateBlockName+IntToStr(rotateBlockPos),EmptyParam) as IHTMLElement;
  end
 else
  begin
   //styles nagaan
   StyleShown(WebDoc,aTTime,'.time');
   aWordWrap.Checked:=not(WebDoc.body.style.whiteSpace='');
  end;

end;

procedure TIdentDock.Msg(s:string);
var
 ScrollY,FirstY:integer;
 rid:string;
 e:IHTMLElement;
begin
 {Memo1.Lines.Add('['+TimeToStr(Now)+'] '+s);
 Memo1.ScrollBy(0,200);}

 //in het begin web1 nog aan het laden
 while WebDoc=nil do Application.ProcessMessages;

 if rotateLine>=rotateBlockSize then
  begin
   rotateLine:=0;
   rotateBlock:=nil;//volgende zoeken!
  end;
 inc(rotateLine);

 if (rotateBlock=nil) then
  begin
   if rotateBlockPos>=rotateBlockCount then rotateBlockPos:=0;
   inc(rotateBlockPos);
   rid:=rotateBlockName+IntToStr(rotateBlockPos);
   //oude wissen
   e:=WebDoc.all.item(rid,EmptyParam) as IHTMLElement;
   if not(e=nil) then e.outerHTML:='';
   //nieuwe bij
   WebDoc.body.insertAdjacentHTML('BeforeEnd','<span id="'+rid+'"></span>');
   rotateBlock:=WebDoc.all.item(rid,EmptyParam) as IHTMLElement;
  end;

 //coors nemen voor nieuwe content
 with (WebDoc.body as IHTMLElement2) do
  begin
   FirstY:=scrollHeight;
   ScrollY:=FirstY-(clientHeight+scrollTop);
  end;

 //assert not(rotateBlock=nil);
 rotateBlock.insertAdjacentHTML('BeforeEnd',SysTimeHTML+HTMLEncode(s)+'<br />');

 //scroll down
 if ScrollY<16 then WebDoc.parentWindow.scrollBy(0,
   (WebDoc.body as IHTMLElement2).scrollHeight-FirstY);

end;

procedure TIdentDock.FormDestroy(Sender: TObject);
begin
  inherited;
  FreeAndNil(Listener);
end;

procedure TIdentDock.FormShow(Sender: TObject);
begin
 //kludge om de WebBrowser te restoren!!

 if WebDoc=nil then WebNavKeptContent:='' else
  WebNavKeptContent:=WebDoc.body.innerHTML;

 inherited;

 if not(Web1.HandleAllocated) then Web1.HandleNeeded;
 WebNavOk:=true;
 WebNavKeepContent:=true;
 Web1.Navigate('res://'+Application.ExeName+'/base');
end;

procedure TIdentDock.aListenExecute(Sender: TObject);
begin
  inherited;
  if Listener=nil then
   begin
    FreeAndNil(Listener);
    aListen.Caption:='Start server';
    Msg('Stopped listening.');
   end
  else
    Listener:=TSThread.Create;
end;

procedure TIdentDock.aTTimeExecute(Sender: TObject);
begin
  inherited;
 ToggleStyle(WebDoc,aTTime,'.time');
end;

procedure TIdentDock.aWordWrapExecute(Sender: TObject);
var
 a:boolean;
begin
  inherited;
 a:=not(aWordWrap.Checked);

 aWordWrap.Checked:=a;
 if a then
  WebDoc.body.style.whiteSpace:='nowrap'
 else
  WebDoc.body.style.whiteSpace:='';
end;

{ TSThread }

constructor TSThread.Create;
begin
  inherited Create(false);
end;

procedure TSThread.Execute;
var
  s:TTcpSocket;
  x:AnsiString;
begin
  FServer:=TTcpServer.Create(AF_INET);//TODO: IPv6
  try
    try
      FServer.Bind('',113);
      FServer.Listen;
      IdentDock.Data:='113';
      PostMessage(IdentDock.Handle,WM_USER,0,1);
      while not Terminated do
       begin
        FServer.WaitForConnection;
        s:=FServer.Accept;
        try
          IdentDock.Remote:=s.HostName+':'+IntToStr(s.Port);
          PostMessage(IdentDock.Handle,WM_USER,0,2);
          SetLength(x,$10000);
          IdentDock.Data:=Trim(Copy(x,1,s.ReceiveBuf(x[1],$10000)));
          SendMessage(IdentDock.Handle,WM_USER,0,3);
          s.SendBuf(IdentDock.Data[1],Length(IdentDock.Data));
        finally
          s.Free;
        end;
       end;
    except
      on e:Exception do
       begin
        IdentDock.Data:=e.Message;//e.ClassName
        SendMessage(IdentDock.Handle,WM_USER,0,4);
       end;
    end;
  finally
    FreeAndNil(FServer);
  end;
end;

destructor TSThread.Destroy;
begin
  if FServer<>nil then closesocket(FServer.Handle);
  inherited;
end;

end.
