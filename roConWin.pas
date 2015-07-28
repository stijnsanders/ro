unit roConWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, roChildWin, OleCtrls, SHDocVw, Menus, ActnList, MSHTML,
  StdCtrls, roHexTree, roStuff, roLogger, roDocHost, ComCtrls, ToolWin,
  roSock;

type
  TConnectionWin = class(TChildWin)
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    aConnect: TAction;
    aDisconnect: TAction;
    Connection1: TMenuItem;
    aConnect1: TMenuItem;
    aDisconnect1: TMenuItem;
    OpenDialog1: TOpenDialog;
    aTTime: TAction;
    aTCode: TAction;
    aTSystem: TAction;
    aTCode1: TMenuItem;
    aTSystem1: TMenuItem;
    Com: TMemo;
    Web1: TRestrictedWebBrowser;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    N1: TMenuItem;
    Selectall1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Web1BeforeNavigate2(Sender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure FormCreate(Sender: TObject);
    procedure aConnectExecute(Sender: TObject);
    procedure aDisconnectExecute(Sender: TObject);
    procedure Web1DocumentComplete(Sender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure aTTimeExecute(Sender: TObject);
    procedure aTCodeExecute(Sender: TObject);
    procedure aTSystemExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function WebTranslateAccelerator(Sender:TObject;const lpMsg: PMSG):boolean;
    procedure ComChange(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure ComKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    WebNavOk,LastWasPing:boolean;
    MotdCount:integer;
    inbuffer:AnsiString;
    WebDoc:IHTMLDocument2;
    TriedNick,WasHigh:boolean;
    MsgWindows:TList;
    PingElem:IHTMLElement;
    PingCount,rotateLine,rotateBlockPos:integer;
    rotateBlock:IHTMLElement;
    History:TStringList;
    HistIndex:integer;
    HistCom:string;

    ServerParams,ServerProperties:string;
    ServerStartUserMode:integer;

    RemoteHost,UserName1,UserName2,IdentDid,ModeFlags:string;
    RemotePort:word;
    Logger:TRoLogger;

    procedure Msg(pl:TRoParsedLine;IsPingMsg:boolean=false);
    procedure MsgError(s:string;code:string='');
    procedure DoIncoming(s:string;loopback:boolean=true);
    procedure DoCaption;
    procedure DoUserModes(s:string);
    procedure DoSetIcon(isHighNow:boolean);
  protected
    procedure csError(var Msg: TMessage); message WM_TCP_ERROR;
    procedure csConnect(var Msg: TMessage); message WM_TCP_CONNECT;
    procedure csDisconnect(var Msg: TMessage); message WM_TCP_DISCONNECT;
    procedure csReceive(var Msg: TMessage); message WM_TCP_DATA;
  public
    { Public declarations }

    cs:TTcpSocket;
    ConnectOnComplete:boolean;
    ConSince:TDateTime;

    NetworkId,ServerId:integer;
    ServerName,NetworkName,NoticeServerName:string;

    Nick,AltNicks,FullName,EMail,LastNick:string;
    HexTree:THexTree;

    procedure DoCommand(s:string);
    procedure DoConnect;
    procedure NetSend(s:string);
    procedure DataByServer(id:integer);
    procedure DataByNetwork(id:integer);
    function IdentdReply(Remote:string):string;
    procedure LogUserComment(const target,s:string);

    function FindTarget(target:string;CreateIfNotFound,FocusOnCreate:boolean):TForm;

    procedure AppDeactivate; override;
    procedure ReleaseMsgWin(f:TForm);
    procedure PreClose;
    procedure DoDebugLog;
    function GetCompleted(from:string;exclude:TChildWin=nil):string;
  end;

implementation

uses SQLiteData, roMain, roMsgWin, roHTMLHelp;

{$R *.dfm}

procedure TConnectionWin.FormCreate(Sender: TObject);
begin
  inherited;
  cs:=TTcpSocket.Create(AF_INET);//TODO: IPv6
  ServerId:=-1;
  ServerName:='';
  NoticeServerName:='';//om notices van te herkennen
  ServerStartUserMode:=8;
  NetworkId:=-1;
  NetworkName:='';
  RemoteHost:='';
  RemotePort:=6667;
  UserName1:='';
  UserName2:='';
  FullName:='';
  Nick:='';
  WebDoc:=nil;
  WebNavOk:=false;
  History:=TStringList.Create;
  Web1.OnTranslateAccelerator:=WebTranslateAccelerator;
  TriedNick:=false;
  Logger:=nil;
  HexTree:=THexTree.Create;
  ConnectOnComplete:=false;
  MsgWindows:=TList.Create;
  MainWin.ConWindows.Add(Self);
  LastWasPing:=false;
  PingElem:=nil;
  PingCount:=0;
  rotateLine:=0;
  rotateBlockPos:=0;
  rotateBlock:=nil;
  MotdCount:=1;
  WasHigh:=false;
end;

procedure TConnectionWin.FormShow(Sender: TObject);
begin
  inherited;
  if not(Web1.HandleAllocated) then Web1.HandleNeeded;
  WebNavOK:=true;
  Web1.Navigate('res://'+application.ExeName+'/base');
end;

procedure TConnectionWin.Web1BeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
 s:string;  
begin
  inherited;
  if WebNavOk then
   begin
    rotateLine:=0;
    rotateBlockPos:=0;
    rotateBlock:=nil;
    WebNavOk:=false;
    WebDoc:=nil;
    //SetCaption(VarToStr(URL));
    //Cancel:=true;
   end
  else
   begin
    s:=URL;
    if (length(s)>9) and (copy(s,1,9)='ro:paste?') then
      Com.Text:=Com.Text+URLDecode(copy(s,10,length(s)-9));
    Cancel:=true;
   end;
end;

procedure TConnectionWin.csError(var Msg: TMessage);
var
  pl:TRoParsedLine;
  x:AnsiString;
begin
  inherited;
  SetLength(x,Msg.LParam);
  Move(pointer(Msg.WParam)^,x[1],Msg.LParam);
  pl:=TRoParsedLine.Create('Error: '+x);
  pl.MessageType:=cmNetwork;
  //pl.code:=IntToStr(ErrorCode);
  Self.Msg(pl);
  pl.Free;
  //ErrorCode:=0;
  //Socket.Close;
  //disconnect?
end;

procedure TConnectionWin.MsgError(s:string;code:string='');
var
  pl:TRoErrorLine;
begin
  pl:=TRoErrorLine.Create(s,code);
  Msg(pl);
  pl.Free;
end;

procedure TConnectionWin.Msg(pl:TRoParsedLine;IsPingMsg:boolean=false);
var
 ScrollY,FirstY:integer;
 e:IHTMLElement;
 mid,rid:string;
begin

 if LastWasPing and not(IsPingMsg) and not(PingElem=nil) then
  begin
   PingElem.outerHTML:=PingElem.innerHTML;
   PingElem:=nil;
   PingCount:=0;
  end;
 if IsPingMsg and (PingCount>0) then
  pl.text:=pl.text+' (hidden '+inttostr(PingCount)+' similar)';

 pl.PrepHTML;

 //in het begin web1 nog aan het laden?
 while WebDoc=nil do Application.ProcessMessages;


 //motd als geheel meeroteren, niet tellen als lijn
 //ping ook niet meetellen als lijn (want worden bij niets tussen in PingElem getoond)
 if not(pl.MessageType=cmMotd) and not(IsPingMsg) then
  begin
   if rotateLine>=rotateBlockSize then
    begin
     rotateLine:=0;
     rotateBlock:=nil;//volgende zoeken!
    end;
   inc(rotateLine);
  end;

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

 if (pl.MessageType=cmMotd) then
  begin
   mid:='motd'+inttostr(MotdCount);
   e:=WebDoc.all.item(mid,EmptyParam) as IHTMLElement;
   if e=nil then
    begin
     //nieuw motd blok
     rotateBlock.insertAdjacentHTML('BeforeEnd',
      StringReplace(MainWin.GetResHTML('motd'),
       '$1',IntToStr(MotdCount),[rfReplaceAll]));
     e:=WebDoc.all.item(mid,EmptyParam) as IHTMLElement;
    end;
   //assert not(e=nil)
   e.insertAdjacentHTML('BeforeEnd',pl.GetHTML);
  end
 else
  begin
   if IsPingMsg then
    begin
     if PingElem=nil then
      begin
       rotateBlock.insertAdjacentHTML('BeforeEnd','<span id="pingMsg"></span>');
       PingElem:=WebDoc.all.item('pingMsg',EmptyParam) as IHTMLElement;
      end;
     //assert not PingElem=nil
     PingElem.innerHTML:=pl.GetHTML;
     inc(PingCount);
    end
   else
    rotateBlock.insertAdjacentHTML('BeforeEnd',pl.GetHTML);
  end;

 if pl.MessageType in [cmIrc,cmNetwork,cmError] then
  begin
   DoSetIcon(pl.MessageType in [cmNetwork,cmError]);
  end;

 //scroll down
 if ScrollY<16 then WebDoc.parentWindow.scrollBy(0,
   (WebDoc.body as IHTMLElement2).scrollHeight-FirstY);

 LastWasPing:=IsPingMsg;
end;

procedure TConnectionWin.DoCommand(s:string);
var
 command:string;
type
 TCommands=(
   icDebug,

   icJoin,icMsg,icQuery,icCtcp,icDCC,
   icAll,icAllMsg,icAllMe,icAllNotice,
   icAllCons,
   icLeave,icPart,icRaw,icQuote,
   icNew,icShow,icSwitch,
   icConnect,icMode,icNick,icUser,icTopic,
   icPing,icNotice,icKick,
   icWho,icWhoIs,icWhoWas,
   icDisconnect,icQuit,
   icInvite,icAway,
   icClose,icExit,icEcho,icRotate,icClear,
   icUp,icLog,icLine,
   icDescribe,

   //nieuwe hier

   icUnknown
 );
const
  {
   'DEBUG',
   'ICON',
 NAMES,LIST,MOTD,LUSERS,VERSION,STATS,LINKS,TIME
 SQUIT,TRACE,ADMIN,INFO,SQUERY,KILL
 }

 Commands:array[TCommands] of string=(
  'DEBUG',
  'JOIN','MSG','QUERY','CTCP','DCC',
  'ALL','AMSG','AME','ANOTICE',
  'ACON',
  'LEAVE','PART','RAW','QUOTE',
  'NEW','SHOW','SWITCH',
  'CONNECT','MODE','NICK','USER','TOPIC',
  'PING','NOTICE','KICK',
  'WHO','WHOIS','WHOWAS',
  'DISCONNECT','QUIT',
  'INVITE','AWAY',
  'CLOSE','EXIT','ECHO','ROTATE','CLEAR',
  'UP','LOG','LINE',
  'DESCRIBE',

  //nieuwe hier
  ''
 );
var
 IsCommand:TCommands;
 p1,p2:string;
 pl:TRoParsedLine;
 pn:TRoNetworkLine;
 i,j:integer;
 a:array of string;
 date:TDateTime;
 datex:array[0..3] of word absolute date;
 e:IHTMLElement;
begin

 try

 //scripting?
 //filters?
 //logging hier of bij netsend?

 if not(s='') then
  begin
   if s[1]=CommandPrefix then
    begin

     //commandchars can prefix without whitespace
     if s[2] in commandchars then
      begin
       command:=s[2];
       i:=3;
       while (i<=length(s)) and (s[i] in WhiteSpace) do inc(i);
       s:=copy(s,i,length(s)-i+1);
      end
     else
      begin
       s:=copy(s,2,length(s)-1);
       command:=UpperCase(cutNext(s));
      end;

     if length(command)=0 then IsCommand:=icMsg else //default
     if length(command)=1 then
      begin
       case UpCase(command[1]) of
        'A':IsCommand:=icAway;
        'C':IsCommand:=icCtcp;
        'D':IsCommand:=icDCC;
        'E':IsCommand:=icEcho;
        'H':IsCommand:=icLine;
        'I':IsCommand:=icInvite;
        'J':IsCommand:=icJoin;
        'K':IsCommand:=icKick;
        'L':IsCommand:=icLeave;
        'M':IsCommand:=icMode;
        'N':IsCommand:=icNotice;
        'P':IsCommand:=icPart;
        'Q':IsCommand:=icQuit;
        'R':IsCommand:=icRaw;
        'T':IsCommand:=icTopic;
        'U':IsCommand:=icUp;
        'W':IsCommand:=icWhoIs;
        //see CommandChars also
        '*':IsCommand:=icAllCons;
        else IsCommand:=icUnknown;
       end;
       command:=Commands[IsCommand];
      end
     else
      begin
       IsCommand:=TCommands(0);
       while not(IsCommand=icUnknown) and not(Commands[IsCommand]=command) do
        inc(IsCommand);
      end;

     case IsCommand of

      icDebug:
       begin
        pl:=TRoParsedLine.Create(s);
        pl.MessageType:=cmNetwork;
        pl.text:='<Debug info>'; Msg(pl);
        pl.text:='Main.Since='+SinceToStr(MainWin.AppSince); Msg(pl);
        pl.text:='SelfSince='+SinceToStr(SelfSince); Msg(pl);
        pl.text:='ConSince='+SinceToStr(ConSince); Msg(pl);
        pl.text:='MotdCount='+IntToStr(MotdCount); Msg(pl);
        pl.text:='MsgWindows.Count='+IntToStr(MsgWindows.Count); Msg(pl);
        pl.text:='PingCount='+IntToStr(PingCount); Msg(pl);
        pl.text:='rotateLine='+IntToStr(rotateLine); Msg(pl);
        pl.text:='rotateBlockPos='+IntToStr(rotateBlockPos); Msg(pl);
        pl.text:='IdentDid='+IdentDid; Msg(pl);
        p1:='';
        for i:=0 to MsgWindows.Count-1 do
         begin
          if not(p1='') then p1:=p1+' ';
          p1:=p1+TMessageWin(MsgWindows[i]).GetTarget;
         end;
        pl.text:='*='+p1; Msg(pl);
        if Logger=nil then
         begin
          pl.text:='Log=none'; Msg(pl);
         end
        else
         begin
          pl.text:='Log='+Logger.FileName; Msg(pl);
          pl.text:='Logged='+IntToStr(Logger.logged); Msg(pl);
         end;
        pl.text:='</Debug info>'; Msg(pl);
        pl.Free;
       end;

      icRaw,icQuote:
       begin
        DoIncoming(s);
        NetSend(s);
       end;
      icNew,icQuery:
       begin
        p1:=cutNext(s);
        if p1='' then
         MsgError(command+' needs target')
        else
         begin
          repeat
           FindTarget(p1,true,true);
           p1:=cutNext(s);
          until p1='';
         end;
       end;
      icShow,icSwitch:
       begin
        p1:=cutNext(s);
        if p1='' then
         MsgError(command+' needs target')
        else
         with FindTarget(p1,true,false) do
          begin
           if ((WindowState=wsMinimized)
            and not(MainWin.ActiveMDIChild.WindowState=wsMaximized)) then
             WindowState:=wsNormal;
           BringToFront;
          end;
       end;

      icTopic,icLeave,icPart:
       begin
        p1:=cutNext(s);
        if p1='' then
         //exception??
         MsgError(command+' needs target')
        else
         begin
          p1:=command+' '+p1+' :'+s;
          //DoIncoming(p1);
          NetSend(p1);
         end;
       end;

      icNick:
       begin
        LastNick:=Nick;
        //doincoming loopback?
        NetSend('NICK '+s);
        TriedNick:=true;
        Nick:=s;
        DoCaption;
       end;
      icUser:
       begin
        p1:=cutNext(s);
        i:=1;
        while (i<=length(p1)) and not(p1[i]='@') do inc(i);
        //USER <user> <mode> <unused> <realname>
        UserName1:=copy(p1,1,i-1);
        UserName2:=copy(p1,i+1,length(p1)-i);

        if UserName2='' then
         begin
          //getcomputername?
          i:=1024;
          SetLength(UserName2,i);
          GetComputerName(@UserName2[1],cardinal(i));
          SetLength(UserName2,i);
         end;

        ServerStartUserMode:=8;//??
        FullName:=s;

        //NetSend?
       end;

      icMsg:
       begin
        p1:=cutNext(s);
        p2:='PRIVMSG '+p1+' :'+s;
        DoIncoming(p2);
        NetSend(p2);
       end;
      icNotice:
       begin
        p1:=cutNext(s);
        p2:='NOTICE '+p1+' :'+s;
        DoIncoming(p2);
        NetSend(p2);
       end;
      icDescribe:
       begin
        p1:=cutNext(s);
        p2:='PRIVMSG '+p1+' :'#1'ACTION '+s+#1;
        DoIncoming(p2);
        NetSend(p2);
       end;
      icKick:
       begin
        p1:=cutNext(s);
        if not(p1='') and (p1[1] in ChannelPrefix) then
         begin
          //KICK chan user reason
          p2:=p1;
          p1:=cutNext(s);
         end
        else
         begin
          //KICK user chan reason
          p2:=cutNext(s);
         end;
        //doincoming loopback?
        NetSend('KICK '+p2+' '+p1+' :'+s);
       end;
      icJoin:
       begin
        //comma separated
        i:=1;
        setlength(a,0);
        while (i<=length(s)) do
         begin
          j:=i;
          while (i<=length(s)) and not(s[i] in UserSeparators) do inc(i);
          p1:=copy(s,j,i-j);
          if not(p1='') then
           begin
            if not(p1[1] in ChannelPrefix) and (length(a)>0) then
             begin
              //channel key!
              a[length(a)-1]:=a[length(a)-1]+' '+p1;
             end
            else
             begin
              //channel!
              setlength(a,length(a)+1);
              a[length(a)-1]:=p1;
             end;
           end;
          inc(i);
         end;
        for i:=0 to length(a)-1 do
         begin
          NetSend('JOIN '+a[i]);
          p1:=cutNext(a[i]);
          NetSend('MODE '+p1);
          FindTarget(p1,true,true);
         end;
       end;
      icMode:
       begin
        p1:=command+' '+s;
        //DoIncoming(p1);
        NetSend(p1);
       end;
      icWho,icWhoIs,icWhoWas:
       begin
        p1:=s;
        FindTarget(cutNext(p1),true,true);
        p1:=command+' '+s;
        //DoIncoming(p1);
        NetSend(p1);
       end;


      //to all channels
      icAll:
       for i:=0 to MsgWindows.Count-1 do
        TMessageWin(MsgWindows[i]).DoAll(CommandPrefix+s);
      icAllMsg:
       for i:=0 to MsgWindows.Count-1 do
        TMessageWin(MsgWindows[i]).DoAll(s);
      icAllMe:
       for i:=0 to MsgWindows.Count-1 do
        TMessageWin(MsgWindows[i]).DoAll(CommandPrefix+'ME '+s);
      icAllNotice:
       for i:=0 to MsgWindows.Count-1 do
        TMessageWin(MsgWindows[i]).DoAll(CommandPrefix+'NOTICE '+s);

      icAllCons:
       for i:=0 to MainWin.ConWindows.Count-1 do
        TConnectionWin(MainWin.ConWindows[i]).DoCommand(s);

      icInvite:
       begin
        p1:=cutNext(s);
        if not(p1='') and (p1[1] in ChannelPrefix) then
         begin
          //eerst een channel, dus channel nemen (p2) en users inviten (p1)
          p2:=p1;
          while not(s='') do
           begin
            p1:=cutNext(s);
            if not(p1='') and (p1[1] in ChannelPrefix) then
             p2:=p1
            else
             NetSend('INVITE '+p1+' '+p2);
           end;
         end
        else
         begin
          while not(s='') do
           begin
            //eerst channel zoeken
            p2:=cutNext(s);
            while not(s='') and ((p2='') or not(p2[1] in ChannelPrefix)) do
             begin
              p1:=p1+' '+p2;//opslaan in p1
              p2:=cutNext(s);
             end;
            //geen gevonden dan assert self
            //if p2='' then p2:=Target;
            while not(p1='') do NetSend('INVITE '+cutNext(p1)+' '+p2);
           end;
         end;
        //DoIncoming?
       end;
      icAway:
       begin
        p1:='AWAY :'+s;
        DoIncoming(p1);
        NetSend(p1);
       end;

      icPing:
       begin
        p1:=cutNext(s);
        if p1='' then
         MsgError(command+' needs target')
        else
         begin
          date:=Now;
          p1:='PRIVMSG '+p1+' :'#1'PING x'+
           inttohex(datex[0],4)+'x'+
           inttohex(datex[1],4)+'x'+
           inttohex(datex[2],4)+'x'+
           inttohex(datex[3],4)+#1;
          DoIncoming(p1);
          NetSend(p1);
         end;
       end;

      icCtcp:
       begin
        p1:=cutNext(s);
        if p1='' then
         MsgError(command+' needs target')
        else
         begin
          p2:=cutNext(s);
          p1:='PRIVMSG '+p1+' :'#1+UpperCase(p2)+' '+s+#1;
          DoIncoming(p1);
          NetSend(p1);
         end;
       end;

      icDCC:
       MsgError('not implemented yet');

      icConnect:
       begin
        if cs.Connected then
         begin
          cs.Disconnect;
          Application.ProcessMessages;//??
         end;
        if not(s='') then
         begin
          NetworkId:=-1;
          NetworkName:='';
          ServerId:=-1;

          i:=1;
          while not(i>length(s)) and not(s[i] in [' ',':']) do inc(i);
          if i>length(s) then
           begin
            ServerName:=s;
            s:='';
           end
          else
           begin
            ServerName:=copy(s,1,i-1);
            s:=copy(s,i+1,length(s)-i);
           end;

          RemoteHost:=ServerName;
          RemotePort:=6667;
          if not(s='') then
           begin
            RemotePort:=StrToInt(cutNext(s));//try except?
            if not(s='') then
             begin
              Nick:=cutNext(s);
              if not(s='') then AltNicks:=s;
             end;
           end;
          //server gegevens opslaan db?
          DoCaption;
         end;
        pn:=TRoNetworkLine.Create(cs,
         'Connecting... '+RemoteHost+':'+IntToStr(RemotePort));
        Msg(pn);
        pn.Free;
        //cs.Connect(RemoteHost,RemotePort);
        TTcpThread.Create(cs,Self.Handle,RemoteHost,RemotePort);
       end;
      icDisconnect:
       begin
        //is iets anders dan quit!!
        cs.Disconnect;
       end;

      icClose:
       begin
        //verifs?
        Close;
       end;
      icExit:
       begin
        //verifs?
        //MainWin.Close;//geeft AV's!
        MainWin.ExitCommandCalled:=true;//dan maar zo met de idle
       end;
      icQuit:
       begin
        //verifs?
        NetSend('QUIT :'+s);
        //weergeven?
        BringToFront;//??
       end;
      icEcho:
       begin
        pl:=TRoParsedLine.Create(s);
        //prefix?
        Msg(pl);
        pl.Free;
       end;
      icRotate:
       begin
        //check?
        for i:=1 to StrToInt(cutNext(s)) do
         begin
          if rotateLine>=rotateBlockSize then
           begin
            rotateLine:=0;
            if rotateBlockPos>=rotateBlockCount then rotateBlockPos:=0;
            inc(rotateBlockPos);
            p1:=rotateBlockName+IntToStr(rotateBlockPos);
            e:=WebDoc.all.item(p1,EmptyParam) as IHTMLElement;
            if not(e=nil) then e.outerHTML:='';
            WebDoc.body.insertAdjacentHTML('BeforeEnd','<span id="'+p1+'"></span>');
            rotateBlock:=WebDoc.all.item(p1,EmptyParam) as IHTMLElement;
           end;
          inc(rotateLine);
         end;
       end;
      icClear:
       begin
        //current rotateBlockPos?
        for i:=1 to rotateBlockCount do
         begin
          e:=WebDoc.all.item(
           rotateBlockName+IntToStr(i),EmptyParam) as IHTMLElement;
          if not(e=nil) then e.outerHTML:='';
         end;
        rotateLine:=0;
        rotateBlockPos:=0;
        rotateBlock:=nil;
       end;

      icUp:
       begin
        MainWin.aNetwork.Execute;
       end;
      icLog:LogUserComment('',s);
      icLine:rotateBlock.insertAdjacentHTML('BeforeEnd','<hr />');

      else
       begin
        p1:=command+' '+s;
        DoIncoming(p1);
        NetSend(p1);
       end;
     end;

    end
   else
    begin
     //internal error?
    end;
  end;

 except
  on e:Exception do
   MsgError(e.Message,e.ClassName);
 end;

end;

procedure TConnectionWin.csConnect(var Msg: TMessage);
var
 pl:TRoParsedLine;
begin
  inherited;
 inbuffer:='';
 ServerProperties:='';
 ServerParams:='';
 ModeFlags:='';
 WasHigh:=false;
 ConSince:=Now;

 //logger thread opzetten
 Logger:=TRoLogger.Create(true);
 Logger.logdir:=MainWin.GetLogDir;
 Logger.Resume;

 IdentDid:=IntToStr(cs.LocalPort)+' , '+IntToStr(cs.Port);
 MainWin.HexTree.SetObject(htIdentD+IdentDid,Self);
 pl:=TRoNetworkLine.Create(cs,'Connected '+RemoteHost+':'+IntToStr(RemotePort));
 Self.Msg(pl);
 pl.Free;

 //checks?

 if UserName1='' then UserName1:=Nick;
 if UserName1='' then UserName1:='roIRC';
 if UserName2='' then UserName2:=cs.LocalHostName;
 if FullName='' then FullName:=AppName;

 NetSend('USER '+
  UserName1+' '+inttostr(ServerStartUserMode)+' "'+UserName2+'" :'+FullName);
 NetSend('NICK '+Nick);
 //schijnt omgekeerd te moeten?

 //OPER en PASS commando's?
end;

procedure TConnectionWin.csDisconnect(var Msg: TMessage);
var
 pl:TRoNetworkLine;
 x:AnsiString;
begin
  inherited;
  SetLength(x,Msg.LParam);
  Move(pointer(Msg.WParam)^,x[1],Msg.LParam);
  
 //assert altijd aangeroepen als de verbinding ook sluit (onerror?)
 MainWin.HexTree.SetObject(htIdentD+IdentDid,nil);
 pl:=TRoNetworkLine.Create(cs,
  'Disconnected ('+RemoteHost+' '+x+')');
 Self.Msg(pl);
 pl.Free;
 //reconnect !!!
 //tenzij echt moeten closen want sluiten
 if not(Logger=nil) then
  begin
   Logger.Terminate;
   Logger.WaitFor;
   Logger.Free;
   Logger:=nil;
  end;
end;

procedure TConnectionWin.NetSend(s:string);
var
  z:AnsiString;
begin
 if not(Logger=nil) then Logger.WriteLog(s);
 z:=s+#13#10;
 cs.SendBuf(z[1],Length(z));
 //add to logs!
end;

procedure TConnectionWin.DataByServer(id:integer);
var
  rs:TSQLiteStatement;
begin
  ServerId:=id;
  rs:=TSQLiteStatement.Create(MainWin.dbCon,
    'SELECT * FROM Server WHERE id=?',[id]);
  try
    RemoteHost:=rs.GetStr('host');
    RemotePort:=rs.GetInt('defaultport');
    //andere poorten bij 2nd pass?
    ServerName:=rs.GetStr('name');
    ServerStartUserMode:=rs.GetInt('connectusermode');
    if NetworkId=-1 then
      DataByNetwork(rs.GetInt('network_id'))
    else
      DoCaption;
  finally
    rs.Free;
  end;
end;

procedure TConnectionWin.DataByNetwork(id:integer);
var
  rs:TSQLiteStatement;
  i:integer;
begin
  NetworkId:=id;
  rs:=TSQLiteStatement.Create(MainWin.dbCon,
    'SELECT * FROM Network WHERE id=?',[id]);
  try
    NetworkName:=rs.GetStr('name');
    Nick:=rs.GetStr('nick');
    AltNicks:=rs.GetStr('altnicks');
    FullName:=rs.GetStr('fullname');
    EMail:=rs.GetStr('email');
    i:=1;
    while (i<=length(EMail)) and not(EMail[i]='@') do inc(i);
    //USER <user> <mode> <unused> <realname>
    UserName1:=copy(EMail,1,i-1);
    UserName2:=copy(EMail,i+1,length(EMail)-i);
    //identd hier?
  finally
    rs.Free;
  end;
  if ServerId=-1 then
   begin
    //select server, minst recent mee geconnecteerd?
    rs:=TSQLiteStatement.Create(MainWin.dbCon,
      'SELECT id FROM Server WHERE network_id=? ORDER BY id LIMIT 1,1',
      [NetworkID]);
    try
      i:=rs.GetInt('id');
    finally
      rs.Free;
    end;
    DataByServer(i);
    MainWin.dbCon.Execute(
      'UPDATE Server SET lastconnect=? WHERE id=?',
      [VarFromDateTime(Now),ServerId]);
   end
  else
   DoCaption;
end;

procedure TConnectionWin.DoConnect;
var
 pl:TRoParsedLine;
begin
 try
   //cs.Connect(RemoteHost,RemotePort);
   TTcpThread.Create(cs,Self.Handle,RemoteHost,RemotePort);
 except
   on e:Exception do
    begin
     pl:=TRoParsedLine.Create('Error: '+e.Message);
     pl.MessageType:=cmNetwork;
     Msg(pl);
     pl.Free;
    end;
 end;
end;

procedure TConnectionWin.aConnectExecute(Sender: TObject);
begin
  inherited;
  if not(cs.Connected) then DoConnect;
end;

procedure TConnectionWin.aDisconnectExecute(Sender: TObject);
begin
  inherited;
  cs.Disconnect;
end;

procedure TConnectionWin.csReceive(var Msg: TMessage);
var
  s:AnsiString;
  i:integer;
begin
  inherited;
  SetLength(s,Msg.LParam);
  Move(pointer(Msg.WParam)^,s[1],Msg.LParam);

  inbuffer:=inbuffer+s;
  repeat
   i:=1;
   while (i<=length(inbuffer)) and not(inbuffer[i] in [#10,#13]) do inc(i);
   if i<=length(inbuffer) then
    begin
     s:=copy(inbuffer,1,i-1);
     if not(Logger=nil) then Logger.WriteLog(s);
     DoIncoming(s,false);
     if (i<length(inbuffer)) and (inbuffer[i]=#13) and (inbuffer[i+1]=#10) then inc(i);
     inbuffer:=copy(inbuffer,i+1,length(inbuffer)-i);
     i:=1;
    end;
  until i>length(inbuffer);
end;

procedure TConnectionWin.DoIncoming(s:string;loopback:boolean=true);
type
  TInboundCommands=(
    icPing,
    icMode,
    icPrivMsg,icNotice,
    icError,
    icJoin,icPart,icKick,
    icTopic,
    icQuit,icKill,icNick,
    icInvite,
    //nieuwe hier (geen displaycode)
    icUnknownCommand
  );
const
  InboundCommandStrings:array[TInboundCommands] of string=(
    'PING',
    'MODE',
    'PRIVMSG','NOTICE',
    'ERROR',
    'JOIN','PART','KICK',
    'TOPIC',
    'QUIT','KILL','NICK',
    'INVITE',
    //nieuwe hier!
    ''
  );
var
  incode:TInboundCommands;
  codenr:integer;
  mw:TMessageWin;
  pl:TRoParsedLine;
  p1:string;
  i:integer;
  WasTriedNick:boolean;
begin

  //loggen, zie OnRead!
  //if not(loopback) and not(Logger=nil) then Logger.WriteLog(s);

  //filteren!
  //nog dingen van de API?

  try

  pl:=TRoParsedLine.Create('');

  if s<>'' then
  begin

   WasTriedNick:=TriedNick;
   TriedNick:=false;

   pl.Parse(s);

   //code nummer?
   if (length(pl.code)=3)
     and (pl.code[1] in ['0'..'9'])
     and (pl.code[2] in ['0'..'9'])
     and (pl.code[3] in ['0'..'9']) then
    begin
     codenr:=
      (byte(pl.code[1])-48)*100+
      (byte(pl.code[2])-48)*10+
      (byte(pl.code[3])-48);
     //sender:=sender+' '+code;

     //nick wegdoen
     cutNext(pl.parameters);//overal?

     case codenr of
      1://init codes!
       begin
        AltNicks:='';//...
        NoticeServerName:=pl.origin;
        pl.MessageType:=cmNetwork;
        Msg(pl);
       end;
      4:
       begin
        ServerProperties:=pl.parameters;
        pl.MessageType:=cmSystem;
        Msg(pl);
       end;
      2,3,5:
       begin
        ServerParams:=pl.parameters;
        pl.MessageType:=cmSystem;
        Msg(pl);
       end;

      251,252,253,254,255,265,266:
       begin
        pl.MessageType:=cmSystem;
        Msg(pl);
       end;

      305://RPL_UNAWAY
       begin
        DoUserModes('-a');
        pl.MessageType:=cmIrc;
        Msg(pl);
       end;
      306://RPL_NOWAWAY
       begin
        DoUserModes('+a');
        pl.MessageType:=cmIrc;
        Msg(pl);
       end;

      372,375://Motd,MotdStart
       begin
        pl.MessageType:=cmMotd;
        Msg(pl);
       end;
      376,422://MotdEnd,MotdNone
       begin
        pl.MessageType:=cmMotd;
        Msg(pl);
        inc(MotdCount);
       end;

      431,432,433,436,437,484://bad nick
       begin
        pl.MessageType:=cmError;
        Msg(pl);
        //reject nick!
        if WasTriedNick then
         begin
          Nick:=LastNick;
          DoCaption;
         end
        else
         begin
          //AltNicks bevat eventueel alternatieven voor net na connect
          //daarom altNicks bij 001 hierboven
          p1:='';
          while not(AltNicks='') and (p1='') do p1:=cutNext(AltNicks);
          if p1='' then
           raise ERoError.Create(roErrorConnectOutOfAltNicks)
          else
           begin
            NetSend('NICK '+p1);
            Nick:=p1;
            DoCaption;
           end;
         end;
       end;

      //nieuwe hier!

      //doorsturen naar channels
      311..319,352,//WHO,WHOIS,WHOWAS
      327,328,329,//?? (van cnn? undernet?
      324,331..339,366,//JOIN
      346..349,367..369,//MODE lists
      301,//WHOIS
      401,403,404,406,441,442,
      471,473..478,482://errors
       begin
        mw:=FindTarget(pl.Parameter(0),true,false) as TMessageWin;
        mw.DoIncoming(pl,loopback);
       end;

      353:
       begin
        mw:=FindTarget(pl.Parameter(1),true,false) as TMessageWin;
        mw.DoIncoming(pl,loopback);
       end;

      else
       begin
        //unknown entry!
        pl.MessageType:=cmIrc;
        {
        if not(pl.parameters='') then
         pl.prefix:='<b>'+HTMLEncode(pl.parameters)+'</b>';
        }
        Msg(pl);
       end;
     end;

    end
   else
    begin

     //code opzoeken
     incode:=TInboundCommands(0);
     while not(incode=icUnknownCommand) and
      not(InboundCommandStrings[incode]=pl.code) do inc(incode);

     //codes!
     case incode of

      icPing:
       begin
        p1:='PONG :'+pl.text;
        pl.MessageType:=cmSystem;
        pl.prefix:='<b>'+pl.code+'</b>';
        pl.code:='';
        Msg(pl,true);
        //DoIncoming(??);
        NetSend(p1);
       end;

      icMode:
       begin
        if CompareTargets(pl.parameter(0),Nick) then
         begin
          DoUserModes(pl.text);
          pl.MessageType:=cmSystem;
          Msg(pl);
         end
        else
         begin
          mw:=FindTarget(pl.parameter(0),true,false) as TMessageWin;
          mw.DoIncoming(pl,loopback);
         end;
       end;
      icJoin:
       begin
        //pl.text of parameter?
        if pl.text='' then p1:=pl.Parameter(0) else p1:=pl.text;
        //assert(pl.text niet comma separated)
        mw:=FindTarget(p1,true,false) as TMessageWin;
        mw.DoIncoming(pl,loopback);

        //assert(pl hier nog bruikbaar!
        //target nick zelf voor reappears
        mw:=FindTarget(pl.NickFromOrigin,false,false) as TMessageWin;
        if not(mw=nil) then mw.DoIncoming(pl,loopback);

       end;
      icPart,icKick,icTopic:
       begin
        if pl.parameters='' then p1:=pl.text else p1:=pl.Parameter(0);
        mw:=FindTarget(p1,true,false) as TMessageWin;
        mw.DoIncoming(pl,loopback);
       end;

      icQuit,icKill,icNick:
       begin
        //dispatch!
        for i:=0 to MsgWindows.Count-1 do
         begin
          mw:=MsgWindows[i];
          mw.DoIncoming(pl,loopback);
         end;
       end;

      icPrivMsg,icNotice:
       begin
        //ctcp filteren eerst? zie MsgWin!

        //sommige servers geven welcome NOTICEs zonder afzender
        if not(loopback) and ((pl.origin='') or (pl.origin=NoticeServerName)) then
         begin
          pl.MessageType:=cmIrc;
          {
          if pl.origin='' then
           //iets met params?
          else
           pl.prefix:=SysImg('dlt',10)+HTMLEncode(pl.NickFromOrigin)+SysImg('dgt',10);
          }
          pl.parameters:='';
          //bold?
          Msg(pl);
         end
        else
         begin
          if loopback then p1:=pl.Parameter(0) else
           if CompareTargets(pl.parameter(0),Nick) then
            p1:=pl.NickFromOrigin else p1:=pl.parameter(0);
          mw:=FindTarget(p1,true,false) as TMessageWin;
          mw.DoIncoming(pl,loopback);
         end;
       end;
      icInvite:
       begin
        //??? auto invite?
        pl.MessageType:=cmIrc;
        pl.prefix:=pl.NickFromOrigin+' invites you to ';
        //assert(pl.parameters=Nick)
        pl.parameters:='';
        Msg(pl);
       end;

      //andere opties voor notice?

      icError:
       begin
        pl.MessageType:=cmError;
        //??
        Msg(pl);
       end;

      else
       begin
        //unknown entry!
        pl.MessageType:=cmIrc;
        pl.prefix:='<b>'+pl.code+'</b>';
        pl.code:='';
        Msg(pl);
       end;
     end;

    end;

  end;

 pl.Free;

 except
   on e:Exception do
     MsgError(e.message,e.ClassName);
 end;

end;

procedure TConnectionWin.Web1DocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  inherited;
  WebDoc:=Web1.Document as IHTMLDocument2;//pdisp?
  if ConnectOnComplete then DoConnect;
  StyleShown(WebDoc,aTTime,'.time');
  StyleShown(WebDoc,aTCode,'.code');
  StyleShown(WebDoc,aTSystem,'.system');
end;

procedure TConnectionWin.DoDebugLog;
var
  ls:TStringList;
  i,j:integer;
  s:string;
begin
  inherited;
  Nick:='Siggma';
  DoCaption;
  if OpenDialog1.Execute then
   begin
    ls:=TStringList.Create;
    try
      ls.LoadFromFile(OpenDialog1.FileName);
      for i:=0 to ls.Count-1 do
       begin
        s:=ls[i];
        j:=1;
        while (j<length(s)) and not(s[j] in WhiteSpace) do inc(j);
        if (j<length(s)) then s:=copy(s,j+1,length(s)-j);
        DoIncoming(s,false);
       end;
    finally
      ls.Free;
    end;
  end;
  Application.MessageBox('done','test',MB_OK);
end;

procedure TConnectionWin.aTTimeExecute(Sender: TObject);
begin
  inherited;
  ToggleStyle(WebDoc,aTTime,'.time');
end;

procedure TConnectionWin.aTCodeExecute(Sender: TObject);
begin
  inherited;
  ToggleStyle(WebDoc,aTCode,'.code');
end;

procedure TConnectionWin.aTSystemExecute(Sender: TObject);
begin
  inherited;
  ToggleStyle(WebDoc,aTSystem,'.system');
end;


procedure TConnectionWin.FormActivate(Sender: TObject);
begin
  inherited;
  //Com.SetFocus;

  //gewoon nog eens naar beneden?
  if WebDoc<>nil then
    with WebDoc.body as IHTMLElement2 do
      WebDoc.parentWindow.scrollTo(0,scrollHeight-clientHeight);
end;

procedure TConnectionWin.ComKeyPress(Sender: TObject; var Key: Char);
var
  i,j:integer;
  s,t,c:string;
begin
  inherited;
  case Key of
   #9:
    begin
     s:=Com.Text;
     //assert Com.SelLength=0?
     i:=Com.SelStart;
     if i<0 then i:=0;
     j:=i;
     while (i<>0) and not(s[i] in WhiteSpace) do dec(i);//begin zoeken
     inc(i);//terug want op spatie! of 0
     while (j<=length(s)) and not(s[j] in WhiteSpace) do inc(j);//end zoeken
     dec(j);//terug want op spatie of voorbij einde
     c:=copy(s,i,j-i+1);
     if c<>'' then
      begin
       t:=GetCompleted(c);//zoeken!
       Com.Text:=copy(s,1,i-1)+t+copy(s,j+1,length(s)-j);
       Com.SelStart:=i+length(t)-1;
      end;
     Key:=#0;
    end;
   #13:
    begin
     //completion

     if Com.Text='' then
      begin
       //iets anders? zoals menu
      end
     else
      begin
       History.Add(Com.Text);
       HistIndex:=-1;
       DoCommand(Com.Text);
       Com.Text:='';
      end;

     Key:=#0;
    end;
   #$7F:
    begin
     s:=Com.Text;
     i:=length(s);
     while (i<>0) and (s[i] in WhiteSpace) do dec(i);
     while (i<>0) and not(s[i] in WhiteSpace) do dec(i);
     Com.Text:=copy(s,1,i)+t;
     Com.SelStart:=length(Com.Text);
     Key:=#0;
    end;
  end;
end;

function TConnectionWin.FindTarget(target:string;CreateIfNotFound,
  FocusOnCreate:boolean):TForm;
var
  mw:TMessageWin;
  f:TForm;
begin
  //clean up target?
  mw:=HexTree.GetObject(htTarget+UpperCase(target));
  if (mw=nil) and CreateIfNotFound then
   begin
    f:=MainWin.ActiveMDIChild;
    mw:=TMessageWin.Create(Application);
    if not(FocusOnCreate) then f.BringToFront;
    mw.ConWin:=Self;
    MsgWindows.Add(mw);//delete gebeurt wel met ReleaseMsgWin...
    mw.SetTarget(target);
    HexTree.SetObject(htTarget+UpperCase(target),mw);
   end;
  Result:=mw;
end;

procedure TConnectionWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  ok:boolean;
begin

 //MessageBox close con?
 if MainWin.MainIsQuitting then ok:=true else
  if cs.Connected then
   ok:=Application.MessageBox(PChar(roConnectionWinClose+#13#10+Caption),
   PChar(AppName),MB_OKCANCEL or MB_ICONQUESTION)=idOK
  else
   ok:=true;

 if not(ok) then Action:=caNone;

 if not(Action=caNone) then
  begin
   cs.Disconnect;

   WebDoc:=nil;
   //assert(MsgWindows sluiten zich mooi af met een delete in msgWindows
   while not(MsgWindows.Count=0) do
    TMessageWin(MsgWindows.Last).Close;

   MsgWindows.Free;
   HexTree.Free;
   MainWin.ConWindows.Remove(Self);
   History.Free;
  end;

  inherited;

end;

procedure TConnectionWin.ReleaseMsgWin(f:TForm);
begin
  MsgWindows.Remove(f);
end;

function TConnectionWin.IdentdReply(Remote:string):string;
var
 pl:TRoParsedLine;
begin
 //assert onmiddellijk verstuurd ook)

 pl:=TRoParsedLine.Create('');
 pl.MessageType:=cmSystem;
 pl.text:='identd request from '+Remote;
 pl.origin:=Remote;
 Msg(pl);
 pl.Free;

 Result:=IdentDid+' : USERID : UNIX : '+UserName1;
end;

procedure TConnectionWin.DoCaption;
var
  s:string;
begin
  s:=Nick;
  if ModeFlags<>'' then s:=s+' ['+ModeFlags+']';
  if NetworkName<>'' then s:=s+' ('+NetworkName+')';
  s:=s+' '+ServerName;
  SetCaption(s);
end;

procedure TConnectionWin.DoUserModes(s:string);
var
 Applicator:char;
 si:integer;
begin
 Applicator:='+';//standaard aan?
 //assert nooit met parameters en van die dingen
 for si:=1 to length(s) do
  case s[si] of
   '+','-':Applicator:=s[si];
   //UserModes, of uitlezen van 001..005?
   else
    //case Applicator of?
    begin
     if Applicator='+' then AddFlag(ModeFlags,s[si]) else DelFlag(ModeFlags,s[si]);
    end;
  end;
 DoCaption;
end;

procedure TConnectionWin.PreClose;
begin
 //alle dependant windows sluiten!
 //assert MsgWins schrijven zich zelf uit de lijst
 while not(MsgWindows.Count=0) do
  begin
   TMessageWin(MsgWindows.Last).RealClose:=true;
   TMessageWin(MsgWindows.Last).Close;
  end;
end;

function TConnectionWin.WebTranslateAccelerator(Sender:TObject;const lpMsg: PMSG):boolean;
begin
 case lpMsg.wParam of
  //VK_TAB?
  VK_F1..VK_F12:
   begin
    PostMessage(Handle,lpMsg.message,lpMsg.wParam,lpMsg.lParam);
    Result:=true;
   end;
  VK_HOME,VK_END,VK_PRIOR,VK_NEXT,//VK_PAGE_UP,VK_PAGE_DOWN,
  VK_SNAPSHOT,//VK_PRINTSCREEN,//?
  VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN:
   Result:=false;
  //$30..$39,$41..$5A,VK_NUMPAD0..VK_NUMPAD9:
  else
   begin
    //kludge want setfocus gewoon werkt nie
    ActiveControl:=Web1;
    Com.SetFocus;
    Com.SelStart:=Length(Com.Text);
    //Application.ProcessMessages;
    PostMessage(Com.Handle,lpMsg.message,lpMsg.wParam,lpMsg.lParam);
    //nog eens via centrale passeren
    Result:=true;
   end;
 end;
end;

procedure TConnectionWin.ComChange(Sender: TObject);
begin
  inherited;
 //ook multi-line paste hier?
 //if Com.Lines.Count>1 then Com.Text:=Com.Lines[0];
 if not(Pos(#13#10,Com.Text)=0) then
  begin
   //paste? gewoon rippen
   Com.Text:=StringReplace(Com.Text,#13#10,'',[rfReplaceAll]);
  end;
end;

procedure TConnectionWin.FormDeactivate(Sender: TObject);
begin
  inherited;
 AppDeactivate;
end;

procedure TConnectionWin.FormResize(Sender: TObject);
begin
  inherited;
 //beter bijhouden als wel naar beneden?
 if not(WebDoc=nil) then
  with (WebDoc.body as IHTMLElement2) do
   WebDoc.parentWindow.scrollTo(0,scrollHeight-clientHeight);
end;

procedure TConnectionWin.Copy1Click(Sender: TObject);
begin
  inherited;
 WebDoc.execCommand('Copy',false,Null);
end;

procedure TConnectionWin.Selectall1Click(Sender: TObject);
begin
  inherited;
 WebDoc.execCommand('SelectAll',false,Null);
end;

procedure TConnectionWin.AppDeactivate;
begin
 inherited;
 WasHigh:=false;
 if cs.Connected then SetIcon(iiConOpen) else SetIcon(iiConClosed);
end;

procedure TConnectionWin.DoSetIcon(isHighNow:boolean);
begin
 if cs.Connected then
  begin
   if isHighNow then WasHigh:=true;
   if WasHigh then
    SetIcon(iiConHigh) 
   else
    SetIcon(iiConMsg);
   //iiConWasHigh
  end
 else SetIcon(iiConClosed);
end;

function TConnectionWin.GetCompleted(from:string;exclude:TChildWin=nil):string;
var
 s,f,max:string;
 i,j:integer;
 mw:TMessageWin;
begin
 //kan dit properder?

 i:=0;
 max:=from;
 //in msgwins zoeken
 while (max=from) and (i<MsgWindows.Count) do
  begin
   if not(MsgWindows[i]=exclude) then
    max:=TMessageWin(MsgWindows[i]).GetCompleted(from);
   inc(i);
  end;

 //dan maar in targets
 if max=from then
  begin
   i:=0;
   f:=LowerCase(from);
   max:=from;
   while i<MsgWindows.Count do
    begin
     mw:=TMessageWin(MsgWindows[i]);
     s:=LowerCase(mw.GetTarget);
     if copy(s,1,length(f))=f then
      begin
       if max=from then
        begin
         max:=mw.GetTarget;
         inc(i);
        end
       else
        begin
         j:=length(f)+1;
         max:=lowercase(max);
         while (j<=length(s)) and (s[j]=max[j]) do inc(j);
         max:=copy(max,1,j-1);
         if lowercase(max)=f then i:=MsgWindows.Count else inc(i);
        end;
      end
     else inc(i);
    end;
  end;
 Result:=max;
end;

procedure TConnectionWin.ComKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
 case Key of
  VK_UP://up
   begin
    if History.Count>0 then
     begin
      if (HistIndex=-1) then
       begin
        HistCom:=Com.Text;
        HistIndex:=History.Count;
       end;
      if HistIndex>0 then dec(HistIndex);
      Com.Text:=History[HistIndex];
     end;
    Key:=0;
   end;
  VK_DOWN://down
   begin
    if not(HistIndex=-1) then
     begin
      inc(HistIndex);
      if HistIndex=History.Count then
       begin
        HistIndex:=-1;
        Com.Text:=HistCom;
       end
      else
       Com.Text:=History[HistIndex];
     end;
    Key:=0;
   end;
 end;
end;

procedure TConnectionWin.LogUserComment(const target,s:string);
begin
 if not(Logger=nil) then
  if target='' then
   Logger.WriteLog('----- :'+s)
  else
   Logger.WriteLog('----- '+target+' :'+s);
 //display?
end;

end.
