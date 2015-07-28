unit roMsgWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, roChildWin, OleCtrls, SHDocVw, ExtCtrls, StdCtrls, roConWin,
  MSHTML, ActnList, Menus, roStuff, ComCtrls, ImgList, roDocHost,
  ToolWin;

type
  TTargetStatus=
   (tsNoTarget,
     tsUser,
     tsUserGone,
     tsChannel,
     tsOffChannel,
     tsPartingChannel,
     tsPartingChannelForHop);
  TMessageWin = class(TChildWin)
    Splitter1: TSplitter;
    Com: TMemo;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    aTTime: TAction;
    aTCode: TAction;
    aTSystem: TAction;
    View1: TMenuItem;
    imetags1: TMenuItem;
    Codes1: TMenuItem;
    Systemmessages1: TMenuItem;
    aTEvents: TAction;
    Channelevents1: TMenuItem;
    ImageList1: TImageList;
    ListView1: TListView;
    Web1: TRestrictedWebBrowser;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    N1: TMenuItem;
    SelectAll1: TMenuItem;
    aPasteCancel: TAction;
    aPastePause: TAction;
    Paste1: TMenuItem;
    Pause1: TMenuItem;
    N2: TMenuItem;
    aPasteCancel1: TMenuItem;
    aWebAOpen: TAction;
    aWebACopy: TAction;
    Copylink1: TMenuItem;
    Openlink1: TMenuItem;
    aPasteNext: TAction;
    aPasteNext1: TMenuItem;
    aCopy: TAction;
    aCopySC: TAction;
    N3: TMenuItem;
    aUTF8: TAction;
    UTF8filter1: TMenuItem;
    aWordWrap: TAction;
    Wordwrap1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Web1BeforeNavigate2(Sender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure ComKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure Web1DocumentComplete(Sender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure aTTimeExecute(Sender: TObject);
    procedure aTCodeExecute(Sender: TObject);
    procedure aTSystemExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure aTEventsExecute(Sender: TObject);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1Deletion(Sender: TObject; Item: TListItem);
    function WebTranslateAccelerator(Sender:TObject;const lpMsg: PMSG):boolean;
    procedure ComChange(Sender: TObject);
    procedure DoPasteTimer(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure aPasteCancelExecute(Sender: TObject);
    procedure aPastePauseExecute(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure aWebAOpenExecute(Sender: TObject);
    procedure aWebACopyExecute(Sender: TObject);
    procedure aPasteNextExecute(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure ComKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure aUTF8Execute(Sender: TObject);
    procedure aWordWrapExecute(Sender: TObject);
  private
    { Private declarations }
    Target,Topic,TopicStripped,UserAway,HopTarget:string;
    TargetSince:TDateTime;
    ModeFlags:array of string;
    WebDoc:IHTMLDocument2;
    WebNavOk,NamesListDone,CheckedTargetCase,WasHigh,HaveOp:boolean;
    MsgCount,rotateLine,rotateBlockPos:integer;
    TargetStatus:TTargetStatus;
    PasteData:TStringList;
    PasteTimer:TTimer;
    PasteCount:integer;
    rotateBlock,CurrentElement:IHTMLElement;
    History:TStringList;
    HistIndex:integer;
    HistCom:string;
    procedure DoCommand(s:string);
    function IsRelevant(SomeTarget:string;var IsTarget:boolean):boolean;
    procedure AddUser(NewNick:string);
    procedure ChangeUser(OldNick,NewNick:string);
    procedure DelUser(OldNick:string);
    procedure SetUserImageIndex(item:TListItem);
    procedure DoCaption;
    procedure DoChannelModes(ss:string);
    procedure TargetSend(s:string);
    procedure CheckNick(s:string);
    procedure DoSetIcon(isHighNow:boolean=false);
    procedure DoPasteFree;
    procedure DisplayInfo(s:string);
  public
    { Public declarations }
    ConWin:TConnectionWin;
    RealClose:boolean;
    procedure AppDeactivate; override;
    procedure SetTarget(NewTarget:string);
    function GetTarget:string;
    procedure Msg(pl:TRoParsedLine);
    procedure MsgError(s:string;code:string='');
    procedure DoIncoming(pl:TRoParsedLine;loopback:boolean=true);
    procedure DoIncomingCTCP(pl:TRoParsedLine;loopback:boolean);
    procedure DoIncomingCTCPReply(pl:TRoParsedLine;loopback:boolean);
    procedure DoAll(cmd:string);
    function GetCompleted(from:string):string;
  end;

var
  MessageWin: TMessageWin;

implementation

uses roMain, roHexTree, VBScript_RegExp_55_TLB, roPaste, ShellApi, ClipBrd,
 roHTMLHelp;

{$R *.dfm}

procedure TMessageWin.FormShow(Sender: TObject);
begin
  inherited;
 if not(Web1.HandleAllocated) then Web1.HandleNeeded;
 WebNavOk:=true;
 Web1.Navigate('res://'+application.ExeName+'/base');
end;

procedure TMessageWin.Web1BeforeNavigate2(Sender: TObject;
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
  end
 else
  begin
   s:=URL;
   if (length(s)>9) and (copy(s,1,9)='ro:paste?') then
    Com.Text:=Com.Text+URLDecode(copy(s,10,length(s)-9));
   Cancel:=true;
  end;
end;

procedure TMessageWin.ComKeyPress(Sender: TObject; var Key: Char);
var
 i,j:integer;
 s,c,t:string;
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
     while not(i=0) and not(s[i] in WhiteSpace) do dec(i);//begin zoeken
     inc(i);//terug want op spatie! of 0
     while not(j>length(s)) and not(s[j] in WhiteSpace) do inc(j);//end zoeken
     dec(j);//terug want op spatie of voorbij einde
     c:=copy(s,i,j-i+1);
     if not(c='') then
      begin
       t:=GetCompleted(c);//zoeken!
       if (t=c) then//niet gevonden?
        begin
         //eigen target?
         if LowerCase(c)=LowerCase(copy(Target,1,length(c))) then t:=Target;
        end;
       if (t=c) and not(ConWin=nil) then//niet gevonden?
        t:=ConWin.GetCompleted(c,Self);//verder zoeken
       Com.Text:=copy(s,1,i-1)+t+copy(s,j+1,length(s)-j);
       Com.SelStart:=i+length(t)-1;
      end;
     Key:=#0;
    end;
   #13:
    begin
     if Com.Text='' then
      begin
       //iets anders zoals menu?
      end
     else
      begin
       History.Add(Com.Text);
       HistIndex:=-1;
       while History.Count>historyLimit do History.Delete(0);
       DoCommand(Com.Text);
       Com.Text:='';
       Key:=#0;
      end;
    end;
   #$7F:
    begin
     s:=Com.Text;
     i:=length(s);
     while not(i=0) and (s[i] in WhiteSpace) do dec(i);
     while not(i=0) and not(s[i] in WhiteSpace) do dec(i);
     Com.Text:=copy(s,1,i)+t;
     Com.SelStart:=length(Com.Text);
     Key:=#0;
    end;
  end;
end;

procedure TMessageWin.DoCommand(s:string);
var
 command:string;
type
 TCommands=(
   icDebug,
   icUp,icLog,icInfo,icLine,
   icClose,icEcho,icRotate,icClear,
   icMe,
   icCtcp,
   icJoin,icLeave,icPart,icHop,
   icMode,icTopic,icPing,icNotice,
   icInvite,icKick,
   icWho,icWhoIs,

   //nieuwe hier
   icUnknown,icWhoSwitch
 );
const
 Commands:array[TCommands] of string=(
  'DEBUG',
  'UP','LOG','INFO','LINE',
  'CLOSE','ECHO','ROTATE','CLEAR',
  'ME',
  'CTCP',
  'JOIN','LEAVE','PART','HOP',
  'MODE','TOPIC','PING','NOTICE',
  'INVITE','KICK',
  'WHO','WHOIS',

  //nieuwe hier

  '',''
 );
var
 IsCommand:TCommands;
 pl:TRoParsedLine;
 p1,p2:string;
 e:IHTMLElement;
 i:integer;
begin

 if aUTF8.Checked then s:=UTF8Encode(s);

 if not(s='') then
  begin
   if s[1]=CommandPrefix then
    begin

     if s[2] in CommandChars then
      begin
       command:=s[2];
       i:=1;
       while (i<=length(s)) and (s[i] in WhiteSpace) do inc(i);
       s:=copy(s,i,length(s)-i+1);
      end
     else
      begin
       s:=copy(s,2,length(s)-1);
       command:=UpperCase(cutNext(s));
      end;

     if length(command)=0 then IsCommand:=icUnknown else
     if length(command)=1 then
      begin
       case UpCase(command[1]) of
        //'A':IsCommand:=icAway
        'C':IsCommand:=icCtcp;
        //'D':IsCommand:=icDCC;
        'E':IsCommand:=icEcho;
        'H':IsCommand:=icLine;
        'I':IsCommand:=icInvite;
        'J':IsCommand:=icJoin;
        'K':IsCommand:=icKick;
        'L':IsCommand:=icLeave;
        'M':IsCommand:=icMode;
        'N':IsCommand:=icNotice;
        'P':IsCommand:=icPart;
        //'Q':IsCommand:=icQuit;
        //'R':IsCommand:=icRaw;
        'T':IsCommand:=icTopic;
        'U':IsCommand:=icUp;
        'W':IsCommand:=icWhoSwitch;
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

        if ConWin=nil then
         pl.text:='Owner=none'
        else
         pl.text:='Owner='+ConWin.Caption;
        Msg(pl);
        pl.text:='SelfSince='+SinceToStr(SelfSince); Msg(pl);
        pl.text:='Target='+Target; Msg(pl);
        pl.text:='TargetSince='+SinceToStr(TargetSince); Msg(pl);
        pl.text:='rotateLine='+IntToStr(rotateLine); Msg(pl);
        pl.text:='rotateBlockPos='+IntToStr(rotateBlockPos); Msg(pl);
        pl.text:='</Debug info>'; Msg(pl);
        pl.Free;
       end;

      icUp:
       begin
        if not(ConWin=nil) then ConWin.BringToFront;
       end;
      icClose:
       begin
        //verify?
        Close;
       end;
      icEcho:
       begin
        pl:=TRoParsedLine.Create(s);
        //pl.prefix:=;
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

      icMe:
       begin
        p1:='PRIVMSG '+Target+' :'#1'ACTION '+s+#1;
        pl:=TRoParsedLine.Create('');
        pl.Parse(p1);
        DoIncoming(pl);
        ConWin.NetSend(p1);
        pl.Free;
       end;

      icJoin:
       begin
        //if gequit?
        if not(target='') and (target[1] in ChannelPrefix) then
         if trim(s)='' then s:=target;
        ConWin.DoCommand(CommandPrefix+command+' '+s);
       end;
      icHop:
       begin
        HopTarget:=cutNext(s);
        if HopTarget='' then HopTarget:=Target;
        //join/settarget in hetzelfde window
        if (TargetStatus=tsChannel) and (ConWin.cs.Connected) then
         begin
          ConWin.NetSend('PART '+Target+' :'+s);
          TargetStatus:=tsPartingChannelForHop;
         end
        else
         begin
          //zie ook incoming:icPart
          SetTarget(HopTarget);
          if not(ConWin=nil) and
            not(HopTarget='') and (HopTarget[1] in ChannelPrefix) then
           ConWin.DoCommand(CommandPrefix+'JOIN '+HopTarget);
         end;
       end;

      icLeave,icPart:
       begin
        if (s='') or not(s[1] in ChannelPrefix) then
         begin
          ConWin.NetSend('PART '+Target+' :'+s);
          //if TargetStatus=tsChannel then
          TargetStatus:=tsPartingChannel;
         end
        else
         begin
          p1:=cutNext(s);
          ConWin.NetSend('PART '+p1+' :'+s);
         end;
       end;
      icTopic:
       begin
        if (s='') or not(s[1] in ChannelPrefix) then
         p1:=Target else p1:=cutNext(s);
        ConWin.NetSend('TOPIC '+p1+' :'+s);
       end;
      icMode:
       begin
        if (s='') or not(s[1] in (ChannelPrefix-['+'])) then
         p1:=Target else p1:=cutNext(s);
        //doincoming loopback?
        ConWin.NetSend('MODE '+p1+' '+s);
       end;
      icNotice:
       begin
        p1:='NOTICE '+Target+' :'+s;
        pl:=TRoParsedLine.Create('');
        pl.Parse(p1);
        DoIncoming(pl);
        ConWin.NetSend(p1);
        pl.Free;
       end;
      icInvite:
       begin
        p1:=cutNext(s);
        if not(p1='') and (p1[1] in ChannelPrefix) then
         begin
          //eerst een channel, dus channel nemen (p2) en users inviten (p1)
          p2:=p1;
          repeat
           p1:=cutNext(s);
           if not(p1='') and (p1[1] in ChannelPrefix) then
            p2:=p1
           else
            ConWin.NetSend('INVITE '+p1+' '+p2);
          until s='';
         end
        else
         repeat
          //eerst channel zoeken
          p2:=cutNext(s);
          while not(s='') and ((p2='') or not(p2[1] in ChannelPrefix)) do
           begin
            p1:=p1+' '+p2;//opslaan in p1
            p2:=cutNext(s);
           end;
          //geen gevonden dan assert self
          if p2='' then p2:=Target;
          //doincoming loopback?
          while not(p1='') do ConWin.NetSend('INVITE '+cutNext(p1)+' '+p2);
         until s='';
       end;
      icKick:
       begin
        p1:=cutNext(s);
        p2:=Target;
        if not(p1='') and (p1[1] in ChannelPrefix) then
         begin
          p2:=p1;
          p1:=cutNext(s);
         end;
        //doincoming loopback?
        ConWin.NetSend('KICK '+p2+' '+p1+' :'+s);
       end;
      icPing,icWho,icWhois:
       begin
        if s='' then s:=Target+' '+Target;
        ConWin.DoCommand(CommandPrefix+command+' '+s);
       end;
      icWhoSwitch:
       begin
        if s='' then s:=Target;
        if not(s='') then
         if s[1] in ChannelPrefix then
          begin
           ConWin.DoCommand(CommandPrefix+'WHO '+s);
          end
         else
          begin
           ConWin.DoCommand(CommandPrefix+'WHOIS '+s+' '+s);
          end;
       end;
      icLog:if not(ConWin=nil) then ConWin.LogUserComment(target,s);
      icInfo:DisplayInfo(s);
      icLine:rotateBlock.insertAdjacentHTML('BeforeEnd','<hr />');

      //icCtcp:;?

      else
       //doorsturen naar boven
       ConWin.DoCommand(CommandPrefix+command+' '+s);
     end;

    end
   else TargetSend(s);

  end;
 //else error no empty string?
end;

procedure TMessageWin.TargetSend(s:string);
var
 p1:string;
 pl:TRoParsedLine;
begin
 if not(s='') then
  begin
   p1:='PRIVMSG '+Target+' :'+s;
   pl:=TRoParsedLine.Create('');
   pl.Parse(p1);
   DoIncoming(pl);
   ConWin.NetSend(p1);
   pl.Free;
  end;
 //else ?
end;

procedure TMessageWin.FormCreate(Sender: TObject);
begin
  inherited;
 ConWin:=nil;
 WebDoc:=nil;
 PasteData:=nil;
 PasteTimer:=nil;
 WebNavOk:=false;
 Web1.OnTranslateAccelerator:=WebTranslateAccelerator;
 NamesListDone:=true;
 TargetStatus:=tsNoTarget;
 Target:='';
 Topic:='';
 TopicStripped:='';
 UserAway:='';
 CheckedTargetCase:=false;
 SetLength(ModeFlags,1);
 ModeFlags[0]:='';
 RealClose:=false;
 rotateLine:=0;
 rotateBlockPos:=0;
 rotateBlock:=nil;
 WasHigh:=false;
 MsgCount:=0;
 HaveOp:=false;
 History:=TStringList.Create;
end;

procedure TMessageWin.SetTarget(NewTarget:string);
var
 a:boolean;
 i:integer;
begin
 if ConWin=nil then
  begin
   //select one??
   raise ERoError.Create(roErrorNoConWin);
  end
 else
  if ConWin.HexTree.SetObjectIfNil(htTarget+UpperCase(NewTarget),Self) then
   begin
    TargetStatus:=tsNoTarget;
    if not(NewTarget='') then
     begin
      ConWin.HexTree.SetObject(htTarget+UpperCase(Target),nil);
      //clear stuff
      Topic:='';
      TopicStripped:='';
      UserAway:='';
      NamesListDone:=true;
      for i:=0 to length(ModeFlags)-1 do ModeFlags[i]:='';
      //best ook nicklist clearen om de hextree te ontlasten
      ListView1.Items.BeginUpdate;
      ListView1.Items.Clear;
      ListView1.Items.EndUpdate;
      a:=NewTarget[1] in ChannelPrefix;
      if a then TargetStatus:=tsChannel else TargetStatus:=tsUser;
      ListView1.Visible:=a;
      Splitter1.Visible:=a;
      if a then
       begin
        //Splitter forceren links!
        Splitter1.Left:=ClientWidth-Splitter1.Width-ListView1.Width;
       end;
      CheckedTargetCase:=a;
     end;

    WasHigh:=false;
    MsgCount:=0;
    HaveOp:=false;
    Target:=NewTarget;
    TargetSince:=Now;
    DoCaption;
    DoSetIcon;
   end
  else
 raise ERoError.Create(roErrorTargetInUse);
end;

function TMessageWin.GetTarget:string;
begin
 Result:=Target;
end;

procedure TMessageWin.Msg(pl:TRoParsedLine);
var
 ScrollY,FirstY:integer;
 re:TRegExp;
 highlight,foundownnick:boolean;
 rid:string;
 e:IHTMLElement;
 w,w1:WideString;
begin
 pl.PrepHTML;

 highlight:=false;
 foundownnick:=false;
 try
  if pl.MessageType=cmIrc then //nog?
   begin
    re:=TRegExp.Create(nil);
    re.IgnoreCase:=true;
    re.Pattern:=ConWin.Nick;
    foundownnick:=re.Test(pl.Stripped);
    if foundownnick then highlight:=true else
     begin
      //extra regexps
     end;
    re.Free;
   end;
 except
 end;

 if pl.MessageType in [cmNetwork,cmIrc,cmError] then
  begin
   inc(MsgCount);
   DoSetIcon(highlight);
  end;

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

 w:=pl.GetHTML(highlight,foundownnick);
 //UTF8
 if aUTF8.Checked then
  begin
   w1:=UTF8Decode(w);
   if not(w1='') then w:=w1;
  end;

 //assert not(rotateBlock=nil);
 rotateBlock.insertAdjacentHTML('BeforeEnd',w);

 //scroll down
 if ScrollY<16 then WebDoc.parentWindow.scrollBy(0,
   (WebDoc.body as IHTMLElement2).scrollHeight-FirstY);

end;

procedure TMessageWin.Web1DocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  inherited;
 WebDoc:=Web1.Document as IHTMLDocument2;//pdisp?
 //if OnComplete then Do...;

 //style checks hier!

 StyleShown(WebDoc,aTTime,'.time');
 StyleShown(WebDoc,aTCode,'.code');
 StyleShown(WebDoc,aTSystem,'.system');
 StyleShown(WebDoc,aTEvents,'.event');

 aWordWrap.Checked:=not(WebDoc.body.style.whiteSpace='');
end;

procedure TMessageWin.aTTimeExecute(Sender: TObject);
begin
  inherited;
 ToggleStyle(WebDoc,aTTime,'.time');
end;

procedure TMessageWin.aTCodeExecute(Sender: TObject);
begin
  inherited;
 ToggleStyle(WebDoc,aTCode,'.code');
end;

procedure TMessageWin.aTSystemExecute(Sender: TObject);
begin
  inherited;
 ToggleStyle(WebDoc,aTSystem,'.system');
end;

procedure TMessageWin.aTEventsExecute(Sender: TObject);
begin
  inherited;
 ToggleStyle(WebDoc,aTEvents,'.event');
end;

procedure TMessageWin.DoIncoming(pl:TRoParsedLine;loopback:boolean=true);
type
 TInboundCommands=(
  icMode,
  icPrivMsg,icNotice,

  icTopic,icNick,
  icJoin,icQuit,icKill,icPart,icKick,
  //nieuwe hier (geen displaycode)

  icUnknownCommand,
  icReappears//eentje extra voor de reappear displaystring
 );
const
 InboundCommandStrings:array[TInboundCommands] of string=(

  'MODE',
  'PRIVMSG','NOTICE',

  'TOPIC','NICK',
  'JOIN','QUIT','KILL','PART','KICK',
  //nieuwe hier!

  '',
  ''
 );
 DisplayMessageString:array[TInboundCommands] of string=(
  ' changes channel mode to',//mode
  '','',//privmsg,notice
  ' changes channel topic to',//topic
  ' changes nick to',//nick
  ' joins channel',//join
  ' quits: ',//quit
  ' kills ',//kill
  ' leaves channel: ',//part
  ' kicks ',//kick
  '',
  ' reappears on channel'//reappears
 );
var
 incode:TInboundCommands;
 codenr:integer;
 p1,p2:string;
 IsTarget:boolean;
 a:boolean;
begin

 try
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

    CheckNick(pl.Parameter(0));
    cutNext(pl.parameters);

    case codenr of
     0:;
     //nieuwe hier!

     324://channel mode
      begin
       DoChannelModes(pl.parameters);
       pl.MessageType:=cmSystem;
       Msg(pl);
      end;
     332://channel topic
      begin
       Topic:=pl.text;
       pl.MessageType:=cmIrc;//vroeger cmNetwork
       Msg(pl);
       TopicStripped:=pl.Stripped;
       DoCaption;
      end;
     311:
      begin
       //na whois, 301 zeker opnieuw tonen
       UserAway:='';
       pl.MessageType:=cmIrc;
       Msg(pl);
      end;
     301://user away message as topic
      begin
       //kludge, vreemd maar bij niet-whois komt er 'Gone'
       if not(UserAway='') and not(UserAway='Gone') then
        if pl.text='Gone' then pl.text:=UserAway;
       if not(pl.text=UserAway) then
        begin
         UserAway:=pl.text;
         Topic:=pl.text;
         pl.MessageType:=cmIrc;//vroeger cmNetwork
         Msg(pl);
         TopicStripped:=pl.Stripped;
         DoCaption;
         DoSetIcon;//nodig?
        end;
      end;
     353://channel names lists
      begin
       ListView1.Items.BeginUpdate;
       if NamesListDone then
        begin
         NamesListDone:=false;
         ListView1.Items.Clear;
        end;
       p1:=pl.text;
       while not(p1='') do
        begin
         p2:=cutNext(p1);
         //assert(not(p2='')
         AddUser(p2);
        end;
       ListView1.Items.EndUpdate;
       pl.MessageType:=cmSystem;
       Msg(pl);
      end;
     366://end of names list!
      begin
       NamesListDone:=true;
       pl.MessageType:=cmSystem;
       Msg(pl);
      end;
     333:
      begin
       //who last set topic?
       pl.MessageType:=cmSystem;
       Msg(pl);
      end;

     367:
      begin
       pl.MessageType:=cmIrc;
       Msg(pl);
      end;

     403,404,471,473,474,475:
      begin
       //assert TargetStatus=tsChannel
       TargetStatus:=tsOffChannel;
       pl.MessageType:=cmIrc;
       Msg(pl);
      end;
     406:
      begin
       //assert TargetStatus=tsUser
       TargetStatus:=tsUserGone;
       pl.MessageType:=cmIrc;
       Msg(pl);
      end;

     else
      begin
       //unknown entry!
       pl.MessageType:=cmIrc;
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

     icMode:
      begin
       pl.MessageType:=cmEvent;
       pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[incode];
       p1:=pl.parameters;
       cutNext(p1);
       DoChannelModes(p1);
       Msg(pl);
      end;
     icTopic:
      begin
       //pl.MessageType:=cmEvent;
       Topic:=pl.text;
       pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[incode];
       Msg(pl);
       TopicStripped:=pl.Stripped;
       DoCaption;
      end;
     icPrivMsg:
      begin
       cutNext(pl.parameters);
       if pl.IsCTCP then
        begin
         pl.ParseCTCP;
         DoIncomingCTCP(pl,loopback);
        end
       else
        begin
//hier ook kijken om op/voice weer te geven in de prefix?
         pl.MessageType:=cmIrc;
         pl.code:='';
         CheckNick(pl.NickFromOrigin);
         if loopback or (pl.origin='') then
          begin
           //toevoegen aan history?
           pl.prefix:=SysImg('lt1',6)+HTMLEncode(ConWin.Nick)+SysImg('gt1',6)
          end
         else
          begin
           pl.prefix:=SysImg('lt',6)+HTMLEncode(pl.NickFromOrigin)+SysImg('gt',6);
           if TargetStatus=tsUserGone then TargetStatus:=tsUser;
           if TargetStatus=tsOffChannel then TargetStatus:=tsChannel;
          end;
         Msg(pl);
        end;
      end;
     icNotice:
      begin
       cutNext(pl.parameters);
       if pl.IsCTCP then
        begin
         pl.ParseCTCP;
         DoIncomingCTCPReply(pl,loopback);
        end
       else
        begin
         pl.MessageType:=cmIrc;
         pl.code:='';
         CheckNick(pl.NickFromOrigin);
         if loopback or (pl.origin='') then
          pl.prefix:=SysImg('dlt1',10)+HTMLEncode(ConWin.Nick)+SysImg('dgt1',10)
         else
          begin
           pl.prefix:=SysImg('dlt',10)+HTMLEncode(pl.NickFromOrigin)+SysImg('dgt',10);
           if TargetStatus=tsUserGone then TargetStatus:=tsUser;
           if TargetStatus=tsOffChannel then TargetStatus:=tsChannel;
          end;
         Msg(pl);
        end;
      end;
     //andere opties voor notice?
     icJoin:
      begin
       if pl.text='' then p1:=pl.Parameter(0) else p1:=pl.text;
       pl.MessageType:=cmEvent;
       if CompareTargets(Target,p1,false) then
        begin
         //joins!
         pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[incode];
         AddUser(pl.NickFromOrigin);
        end
       else
        begin
         if TargetStatus=tsUserGone then
          begin
           //reappears
           pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[icReappears];
           TargetStatus:=tsUser;
          end;
        end;
        //alleen na een quit of zo?
       Msg(pl);
      end;
     icPart,icKick,icQuit,icKill://events-hub
      begin
       a:=true;
       IsTarget:=false;
       case incode of
        icPart:
         begin
          p1:=pl.NickFromOrigin;
          pl.prefix:=HTMLEncode(p1)+DisplayMessageString[incode];
         end;
        icKick:
         begin
          //assert pl.parameter(0)=target
          p1:=pl.Parameter(1);
          pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[incode];
          cutNext(pl.parameters);
         end;
        icQuit:
         begin
          p1:=pl.NickFromOrigin;
          a:=IsRelevant(p1,IsTarget);
          if a then pl.prefix:=HTMLEncode(p1)+DisplayMessageString[incode];
         end;
        icKill:
         begin
          p1:=pl.Parameter(0);
          a:=IsRelevant(p1,IsTarget);
          if a then
           begin
            pl.prefix:=HTMLEncode(pl.NickFromOrigin)+
             DisplayMessageString[incode];
            cutNext(pl.parameters);
           end;
         end;
       end;

       if a then
        begin
         pl.MessageType:=cmEvent;
         if IsTarget then TargetStatus:=tsUserGone else
          begin
           DelUser(p1);
           if (TargetStatus=tsChannel) and (p1=ConWin.Nick) then
            TargetStatus:=tsOffChannel;
          end;
         Msg(pl);
         if incode=icPart then
          case TargetStatus of
           //in alle hier if p1=ConWin.Nick then  overnemen
           tsPartingChannel:if p1=ConWin.Nick then Close;
           tsPartingChannelForHop:if p1=ConWin.Nick then
            begin
             //zie ook command hop
             SetTarget(HopTarget);
             if not(ConWin=nil) and
               not(HopTarget='') and (HopTarget[1] in ChannelPrefix) then
              ConWin.DoCommand(CommandPrefix+'JOIN '+HopTarget);
            end;
          end;
        end;
      end;
     icNick:
      if IsRelevant(pl.NickFromOrigin,IsTarget) then
       begin
        if IsTarget then SetTarget(pl.text) else
         ChangeUser(pl.NickFromOrigin,pl.text);
        pl.MessageType:=cmEvent;
        pl.prefix:=HTMLEncode(pl.NickFromOrigin)+DisplayMessageString[incode];
        Msg(pl);
       end;

     else
      begin
       //unknown entry!
       pl.MessageType:=cmIrc;
       pl.prefix:='<b>'+pl.code+'</b>';
       Msg(pl);
      end;
    end;

   end;

 except
  on e:Exception do
   MsgError(e.message,e.ClassName);
 end;

end;

procedure TMessageWin.DoIncomingCTCP(pl:TRoParsedLine;loopback:boolean);
type
 TInboundCommands=(
  icAction,
  icPing,
  icVersion,
  icClientInfo,
  icEcho,
  icTime,
  //nieuwe hier (geen displaycode)

  icUnknownCommand
 );
const
 InboundCommandStrings:array[TInboundCommands] of string=(

  'ACTION',
  'PING',
  'VERSION',
  'CLIENTINFO',
  'ECHO',
  'TIME',
  //nieuwe hier!

  ''
 );
 CommandInfo:array[TInboundCommands] of string=(

  'ACTION command used to display action-messages in transscript',
  'PING times the round trip to a user and back',
  'VERSION displays a user''s version information',
  'CLIENTINFO displays available CTCP commands or information about a CTCP command',
  'ECHO returns whetever you send',
  'TIME returns current time on this machine',
  //nieuwe hier!

  ''
 );
var
 incode:TInboundCommands;
 p1:string;
 procedure DoSend(data:string);
 var
  pl1:TRoParsedLine;
 begin
  Msg(pl);
  pl1:=TRoParsedLine.Create('');
  pl1.MessageType:=cmSystem;
  pl1.Parse(data);
  DoIncoming(pl1);
  ConWin.NetSend(data);
  pl1.Free;
 end;
var
 replyTo:string;
begin
 incode:=TInboundCommands(0);
 while not(incode=icUnknownCommand) and
  not(InboundCommandStrings[incode]=pl.code) do inc(incode);

 pl.MessageType:=cmSystem;
 if loopback or (pl.origin='') then
  pl.prefix:=SysImg('dlt1',10)+HTMLEncode(ConWin.Nick)+
   SysImg('bro1',4)+pl.code+SysImg('brc1',4)
 else
  pl.prefix:=SysImg('dlt',10)+HTMLEncode(pl.NickFromOrigin)+
   SysImg('bro',4)+pl.code+SysImg('brc',4);

 //replyTo:=target;
 replyTo:=pl.NickFromOrigin;

 if not(loopback) or (incode in [icAction]) then
  begin
   case incode of
    icAction:
     begin
      pl.MessageType:=cmIrc;
      pl.code:='';
      if loopback or (pl.origin='') then
       pl.prefix:=SysImg('bullet1')+' '+HTMLEncode(ConWin.Nick)
      else
       pl.prefix:=SysImg('bullet')+' '+HTMLEncode(pl.NickFromOrigin);
      Msg(pl);
     end;
    icVersion:
     DoSend('NOTICE '+replyTo+' :'#1'VERSION '+AppName+#1);
    icPing:
     DoSend('NOTICE '+replyTo+' :'#1'PING '+pl.text+#1);
    icEcho:
     DoSend('NOTICE '+replyTo+' :'#1'ECHO '+pl.text+#1);
    icTime:
     DoSend('NOTICE '+replyTo+' :'#1'TIME '+DateTimeToStr(Now)+#1);
    icClientInfo:
     begin
      //incode opnieuw gebruiken?
      incode:=TInboundCommands(0);
      p1:=UpperCase(pl.text);
      while not(incode=icUnknownCommand) and
       not(InboundCommandStrings[incode]=p1) do inc(incode);

      if incode=icUnknownCommand then
       begin
        p1:='';
        incode:=TInboundCommands(0);
        while not(incode=icUnknownCommand) do
         begin
          if not(p1='') then p1:=p1+' ';
          p1:=p1+InboundCommandStrings[incode];
          inc(incode);
         end;
       end
      else p1:=CommandInfo[incode];
      DoSend('NOTICE '+replyTo+' :'#1'CLIENTINFO '+p1+#1);
     end;
    else
     begin
      //unknown entry!
      Msg(pl);
     end;
   end;
  end
 else
  Msg(pl);
end;

procedure TMessageWin.DoIncomingCTCPReply(pl:TRoParsedLine;loopback:boolean);
type
 TInboundCommands=(
  icPing,
  icVersion,
  //nieuwe hier (geen displaycode)

  icUnknownCommand
 );
const
 hex:array[0..15] of char='0123456789ABCDEF';
 InboundCommandStrings:array[TInboundCommands] of string=(

  'PING',
  'VERSION',
  //nieuwe hier!

  ''
 );
var
 incode:TInboundCommands;
 i,j,k:integer;
 date:TDateTime;
 datex:array[0..3] of word absolute date;
 p1:string;
begin
 incode:=TInboundCommands(0);
 while not(incode=icUnknownCommand) and
  not(InboundCommandStrings[incode]=pl.code) do inc(incode);

 if loopback then
  pl.MessageType:=cmSystem
 else
  pl.MessageType:=cmIrc;

 if loopback or (pl.origin='') then
  pl.prefix:=SysImg('dgt1',10)+HTMLEncode(ConWin.Nick)+
   SysImg('bro1',4)+pl.code+SysImg('brc1',4)
 else
  pl.prefix:=SysImg('dgt',10)+HTMLEncode(pl.NickFromOrigin)+
   SysImg('bro',4)+pl.code+SysImg('brc',4);


 if not(loopback) {or (incode in [icAction])} then
  begin
   case incode of
    icVersion:
     begin
      pl.MessageType:=cmIrc;
      Msg(pl);
     end;
    icPing:
     begin
      i:=1;
      p1:=pl.text;
      for k:=0 to 3 do
       begin
        datex[k]:=0;
        inc(i);
        while (i<=length(p1)) and (i<(5*(k+1)+1)) do
         begin
          j:=15;
          while not(j=0) and not(hex[j]=p1[i]) do dec(j);
          datex[k]:=(datex[k] shl 4)+j;
          inc(i);
         end;
       end;

      pl.MessageType:=cmIrc;
      pl.prefix:=pl.prefix+' '+
       FloatToStrF((now-date)*86400,ffFixed,10,2)+' seconds';
      //FYI: 86400=60*60*24
      Msg(pl);
     end;

    else
     begin
      //unknown entry!
      Msg(pl);
     end;
   end;
  end
 else
  Msg(pl);
end;

procedure TMessageWin.MsgError(s:string;code:string='');
var
 pl:TRoErrorLine;
begin
 pl:=TRoErrorLine.Create(s,code);
 Msg(pl);
 pl.Free;
end;

procedure TMessageWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin

 if not(RealClose) and not(ConWin=nil) then
  begin
   if (TargetStatus=tsChannel) and (ConWin.cs.Connected) then
    begin
     ConWin.NetSend('PART '+Target+' :'+Com.Text);
     TargetStatus:=tsPartingChannel;
     Action:=caNone;
    end;
  end;

 if not(Action=caNone) then
  begin
   WebDoc:=nil;
   if not(PasteTimer=nil) then PasteTimer.Free;
   if not(PasteData=nil) then PasteData.Free;
   ListView1.Items.BeginUpdate;
   ListView1.Items.Clear;
   //OnDeletion doet de hextree!
   ListView1.Items.EndUpdate;
   if not(ConWin=nil) then
    begin
     ConWin.HexTree.SetObject(htTarget+UpperCase(Target),nil);
     ConWin.ReleaseMsgWin(Self);
    end;
   History.Free;
  end;

 inherited;
end;

procedure TMessageWin.ListView1Compare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  inherited;
 //Item.SubItems[0] gebruiken??
 if (Item1.ImageIndex div 2)<(Item2.ImageIndex div 2) then Compare:=-1 else
  if (Item1.ImageIndex div 2)>(Item2.ImageIndex div 2) then Compare:=1 else
   Compare:=CompareStr(UpperCase(Item1.Caption),UpperCase(Item2.Caption));
end;

procedure TMessageWin.ListView1DblClick(Sender: TObject);
var
 li:TListItem;
begin
  inherited;
 li:=ListView1.ItemFocused;
 if not(li=nil) then ConWin.FindTarget(li.Caption,true,true);
end;

function TMessageWin.IsRelevant(SomeTarget:string;var IsTarget:boolean):boolean;
begin
 if CompareTargets(SomeTarget,Target) then
  begin
   IsTarget:=true;
   Result:=true;
  end
 else
  begin
   IsTarget:=false;
   {i:=0;
   while not(i=ListView1.Items.Count) and
    not(CompareTargets(ListView1.Items[i].Caption,SomeTarget)) do inc(i);
   Result:=not(i=ListView1.Items.Count);
   }
   Result:=not(ConWin.HexTree.GetObject(htNickList+Target+htNick+SomeTarget)=nil);
  end;
end;

procedure TMessageWin.CheckNick(s:string);
begin
 //extra controles hier?
 if TargetStatus=tsUserGone then
  if CompareTargets(s,Target) then TargetStatus:=tsUser;
 if TargetStatus=tsOffChannel then
  if CompareTargets(s,Target) then TargetStatus:=tsChannel;

 if not(CheckedTargetCase) then
  if CompareTargets(s,Target) then
   begin
    Target:=s;
    DoCaption;
    //DoSetIcon;//?
    CheckedTargetCase:=true;
   end;
end;

procedure TMessageWin.ListView1Deletion(Sender: TObject; Item: TListItem);
begin
  inherited;
 ConWin.HexTree.SetObject(htNickList+Target+htNick+Item.Caption,nil);
end;

procedure TMessageWin.AddUser(NewNick:string);
var
 li:TListItem;
 s:string;
begin
 if NewNick='' then
  begin
   //...
   //komt alleen voor bij logs replay (normaal)
  end
 else
  begin
   li:=ListView1.Items.Add;
   case NewNick[1] of
    '@':
     begin
      s:='o';
      NewNick:=copy(NewNick,2,length(NewNick));
     end;
    '+':
     begin
      s:='v';
      NewNick:=copy(NewNick,2,length(NewNick));
     end;
    else s:='';
   end;
   li.Caption:=NewNick;
   li.SubItems.Add(s);
   SetUserImageIndex(li);
   ConWin.HexTree.SetObject(htNickList+Target+htNick+NewNick,li);
  end;
end;

procedure TMessageWin.SetUserImageIndex(item:TListItem);
var
 i,idx:integer;
 flags:string;
begin
 idx:=5;
 flags:=item.SubItems[0];
 for i:=1 to length(flags) do if flags[i]='v' then idx:=3;
 for i:=1 to length(flags) do if flags[i]='o' then idx:=1;
 if item.Caption=ConWin.Nick then
  begin
   //checken of je zelf op bent staat hier! (beetje rare plaats)
   HaveOp:=idx=1;

   dec(idx);//CompareTargets?
  end;
 item.ImageIndex:=idx;
 //re-sort?
 ListView1.SortType:=stNone;
 ListView1.SortType:=stData;
end;

procedure TMessageWin.ChangeUser(OldNick,NewNick:string);
var
 li:TListItem;
 s:string;
begin
 with ConWin.HexTree do
  begin
   s:=htNickList+Target+htNick;
   li:=GetObject(s+OldNick);
   SetObject(s+OldNick,nil);
   if li=nil then AddUser(NewNick) else
    begin
     li.Caption:=NewNick;
     SetObject(s+NewNick,li);
     ListView1.SortType:=stNone;
     ListView1.SortType:=stData;
    end;
  end;
end;

procedure TMessageWin.DelUser(OldNick:string);
var
 li:TListItem;
 i:integer;
begin
 li:=ConWin.HexTree.GetObject(htNickList+Target+htNick+OldNick);
 if li=nil then
  begin
   i:=0;
   while not(i=ListView1.Items.Count) and
    not(CompareTargets(ListView1.Items[i].Caption,OldNick)) do inc(i);
   if not(i=ListView1.Items.Count) then li:=ListView1.Items[i];
  end;
 if not(li=nil) then li.Delete;
end;

procedure TMessageWin.DoCaption;
var
 s,t:string;
 i:integer;
begin
 t:=ModeFlags[0];
 for i:=1 to length(ModeFlags)-1 do
  if not(ModeFlags[i]='') then
   t:=t+' '+ModeFlags[i];
 s:=Target;
 if not(t='') then s:=s+' ['+t+']';
 if not(TopicStripped='') then s:=s+' '+TopicStripped;
 SetCaption(s);
end;

procedure TMessageWin.DoChannelModes(ss:string);
var
 Applicator:char;
 si:integer;
 mf,s,t:string;
 li:TListItem;
 procedure CheckMF(level:integer);
 begin
  while length(ModeFlags)<level+1 do
   begin
     setlength(ModeFlags,length(ModeFlags)+1);
     ModeFlags[length(ModeFlags)-1]:='';
   end;
 end;
const
 mflvlLimit=1;
begin
 mf:=ModeFlags[0];
 Applicator:='+';//standaard aan?
 //assert nooit met parameters en van die dingen
 s:=cutNext(ss);
 for si:=1 to length(s) do
  case s[si] of
   '+','-':Applicator:=s[si];
   //ChannelModes, of uitlezen van 001..005?
   //ChannelModesParamPersist:?
   //ChannelModesParam:?
   'l'://users limit
    begin
     CheckMF(mflvlLimit);
     if Applicator='+' then
      begin
       AddFlag(mf,'l');
       ModeFlags[mflvlLimit]:=cutNext(ss);
      end
     else
      begin
       DelFlag(mf,'l');
       ModeFlags[mflvlLimit]:='';
      end;
    end;
   'k'://channel key
    begin
     if Applicator='+' then
      begin
       AddFlag(mf,'k');
       cutNext(ss);
      end
     else DelFlag(mf,'k');
    end;
   'o','v'://operators,voiced users
    begin
     t:=cutNext(ss);
     li:=ConWin.HexTree.GetObject(htNickList+Target+htNick+t);
     if not(li=nil) then
      begin
       //assert(li.Caption=t) of comparetargets?
       t:=li.SubItems[0];//iets anders dan t hergebruiken?
       if Applicator='+' then AddFlag(t,s[si]) else DelFlag(t,s[si]);
       li.SubItems[0]:=t;
       SetUserImageIndex(li);
      end;
    end;
   'b','e','I':cutNext(ss);//niet weergeven
   //nog?

   else
    //case Applicator of?
    begin
     if Applicator='+' then AddFlag(mf,s[si]) else DelFlag(mf,s[si]);
    end;
  end;
 ModeFlags[0]:=mf;
 DoCaption;
 DoSetIcon;//extra controles?
end;

procedure TMessageWin.DoAll(cmd:string);
begin
 //assert pl klaar om gedisplayed te worden!
 if not(Target='') and (Target[1] in ChannelPrefix) then
  //and TargetStatus?
  DoCommand(cmd);
end;

function TMessageWin.WebTranslateAccelerator(Sender:TObject;const lpMsg: PMSG):boolean;
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

procedure TMessageWin.ComChange(Sender: TObject);
var
 x,y:integer;
 v:OleVariant;
begin
  inherited;
 //paste detect!

 //if Com.Lines.Count>1 then Com.Text:=trim(Com.Text);
 //if Com.Lines.Count>1 then
 if not(Pos(#13#10,Com.Text)=0) then
  begin
   //paste!

   if PasteTimer=nil then
    begin
     x:=ClientOrigin.X;
     y:=ClientOrigin.Y;
     with TPasteWin.Create(Application) do
      begin
       Top:=y;
       Left:=x;
       txtData.Text:=Com.Text;
       v:=MainWin.HexTree.GetValue(htSetting+'PasteInterval');
       if not(VarIsNull(v)) then udInterval.Position:=v;
       case ShowModal of
        mrOk:
         begin
          MainWin.HexTree.SetValue(htSetting+'PasteInterval',udInterval.Position);
          aPastePause.Checked:=false;
          PasteData:=TStringList.Create;
          PasteData.Text:=txtData.Text;
          PasteTimer:=TTimer.Create(Application);
          PasteTimer.Interval:=udInterval.Position;
          PasteTimer.OnTimer:=DoPasteTimer;
          PasteCount:=PasteData.Count;
          Paste1.Visible:=true;
          Paste1.Caption:='Paste '+IntToStr(PasteCount-PasteData.Count)+'/'+
           IntToStr(PasteCount);
         end;
        101:
         begin
          TargetSend(StringReplace(txtData.Text,#13#10,'',[rfReplaceAll]));
         end;
       end;
       Free;
      end;
    end
   else
    begin
     Application.MessageBox(PChar(roAlreadyPasting),PChar(AppName),MB_OK or MB_ICONWARNING);
    end;

   Com.Text:='';
  end;

end;

procedure TMessageWin.DoPasteTimer(Sender: TObject);
begin
 //assert not(PasteData.Count=0)
 TargetSend(PasteData[0]);
 PasteData.Delete(0);
 Paste1.Caption:='Paste '+IntToStr(PasteCount-PasteData.Count)+'/'+
  IntToStr(PasteCount);
 if PasteData.Count=0 then DoPasteFree;
end;

procedure TMessageWin.DoPasteFree;
var
 pl:TRoParsedLine;
 s:string;
 c:integer;
begin
 c:=PasteData.Count;
 PasteTimer.Free;
 PasteData.Free;
 PasteTimer:=nil;
 PasteData:=nil;
 if c=0 then
  s:='Pasted '+IntToStr(PasteCount)+' lines'
 else
  s:='Pasted '+IntToStr(PasteCount-c)+'/'+
   IntToStr(PasteCount)+' lines (cancelled)';
 pl:=TRoParsedLine.Create(s);
 pl.MessageType:=cmNetwork;
 Msg(pl);
 pl.Free;
 Paste1.Visible:=false;
 aPastePause.Checked:=false;
end;

procedure TMessageWin.FormDeactivate(Sender: TObject);
begin
  inherited;
 AppDeactivate;
end;

procedure TMessageWin.FormResize(Sender: TObject);
begin
  inherited;
 //beter bijhouden als wel naar beneden?
 if not(WebDoc=nil) then
  with (WebDoc.body as IHTMLElement2) do
   WebDoc.parentWindow.scrollTo(scrollLeft,scrollHeight-clientHeight);
end;

procedure TMessageWin.Copy1Click(Sender: TObject);
begin
  inherited;
 //html overlopen?
 WebDoc.execCommand('Copy',false,Null);
end;

procedure TMessageWin.SelectAll1Click(Sender: TObject);
begin
  inherited;
 WebDoc.execCommand('SelectAll',false,Null);
end;

procedure TMessageWin.AppDeactivate;
begin
 inherited;
 WasHigh:=false;
 MsgCount:=0;
 DoSetIcon;
end;

procedure TMessageWin.FormActivate(Sender: TObject);
begin
  inherited;
 //Com.SetFocus;
 //gewoon nog eens naar beneden?
 if not(WebDoc=nil) then
  with (WebDoc.body as IHTMLElement2) do
   WebDoc.parentWindow.scrollTo(0,scrollHeight-clientHeight);
end;

procedure TMessageWin.DoSetIcon(isHighNow:boolean=false);
type
 TIconType=(itUnknown,itChan,itChanOp,itUser);
 TIconState=(isNew,isMsg,isHigh,isWasHigh,isOld);
const
 IconsSet:array[TIconType,TIconState] of integer=
  ((iiDefault,iiDefault,iiDefault,iiDefault,iiDefault), //unknown
   (iiChan,iiChanMsg,iiChanHigh,iiChanWasHigh,iiChanOld), //chan
   (iiChanOp,iiChanOpMsg,iiChanOpHigh,iiChanOpWasHigh,iiChanOpOld), //chanop
   (iiAlpha,iiAlphaMsg,iiAlphaHigh,iiAlphaWasHigh,iiAlphaOld));//user
var
 t:TIconType;
 s:TIconState;
begin
 case TargetStatus of
  tsUser:t:=itUser;
  tsChannel,tsPartingChannel,tsPartingChannelForHop:
   if HaveOp then t:=itChanOp else t:=itChan;
  //tsUserGone
  //tsOffChannel
  else t:=itUnknown;
 end;
 if isHighNow then
  begin
   s:=isHigh;
   WasHigh:=true
  end
 else
  if MsgCount>iconOldMsgCount then s:=isOld else
   if WasHigh then s:=isWasHigh else
    if MsgCount=0 then s:=isNew else s:=isMsg;
 SetIcon(IconsSet[t,s]);
end;

procedure TMessageWin.aPasteCancelExecute(Sender: TObject);
begin
  inherited;
 DoPasteFree;
end;

procedure TMessageWin.aPastePauseExecute(Sender: TObject);
var
 a:boolean;
begin
  inherited;
 a:=not(aPastePause.Checked);
 aPastePause.Checked:=a;
 if not(PasteTimer=nil) then PasteTimer.Enabled:=not(a);
 if a then
  Paste1.Caption:='Paste ['+IntToStr(PasteCount-PasteData.Count)+'/'+
   IntToStr(PasteCount)+']'
 else
  Paste1.Caption:='Paste '+IntToStr(PasteCount-PasteData.Count)+'/'+
   IntToStr(PasteCount);
end;

function TMessageWin.GetCompleted(from:string):string;
var
 s,f,max:string;
 i,j:integer;
 li:TListItem;
begin
 //kan dit properder?
 i:=0;
 f:=LowerCase(from);
 max:=from;
 while i<ListView1.Items.Count do
  begin
   li:=ListView1.Items[i];
   s:=LowerCase(li.Caption);
   if copy(s,1,length(f))=f then
    begin
     if max=from then
      begin
       max:=li.Caption;
       inc(i);
      end
     else
      begin
       j:=length(f)+1;
       max:=lowercase(max);
       while (j<=length(s)) and (s[j]=max[j]) do inc(j);
       max:=copy(max,1,j-1);
       if lowercase(max)=f then i:=ListView1.Items.Count else inc(i);
      end;
    end
   else inc(i);
  end;
 Result:=max;
end;

procedure TMessageWin.PopupMenu1Popup(Sender: TObject);
var
 s,t:string;
begin
  inherited;

 if not(Web1.PoppedUp.HTMLObject.QueryInterface(IID_IHTMLElement,CurrentElement)=S_OK) then
  CurrentElement:=nil;

 if CurrentElement=nil then s:='' else s:=CurrentElement.tagName;

 if s='A' then
  begin
   try
    t:=(CurrentElement as IHTMLAnchorElement).href;
   except
    t:='';
   end;
   t:=copy(t,1,4);
  end;
 aWebAOpen.Visible:=(s='A') and not(t='ro:');
 aWebACopy.Visible:=(s='A') and not(t='ro:');
end;

procedure TMessageWin.aWebAOpenExecute(Sender: TObject);
begin
  inherited;
 ShellExecuteW(Handle,nil,
  PWideChar((CurrentElement as IHTMLAnchorElement).href),nil,nil,SW_NORMAL);
end;

procedure TMessageWin.aWebACopyExecute(Sender: TObject);
begin
  inherited;
 Clipboard.Open;
 Clipboard.Clear;
 Clipboard.AsText:=(CurrentElement as IHTMLAnchorElement).href;
 Clipboard.Close;
end;

procedure TMessageWin.aPasteNextExecute(Sender: TObject);
begin
  inherited;
 //assert PasteTimer bestaat
 PasteTimer.Enabled:=false;
 DoPasteTimer(PasteTimer);
 PasteTimer.Enabled:=true;
end;

procedure TMessageWin.aCopyExecute(Sender: TObject);
begin
  inherited;
 if Com.SelLength=0 then
  WebDoc.execCommand('Copy',false,Null)   //html overlopen?
 else
  Com.CopyToClipboard;
end;

procedure TMessageWin.ComKeyDown(Sender: TObject; var Key: Word;
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

procedure TMessageWin.DisplayInfo(s:string);
type
 TInfos=(
  inTopic,inAway,inMode,

  inOwner,inTarget,inSince,inTargetSince,inRotate,

  //nieuwe hier
  inUnknown
 );
const
 Infos:array[TInfos] of string=(
  'TOPIC','AWAY','MODE',

  'OWNER','TARGET','SINCE','TARGETSINCE','ROTATE',

  //nieuwe hier
  ''
 );
var
 IsInfo:TInfos;
 pl:TRoParsedLine;
 p1:string;
 i:integer;
begin
 while not(s='') do
  begin
   p1:=cutNext(s);

   pl:=TRoParsedLine.Create('');

   pl.MessageType:=cmNetwork;

   try

   IsInfo:=TInfos(0);
   while not(IsInfo=inUnknown) and not(Infos[IsInfo]=UpperCase(p1)) do
    inc(IsInfo);

   if IsInfo in [inTopic,inAway] then
    pl.MessageType:=cmIrc
   else
    pl.MessageType:=cmNetwork;

   case IsInfo of
    inTopic:pl.text:=Topic;//TopicStripped;
    inAway:pl.text:=UserAway;
    inMode:
     begin
      p1:='';
      for i:=0 to length(ModeFlags)-1 do
       begin
        if i>0 then p1:=p1+' ';
        p1:=p1+ModeFlags[i];
       end;
      pl.text:=p1;
     end;

    inOwner:if ConWin=nil then pl.text:='none' else pl.text:=ConWin.Caption;
    inTarget:pl.text:=Target;
    inSince:pl.text:=SinceToStr(SelfSince);
    inTargetSince:pl.text:=SinceToStr(TargetSince);
    inRotate:pl.text:=IntToStr(rotateBlockPos)+','+IntToStr(rotateLine);


    //nieuwe hier

    else
     begin
      //error
     end;
   end;

   except
    on e:Exception do
     begin
      pl.MessageType:=cmError;
      pl.text:=e.Message;
     end;
   end;

   if not(pl=nil) then
    begin
     Msg(pl);
     pl.Free;
    end;

  end;
end;

procedure TMessageWin.aUTF8Execute(Sender: TObject);
begin
  inherited;
 aUTF8.Checked:=not(aUTF8.Checked);
end;

procedure TMessageWin.aWordWrapExecute(Sender: TObject);
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

end.
